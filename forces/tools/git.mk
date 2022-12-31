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
#███ GIT
#███████████████████████████████████████████████████████████████████████████████████████████████████

GIT_DATE           ?= $(shell date)

/grl: ##  {forces/git} git reflog
	$(M) $@+INFO
	set -x
	git reflog --date=short --pretty=fuller

/gaa: ## {forces/git} git add all
	$(M) $@+INFO
	set -x
	git add --all

/gcam: ## {forces/git} git commit ammend with message
	$(M) $@+INFO
	set -x

	if [ "$(GIT_MSG)" == "" ]
	then
		$(M) $@+ERROR -- GIT_MSG is not set
		exit 1
	fi

	if [ "$(GIT_DATE)" == "" ]
	then
		$(M) $@+ERROR -- GIT_DATE is not set
		exit 1
	fi

  ifdef GIT_AUTHOR
	git commit --amend --author="$(GIT_AUTHOR)" --date="$(GIT_DATE)" -m "$(GIT_MSG)"
  else
	git commit --amend --date="$(GIT_DATE)" -m "$(GIT_MSG)"
  endif

/gcae: ## {forces/git} git commit ammend --no-edit
	$(M) $@+INFO
	set -x

	if [ "$(GIT_DATE)" == "" ]
	then
		$(M) $@+ERROR -- GIT_DATE is not set
		exit 1
	fi

  ifdef GIT_AUTHOR
	git commit --amend --no-edit --author="$(GIT_AUTHOR)" --date="$(GIT_DATE)"
  else
	git commit --amend --no-edit --date="$(GIT_DATE)"
  endif

/gca: ## {forces/git} git commit ammend
	$(M) $@+INFO
	set -x

	if [ "$(GIT_DATE)" == "" ]
	then
		$(M) $@+ERROR -- GIT_DATE is not set
		exit 1
	fi

  ifdef GIT_AUTHOR
	git commit --amend --author="$(GIT_AUTHOR)" --date="$(GIT_DATE)"
  else
	git commit --amend --date="$(GIT_DATE)"
  endif

/gcm: ## {forces/git} git commit with message
	$(M) $@+INFO
	set -x

	if [ "$(GIT_MSG)" == "" ]
	then
		$(M) $@+ERROR -- GIT_MSG is not set
		exit 1
	fi

	if [ "$(GIT_DATE)" == "" ]
	then
		$(M) $@+ERROR -- GIT_DATE is not set
		exit 1
	fi

  ifdef GIT_AUTHOR
	git commit --author="$(GIT_AUTHOR)" --date="$(GIT_DATE)" -m "$(GIT_MSG)"
  else
	git commit --date="$(GIT_DATE)" -m "$(GIT_MSG)"
  endif

/gs: ## {forces/git} git status
	$(M) $@+INFO
	set -x
	git status

/gp: ## {forces/git} git push
	$(M) $@+INFO
	set -x
	git push

/gpf: ## {forces/git} git push force with lease
	$(M) $@+INFO
	set -x
	git push --force --force-with-lease

/gf: ## {forces/git} git fetch
	$(M) $@+INFO
	set -x
	git fetch

/gtdl: ## {forces/git} git tag delete
	$(M) $@+INFO
	set -x

	if [ "$(ARGVN)" == "" ]
	then
		$(M) $@+ERROR -- tag is not provided
		exit 1
	fi

	git tag -d $(ARGVN)

/gtdr: ## {forces/git} git tag delete remote
	$(M) $@+INFO
	set -x

	if [ "$(ARGVN)" == "" ]
	then
		$(M) $@+ERROR -- tag is not provided
		exit 1
	fi

	git push origin --delete $(ARGVN)

/gtd: ## {forces/git} git tag delete locally and remote
	$(M) $@+INFO
	set -x

	$(M) /gtdl -- "$(ARGVN)" || true
	$(M) /gtdr -- "$(ARGVN)"

/gt: ## {forces/git} git tag
	$(M) $@+INFO
	set -x
	git tag $(file < VERSION)


/gtf: ## {forces/git} git tag force
	$(M) $@+INFO
	set -x
	git tag $(file < VERSION) --force

/gpt: ## {forces/git} git push tag
	$(M) $@+INFO
	set -x
	git push origin --tags

/gptf: ## {forces/git} git push tag force
	$(M) $@+INFO
	set -x
	git push origin --tags --force

/GACP: ## {forces/git} git add all, commit, and push
	$(M) $@+INFO
	$(M) /gaa
	$(M) /gcm
	$(M) /gp

/GACPF: ## {forces/git} git add all, commit ammend no edit, and push force with lease
	$(M) $@+INFO
	$(M) /gaa
	$(M) /gcae
	$(M) /gpf

/GACMPF: ## {forces/git} git add all, commit ammend message, and push force with lease
	$(M) $@+INFO
	$(M) /gaa
	$(M) /gcam
	$(M) /gpf

/GACMTP: ## {forces/git} git add all, commit, push, and tag
	$(M) $@+INFO
	$(M) /gaa
	$(M) /gcm
	$(M) /gt
	$(M) /gp
	$(M) /gpt

/GACMTPF: ## {forces/git} git add all, commit ammend message, push force with lease, tag force
	$(M) $@+INFO
	$(M) /gaa
	$(M) /gcam
	$(M) /gtf
	$(M) /gpf
	$(M) /gptf

/git-super-config: ## {forces/git} set super(lazy) git config (submodule.recurse, rebase.autoStash, pull.rebase)
	$(M) $@+INFO
	set -x
	git config submodule.recurse true
	git config rebase.autoStash true
	git config pull.rebase true
	git config push.followTags true

/git-org-config: ## {forces/git} set org git config
	$(M) $@+INFO

	if [ -z "$(ORG)" ]; then
		$(M) $@+ERROR -- ORG is not set
	fi

	if [ -z "$(ORG_REPOS_DIR)" ]; then
		$(M) $@+ERROR -- ORG_REPOS_DIR is not set
	fi

	if [ -z "$(GIT_AUTHOR)" ]; then
		$(M) $@+ERROR -- GIT_AUTHOR is not set
	fi

	if [ -z "$(GIT_AUTHOR_EMAIL)" ]; then
		$(M) $@+ERROR -- GIT_AUTHOR_EMAIL is not set
	fi

	if [ -z "$(ORG_SSH_KEY)" ]; then
		$(M) $@+ERROR -- ORG_SSH_KEY is not set
	fi

	set -x

	cat <<-EOF >> .gitconfig
	[includeIf "gitdir:$(ORG)/"]
		path = $(ORG_REPOS_DIR)/.gitconfig
	EOF

	mkdir -p $(ORG_REPOS_DIR)

	cat <<-EOF >> $(ORG_REPOS_DIR)/.gitconfig
		[user]
		name = $(GIT_AUTHOR)
		email = $(GIT_AUTHOR_EMAIL)

		[core]
		sshCommand = ssh -i $(ORG_SSH_KEY)
	EOF

/git-sizer: ## {forces/git} run git-sizer
	$(M) $@+INFO
	git-sizer  --threshold=1 -v

#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ Install tools
#███████████████████████████████████████████████████████████████████████████████████████████████████
ifdef FORCES_TOOLS_ENABLE_INSTALL

#---------------------------------------------------------------------------------------------------
#-- Git
#---------------------------------------------------------------------------------------------------

/install-git-sizer: ## {forces/git} installs git-sizer
	$(M) $@+INFO
	wget https://github.com/github/git-sizer/releases/download/v1.5.0/git-sizer-1.5.0-linux-amd64.zip -nc
	mkdir -p git-sizer
	$(SUDO) unzip  -o git-sizer-1.5.0-linux-amd64.zip -d git-sizer
	$(SUDO) mv git-sizer/git-sizer /usr/local/bin/git-sizer
	$(SUDO) chmod +x /usr/local/bin/git-sizer
	rm -rf git-sizer-1.5.0-linux-amd64.zip
	rm -rf git-sizer


endif