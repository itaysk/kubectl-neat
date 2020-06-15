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
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"unicode"

	"github.com/ghodss/yaml"
	"github.com/spf13/cobra"
)

var outputFormat *string
var inputFile *string

func init() {
	outputFormat = rootCmd.PersistentFlags().StringP("output", "o", "yaml", "output format: yaml or json")
	inputFile = rootCmd.Flags().StringP("file", "f", "-", "file path to neat, or - to read from stdin")
	rootCmd.MarkFlagFilename("file")
	rootCmd.AddCommand(getCmd)
}

// Execute is the entry point for the command package
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

var rootCmd = &cobra.Command{
	Use: "kubectl-neat",
	Example: `kubectl get pod mypod -o yaml | kubectl neat
kubectl get pod mypod -oyaml | kubectl neat -o json
kubectl neat -f - <./my-pod.json
kubectl neat -f ./my-pod.json
kubectl neat -f ./my-pod.json --output yaml`,
	RunE: func(cmd *cobra.Command, args []string) error {
		var in, out []byte
		var err error
		if *inputFile == "-" {
			stdin := cmd.InOrStdin()
			in, err = ioutil.ReadAll(stdin)
		} else {
			in, err = ioutil.ReadFile(*inputFile)
			if err != nil {
				return err
			}
		}
		outFormat := *outputFormat
		if !cmd.Flag("output").Changed {
			outFormat = "same"
		}
		out, err = NeatYAMLOrJSON(in, outFormat)
		if err != nil {
			return err
		}
		cmd.Println(string(out))
		return nil
	},
}

var kubectl string = "kubectl"

var getCmd = &cobra.Command{
	Use: "get",
	Example: `kubectl neat get pod mypod -oyaml
kubectl neat get svc -n default myservice --output json`,
	FParseErrWhitelist: cobra.FParseErrWhitelist{UnknownFlags: true}, //don't validate kubectl get's flags
	RunE: func(cmd *cobra.Command, args []string) error {
		var in, out []byte
		var err error
		cmdArgs := append([]string{"get", "-o"}, *outputFormat)
		cmdArgs = append(cmdArgs, args...)
		kubectlCmd := exec.Command(kubectl, cmdArgs...)
		kres, err := kubectlCmd.CombinedOutput()
		if err != nil {
			return err
		}
		in = kres

		out, err = NeatYAMLOrJSON(in, *outputFormat)
		if err != nil {
			return err
		}
		cmd.Println(string(out))
		return nil
	},
}

// NeatYAMLOrJSON converts 'in' to json if needed, invokes neat, and converts back if needed according the the outputFormat argument: yaml/json/same
func NeatYAMLOrJSON(in []byte, outputFormat string) (out []byte, err error) {
	var injson, outjson string

	// detect if 'in' is yaml or json
	itsYaml := !bytes.HasPrefix(bytes.TrimLeftFunc(in, unicode.IsSpace), []byte{'{'})
	if itsYaml {
		injsonbytes, err := yaml.YAMLToJSON(in)
		if err != nil {
			return nil, fmt.Errorf("error converting from yaml to json : %v", err)
		}
		injson = string(injsonbytes)
	} else {
		injson = string(in)
	}

	outjson, err = Neat(injson)
	if err != nil {
		return nil, fmt.Errorf("error neating : %v", err)
	}

	if outputFormat == "yaml" || (outputFormat == "same" && itsYaml) {
		out, err = yaml.JSONToYAML([]byte(outjson))
		if err != nil {
			return nil, fmt.Errorf("error converting from json to yaml : %v", err)
		}
	} else {
		out = []byte(outjson)
	}
	return
}
