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
#███ Install tools
#███████████████████████████████████████████████████████████████████████████████████████████████████

#---------------------------------------------------------------------------------------------------
#-- File System
#---------------------------------------------------------------------------------------------------

/install-archivemount: ## {forces/fs} installs archivemount
	$(SUDO) apt install archivemount

#---------------------------------------------------------------------------------------------------
#-- Net
#---------------------------------------------------------------------------------------------------

/install-nmap: ## {forces/net} installs nmap
	$(M) $@+INFO
	$(SUDO) apt-get install -y nmap

/install-lsof: ## {forces/net} installs lsof
	$(M) $@+INFO
	$(SUDO) apt install lsof -yy

/install-netcat: ## {forces/net} installs netcat
	$(M) $@+INFO
	$(SUDO) apt install netcat-openbsd -yy

#---------------------------------------------------------------------------------------------------
#-- Terminal
#---------------------------------------------------------------------------------------------------

/install-tmux-opt: ## {forces/terminal} installs tmux in /opt/.config
	$(M) $@+INFO
	set -x
	$(SUDO) apt install tmux -yy
	$(SUDO) mkdir -p /opt/.config
	$(SUDO) cp $(FORCES_PATH)/tmux/.config/.tmux.conf /opt/.config/.tmux.conf
	$(SUDO) ln -s /opt/.config/.tmux.conf ~/.tmux.conf

/install-tmux: ## {forces/terminal} installs tmux in ~/.tmux.conf
	$(M) $@+INFO
	set -x
	$(SUDO) apt install tmux -yy
	cp $(FORCES_PATH)/tmux/.config/.tmux.conf ~/.tmux.conf
