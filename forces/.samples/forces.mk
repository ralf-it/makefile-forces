#███████████████████████████████████████████████████████████████████████████████████████████████████
#████ Makefile Forces - BASELINE
#███████████████████████████████████████████████████████████████████████████████████████████████████
FORCES_TOOLS_ENABLE_AZ := true
FORCES_TOOLS_ENABLE_TF := true
FORCES_TOOLS_ENABLE_GIT := true
FORCES_TOOLS_ENABLE_PSQL := true
FORCES_TOOLS_ENABLE_DOCKER := true
FORCES_TOOLS_ENABLE_INSTALL := true

-include .env.forces
FORCES_PATH ?= $(file < .make/FORCES)
ifeq ($(FORCES_PATH),)
  FORCES_PATH := $(file < ~/.make/FORCES)
endif

include $(FORCES_PATH)/main.mk