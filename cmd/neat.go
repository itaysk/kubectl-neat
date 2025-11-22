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
	"strings"

	"github.com/itaysk/kubectl-neat/pkg/defaults"

	"github.com/tidwall/gjson"
	"github.com/tidwall/sjson"
)

// Neat gets a Kubernetes resource json as string and de-clutters it to make it more readable.
func Neat(in string) (string, error) {
	var err error
	draft := in

	if in == "" {
		return draft, fmt.Errorf("input JSON is empty: provide a valid Kubernetes resource JSON to process")
	}
	if !gjson.Valid(in) {
		preview := in
		if len(in) > 50 {
			preview = in[:50] + "..."
		}
		return draft, fmt.Errorf("input is not valid JSON (typo: 'vaild' -> 'valid' in original message). First 50 chars: %s. Ensure your input is valid JSON before processing", preview)
	}

	kind := gjson.Get(in, "kind").String()

	// handle list
	if kind == "List" {
		items := gjson.Get(draft, "items").Array()
		for i, item := range items {
			itemNeat, err := Neat(item.String())
			if err != nil {
				continue
			}
			draft, err = sjson.SetRaw(draft, fmt.Sprintf("items.%d", i), itemNeat)
			if err != nil {
				continue
			}
		}
		// general neating
		draft, err = neatMetadata(draft)
		if err != nil {
			return draft, fmt.Errorf("failed to process metadata (removing annotations/labels): %v. This may indicate malformed metadata in the input", err)
		}
		return draft, nil
	}

	// defaults neating
	draft, err = defaults.NeatDefaults(draft)
	if err != nil {
		return draft, fmt.Errorf("failed to remove default values from spec: %v. This may indicate the resource type is not recognized or the spec is malformed", err)
	}

	// controllers neating
	draft, err = neatScheduler(draft)
	if err != nil {
		return draft, fmt.Errorf("failed to remove scheduler fields (spec.nodeName): %v", err)
	}
	if kind == "Pod" {
		draft, err = neatServiceAccount(draft)
		if err != nil {
			return draft, fmt.Errorf("failed to process service account fields for Pod: %v. This may indicate malformed volume or container configuration", err)
		}
	}

	// general neating
	draft, err = neatMetadata(draft)
	if err != nil {
		return draft, fmt.Errorf("failed to process metadata (removing annotations/labels): %v. This may indicate malformed metadata in the input", err)
	}
	draft, err = neatStatus(draft)
	if err != nil {
		return draft, fmt.Errorf("failed to remove status field: %v", err)
	}
	draft, err = neatEmpty(draft)
	if err != nil {
		return draft, fmt.Errorf("error in neatEmpty : %v", err)
	}

	return draft, nil
}

func neatMetadata(in string) (string, error) {
	var err error
	in, err = sjson.Delete(in, `metadata.annotations.kubectl\.kubernetes\.io/last-applied-configuration`)
	if err != nil {
		return in, fmt.Errorf("failed to delete kubectl.kubernetes.io/last-applied-configuration annotation: %v. The annotation may not exist (this is normal)", err)
	}
	// TODO: prettify this. gjson's @pretty is ok but setRaw the pretty code gives unwanted result
	newMeta := gjson.Get(in, "{metadata.name,metadata.namespace,metadata.labels,metadata.annotations}")
	in, err = sjson.Set(in, "metadata", newMeta.Value())
	if err != nil {
		return in, fmt.Errorf("failed to set cleaned metadata: %v. This may indicate the metadata structure is invalid", err)
	}
	return in, nil
}

func neatStatus(in string) (string, error) {
	return sjson.Delete(in, "status")
}

func neatScheduler(in string) (string, error) {
	return sjson.Delete(in, "spec.nodeName")
}

func neatServiceAccount(in string) (string, error) {
	var err error
	// keep an eye open on https://github.com/tidwall/sjson/issues/11
	// when it's implemented, we can do:
	// sjson.delete(in, "spec.volumes.#(name%default-token-*)")
	// sjson.delete(in, "spec.containers.#.volumeMounts.#(name%default-token-*)")

	for vi, v := range gjson.Get(in, "spec.volumes").Array() {
		vname := v.Get("name").String()
		if strings.HasPrefix(vname, "default-token-") {
			in, err = sjson.Delete(in, fmt.Sprintf("spec.volumes.%d", vi))
			if err != nil {
				continue
			}
		}
	}
	for ci, c := range gjson.Get(in, "spec.containers").Array() {
		for vmi, vm := range c.Get("volumeMounts").Array() {
			vmname := vm.Get("name").String()
			if strings.HasPrefix(vmname, "default-token-") {
				in, err = sjson.Delete(in, fmt.Sprintf("spec.containers.%d.volumeMounts.%d", ci, vmi))
				if err != nil {
					continue
				}
			}
		}
	}
	in, _ = sjson.Delete(in, "spec.serviceAccount") //Deprecated: Use serviceAccountName instead

	return in, nil
}

// neatEmpty removes all zero length elements in the json
func neatEmpty(in string) (string, error) {
	var err error
	jsonResult := gjson.Parse(in)
	var empties []string
	findEmptyPathsRecursive(jsonResult, "", &empties)
	for _, emptyPath := range empties {
		// if we just delete emptyPath, it may create empty parents
		// so we walk the path and re-check for emptiness at every level
		emptyPathParts := strings.Split(emptyPath, ".")
		for i := len(emptyPathParts); i > 0; i-- {
			curPath := strings.Join(emptyPathParts[:i], ".")
			cur := gjson.Get(in, curPath)
			if isResultEmpty(cur) {
				in, err = sjson.Delete(in, curPath)
				if err != nil {
					continue
				}
			}
		}
	}
	return in, nil
}

// findEmptyPathsRecursive builds a list of paths that point to zero length elements
// cur is the current element to look at
// path is the path to cur
// res is a pointer to a list of empty paths to populate
func findEmptyPathsRecursive(cur gjson.Result, path string, res *[]string) {
	if isResultEmpty(cur) {
		*res = append(*res, path[1:]) //remove '.' from start
		return
	}
	if !(cur.IsArray() || cur.IsObject()) {
		return
	}
	// sjson's ForEach doesn't put track index when iterating arrays, hence the index variable
	index := -1
	cur.ForEach(func(k gjson.Result, v gjson.Result) bool {
		var newPath string
		if cur.IsArray() {
			index++
			newPath = fmt.Sprintf("%s.%d", path, index)
		} else {
			newPath = fmt.Sprintf("%s.%s", path, k.Str)
		}
		findEmptyPathsRecursive(v, newPath, res)
		return true
	})
}

func isResultEmpty(j gjson.Result) bool {
	v := j.Value()
	switch vt := v.(type) {
	// empty string != lack of string. keep empty strings as it's meaningful data
	// case string:
	// 	return vt == ""
	case []interface{}:
		return len(vt) == 0
	case map[string]interface{}:
		return len(vt) == 0
	}
	return false
}
