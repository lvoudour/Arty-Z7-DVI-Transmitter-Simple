SRC_DIR   := src
BUILD_DIR := build
SIM_DIR   := sim

MAKE_BUILD  := $(MAKE) -C $(BUILD_DIR)
MAKE_SIM    := $(MAKE) -C $(SIM_DIR)

include src.mk

XDC_SRC_REL  ?=
VHDL_SRC_REL ?=
TB_SRC_REL   ?=

export XDC_SRC  := $(abspath $(XDC_SRC_REL))
export VHDL_SRC := $(abspath $(VHDL_SRC_REL))
export TB_SRC   := $(abspath $(TB_SRC_REL))

export TOP_MODULE := dvi_tx
export FPGA_PART  := xc7z020clg400-1

.PHONY: build program vsim xsim lint clean
build:
	$(MAKE_BUILD) $@

program:
	$(MAKE_BUILD) $@

vsim:
	$(MAKE_SIM) $@

xsim:
	$(MAKE_SIM) $@

# Used for sublime text editor linting
lint: $(TB_SRC)
	@xvhdl --2008 $(TB_SRC)

clean:
	rm xvhdl.* 2>/dev/null \
	rm -rf xsim.dir 2>/dev/null
	$(MAKE) -C $(BUILD_DIR) $@
	$(MAKE) -C $(SIM_DIR) $@