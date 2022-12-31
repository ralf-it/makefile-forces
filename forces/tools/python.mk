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
#███ PYTHON
#███████████████████████████████████████████████████████████████████████████████████████████████████

#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ installs tools
#███████████████████████████████████████████████████████████████████████████████████████████████████

ifdef FORCES_TOOLS_ENABLE_INSTALL

#---------------------------------------------------------------------------------------------------
#-- Python Distribution
#---------------------------------------------------------------------------------------------------

/install-miniconda3-opt: ## {forces/python} installs miniconda3 in /opt/miniconda3
	$(M) $@+INFO
	set -x
	$(SUDO) mkdir -p /opt/miniconda3
	$(SUDO) chown root:$(SUDO) -Rf /opt/miniconda3
	$(SUDO) chmod 775 -Rf /opt/miniconda3
	wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /opt/miniconda3/miniconda.sh
	bash /opt/miniconda3/miniconda.sh -b -u -p /opt/miniconda3

#---------------------------------------------------------------------------------------------------
#-- IDEs
#---------------------------------------------------------------------------------------------------

/install-jetbrains-toolbox: ## {forces/tools} installs jetbrains-toolbox
	$(M) $@+INFO-B

	set -x
	TMP_DIR="/tmp"
	INSTALL_DIR="$$HOME/.local/share/JetBrains/Toolbox/bin"
	INSTALL_DIR_CHECKSUM="$$HOME/.local/share/JetBrains/Toolbox/checksum"
	OS_LOWER=$(shell echo $(OS) | tr '[:upper:]' '[:lower:]')

	$(M) $@+INFO -- Fetching the URL of the latest version...

	export TOOLBOOX_URL='https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release'
	curl -s $$TOOLBOOX_URL > $$TMP_DIR/jetbrains-toolbox-releases.json

	ARCHIVE_URL=`jq -r .TBA[0].downloads.$${OS_LOWER}.link -r $$TMP_DIR/jetbrains-toolbox-releases.json`
	ARCHIVE_URL_CHECKSUM=`jq -r .TBA[0].downloads.$${OS_LOWER}.checksumLink -r $$TMP_DIR/jetbrains-toolbox-releases.json`

	ARCHIVE_FILENAME=`basename "$$ARCHIVE_URL"`
	ARCHIVE_CHECKSUM_FILENAME=`basename "$$ARCHIVE_URL_CHECKSUM"`

	$(M) $@+INFO -- Downloading $$ARCHIVE_CHECKSUM_FILENAME...

	wget -nc --show-progress -cO "$$TMP_DIR/$$ARCHIVE_CHECKSUM_FILENAME" "$$ARCHIVE_URL_CHECKSUM" || true

	$(M) $@+INFO -- Downloading $$ARCHIVE_FILENAME...

	wget -nc --show-progress -cO "$$TMP_DIR/$$ARCHIVE_FILENAME" "$$ARCHIVE_URL" || true

	$(M) $@+INFO -- Verifying the checksum...

	ARCHIVE_CHECKSUM0=`cat "$$TMP_DIR/$$ARCHIVE_CHECKSUM_FILENAME" | awk '{print $$1}'`
	ARCHIVE_CHECKSUM=`sha256sum "$$TMP_DIR/$$ARCHIVE_FILENAME" | awk '{print $$1}'`

	diff <(echo "$$ARCHIVE_CHECKSUM0") <(echo "$$ARCHIVE_CHECKSUM")

	$(M) $@+INFO -- Extracting to $$INSTALL_DIR...

	mkdir -p "$$INSTALL_DIR"
	rm "$$INSTALL_DIR/jetbrains-toolbox" 2>/dev/null || true
	tar -xzf "$$TMP_DIR/$$ARCHIVE_FILENAME" -C "$$INSTALL_DIR" --strip-components=1
	rm "$$TMP_DIR/$$ARCHIVE_FILENAME"
	chmod +x "$$INSTALL_DIR/jetbrains-toolbox"

	SYMLINK_DIR="$$HOME/.local/bin"

	$(M) $@+INFO -- Symlinking to $$SYMLINK_DIR/jetbrains-toolbox...

	mkdir -p $$SYMLINK_DIR
	rm "$$SYMLINK_DIR/jetbrains-toolbox" 2>/dev/null || true
	ln -s "$$INSTALL_DIR/jetbrains-toolbox" "$$SYMLINK_DIR/jetbrains-toolbox"

ifndef CI
	$(M) $@+INFO -- Running for the first time to set-up...
	( "$$INSTALL_DIR/jetbrains-toolbox" & )

	$(M) $@+INFO -- Done! JetBrains Toolbox should now be running, in your application list, and you can run it in terminal as jetbrains-toolbox
	$(M) $@+INFO -- ensure that $$SYMLINK_DIR is on your PATH
else
	$(M) $@+INFO -- Done! Running in a CI -- skipped launching the AppImage.
endif
	$(M) $@+INFO-E


endif