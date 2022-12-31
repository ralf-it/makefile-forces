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
#███ PSQL
#███████████████████████████████████████████████████████████████████████████████████████████████████

/psql-exec-cmd: ## {forces/psql/cmd} Execute psql command
	$(M) $@+INFO
	set -xueo pipefail
	if psql --echo-queries --no-password -h $(DB_HOST) -p $(DB_PORT) -U $(POSTGRES_USER) -d $(POSTGRES_DB)  -c "$(PSQL_CMD)"; then
		echo "Success."
	else
		echo "Failed."
	fi

/psql-exec-cmd-migrator: ## {forces/psql/cmd} Execute psql command as migrator user
	$(M) $@+INFO
	set -xueo pipefail

	if psql --echo-queries --no-password -h $(DB_HOST) -p $(DB_PORT) -U $(POSTGRES_USER_MIGRATOR) -d $(POSTGRES_DB)  -c "$(PSQL_CMD)"; then
		set +x
		$(M) $@+INFO -- Success.
	else
		set +x
		$(M) $@+ERROR -- Failed.
	fi

#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ Install tools
#███████████████████████████████████████████████████████████████████████████████████████████████████

ifdef FORCES_TOOLS_ENABLE_INSTALL

#---------------------------------------------------------------------------------------------------
#-- PSQL
#---------------------------------------------------------------------------------------------------

/install-psql-16:
	$(M) $@+INFO
	set -x
	# First, update the package index and install required packages:
	sudo apt update
	sudo apt install gnupg2 wget vim
	# Add the PostgreSQL 16 repository:
	sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(shell lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
	# Import the repository signing key:
	curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
	# Update the package list:
	sudo apt update
	sudo apt install postgresql-client-16*

endif