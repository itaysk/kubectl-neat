/*
Copyright © 2019 Itay Shakury @itaysk

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package cmd

import (
	"io/ioutil"
	"path/filepath"
	"strings"
	"testing"

	"github.com/itaysk/kubectl-neat/v2/pkg/testutil"
)

func TestNeatMetadata(t *testing.T) {
	cases := []struct {
		title  string
		data   string
		expect string
	}{
		{
			title: "pod metadata",
			data: `{
				"metadata": {
					"creationTimestamp": "2019-04-24T19:55:27Z",
					"labels": {
						"name": "myapp"
					},
					"name": "myapp",
					"namespace": "default",
					"resourceVersion": "274103",
					"selfLink": "/api/v1/namespaces/default/pods/myapp",
					"uid": "e8330f3c-66ca-11e9-b6fa-0800271788ca"
				}
			}`,
			expect: `{
				"metadata": {
					"labels": {
						"name": "myapp"
					},
					"name": "myapp",
					"namespace": "default"
				}
			}`,
		},
		{
			title: "annotations with apply",
			data: `{
				"metadata": {
					"name": "test",
					"namespace": "testns",
					"annotations": {
						"my-annotation": "is here",
						"kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"authentication.istio.io/v1alpha1\",\"kind\":\"Policy\",\"metadata\":{\"annotations\":{},\"name\":\"default\",\"namespace\":\"one\"},\"spec\":{\"peers\":[{\"mtls\":{}}]}}\n"
					}
				}
			}`,
			expect: `{
				"metadata": {
					"name": "test",
					"namespace": "testns",
					"annotations": {
						"my-annotation": "is here"
					}
				}
			}`,
		},
	}
	for _, c := range cases {
		resJSON, err := neatMetadata(c.data)
		if err != nil {
			t.Errorf("error in neatMetadata for case '%s': %v", c.title, err)
			continue
		}
		equal, err := testutil.JSONEqual(resJSON, c.expect)
		if err != nil {
			t.Errorf("error in JSONEqual for case '%s': %v", c.title, err)
			continue
		}
		if !equal {
			t.Errorf("test case '%s' failed. want: '%s' have: '%s'", c.title, c.expect, resJSON)
		}

	}
}

func TestNeatScheduler(t *testing.T) {
	cases := []struct {
		title  string
		data   string
		expect string
	}{
		{
			title: "nodeName",
			data: `{
				"apiVersion": "v1",
				"kind": "Pod",
				"metadata": {
					"name": "myapp",
					"namespace": "default"
				},
				"spec": {
					"containers": [
						{
							"image": "nginx",
							"imagePullPolicy": "Always",
							"name": "myapp"
						}
					],
					"nodeName": "minikube"
				}
			}`,
			expect: `{
				"apiVersion": "v1",
				"kind": "Pod",
				"metadata": {
					"name": "myapp",
					"namespace": "default"
				},
				"spec": {
					"containers": [
						{
							"image": "nginx",
							"imagePullPolicy": "Always",
							"name": "myapp"
						}
					]
				}
			}`,
		},
	}
	for _, c := range cases {
		resJSON, err := neatScheduler(c.data)
		if err != nil {
			t.Errorf("error in neatScheduler for case '%s': %v", c.title, err)
			continue
		}
		equal, err := testutil.JSONEqual(resJSON, c.expect)
		if err != nil {
			t.Errorf("error in JSONEqual for case '%s': %v", c.title, err)
			continue
		}
		if !equal {
			t.Errorf("test case '%s' failed. want: '%s' have: '%s'", c.title, c.expect, resJSON)
		}

	}
}

func TestNeatServiceAccount(t *testing.T) {
	cases := []struct {
		title  string
		data   string
		expect string
	}{
		{
			title: "pod multi volumes",
			data: `{
				"apiVersion": "v1",
				"kind": "Pod",
				"metadata": {
					"labels": {
						"name": "myapp"
					},
					"name": "myapp",
					"namespace": "default"
				},
				"spec": {
					"containers": [
						{
							"image": "nginx",
							"name": "myapp",
							"volumeMounts": [
								{
									"mountPath": "/my",
									"name": "my",
									"readOnly": false
								},
								{
									"mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
									"name": "default-token-nmshj",
									"readOnly": true
								}						
							]
						}
					],
					"serviceAccount": "default",
					"serviceAccountName": "default",
					"volumes": [
						{
							"name": "default-token-nmshj",
							"secret": {
								"defaultMode": 420,
								"secretName": "default-token-nmshj"
							}
						},
						{
							"name": "my",
							"hostPath": {
								"path": "/my",
								"type": "Directory"
							}
						}
					]
				}
			}`,
			expect: `{
				"apiVersion": "v1",
				"kind": "Pod",
				"metadata": {
					"labels": {
						"name": "myapp"
					},
					"name": "myapp",
					"namespace": "default"
				},
				"spec": {
					"containers": [
						{
							"image": "nginx",
							"name": "myapp",
							"volumeMounts": [
								{
									"mountPath": "/my",
									"name": "my",
									"readOnly": false
								}						
							]
						}
					],
					"serviceAccountName": "default",
					"volumes": [
						{
							"name": "my",
							"hostPath": {
								"path": "/my",
								"type": "Directory"
							}
						}
					]
				}
			}`,
		},
	}
	for _, c := range cases {
		resJSON, err := neatServiceAccount(c.data)
		if err != nil {
			t.Errorf("error in neatServiceAccount for case '%s': %v", c.title, err)
			continue
		}
		equal, err := testutil.JSONEqual(resJSON, c.expect)
		if err != nil {
			t.Errorf("error in JSONEqual for case '%s': %v", c.title, err)
			continue
		}
		if !equal {
			t.Errorf("test case '%s' failed. want: '%s' have: '%s'", c.title, c.expect, resJSON)
		}

	}
}

func TestNeatEmpty(t *testing.T) {
	cases := []struct {
		title  string
		data   string
		expect string
	}{
		{
			title:  "empty object",
			data:   `{ "foo": "bar", "baz": {} }`,
			expect: `{ "foo": "bar"}`,
		},
		{
			title:  "empty array",
			data:   `{ "foo": "bar", "baz": [] }`,
			expect: `{ "foo": "bar"}`,
		},
		{
			title:  "empty second arrray element",
			data:   `{ "foo": [ "bar", {} ] }`,
			expect: `{ "foo": [ "bar" ] }`,
		},
		{
			title:  "empty array object",
			data:   `{ "foo": "bar", "baz": { [] } }`,
			expect: `{ "foo": "bar"}`,
		},
		{
			title:  "single empty array in object",
			data:   `{ "foo": "bar", "baz": { "fiz": [] } }`,
			expect: `{ "foo": "bar"}`,
		},
	}
	for _, c := range cases {
		resJSON, err := neatEmpty(c.data)
		if err != nil {
			t.Errorf("error in Neat for case '%s': %v", c.title, err)
			continue
		}
		equal, err := testutil.JSONEqual(resJSON, c.expect)
		if err != nil {
			t.Errorf("error in JSONEqual for case '%s': %v", c.title, err)
			continue
		}
		if !equal {
			t.Errorf("test case '%s' failed. want: '%s' have: '%s'", c.title, c.expect, resJSON)
		}

	}
}

func TestNeat(t *testing.T) {
	testsDir := "../test/fixtures"
	testFiles, err := ioutil.ReadDir(testsDir)
	if err != nil {
		t.Fatalf("can't list tests in: %s", testsDir)
	}
	for _, f := range testFiles {
		fName := f.Name()
		fParts := strings.Split(fName, "-")
		if fParts[1] == "raw.json" {
			fFullName := filepath.Join(testsDir, f.Name())
			inBytes, err := ioutil.ReadFile(fFullName)
			if err != nil {
				t.Errorf("can't read file: %s", fFullName)
			}
			expFullName := filepath.Join(testsDir, fParts[0]+"-neat.json")
			expBytes, err := ioutil.ReadFile(expFullName)
			if err != nil {
				t.Errorf("can't read file: %s", expFullName)
			}
			resJSON, err := Neat(string(inBytes))
			if err != nil {
				t.Errorf("error in Neat for case: %s: %v", fName, err)
				continue
			}
			equal, err := testutil.JSONEqual(resJSON, string(expBytes))
			if err != nil {
				t.Errorf("error in JSONEqual for case: %s: %v", fName, err)
				continue
			}
			if !equal {
				t.Errorf("test case failed: %s:\nhave %s\nwant %s", fName, string(expBytes), resJSON)
			}
		}
	}
}
