lint:
	verilator --lint-only -Wall tb/busProtocolAssertions.sv

formal:
	jg jg/jg.tcl &

clean:
	rm -rf jgproject
