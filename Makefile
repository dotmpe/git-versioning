BUILD               := .build/
DIR                 := $(CURDIR)
BASE                := $(shell cd $(DIR);pwd)

HOST                := $(shell hostname|tr '.' '-')
APP_ID              := 

ifneq ($(wildcard package.yml),)
APP_ID := $(shell grep '^main: ' package.yaml)
endif

ifeq ($(APP_ID),)
APP_ID := $(notdir $(BASE))
endif

#      ------------ --

## Make internals

# make include search path
VPATH              := . /

# make shell
SHELL              := /bin/bash

# reset file extensions
# xxx for imlicit rules?
.SUFFIXES:
#.SUFFIXES:         .rst .js .xhtml .mk .tex .pdf .list
.SUFFIXES: .rst .mk

#      ------------ --

## Local setup

# name default target
default::

# global path/file lists
SRC                :=
DMK                :=
#already setMK                 :=
DEP                :=
TRGT               :=
STRGT              := default stat build install clean info
CLN                :=
TEST               :=
INSTALL            :=

relative = $(patsubst $(BASE)%,$(APP_ID):%,$1)
where-am-i = $(call relative,$(lastword $(MAKEFILE_LIST)))

# rules: return Rules files for each directory in $1
rules = $(foreach D,$1,\
	$(wildcard \
		$DRules.mk $D.Rules.mk \
		$DRules.$(APP_ID).mk $D.Rules.$(APP_ID).mk \
		$DRules.$(HOST).mk $D.Rules.$(HOST).mk))

# Include local rules
#
include                $(call rules,$(DIR)/)

# pseudo targets are not files, don't check with OS
.PHONY: $(STRGT)

#      ------------ --

## Main rules/deps

default:: $(DMK) $(DEP)
default:: $(DEFAULT)

stat:: $(SRC)

build:: $(TRGT)

install:: $(INSTALL)

clean:: .
	rm -rf $(CLN)

info::
	@echo "Id: $(APP_ID)"

