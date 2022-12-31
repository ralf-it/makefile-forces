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
#████ Makefile Forces - BASELINE
#███████████████████████████████████████████████████████████████████████████████████████████████████
FORCES_TOOLS_ENABLE_AZ := true
FORCES_TOOLS_ENABLE_TF := true
FORCES_TOOLS_ENABLE_GIT := true
FORCES_TOOLS_ENABLE_PSQL := true
FORCES_TOOLS_ENABLE_ACMESH := true
FORCES_TOOLS_ENABLE_DOCKER := true
FORCES_TOOLS_ENABLE_INSTALL := true
FORCES_TOOLS_ENABLE_VERSION := true

-include .env.forces
FORCES_PATH ?= $(file < .make/FORCES)
ifeq ($(FORCES_PATH),)
  FORCES_PATH := $(file < $(HOME)/.make/FORCES)
endif

include $(FORCES_PATH)/main.mk