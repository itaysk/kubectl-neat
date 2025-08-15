module github.com/itaysk/kubectl-neat

go 1.22.0

toolchain go1.22.5

require (
	github.com/ghodss/yaml v1.0.0
	github.com/jeremywohl/flatten v0.0.0-20180923035001-588fe0d4c603
	github.com/openshift/openshift-apiserver v0.0.0-alpha.0.0.20240514073636-6b5184128103
	github.com/sirupsen/logrus v1.9.0
	github.com/spf13/cobra v1.7.0
	github.com/spf13/viper v1.19.0
	github.com/tidwall/gjson v1.9.3
	github.com/tidwall/sjson v1.0.4
	k8s.io/apimachinery v0.30.2
	k8s.io/client-go v0.30.2
	k8s.io/kubernetes v1.30.2
)

require github.com/openshift/library-go v0.0.0-20240513090140-e22d25af5587 // indirect

require (
	github.com/beorn7/perks v1.0.1 // indirect
	github.com/blang/semver/v4 v4.0.0 // indirect
	github.com/cespare/xxhash/v2 v2.2.0 // indirect
	github.com/distribution/reference v0.5.0 // indirect
	github.com/fsnotify/fsnotify v1.7.0 // indirect
	github.com/go-logr/logr v1.4.1 // indirect
	github.com/gogo/protobuf v1.3.2 // indirect
	github.com/golang/protobuf v1.5.4 // indirect
	github.com/google/gofuzz v1.2.0 // indirect
	github.com/hashicorp/hcl v1.0.0 // indirect
	github.com/inconshreveable/mousetrap v1.1.0 // indirect
	github.com/json-iterator/go v1.1.12 // indirect
	github.com/magiconair/properties v1.8.7 // indirect
	github.com/matttproud/golang_protobuf_extensions v1.0.4 // indirect
	github.com/mitchellh/mapstructure v1.5.0 // indirect
	github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd // indirect
	github.com/modern-go/reflect2 v1.0.2 // indirect
	github.com/opencontainers/go-digest v1.0.0 // indirect
	github.com/openshift/api v0.0.0-20240830023148-b7d0481c9094 // indirect
	github.com/openshift/apiserver-library-go v0.0.0-20240313131158-facc40cc7688 // indirect
	github.com/pelletier/go-toml/v2 v2.2.2 // indirect
	github.com/prometheus/client_golang v1.16.0 // indirect
	github.com/prometheus/client_model v0.4.0 // indirect
	github.com/prometheus/common v0.44.0 // indirect
	github.com/prometheus/procfs v0.10.1 // indirect
	github.com/sagikazarmark/locafero v0.4.0 // indirect
	github.com/sagikazarmark/slog-shim v0.1.0 // indirect
	github.com/sourcegraph/conc v0.3.0 // indirect
	github.com/spf13/afero v1.11.0 // indirect
	github.com/spf13/cast v1.6.0 // indirect
	github.com/spf13/pflag v1.0.5 // indirect
	github.com/subosito/gotenv v1.6.0 // indirect
	github.com/tidwall/match v1.1.1 // indirect
	github.com/tidwall/pretty v1.2.0 // indirect
	go.uber.org/multierr v1.11.0 // indirect
	golang.org/x/exp v0.0.0-20230905200255-921286631fa9 // indirect
	golang.org/x/net v0.25.0 // indirect
	golang.org/x/sys v0.20.0 // indirect
	golang.org/x/text v0.15.0 // indirect
	google.golang.org/protobuf v1.33.0 // indirect
	gopkg.in/inf.v0 v0.9.1 // indirect
	gopkg.in/ini.v1 v1.67.0 // indirect
	gopkg.in/yaml.v2 v2.4.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
	k8s.io/api v0.30.2 // indirect
	k8s.io/apiextensions-apiserver v0.30.1 // indirect
	k8s.io/apiserver v0.30.2 // indirect
	k8s.io/cloud-provider v0.29.2 // indirect
	k8s.io/component-base v0.30.2 // indirect
	k8s.io/controller-manager v0.30.2 // indirect
	k8s.io/klog/v2 v2.120.1 // indirect
	k8s.io/kube-aggregator v0.29.2 // indirect
	k8s.io/utils v0.0.0-20240310230437-4693a0247e57 // indirect
	sigs.k8s.io/json v0.0.0-20221116044647-bc3834ca7abd // indirect
	sigs.k8s.io/structured-merge-diff/v4 v4.4.1 // indirect
	sigs.k8s.io/yaml v1.3.0 // indirect
)

replace k8s.io/api => k8s.io/api v0.30.2

replace k8s.io/apiextensions-apiserver => k8s.io/apiextensions-apiserver v0.30.2

replace k8s.io/apimachinery => k8s.io/apimachinery v0.30.2

replace k8s.io/apiserver => k8s.io/apiserver v0.30.2

replace k8s.io/cli-runtime => k8s.io/cli-runtime v0.30.2

replace k8s.io/client-go => k8s.io/client-go v0.30.2

replace k8s.io/cloud-provider => k8s.io/cloud-provider v0.30.2

replace k8s.io/cluster-bootstrap => k8s.io/cluster-bootstrap v0.30.2

replace k8s.io/code-generator => k8s.io/code-generator v0.30.2

replace k8s.io/component-base => k8s.io/component-base v0.30.2

replace k8s.io/component-helpers => k8s.io/component-helpers v0.30.2

replace k8s.io/controller-manager => k8s.io/controller-manager v0.30.2

replace k8s.io/cri-api => k8s.io/cri-api v0.30.2

replace k8s.io/csi-translation-lib => k8s.io/csi-translation-lib v0.30.2

replace k8s.io/kube-aggregator => k8s.io/kube-aggregator v0.30.2

replace k8s.io/kube-controller-manager => k8s.io/kube-controller-manager v0.30.2

replace k8s.io/kube-proxy => k8s.io/kube-proxy v0.30.2

replace k8s.io/kube-scheduler => k8s.io/kube-scheduler v0.30.2

replace k8s.io/kubectl => k8s.io/kubectl v0.30.2

replace k8s.io/kubelet => k8s.io/kubelet v0.30.2

replace k8s.io/legacy-cloud-providers => k8s.io/legacy-cloud-providers v0.30.2

replace k8s.io/metrics => k8s.io/metrics v0.30.2

replace k8s.io/mount-utils => k8s.io/mount-utils v0.30.2

replace k8s.io/sample-apiserver => k8s.io/sample-apiserver v0.30.2

replace k8s.io/sample-cli-plugin => k8s.io/sample-cli-plugin v0.30.2

replace k8s.io/sample-controller => k8s.io/sample-controller v0.30.2
