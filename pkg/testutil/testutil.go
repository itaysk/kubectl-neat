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
package testutil

import (
	"encoding/json"
	"reflect"
)

// JSONEqual compares two json strings. true means they are equal
func JSONEqual(a, b string) (bool, error) {
	var ao interface{}
	var bo interface{}

	var err error
	err = json.Unmarshal([]byte(a), &ao)
	if err != nil {
		return false, err
	}
	err = json.Unmarshal([]byte(b), &bo)
	if err != nil {
		return false, err
	}
	return reflect.DeepEqual(ao, bo), nil
}
