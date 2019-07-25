package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"os"

	"github.com/tidwall/gjson"
	"github.com/tidwall/sjson"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/client-go/kubernetes/scheme"
	apisv1 "k8s.io/kubernetes/pkg/apis/core/v1"
)

func checkError(err error) {
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func checkString(s string, name string) {
	if s == "" {
		fmt.Printf("%s is missing\n", name)
		os.Exit(1)
	}
}

func main() {
	var jsonPathToDefault string
	var command string
	flag.StringVar(&jsonPathToDefault, "path", "", "json path to default")
	flag.StringVar(&command, "command", "", "get-default / is-default")
	flag.Parse()
	stat, _ := os.Stdin.Stat()
	var stdin []byte
	var err error
	if (stat.Mode() & os.ModeCharDevice) == 0 {
		stdin, err = ioutil.ReadAll(os.Stdin)
		checkError(err)
	}
	resourcePayload := string(stdin)
	checkString(command, "command")
	checkString(jsonPathToDefault, "path")
	checkString(resourcePayload, "stdin")

	if command == "get-default" {
		res := getKubeDefault(resourcePayload, jsonPathToDefault)
		fmt.Println(res)
		return
	}

	if command == "is-default" {
		originalValue := gjson.Get(resourcePayload, jsonPathToDefault)
		if !originalValue.Exists() {
			fmt.Printf("can't find %s\n", jsonPathToDefault)
			os.Exit(1)
			return
		}
		res := getKubeDefault(resourcePayload, jsonPathToDefault)
		fmt.Println(originalValue.String() == res)
		return
	}
}

func getKubeDefault(resourcePayload string, jsonPathToDefault string) string {
	resourcePayload, err := sjson.Delete(resourcePayload, jsonPathToDefault)
	checkError(err)
	decode := scheme.Codecs.UniversalDeserializer().Decode
	obj, _, err := decode([]byte(resourcePayload), nil, nil)
	checkError(err)
	scheme := runtime.NewScheme()
	apisv1.RegisterDefaults(scheme)

	scheme.Default(obj)

	marshaled, err := json.Marshal(obj)
	checkError(err)
	res := gjson.Get(string(marshaled), jsonPathToDefault)
	return res.String()
}
