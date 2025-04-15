clear -all

# Load and analyze the RTL & TB.
analyze -v2k -f_relative_to_file_location hdl/te.f +incdir+hdl/ +libext+.vlib -y hdl/
analyze -sv tb/busProtocolTb.sv tb/busProtocolAssertions.sv

# Synthesize the RTL and read the netlist.
elaborate -top busProtocolTb

clock clk_bus
clock clk_pkt

reset !arst_n

# Prove all properties.
prove -all
