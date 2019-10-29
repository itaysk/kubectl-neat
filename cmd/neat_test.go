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
	"fmt"
	"testing"

	"github.com/itaysk/kubectl-neat/pkg/testutil"
)

const (
	podData string = `{
		"apiVersion": "v1",
		"kind": "Pod",
		"metadata": {
			"creationTimestamp": "2019-04-24T19:55:27Z",
			"labels": {
				"app": "myapp"
			},
			"name": "myapp",
			"namespace": "default",
			"resourceVersion": "274103",
			"selfLink": "/api/v1/namespaces/default/pods/myapp",
			"uid": "e8330f3c-66ca-11e9-b6fa-0800271788ca"
		},
		"spec": {
			"containers": [
				{
					"image": "nginx",
					"imagePullPolicy": "Always",
					"name": "myapp",
					"ports": [
						{
							"containerPort": 1234,
							"protocol": "TCP"
						}
					],
					"resources": {},
					"terminationMessagePath": "/dev/termination-log",
					"terminationMessagePolicy": "File",
					"volumeMounts": [
						{
							"mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
							"name": "default-token-nmshj",
							"readOnly": true
						}
					]
				}
			],
			"dnsPolicy": "ClusterFirst",
			"enableServiceLinks": true,
			"nodeName": "minikube",
			"priority": 0,
			"restartPolicy": "Always",
			"schedulerName": "default-scheduler",
			"securityContext": {},
			"serviceAccount": "default",
			"serviceAccountName": "default",
			"terminationGracePeriodSeconds": 30,
			"tolerations": [
				{
					"effect": "NoExecute",
					"key": "node.kubernetes.io/not-ready",
					"operator": "Exists",
					"tolerationSeconds": 300
				},
				{
					"effect": "NoExecute",
					"key": "node.kubernetes.io/unreachable",
					"operator": "Exists",
					"tolerationSeconds": 300
				}
			],
			"volumes": [
				{
					"name": "default-token-nmshj",
					"secret": {
						"defaultMode": 420,
						"secretName": "default-token-nmshj"
					}
				}
			]
		},
		"status": {
			"conditions": [
				{
					"lastProbeTime": null,
					"lastTransitionTime": "2019-04-24T19:55:27Z",
					"status": "True",
					"type": "Initialized"
				},
				{
					"lastProbeTime": null,
					"lastTransitionTime": "2019-07-06T18:41:25Z",
					"status": "True",
					"type": "Ready"
				},
				{
					"lastProbeTime": null,
					"lastTransitionTime": "2019-07-06T18:41:25Z",
					"status": "True",
					"type": "ContainersReady"
				},
				{
					"lastProbeTime": null,
					"lastTransitionTime": "2019-04-24T19:55:27Z",
					"status": "True",
					"type": "PodScheduled"
				}
			],
			"containerStatuses": [
				{
					"containerID": "docker://92d7dc7a851453c2f1e75c4af42a9e72fea50127fede62dfbd5fbb6fb0481fcc",
					"image": "nginx:latest",
					"imageID": "docker-pullable://nginx@sha256:96fb261b66270b900ea5a2c17a26abbfabe95506e73c3a3c65869a6dbe83223a",
					"lastState": {
						"terminated": {
							"containerID": "docker://288fc0a2b98708d6a4661f59c54c4ae366c1acea642f000ba9615932dbff411f",
							"exitCode": 0,
							"finishedAt": "2019-07-04T08:17:20Z",
							"reason": "Completed",
							"startedAt": "2019-07-03T05:55:39Z"
						}
					},
					"name": "myapp",
					"ready": true,
					"restartCount": 3,
					"state": {
						"running": {
							"startedAt": "2019-07-06T18:41:25Z"
						}
					}
				}
			],
			"hostIP": "10.0.2.15",
			"phase": "Running",
			"podIP": "172.17.0.2",
			"qosClass": "BestEffort",
			"startTime": "2019-04-24T19:55:27Z"
		}
	}`
	podExpect string = `{
		"apiVersion": "v1",
		"kind": "Pod",
		"metadata": {
			"labels": {
				"app": "myapp"
			},
			"namespace": "default",
			"name": "myapp"
		},
		"spec": {
			"containers": [
				{
					"image": "nginx",
					"name": "myapp",
					"ports": [
						{
							"containerPort": 1234
						}
					]
				}
			],
			"priority": 0,
			"serviceAccountName": "default",
			"tolerations": [
				{
					"effect": "NoExecute",
					"key": "node.kubernetes.io/not-ready",
					"operator": "Exists",
					"tolerationSeconds": 300
				},
				{
					"effect": "NoExecute",
					"key": "node.kubernetes.io/unreachable",
					"operator": "Exists",
					"tolerationSeconds": 300
				}
			]
		}
	}`
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

func TestNeatPod(t *testing.T) {
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
		resJSON, err := neatPod(c.data)
		if err != nil {
			t.Errorf("error in neatPod for case '%s': %v", c.title, err)
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
	cases := []struct {
		title  string
		data   string
		expect string
	}{
		{
			title: "pod 1",
			data: podData,
			expect: podExpect,
		},
		{
			title: "empty list",
			data: `{
				"apiVersion": "v1",
				"items": [],
				"kind": "List",
				"metadata": {
					"resourceVersion": "",
					"selfLink": ""
				}
			}`,
			expect: `{
				"apiVersion": "v1",
				"kind": "List"
			}`,
		},
	}
	for _, c := range cases {
		resJSON, err := Neat(c.data)
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
			data:   `{ "foo": [ "bar", "" ] }`,
			expect: `{ "foo": [ "bar" ] }`,
		},
		{
			title:  "empty string",
			data:   `{ "foo": "bar", "baz": "" }`,
			expect: `{ "foo": "bar"}`,
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

func TestNeatList(t *testing.T) {
	cases := []struct {
		title  string
		data   string
		expect string
	}{
		{
			title: "list pod 1",
			data: fmt.Sprintf(`{
				"apiVersion": "v1",
				"kind": "List",
				"items": [
					%s
				]
			}`, podData),
			expect: fmt.Sprintf(`{
				"apiVersion": "v1",
				"kind": "List",
				"items": [
					%s
				]
			}`, podExpect),
		},
	}
	for _, c := range cases {
		resJSON, err := neatList(c.data)
		if err != nil {
			t.Errorf("error in NeatList for case '%s': %v", c.title, err)
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
