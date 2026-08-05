ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

include mk/pipeline.mk
