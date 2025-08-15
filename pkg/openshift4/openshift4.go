package openshift4

import (
	"fmt"
	"strings"

	"github.com/tidwall/gjson"
	"github.com/tidwall/sjson"
)

// TODO
func NeatOpenShift4(in string) (string, error) {
	var err error
	draft := in

	if in == "" {
		return draft, fmt.Errorf("error in neatPod, input json is empty")
	}
	if !gjson.Valid(in) {
		return draft, fmt.Errorf("error in neatPod, input is not a vaild json: %s", in[:20])
	}

	// general neating
	draft, err = neatMetadata(draft)
	if err != nil {
		return draft, fmt.Errorf("error in neatMetadata : %v", err)
	}

	// serviceaccount neating
	draft, err = neatServiceAccount(draft)
	if err != nil {
		return draft, fmt.Errorf("error in neatServiceAccount : %v", err)
	}

	// defaults neating
	draft, err = NeatDefaults(draft)
	if err != nil {
		return draft, fmt.Errorf("error in NeatDefaults : %v", err)
	}

	fmt.Println("Plugin OpenShift4 executed")
	return draft, nil
}

func neatMetadata(in string) (string, error) {
	var err error

	// Annotations
	in, err = sjson.Delete(in, `metadata.annotations.k8s\.ovn\.org/pod-networks`)
	if err != nil {
		return in, fmt.Errorf("error deleting pod-networks : %v", err)
	}
	in, err = sjson.Delete(in, `metadata.annotations.k8s\.v1\.cni\.cncf\.io/network-status`)
	if err != nil {
		return in, fmt.Errorf("error deleting network-status : %v", err)
	}
	in, err = sjson.Delete(in, `metadata.annotations.openshift\.io/scc`)
	if err != nil {
		return in, fmt.Errorf("error deleting openshift.io/scc: %v", err)
	}
	in, err = sjson.Delete(in, `metadata.annotations.seccomp\.security\.alpha\.kubernetes\.io/pod`)
	if err != nil {
		return in, fmt.Errorf("error deleting pod runtime: %v", err)
	}

	// Labels
	in, err = sjson.Delete(in, `metadata.labels.pod-template-hash`)
	if err != nil {
		return in, fmt.Errorf("error deleting pod-template-hash: %v", err)
	}

	// TODO: prettify this. gjson's @pretty is ok but setRaw the pretty code gives unwanted result
	// newMeta := gjson.Get(in, "{metadata.name,metadata.namespace,metadata.labels,metadata.annotations}")
	// in, err = sjson.Set(in, "metadata", newMeta.Value())
	// if err != nil {
	// return in, fmt.Errorf("error setting new metadata : %v", err)
	// }
	return in, nil
}

func neatServiceAccount(in string) (string, error) {
	var err error
	// keep an eye open on https://github.com/tidwall/sjson/issues/11
	// when it's implemented, we can do:
	// sjson.delete(in, "spec.volumes.#(name%kube-api-*)")
	// sjson.delete(in, "spec.containers.#.volumeMounts.#(name%kube-api-*)")

	for vi, v := range gjson.Get(in, "spec.volumes").Array() {
		vname := v.Get("name").String()
		if strings.HasPrefix(vname, "kube-api-") {
			in, err = sjson.Delete(in, fmt.Sprintf("spec.volumes.%d", vi))
			if err != nil {
				continue
			}
		}
	}
	for ci, c := range gjson.Get(in, "spec.containers").Array() {
		for vmi, vm := range c.Get("volumeMounts").Array() {
			vmname := vm.Get("name").String()
			if strings.HasPrefix(vmname, "kube-api-") {
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
