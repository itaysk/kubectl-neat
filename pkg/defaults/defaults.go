package defaults

import (
	"encoding/json"
	"fmt"

	"github.com/jeremywohl/flatten"
	log "github.com/sirupsen/logrus"
	"github.com/tidwall/gjson"
	"github.com/tidwall/sjson"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/client-go/kubernetes/scheme"
	apisv1 "k8s.io/kubernetes/pkg/apis/core/v1"
)

// NeatDefaults gets a json document representing a Kubernetes resource, and removes all fields with default values.
// default values is determined by invoking the "defaulting" code from Kubernetes apimachinery
func NeatDefaults(in string) (string, error) {
	var err error

	var pom metav1.PartialObjectMetadata
	err = json.Unmarshal([]byte(in), &pom)
	if err != nil {
		return "", fmt.Errorf("error unmarshaling as PartialObject : %v", err)
	}
	if !myscheme.Recognizes(pom.GroupVersionKind()) {
		return in, nil
	}

	specJSON := gjson.Get(in, "spec")
	if !specJSON.Exists() {
		return in, nil
	}
	pathsToDelete, err := flatMapJSON(specJSON.String(), "spec.")
	if err != nil {
		return "", fmt.Errorf("error flattening json : %v", err)
	}
	for k, v := range pathsToDelete {
		isDefault, err := isDefault(k, v, in)
		if err != nil {
			log.Error(fmt.Errorf("error determining default for '%s' : %v", k, err))
			continue
		}
		if !isDefault {
			// don't want to delete from 'in' yet because that would affect the following isDefault tests
			delete(pathsToDelete, k)
		}
	}
	for k := range pathsToDelete {
		in, err = sjson.Delete(in, k)
		if err != nil {
			log.Error(fmt.Errorf("error deleting default '%s' : %v", k, err))
			continue
		}
	}
	return in, nil
}

// flatMapJSON gets a json document and builds a map of all the leaf keys and their values
func flatMapJSON(j string, prefix string) (map[string]interface{}, error) {
	var jParsed map[string]interface{}
	err := json.Unmarshal([]byte(j), &jParsed)
	if err != nil {
		return nil, fmt.Errorf("error unmarshaling: %v", err)
	}
	res, err := flatten.Flatten(jParsed, prefix, flatten.DotStyle)
	if err != nil {
		return nil, err
	}
	return res, nil
}

var myscheme *runtime.Scheme
var decoder runtime.Decoder

func init() {
	myscheme = runtime.NewScheme()
	apisv1.AddToScheme(myscheme)
	decoder = scheme.Codecs.UniversalDeserializer()
}

// isDefault determins if the observed 'value' of the 'path' (gjson path) to field  in 'objJSON' is a default value
func isDefault(path string, value interface{}, objJSON string) (bool, error) {
	computed, err := computeDefault(path, objJSON)
	if err != nil {
		return false, fmt.Errorf("error computing default for '%s' : %v", path, err)
	}
	expect := fmt.Sprintf("%v", value)
	return computed == expect, nil
}

// computeDefault returns the default value for the 'path' (gjson path) to field in 'objJSON'
func computeDefault(path string, objJSON string) (string, error) {
	candidateJSON, err := sjson.Delete(objJSON, path)
	if err != nil {
		return "", fmt.Errorf("error deleting path to default '%s' : %v", path, err)
	}
	candidate, _, err := decoder.Decode([]byte(candidateJSON), nil, nil)
	if err != nil {
		return "", fmt.Errorf("error decoding into kubernetes object : %v", err)
	}

	// why this doesn't work?
	//scheme.Scheme.Default(candidate)
	myscheme.Default(candidate)

	resJSON, err := json.Marshal(candidate)
	if err != nil {
		return "", fmt.Errorf("error marshaling kubernetes object : %v", err)
	}
	defaultValue := gjson.Get(string(resJSON), path).String()
	return defaultValue, nil
}
