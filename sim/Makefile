TOP_MODULE   ?=
TB_SRC       ?=
XSIM_OPTIONS ?=

.PHONY: vsim xsim clean

vsim: $(TB_SRC)
	vsim $(VSIM_OPTIONS) -do 'do $@.tcl "$(TB_SRC)" $(TOP_MODULE)'

xsim: $(TB_SRC)
	xvhdl --2008 $(TB_SRC)
	xelab -debug typical -s top tb_$(TOP_MODULE)
	xsim $(XSIM_OPTIONS) -t xsim.tcl top -gui

clean:
	rm transcript *.wlf modelsim.ini *.log *.pb *.jou webtalk*.* *.wdb 2>/dev/null \
	rm -rf xsim.dir work .Xil 2>/dev/null