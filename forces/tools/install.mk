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

/install-archivemount:
	sudo apt install archivemount

#---------------------------------------------------------------------------------------------------
#-- Net
#---------------------------------------------------------------------------------------------------

/install-nmap: ## {forces/net} install nmap
	$(M) $@+INFO
	sudo apt-get install -y nmap

/install-lsof: ## {forces/net} install lsof
	$(M) $@+INFO
	sudo apt install lsof -yy

/install-netcat: ## {forces/net} install netcat
	$(M) $@+INFO
	sudo apt install netcat-openbsd -yy

#---------------------------------------------------------------------------------------------------
#-- Terminal
#---------------------------------------------------------------------------------------------------

/install-tmux-opt: ## {forces/terminal} install tmux in /opt/.config
	$(M) $@+INFO
	set -x
	sudo apt install tmux -yy
	sudo mkdir -p /opt/.config
	sudo cp $(FORCES_PATH)/tmux/.config/.tmux.conf /opt/.config/.tmux.conf
	sudo ln -s /opt/.config/.tmux.conf ~/.tmux.conf

/install-tmux: ## {forces/terminal} install tmux in ~/.tmux.conf
	$(M) $@+INFO
	set -x
	sudo apt install tmux -yy
	cp $(FORCES_PATH)/tmux/.config/.tmux.conf ~/.tmux.conf
