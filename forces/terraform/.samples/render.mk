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

#!██████████████████████████████████████████████████████████████████████████████████████████████████
#!███ Alters the make to work as `make <target> *args... -- **kwargs`
#!███ (Parallelism is disabled)
#!██████████████████████████████████████████████████████████████████████████████████████████████████


ifndef MAKECMDGOALS
   MAKECMDGOALS :=
endif

%-terraform:

	mkdir -p .make
	touch .make/.datetime # ! file need to exist for grep (fails in CICD)
	if ! grep -q "$(DATETIME0)" .make/.datetime; ## ! render only once
	then

		# echo "Undefined target: $@"
		# echo "MAKECMDGOALS: $(MAKECMDGOALS)"
		# echo "ARGV: $(ARGV)"
		# echo "ARGV0: $(ARGV0)"
		# echo "ARGVN: $(ARGVN)"
		# echo "*=$*"
		# echo "%=$%"
		# echo "<=$<"

		#!======================================================================================
		#!███ Copy terraform templates
		#!======================================================================================
		if [ -d "terraform/configs" ]; then
			for d in terraform/configs/*; do
				if [ -d "$$d" ]; then
					echo find $$d \
						-type f \
						-name "*.TPL" \
						-exec bash -c \
							'cp -n "$$1" "$${1%.TPL}"' \
						_ {} \;
				fi
			done
		fi

		echo $(DATETIME0) > .make/.datetime
	fi

	if [ "$(ARGV0)" != "$(MAKECMDGOALS)" ]; then
		exit 0
	fi


	@:


