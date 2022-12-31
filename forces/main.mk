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
#███                                                                                            ████
#███             ███╗   ███╗  █████╗  ██╗  ██╗ ███████╗ ███████╗ ██╗ ██╗      ███████╗          ████
#███             ████╗ ████║ ██╔══██╗ ██║ ██╔╝ ██╔════╝ ██╔════╝ ██║ ██║      ██╔════╝          ████
#███             ██╔████╔██║ ███████║ █████╔╝  █████╗   █████╗   ██║ ██║      █████╗            ████
#███             ██║╚██╔╝██║ ██╔══██║ ██╔═██╗  ██╔══╝   ██╔══╝   ██║ ██║      ██╔══╝            ████
#███             ██║ ╚═╝ ██║ ██║  ██║ ██║  ██╗ ███████╗ ██║      ██║ ███████╗ ███████╗          ████
#███             ╚═╝     ╚═╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚══════╝ ╚═╝      ╚═╝ ╚══════╝ ╚══════╝          ████
#███                                                                                            ████
#███                   ███████╗  ██████╗  ██████╗   ██████╗ ███████╗ ███████╗                   ████
#███                   ██╔════╝ ██╔═══██╗ ██╔══██╗ ██╔════╝ ██╔════╝ ██╔════╝                   ████
#███                   █████╗   ██║   ██║ ██████╔╝ ██║      █████╗   ███████╗                   ████
#███                   ██╔══╝   ██║   ██║ ██╔══██╗ ██║      ██╔══╝   ╚════██║                   ████
#███                   ██║      ╚██████╔╝ ██║  ██║ ╚██████╗ ███████╗ ███████║                   ████
#███                   ╚═╝       ╚═════╝  ╚═╝  ╚═╝  ╚═════╝ ╚══════╝ ╚══════╝                   ████
#███                                                                                            ████
#███                                                                                            ████
#███ [ASCII TEXT](https://patorjk.com/software/taag/#p=display&h=0&f=ANSI%20Shadow&t=output%3A) ████
#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ Makefile forces (fith force of nature for lazy people)
#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ Updates (ifany): https://github.com/ralf-it/makefile-forces.git
#███
#███ FAQ:
#███	+= append to variable
#███	 = is regular assignment, dynamically evaluated when used
#███	:= is immediate assignment (evaluated at declaration)
#███	?= If the variable is not defined, set it to this value similar to :=
#███
#███ ! NOTE: non-internal targets must be commented with "## ...description..." else they are doomed
#███████████████████████████████████████████████████████████████████████████████████████████████████


#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ Configs
#███████████████████████████████████████████████████████████████████████████████████████████████████

-include .env.forces
FORCES_PATH ?= $(file < .make/FORCES)
ifeq ($(FORCES_PATH),)
  FORCES_PATH := $(file < ~/.make/FORCES)
endif

include $(FORCES_PATH)/render.mk

# ! TODO do we want to EXPORT all variables?
# ! else do
# VAR := 1
# export VAR
.EXPORT_ALL_VARIABLES:

#===================================================================================================
#=== Debugging and logging
#===================================================================================================

TRACE         ?= false
DEBUG         ?= false
VERBOSE       ?= false

ifeq ($(TRACE),true)
  TF_LOG    := TRACE
else ifeq ($(DEBUG),true)
  TF_LOG    := DEBUG
else ifeq ($(VERBOSE),true)
  TF_LOG    := INFO
endif

ifeq  ($(filter true, $(TRACE) $(DEBUG) $(VERBOSE)),)
  .SILENT:
  SILENT := true
else
  SILENT := false
endif

#===================================================================================================
#=== Makefile Flags
#===================================================================================================
M             ?= gmake

# force to run without caching targets
# disable built-in rules (e.g. %.o: %.c)
# warn if an undefined variable is referenced
MAKEFLAGS     += --always-make
MAKEFLAGS     += --no-builtin-rules
MAKEFLAGS     += --warn-undefined-variables

ifeq ($(TRACE),true)
MAKEFLAGS	  += --trace
endif

ifeq ($(DEBUG),true)
MAKEFLAGS	  += --debug
endif

ifeq ($(SILENT),false)
MAKEFLAGS	  += --print-directory
MAKEFLAGS     += --no-silent
else
MAKEFLAGS     += --no-print-directory
endif

# ! NOTE: disable parallelism, so thst we cam use make like `make TGT ARGS -- KWARGS`
# 0: disabled, -1: all-cores, n: number of jobs
PARALLEL      := 0

#===================================================================================================
#=== Shell
#===================================================================================================

.ONESHELL:    # multiline targets
.SHELL        := $(shell which bash) -euo pipefail
SHELL         := $(shell which bash)
SHELL_NAME    := $(notdir ${SHELL})
SHELL_VERSION := $(shell echo $${BASH_VERSION%%[^0-9.]*})



ifneq ($(DEBUG),true)
   # -e: exit on error
   # -u: error on undefined variable
   # -o pipefail: catch pipe errors
   # -c: run in non-interactive mode
  .SHELLFLAGS	:= -eu -o pipefail -c
else
   # -x: print command before execution
  .SHELLFLAGS	:= -xeu -o pipefail -c
endif


#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ System Checks
#███████████████████████████████████████████████████████████████████████████████████████████████████

#===================================================================================================
#=== Os Check
#===================================================================================================
ifndef OS
  OS := $(shell uname -s)
else ifneq ($(OS),Windows_NT)
  OS := $(shell uname -s)
else ifeq ($(OS),Windows_NT)
  $(error Windows is not supported. Scram!)
endif

OS_LOWER := $(shell echo $(OS) | tr '[:upper:]' '[:lower:]')

#===================================================================================================
#=== Make Check
#===================================================================================================
ifeq ($(shell expr $(MAKE_VERSION) \< 4.3), 1)
    $(error Using not supported Make $(MAKE_VERSION))
else ifeq ($(SILENT),false)
    $(info Using Make $(MAKE_VERSION))
endif

#===================================================================================================
#=== Bash Check
#===================================================================================================
ifeq ($(shell expr $(SHELL_VERSION) \< 5.1), 1)
    $(error Using not supported Bash $(SHELL_VERSION))
else ifeq ($(SILENT),false)
    $(info Using Bash $(SHELL_VERSION))
endif

#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ ENV VARS
#███████████████████████████████████████████████████████████████████████████████████████████████████

DATE          ?= $(shell date)
DATETIME      ?= $(shell date +%Y%m%dT%H%M%S)
TERM          ?= xterm-256color
COWSAY        := $(shell which cowsay || echo /usr/games/cowsay)

WHOAMI        := $(shell whoami)
CPUS          := $(shell nproc)

ONLINE        := $(shell [ ! -z "`dig +short google.com`" ] && echo true || echo false)

ifeq ($(ONLINE), true)
    MY_IP       := $(shell timeout 1 curl -ss "http://ipv4.icanhazip.com" | tr -d [:space:])
    MY_IP_CIDR  := $(MY_IP)/32
else
    MY_IP	    := null
    MY_IP_CIDR  := null
endif

ifndef DATETIME0
DATETIME0 := $(DATETIME)
endif

null :=
space := ${null} ${null}
${space} := ${space}

define \n


endef


#!███████████████████████████████████████████████████████████████████████████████████████████████████
#!███ HACKS
#!███████████████████████████████████████████████████████████████████████████████████████████████████


# # If command line input is defined (i.e. `$(M) INFO aladef -- --ala --ma --kota`)
# ifdef MAKECMDGOALS
#     # Get first item from MAKECMDGOALS
#     ifndef ARGV0
#     ARGV0 := $(firstword $(MAKECMDGOALS))
#     endif

#     # Get second and next items from MAKECMDGOALS
#     ifndef ARGVN
#     ARGVN := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
#     endif

#     ifndef ARGV
#     ARGV = $(filter-out $@,$(filter-out --,$(MAKECMDGOALS)))
#     endif

# ## ! Catch undefined targets when doing `$(M) INFO ala ma kota`
# ## ! Note: use `$(M) INFO -- --ala --ma --kota` to pass arguments to target
# ## ! when `--warn-undefined-variables` and `ARGV` are used
# ## !
# %: main-main-render

# 	# echo "Undefined target: $@"
# 	# echo "MAKECMDGOALS: $(MAKECMDGOALS)"
# 	# echo "ARGV: $(ARGV)"
# 	# echo "%=$*"
# 	if [ "$(ARGV0)" != "$(MAKECMDGOALS)" ]; then # ! NOTE: disable parallelism, change behaviour of make TGT1 TG2 to make TGT1 ARGS...
# 		if [ "$(SILENT)" == "false" ]; then
# 			echo "ARGVs & MAKECMDGOALS: $(ARGV0); $(ARGVN); $(ARGV); $(MAKECMDGOALS)"
# 		fi
# 		exit 0
# 	fi
# 	@:

# ## ! .......................................................................
# else
#     ARGV ?=
#     ARGV0 ?=
#     ARGVN ?=
# endif


#███████████████████████████████████████████████████████████████████████████████████████████████████
#███ TARGETS
#███████████████████████████████████████████████████████████████████████████████████████████████████


#===================================================================================================
#=== UTILS
#===================================================================================================

/show-env: ## {forces/terminal} show environment variables
	$(M) $@+INFO
	env | sort

/rm-temps: ## {forces/utils} remove temporary files
	$(M) $@+INFO
	cd /tmp
	find . -delete

/generate-secret-alfanum: ## {forces/utils} generate secret
	$(M) $@+INFO
	openssl rand -hex 22

/generate-secret-base64: ## {forces/utils} generate secret
	$(M) $@+INFO
	openssl rand -base64 32


#===================================================================================================
#=== SELF UPDATE
#===================================================================================================


MAKEFILE_FORCES_GIT     ?= https://github.com/ralf-it/makefile-forces
MAKEFILE_FORCES_GIT_API ?= https://api.github.com/repos/ralf-it/makefile-forces/tags

/makefile-update: ## {forces/update} update and install makefile-forces from github via pip
	$(M) $@+INFO-B
	set +x
	MAKEFILE_FORCES_VERSION=`curl $(MAKEFILE_FORCES_GIT_API) | jq '.[].name' -r | sort -r --version-sort | head -n1`
	pip install git+$(MAKEFILE_FORCES_GIT).git@$${MAKEFILE_FORCES_VERSION} --verbose --force

/makefile-version: ## {forces/update} show makefile-forces version
	$(M) $@+INFO
	MAKEFILE_FORCES_VERSION=`curl $(MAKEFILE_FORCES_GIT_API) | jq '.[].name' -r | sort -r --version-sort | head -n1`
	echo $${MAKEFILE_FORCES_VERSION}


#███████████████████████████████████████████████████████████████████████████████████████████████████
#██ HELP
#███████████████████████████████████████████████████████████████████████████████████████████████████


# Set the default target
.DEFAULT_GOAL := help
.PHONY: help

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## {help} Help for project targets.
	echo -e "\n$(COLOR_BGREEN)>>> PROJECT HELP <<<$(END_COLOR)"
	@awk \
		-v bwhite="$(COLOR_BWHITE)" \
		-v green="$(COLOR_GREEN)" \
		-v end="$(END_COLOR)" \
		-v gray="$(COLOR_GRAY)" \
		-v bgray="$(COLOR_BGRAY)" \
		-v format="%-50s %s\n" \
	'
	BEGIN {FS = ":.*?## "; } \
	/^[a-zA-Z_0-9-]+:.*?## / { \
		item = $$1; \
		comment = $$2; \
		if (match(comment, /\[([^}]*)\]/, m)) { \
			category = m[1]; \
		} else { \
			category = ""; \
		} \
		if ((category != "") && (category != "help")) { \
			sub(/\/.*/, "", category); \
			array[category][item] = comment; \
		} \
	} \
	END { \
		PROCINFO["sorted_in"] = "@ind_str_asc";  # Ensure categories are processed in alphabetical order \
		for (cat in array) { \
			print "\n"
			printf format, bwhite ".:: " cat " ::.", bgray "::..." ; \
			for (item in array[cat]) { \
				printf format, green item":", gray array[cat][item]; \
			} \
		} \
	}' $(MAKEFILE_LIST_UNIQ) || echo "..."
	@echo "..."

	if [ "$(NO_HELP_INSTRUCTIONS)" == "" ]; then
		$(M) help-instructions
	fi

/help: ## {help} Help for forces targets.
	echo -e "\n$(COLOR_BPURPLE)>>> TOOLS HELP <<<$(END_COLOR)"

	@awk \
		-v bwhite="$(COLOR_BWHITE)" \
		-v purple="$(COLOR_PURPLE)" \
		-v end="$(END_COLOR)" \
		-v gray="$(COLOR_GRAY)" \
		-v bgray="$(COLOR_BGRAY)" \
		-v format="%-50s %s\n" \
	'
	BEGIN {FS = ":.*?## "; } \
	/^\/[a-zA-Z_0-9-]+:.*?## / { \
		item = $$1; \
		comment =  $$2; \
		category = $$2; \
		if (match(comment, /\{([^}]*)\}/, m)) { \
			category = m[1]; \
		} else { \
			category = ""; \
		} \
		if ((category != "") && (category != "help")) { \
			sub(/forces\//, "", category); \
			if (index(category, "/") != 0) { \
				split(category, parts, "/"); \
				category = parts[1]; \
			} else { \
				category = category; \
			} \
			gsub(/ /, "", category); \
			if (length(category) > 0) { \
				# print purple category end item "...." comment; \
				array[category][item] = comment; \
			} \
		} \
	} \
	END { \
		PROCINFO["sorted_in"] = "@ind_str_asc";  # Ensure categories are processed in alphabetical order \
		for (cat in array) { \
			print "\n"
			printf format, bwhite ".:: " cat " ::.", bgray "::..." ; \
			for (item in array[cat]) { \
				printf format, purple item":", gray array[cat][item]; \

			} \
		} \
	}' $(MAKEFILE_LIST_UNIQ) || echo "..."
	@echo "..."

	echo -e "\n$(COLOR_BYELLOW)>>> LOGGING HELP <<<$(END_COLOR)"
	@awk 'BEGIN {FS = ":.*?## "} /^\.[a-zA-Z_0-9-]+:.*?## / {printf "$(COLOR_ORANGE)%-50s$(END_COLOR) %s\n", $$1":", $$2}' $(MAKEFILE_LIST_UNIQ) | grep '\{' |  LC_COLLATE=C sort -k 1 || echo "..."
	echo "..."

	echo -e "\n$(COLOR_BGRAY)>>> LOGGING - DEFINITIONS <<<$(END_COLOR)"
	@awk 'BEGIN {FS = ":.*?## "} /^[%(-+a-zA-Z_0-9-]+:.*?## / {printf "$(COLOR_GRAY)%-50s$(END_COLOR) %s\n", $$1":", $$2}' $(MAKEFILE_LIST_UNIQ)  | grep -v '\{' | grep '(' | grep logging | sort -k 2 || echo "..."

	echo "..."


	if [ "$(NO_HELP_INSTRUCTIONS)" == "" ]; then
		$(M) help-instructions
	fi

@help: ## {help/internal} Help for dynamic targets.

	echo -e "\n$(COLOR_BGRAY)>>> INTERNAL - DECLARATIONS <<<$(END_COLOR)"
	@awk 'BEGIN {FS = ":.*?## "} /^@[$$_(-+a-zA-Z_0-9-]+:.*?## / {printf "$(COLOR_GRAY)%-50s$(END_COLOR) %s\n", $$1":", $$2}' $(MAKEFILE_LIST_UNIQ)  | grep -v '\{' | grep '(' |  sort -k 2 || echo "..."

	echo -e "\n$(COLOR_BGRAY)>>> INTERNAL - DEFINITIONS <<<$(END_COLOR)"
	@awk 'BEGIN {FS = ":.*?## "} /^@[$$_%(-+a-zA-Z_0-9-]+:.*?## / {printf "$(COLOR_GRAY)%-50s$(END_COLOR) %s\n", $$1":", $$2}' $(MAKEFILE_LIST_UNIQ)  | grep -v '\{' | grep '(' | grep -v logging | sort -k 2 || echo "..."


HELP: ## {help} All Helps.
	NO_HELP_INSTRUCTIONS=1 $(M) help
	NO_HELP_INSTRUCTIONS=1 $(M) /help
	NO_HELP_INSTRUCTIONS=1 $(M) @help
ifndef NO_HELP_INSTRUCTIONS
	$(M) help-instructions
endif

help-instructions: ## {help} Instructions how to use makefile-forces
	echo -e "\n$(COLOR_BRED)>>> INSTRUCTIONS: $(END_COLOR)"
	echo -e "..."
	echo -e "... use $(COLOR_RED)\`make <TAB>\`$(END_COLOR) to view project targets."
	echo -e "... use $(COLOR_RED)\`make @<TAB>\`$(END_COLOR) to view project dynamic targets."
	echo -e "... use $(COLOR_RED)\`make /<TAB>\`$(END_COLOR) to view forces targets."
	echo -e "..."
	echo -e "... use $(COLOR_RED)\`make TARGET <*args> -- <**kwargs>\`$(END_COLOR) to pass arguments to targets."
	echo -e "..."
	echo -e "... execute $(COLOR_RED)\`make help\`$(END_COLOR) to view project targets help."
	echo -e "... execute $(COLOR_RED)\`make @help\`$(END_COLOR) to view project dynamic targets help."
	echo -e "... execute $(COLOR_RED)\`make /help\`$(END_COLOR) to view forces targets help."
	echo -e "... execute $(COLOR_RED)\`make HELP\`$(END_COLOR) to view ALL targets help."

# ! TODO
# help-draft: ##
# 	awk '/^# Not a target:/ { flag = 1; next }    flag && NF == 0 { flag = 0; next }    !flag'

# 	awk '!/^[#[:space:]]*Implicit rule search has not been done\.$$/ && !/^[#[:space:]]*Modification time never checked\.$$/ && !/^[#[:space:]]*File has not been updated\.$$/'

# 	awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}'

# 	awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {printf $$1 "/2:" $$2 "/3:" $$3 "\n"}}'

/help-all-no-color: ## {forces/help} This help (no color).
	@awk 'BEGIN {FS = ":.*?## "} /^[-+%\(\.\/a-zA-Z_0-9-]+:.*?## / {printf "%-40s %s\n", $$1":", $$2}' $(MAKEFILE_LIST_UNIQ) | sort



#███████████████████████████████████████████████████████████████████████████████████████████████████
#██ Logging
#███████████████████████████████████████████████████████████████████████████████████████████████████

COLOR_GRAY       = \033[0;30m
COLOR_RED        = \033[0;31m
COLOR_GREEN      = \033[0;32m
COLOR_ORANGE     = \033[0;33m
COLOR_BLUE       = \033[0;34m
COLOR_PURPLE     = \033[0;35m
COLOR_CYAN       = \033[0;36m
COLOR_WHITE      = \033[0;37m
COLOR_BGRAY      = \033[1;30m
COLOR_BRED       = \033[1;31m
COLOR_BGREEN     = \033[1;32m
COLOR_BYELLOW    = \033[1;33m
COLOR_BBLUE      = \033[1;34m
COLOR_BPURPLE    = \033[1;35m
COLOR_BCYAN      = \033[1;36m
COLOR_BWHITE     = \033[1;37m
END_COLOR        = \033[0m
LINE_CHAR       ?= █
SUB_LINE_CHAR   ?= ═
COLUMNS         ?= $(shell tput cols)
MSG              =

.clear: ## {forces/logging} clear the screen
	clear

.line: ## {forces/logging} print line
	printf -- '$(LINE_CHAR)%.0s' {1..$(COLUMNS)}; echo

.subline: ## {forces/logging} print subline
	printf -- '$(SUB_LINE_CHAR)%.0s' {1..$(COLUMNS)}; echo

.output-banner: ## {forces/logging} print output banner
	@echo -e '$(COLOR_GREEN)$(file < $(FORCES_PATH)/assets/output.asci)$(END_COLOR)'

#---------------------------------------------------------------------------------------------------
#-- TARGETS
#---------------------------------------------------------------------------------------------------

.INFO-B: ## {forces/logging} log info begin
	$(M) $@+INFO-B

.INFO-E: ## {forces/logging} log info end
	$(M) $@+INFO-E

.INFO: ## {forces/logging} log info
	$(M) $@+INFO

.WARN: ## {forces/logging} log warning
	$(M) $@+WARN

.ERROR: ## {forces/logging} log error
	$(M) $@+ERROR

%+INFO-B: ## (forces/define/logging) log info begin template
	export TARGET=$*
	set +x
	if [ "$(ARGVN)" != "" ];
	then
		MSG="$(MSG)$(ARGVN)"
	else
		MSG="$(MSG)$(ARGV0)"
	fi
	if [ "$$MSG" == "$$TARGET" ];
	then
		HELP=`NO_HELP_INSTRUCTIONS=1 $(M) /help-all-no-color | grep -- "$$TARGET:" | cut -d ' ' -f 2- | awk '{$$1=$$1};1' || ( echo "No help comment available for $$TARGET. Abort" && exit 1 )`
		MSG="$$HELP"
	fi

	echo -en "" "$(COLOR_GREEN)\r"
	$(M) .line
	if [ "$$TARGET" == "INFO" ];
	then
		echo -e "[$(DATE)] INFO BEGIN - $${MSG}..."
	else
		echo -e "[$(DATE)] INFO BEGIN - $${TARGET^^} - $${MSG}..."
	fi
	$(M) .line LINE_CHAR='-'
	echo -en "" "$(END_COLOR)\r"
	echo

%+INFO-E: ## (forces/define/logging) log info end template
	export TARGET=$*
	set +x
	if [ "$(ARGVN)" != "" ];
	then
		MSG="$(MSG)$(ARGVN)"
	else
		MSG="$(MSG)$(ARGV0)"
	fi
	if [ "$$MSG" == "$$TARGET" ];
	then
		HELP=`NO_HELP_INSTRUCTIONS=1 $(M) /help-all-no-color | grep -- "$$TARGET:" | cut -d ' ' -f 2- | awk '{$$1=$$1};1' || ( echo "No help comment available for $$TARGET. Abort" && exit 1 )`
		MSG="$$HELP"
	fi

	echo
	echo -en "" "$(COLOR_GREEN)\r"
	$(M) .line LINE_CHAR='-'
	if [ "$$TARGET" == "INFO" ];
	then
		echo -e "[$(DATE)] INFO END - $${MSG}..."
	else
		echo -e "[$(DATE)] INFO END - $${TARGET^^} - $${MSG}..."
	fi
	$(M) .line
	echo -e "$(END_COLOR)"

%+INFO: ## (forces/define/logging) log info template
	export TARGET=$*
	set +x
	if [ "$(ARGVN)" != "" ];
	then
		MSG="$(MSG)$(ARGVN)"
	else
		MSG="$(MSG)$(ARGV0)"
	fi

	if [ "$$MSG" == "$$TARGET" ];
	then
		HELP=`NO_HELP_INSTRUCTIONS=1 $(M) /help-all-no-color | grep -- "$$TARGET:" | cut -d ' ' -f 2- | awk '{$$1=$$1};1' || ( echo "No help comment available for $$TARGET. Abort" && exit 1 )`
		MSG="$$HELP"
	fi

	if [ "$$TARGET" == "INFO" ];
	then
		echo -e "$(COLOR_GREEN)[$(DATE)] INFO - $${MSG}...$(END_COLOR)"
	else
		echo -e "$(COLOR_GREEN)[$(DATE)] INFO - $${TARGET} - $${MSG}...$(END_COLOR)"
	fi

%+WARN: ## (forces/define/logging) log warning template
	export TARGET=$*
	set +x
	if [ "$(ARGVN)" != "" ];
	then
		MSG="$(MSG)$(ARGVN)"
	else
		MSG="$(MSG)$(ARGV0)"
	fi
	if [ "$$TARGET" == "WARN" ];
	then
		echo -e "$(COLOR_ORANGE)[$(DATE)] WARN - $${MSG}...$(END_COLOR)"
	else
		echo -e "$(COLOR_ORANGE)[$(DATE)] WARN - $${TARGET^^} - $${MSG}...$(END_COLOR)"
	fi

%+ERROR: ## (forces/define/logging) log error template
	echo "ERROR"
	export TARGET=$*
	set +x
	if [ "$(ARGVN)" != "" ];
	then
		MSG="$(MSG)$(ARGVN)"
	else
		MSG="$(MSG)$(ARGV0)"
	fi
	if [ "$$TARGET" == "ERROR" ];
	then
		echo -e "$(COLOR_RED)[$(DATE)] ERROR - $${MSG}...$(END_COLOR)"
	else
		echo -e "$(COLOR_RED)[$(DATE)] ERROR -  $${TARGET^^} - $${MSG}...$(END_COLOR)"
	fi
	exit 1




#███████████████████████████████████████████████████████████████████████████████████████████████████
#██ TOOLS
#███████████████████████████████████████████████████████████████████████████████████████████████████

MAKEFILE_LIST_UNIQ = `echo $(MAKEFILE_LIST)  | tr ' ' '\n' |  sort | uniq`

/makefile-list: ## {forces/make} Show list of loaded Makefiles and .env's
	echo $(MAKEFILE_LIST_UNIQ)

#===================================================================================================
#=== LINT
#===================================================================================================

/pre-commit-run: ## {forces/lint} run pre-commit
	$(M) $@+INFO
	set -x
	pre-commit run --all-files --show-diff-on-failure --verbose --color always

#===================================================================================================
#== NET
#===================================================================================================

/show-used-ports: ## {forces/net} show used ports
	$(M) $@+INFO
	sudo lsof -i -P -n | grep LISTEN

#███████████████████████████████████████████████████████████████████████████████████████████████████
#██ EXTENSIONS
#███████████████████████████████████████████████████████████████████████████████████████████████████

ifdef FORCES_TOOLS_ENABLE_AZ
    include  $(FORCES_PATH)/tools/az.mk
endif

ifdef FORCES_TOOLS_ENABLE_TF
    include $(FORCES_PATH)/tools/tf.mk
endif

ifdef FORCES_TOOLS_ENABLE_GIT
    include $(FORCES_PATH)/tools/git.mk
endif

ifdef FORCES_TOOLS_ENABLE_PSQL
    include $(FORCES_PATH)/tools/psql.mk
endif

ifdef FORCES_TOOLS_ENABLE_DOCKER
    include $(FORCES_PATH)/tools/docker.mk
endif

ifdef FORCES_TOOLS_ENABLE_PYTHON
    include $(FORCES_PATH)/tools/python.mk
endif

ifdef FORCES_TOOLS_ENABLE_INSTALL
    include $(FORCES_PATH)/tools/install.mk
endif

#███████████████████████████████████████████████████████████████████████████████████████████████████
#██ HACKS (POST)
#███████████████████████████████████████████████████████████████████████████████████████████████████

ifneq ($(RENDER_DISABLE), true)

    include $(FORCES_PATH)/render.mk

    ifdef FORCES_TOOLS_ENABLE_TF
        ifdef FORCES_TF_RENDER
            include $(FORCES_TF_RENDER)
        endif
    endif

endif
