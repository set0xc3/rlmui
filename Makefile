DEBUG_FLAGS ?=
BUILD_MODE ?=
OUT_NAME ?=

ifeq ($(BUILD_MODE), debug)
	DEBUG_FLAGS = -o:none -debug
	OUT_NAME = out-debug.bin
else ifeq ($(BUILD_MODE), release)
	DEBUG_FLAGS = -o:speed
	OUT_NAME = out-release.bin
else
	DEBUG_FLAGS = -o:none -debug
	OUT_NAME = out-debug.bin
endif

build:
	mkdir -p bin
	odin build src -out:bin/$(OUT_NAME) $(DEBUG_FLAGS) -build-mode:exe -collection:my=.

run:
	./bin/$(OUT_NAME)
