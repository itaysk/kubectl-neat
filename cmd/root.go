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
	"log"
	"os"
	"os/exec"
	"unicode"

	"github.com/ghodss/yaml"
	"github.com/spf13/cobra"
)

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "kubectl-neat",
	Short: "Remove clutter from Kubernetes manifests to make them more readable.",
	Long: `If you try to 'kubectl get' resources you have just created,
they will be unreadably verbose. 'kubectl-neat' cleans up that redundant information.
Can be used as a 'kubectl get' replacement, or by piping resources into it.
Examples:
$ 'kubectl get pod mypod -o yaml | kubectl-neat'
$ 'kubectl-neat pod mypod -o yaml'`,
	Run: func(cmd *cobra.Command, args []string) {
		var in, out []byte
		var err error
		stat, _ := os.Stdin.Stat()
		if len(args) > 0 {
			cmdArgs := args
			if args[0] != "get" {
				cmdArgs = append([]string{"get"}, args...)
			}
			kubectlCmd := exec.Command("kubectl", cmdArgs...)
			var cmdOut bytes.Buffer
			kubectlCmd.Stdout = &cmdOut
			err := kubectlCmd.Run()
			if err != nil {
				details, _ := kubectlCmd.CombinedOutput()
				log.Fatalf("error while running %s: %v \n %v", kubectlCmd.Args, err, details)
			}
			in = cmdOut.Bytes()
		} else if (stat.Mode() & os.ModeCharDevice) == 0 {
			in, err = ioutil.ReadAll(os.Stdin)
			if err != nil {
				log.Fatalf("error reading stdin : %v", err)
			}
		} else {
			log.Fatalf("not valid arguments provided")
		}

		out, err = NeatYAMLOrJSON(in)
		if err != nil {
			log.Fatalf("error neating : %v", err)
		}
		fmt.Println(string(out))
	},
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	rootCmd.Flags().SetInterspersed(false) // prevent cobra for parsing kubectl get's args
}

// isYaml determines if the given text is a yaml
func isYaml(in []byte) bool {
	in = bytes.TrimLeftFunc(in, unicode.IsSpace)
	return !bytes.HasPrefix(in, []byte{'{'})
}

// NeatYAMLOrJSON converts 'in' to json if needed, invokes neat, and converts back if needed
func NeatYAMLOrJSON(in []byte) (out []byte, err error) {
	var injson, outjson string

	// detect if 'in' is yaml or json
	itsYaml := !bytes.HasPrefix(bytes.TrimLeftFunc(in, unicode.IsSpace), []byte{'{'})
	if itsYaml {
		injsonbytes, err := yaml.YAMLToJSON(in)
		if err != nil {
			log.Fatalf("error converting from yaml to json : %v", err)
		}
		injson = string(injsonbytes)
	} else {
		injson = string(in)
	}

	outjson, err = Neat(injson)
	if err != nil {
		log.Fatalf("error neating : %v", err)
	}

	if itsYaml {
		out, err = yaml.JSONToYAML([]byte(outjson))
		if err != nil {
			log.Fatalf("error converting from json to yaml : %v", err)
		}
	} else {
		out = []byte(outjson)
	}
	return
}
