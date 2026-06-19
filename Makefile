.PHONY: build check lint test verify

XCODEBUILD ?= xcodebuild
override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

lint:
	$(ROOT)scripts/check-baseline.sh

test:
	$(ROOT)scripts/check-baseline.sh
	python3 $(ROOT)tests/test-wit-lifecycle.py
	python3 $(ROOT)tests/test-wit-mutations.py
	$(ROOT)scripts/test-wit-http-policy.sh
	@if command -v "$(XCODEBUILD)" >/dev/null 2>&1; then \
		echo "xcodebuild found, but no shared UI-test scheme is checked in; run ArloUITests from Arlo.xcworkspace with the legacy toolchain."; \
	else \
		echo "xcodebuild not found; simulator UI tests require macOS with the legacy Swift 3.0 toolchain."; \
	fi

build:
	$(ROOT)scripts/check-baseline.sh
	@if command -v "$(XCODEBUILD)" >/dev/null 2>&1; then \
		echo "xcodebuild found, but no shared build scheme is checked in; build Arlo.xcworkspace with the legacy Swift 3.0 toolchain."; \
	else \
		echo "xcodebuild not found; full iOS build requires macOS with the legacy Swift 3.0 toolchain."; \
	fi

verify: lint test build

check: verify
