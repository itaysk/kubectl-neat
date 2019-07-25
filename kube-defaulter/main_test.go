package main

import (
	"testing"
)

func TestGetKubeDefault(t *testing.T) {
	cases := []struct {
		testCase          string
		resourcePayload   string
		jsonPathToDefault string
		expect            string
	}{
		{
			testCase: "PullPolicyAlways",
			resourcePayload: `{
				"apiVersion": "v1",
				"kind": "Pod",
				"metadata": {
					"name": "myapp",
					"namespace": "default"
				},
				"spec": {
					"containers": [
						{
							"image": "foo",
							"name": "myapp"
						}
					]
				}
			}`,
			jsonPathToDefault: "spec.containers.0.imagePullPolicy",
			expect:            "Always",
		},
		{
			testCase: "PullPolicyIfNotPresent",
			resourcePayload: `{
				"apiVersion": "v1",
				"kind": "Pod",
				"metadata": {
					"name": "myapp",
					"namespace": "default"
				},
				"spec": {
					"containers": [
						{
							"image": "foo:bar",
							"name": "myapp"
						}
					]
				}
			}`,
			jsonPathToDefault: "spec.containers.0.imagePullPolicy",
			expect:            "IfNotPresent",
		},
		{
			testCase: "RestartPolicy",
			resourcePayload: `{
				"apiVersion": "v1",
				"kind": "Pod",
				"metadata": {
					"name": "myapp",
					"namespace": "default"
				},
				"spec": {
					"containers": [
						{
							"image": "foo:bar",
							"name": "myapp"
						}
					]
				}
			}`,
			jsonPathToDefault: "spec.restartPolicy",
			expect:            "Always",
		},
		{
			testCase: "TerminationMessagePath",
			resourcePayload: `{
				"apiVersion": "v1",
				"kind": "Pod",
				"metadata": {
					"name": "myapp",
					"namespace": "default"
				},
				"spec": {
					"containers": [
						{
							"image": "foo:bar",
							"name": "myapp",
							"terminationMessagePath": "/dev/termination-log""
						}
					]
				}
			}`,
			jsonPathToDefault: "spec.containers.0.terminationMessagePath",
			expect:            "/dev/termination-log",
		},
	}

	for _, c := range cases {
		out := getKubeDefault(c.resourcePayload, c.jsonPathToDefault)
		if out != c.expect {
			t.Errorf("test case '%s' failed. want: '%s' have: '%s'", c.testCase, c.expect, out)
		}
	}
}
