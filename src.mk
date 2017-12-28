
XDC_SRC_REL  += \
              $(BUILD_DIR)/arty-z7.xdc

VHDL_SRC_REL += \
              $(SRC_DIR)/sync_dff.vhd \
              $(SRC_DIR)/rst_bridge.vhd \
              $(SRC_DIR)/oserdes_ddr_10_1.vhd \
              $(SRC_DIR)/tmds_encoder.vhd \
              $(SRC_DIR)/dvi_tx_clkgen.vhd \
              $(SRC_DIR)/rgb_pattern.vhd \
              $(SRC_DIR)/rgb_timing.vhd \
              $(SRC_DIR)/rgb_to_dvi.vhd \
              $(SRC_DIR)/dvi_tx.vhd \

TB_SRC_REL   += \
              $(VHDL_SRC_REL) \
              $(SIM_DIR)/tb_dvi_tx.vhd \

