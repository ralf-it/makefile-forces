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
#███ DOCKER
#███████████████████████████████████████████████████████████████████████████████████████████████████

D                    ?= docker
D_PRUNE_IMG           = $(D) image prune --force
D_PRUNE_NET           = $(D) network prune --force
D_PRUNE_VOL           = $(D) volume prune --force
D_PRUNE               =	$(D) system prune --volumes --force
D_PURGE               = $(D) system prune --all --volumes --force

/docker-purge: ## {forces/docker} purge all docker resources
	$(M) $@+INFO
	$(D_PURGE)

/docker-prune: ## {forces/docker} Prune dandling resources
	$(M) $@+INFO
	set -x
	$(D_PRUNE)

/docker-prune-net: ## {forces/docker} Prune networks
	$(M) $@+INFO
	set -x
	$(D_PRUNE_NET)

/docker-prune-vol: ## {forces/docker} Prune volumes
	$(M) $@+INFO
	set -x
	$(D_PRUNE_VOL)

/docker-prune-vol-ci-pipeline: ## {forces/docker} Prune volumes with label ci=${CI} and ci_pipeline_id=${CI_PIPELINE_ID}
	$(M) $@+INFO
	set -x
	$(D_PRUNE_VOL) --filter "label=ci=${CI}" --filter "label=ci_pipeline_id=${CI_PIPELINE_ID}"

/docker-prune-img-ci-pipeline: ## {forces/docker} Prune images with label ci=${CI} and ci_pipeline_id=${CI_PIPELINE_ID}
	$(M) $@+INFO
	set -x
	$(D_PRUNE_IMG) --filter "label=ci=${CI}" --filter "label=ci_pipeline_id=${CI_PIPELINE_ID}"

/docker-prune-net-ci-pipeline: ## {forces/docker} Prune network with label ci=${CI} and ci_pipeline_id=${CI_PIPELINE_ID}
	$(M) $@+INFO
	set -x
	$(D_PRUNE_NET) --filter "label=ci=${CI}" --filter "label=ci_pipeline_id=${CI_PIPELINE_ID}"

#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ Install tools
#███████████████████████████████████████████████████████████████████████████████████████████████████

ifdef FORCES_TOOLS_ENABLE_INSTALL

#---------------------------------------------------------------------------------------------------
#-- Docker & Docker Compose
#---------------------------------------------------------------------------------------------------

/install-docker: ## {forces/docker} installs docker
	$(M) $@+INFO
	set -x
	unset VERSION
	$(SUDO) apt-get install -y dbus-user-session
	# [Install Docker Engine on Debian](https://docs.docker.com/engine/install/debian/#install-using-the-convenience-script)
	mkdir -p .install
	curl -fsSL https://get.docker.com -o .install/get-docker.sh
	$(SUDO) bash .install/get-docker.sh
	rm -rf .install/get-docker.sh
	$(M) post-install-docker

/post-install-docker: ## {forces/docker} post installs docker
	$(M) $@+INFO
	set -x
	unset VERSION
	$(SUDO) journalctl -n 20 --no-pager --unit docker.service
	$(SUDO)  docker run hello-world

/uninstall-docker: ## {forces/docker} uninstalls docker
	$(M) $@+INFO
	set -x
	unset VERSION
	dockerd-rootless-setuptool.sh uninstall --force || true
	/usr/bin/dockerd-rootless-setuptool.sh uninstall -f || true
	systemctl --user daemon-reload
	$(SUDO) systemctl daemon-reload
	/usr/bin/rootlesskit rm -rf $(HOME)/.local/share/docker || true

	$(SUDO) apt-get purge docker* docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras -yy

	$(SUDO) rm -rf /var/lib/docker
	$(SUDO) rm -rf /var/lib/containerd
	$(SUDO) rm -rf /home/docker || true
	$(SUDO) rm -rf $(HOME)/.config/systemd/user/docker.service



endif