#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ Copyright 2020-2024 (c) RALF-IT LLC
#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ Licensed under the Apache License, Version 2.0 (the "License");
#███ you may not use this file except in compliance with the License.
#███ You may obtain a copy of the License at
#███
#███     https://raw.githubusercontent.com/ralf-it/makefile-forces/main/LICENSE.md
#███
#███ Unless required by applicable law or agreed to in writing, software
#███ distributed under the License is distributed on an "AS IS" BASIS,
#███ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#███ See the License for the specific language governing permissions and
#███ limitations under the License.
#███████████████████████████████████████████████████████████████████████████████████████████████████

#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ VERSION
#███████████████████████████████████████████████████████████████████████████████████████████████████

ifneq ($(wildcard VERSION),)
    VERSION = $(file < VERSION)
endif

/version: ## [version] show version
	$(M) $@+INFO
	echo $(VERSION)

/version-raw: ## [version] show version raw
	echo $(VERSION)

/version-increment-patch: ## [version] increment patch version
	$(M) $@+INFO

	if [ "$(VERSION)" == "" ];
	then
		echo "1.0.0" > VERSION
	else
		echo $(VERSION) | awk -F '.' '{print $$1"."$$2"."$$3+1}' > VERSION
	fi

/version-increment-minor: ## [version] increment minor version
	$(M) $@+INFO
	if [ "$(VERSION)" == "" ];
	then
		echo "1.0.0" > VERSION
	else
		echo $(VERSION) | awk -F '.' '{print $$1"."$$2+1".0"}' > VERSION
	fi

/version-increment-major: ## [version] increment major version
	$(M) $@+INFO

	if [ "$(VERSION)" == "" ];
	then
		echo "1.0.0" > VERSION
	else
		echo $(VERSION) | awk -F '.' '{print $$1+1".0.0"}' > VERSION
	fi