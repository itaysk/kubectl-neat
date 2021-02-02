package cmd

import (
	"github.com/spf13/cobra"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
)

var diffCmd = &cobra.Command{
	Use:   "diff",
	Short: "Replacement for diff that removes clutter from Kubernetes manifests.",
	Long: `
Use the env variable KUBECTL_EXTERNAL_DIFF to customize the diff function of kubectl
and filter all the manifests through 'kubectl neat' before comparing the resources.
`,
	Example: `export KUBECTL_EXTERNAL_DIFF="kubectl neat diff"; kubectl diff -f manifest.yaml`,
	Args:    cobra.ExactArgs(2),
	RunE: func(cmd *cobra.Command, args []string) error {
		return diffDirs(args[0], args[1])
	},
}

func diffDirs(fromPath, toPath string) (err error) {
	err = neatDir(fromPath)
	if err != nil {
		return err
	}
	err = neatDir(toPath)
	if err != nil {
		return err
	}

	// TODO: expose KUBECTL_NEAT_EXTERNAL_DIFF to users for even more flexibility
	diff := exec.Command("diff", "-u", "-N", fromPath, toPath)
	diff.Stdout = os.Stdout
	diff.Stderr = os.Stderr
	err = diff.Run()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			os.Exit(exitErr.ExitCode())
		}
	}
	return nil
}

func neatDir(dir string) error {
	return filepath.Walk(dir, func(path string, f os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if f.Name() == ".git" {
			return filepath.SkipDir
		}

		if !f.IsDir() {
			content, err := ioutil.ReadFile(path)
			if err != nil {
				return err
			}
			fixed, err := NeatYAMLOrJSON(content, "same")
			if err != nil {
				return err
			}
			return ioutil.WriteFile(path, fixed, f.Mode())
		}

		return nil
	})
}
