.PHONY: build check lint test verify

XCODEBUILD ?= xcodebuild

lint:
	scripts/check-baseline.sh

test:
	scripts/check-baseline.sh
	@if command -v "$(XCODEBUILD)" >/dev/null 2>&1; then \
		echo "xcodebuild found, but no shared UI-test scheme is checked in; run ArloUITests from Arlo.xcworkspace with the legacy toolchain."; \
	else \
		echo "xcodebuild not found; simulator UI tests require macOS with the legacy Swift 3.0 toolchain."; \
	fi

build:
	scripts/check-baseline.sh
	@if command -v "$(XCODEBUILD)" >/dev/null 2>&1; then \
		echo "xcodebuild found, but no shared build scheme is checked in; build Arlo.xcworkspace with the legacy Swift 3.0 toolchain."; \
	else \
		echo "xcodebuild not found; full iOS build requires macOS with the legacy Swift 3.0 toolchain."; \
	fi

verify: lint test build

check: verify
