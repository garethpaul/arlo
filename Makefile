.DEFAULT_GOAL := check
.PHONY: __repository-make-authority build check lint root-test test verify
.SECONDEXPANSION:

override SHELL := /bin/sh
override .SHELLFLAGS := -c
build check lint root-test test verify __repository-make-authority: override SHELL := /bin/sh
build check lint root-test test verify __repository-make-authority: override .SHELLFLAGS := -c

ifeq ($(origin PYTHON),undefined)
override PYTHON := $(shell /bin/sh -c 'command -v python3')
else
override PYTHON := $(value PYTHON)
endif
ifeq ($(origin XCODEBUILD),undefined)
override XCODEBUILD := xcodebuild
else
override XCODEBUILD := $(value XCODEBUILD)
endif
override ROOT := $(shell path='$(subst ','"'"',$(value MAKEFILE_LIST))'; path=$$(/usr/bin/printf '%s' "$$path" | /usr/bin/sed 's/^ //'); [ -f "$$path" ] || exit 1; directory=$$(/usr/bin/dirname -- "$$path"); /usr/bin/printf '%s\n' "$$directory" | /usr/bin/grep -q '^/' || directory=./$$directory; CDPATH= cd "$$directory" && /bin/pwd -P)
export PYTHON XCODEBUILD ROOT

override REPOSITORY_MAKE_DOLLAR := $$
override REPOSITORY_MAKE_OPEN := (
override REPOSITORY_MAKE_OPEN_BRACE := {
define REPOSITORY_REJECT_MAKE_SYNTAX
ifneq ($$(findstring $$(REPOSITORY_MAKE_DOLLAR)$$(REPOSITORY_MAKE_OPEN),$$(value $(1))),)
$$(error $(1) must be a literal value, not Make syntax)
endif
ifneq ($$(findstring $$(REPOSITORY_MAKE_DOLLAR)$$(REPOSITORY_MAKE_OPEN_BRACE),$$(value $(1))),)
$$(error $(1) must be a literal value, not Make syntax)
endif
endef
$(foreach variable,PYTHON XCODEBUILD,$(eval $(call REPOSITORY_REJECT_MAKE_SYNTAX,$(variable))))

ifeq ($(strip $(PYTHON)),)
$(error python3 is unavailable; set PYTHON to a literal executable)
endif
ifeq ($(strip $(XCODEBUILD)),)
$(error XCODEBUILD must be a literal executable)
endif
ifeq ($(strip $(ROOT)),)
$(error repository Makefile path could not be resolved)
endif
ifneq ($(filter command line,$(origin MAKEFLAGS)),)
$(error MAKEFLAGS must not be overridden for repository verification)
endif
override REPOSITORY_MAKE_FIRST_FLAGS := $(firstword $(MAKEFLAGS))
ifneq ($(filter -%,$(REPOSITORY_MAKE_FIRST_FLAGS)),)
override REPOSITORY_MAKE_FIRST_FLAGS :=
endif
override REPOSITORY_MAKE_SHORT_FLAGS := $(REPOSITORY_MAKE_FIRST_FLAGS) $(filter-out --%,$(filter -%,$(MAKEFLAGS)))
ifneq ($(findstring n,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring t,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring q,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(findstring i,$(REPOSITORY_MAKE_SHORT_FLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(filter --just-print --dry-run --recon --touch --question --ignore-errors,$(MAKEFLAGS)),)
$(error non-executing or error-ignoring MAKEFLAGS are not supported for repository verification)
endif
ifneq ($(strip $(MAKEFILES)),)
$(error MAKEFILES must be empty; repository verification requires this Makefile to be loaded alone)
endif
override MAKEFILES :=
ifneq ($(origin MAKEFILE_LIST),file)
$(error MAKEFILE_LIST must not be overridden)
endif

override REPOSITORY_SHELL_LITERAL = $(subst $$,$$$$,$(subst ','"'"',$1))
override REPOSITORY_ROOT_LITERAL := $(call REPOSITORY_SHELL_LITERAL,$(ROOT))
override REPOSITORY_PYTHON_LITERAL := $(call REPOSITORY_SHELL_LITERAL,$(PYTHON))
override REPOSITORY_XCODEBUILD_LITERAL := $(call REPOSITORY_SHELL_LITERAL,$(XCODEBUILD))

build check lint root-test test verify:: $$(if $$(filter file,$$(origin MAKEFILE_LIST)),,$$(error MAKEFILE_LIST must not be overridden))
build check lint root-test test verify:: $$(if $$(shell path=$$$$(/usr/bin/printf '%s' '$$(subst ','"'"',$$(MAKEFILE_LIST))' | /usr/bin/sed 's/^ //') && [ -f "$$$$path" ] && /usr/bin/printf '%s' ok),,$$(error repository Makefile must be loaded alone))
build check lint root-test test verify:: __repository-make-authority

__repository-make-authority::
	@:

define REPOSITORY_PUBLIC_RECIPES
root-test::
	/bin/sh '$(REPOSITORY_ROOT_LITERAL)/scripts/test-makefile-root.sh'
lint::
	/bin/sh '$(REPOSITORY_ROOT_LITERAL)/scripts/check-baseline.sh'
test::
	/bin/sh '$(REPOSITORY_ROOT_LITERAL)/scripts/check-baseline.sh'
	'$(REPOSITORY_PYTHON_LITERAL)' '$(REPOSITORY_ROOT_LITERAL)/tests/test-wit-lifecycle.py'
	'$(REPOSITORY_PYTHON_LITERAL)' '$(REPOSITORY_ROOT_LITERAL)/tests/test-wit-mutations.py'
	/bin/sh '$(REPOSITORY_ROOT_LITERAL)/scripts/test-wit-http-policy.sh'
	@if command -v '$(REPOSITORY_XCODEBUILD_LITERAL)' >/dev/null 2>&1; then echo "xcodebuild found, but no shared UI-test scheme is checked in; run ArloUITests from Arlo.xcworkspace with the legacy toolchain."; else echo "xcodebuild not found; simulator UI tests require macOS with the legacy Swift 3.0 toolchain."; fi
build::
	/bin/sh '$(REPOSITORY_ROOT_LITERAL)/scripts/check-baseline.sh'
	@if command -v '$(REPOSITORY_XCODEBUILD_LITERAL)' >/dev/null 2>&1; then echo "xcodebuild found, but no shared build scheme is checked in; build Arlo.xcworkspace with the legacy Swift 3.0 toolchain."; else echo "xcodebuild not found; full iOS build requires macOS with the legacy Swift 3.0 toolchain."; fi
verify:: root-test lint test build
check:: verify
endef
$(eval $(REPOSITORY_PUBLIC_RECIPES))
