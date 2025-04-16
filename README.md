# Formal verification of a bus protocol

In this repository the interface of a module blackboxed is formally verified.

Formal verification employs mathematical analysis to explore the entire space of
possible simulations. Properties are defined to specify the design behavior, and
assertions are used to instruct the formal tool to verify that these properties
always hold true.

# HDL

The Transfer Engine `te.sv` is interfaced by a bus protocol. For the purpose of
this exercise, the internal functionality of the Transfer Engine is not
important and has been blackboxed.

The figure below depicts this.

![te](docs/te.svg)

## Bus protocol


## TB

`busProtocolTb.sv` is the top level Tb module. The module instances the DUT and
`busProtocolAssertions.sv` which contains the properties and assertions.
The top level Tb drives the inputs of both submodules and connects the output of
the DUT to the respective inputs of `frameAssertions.sv`.

`busProtocolAssertions.sv` contains ONLY synthesizable auxillary logic i.e does
not contain implication operators or time delays.

Note: Properties were written in this manner as Verilator has limited support
for the `property` keyword. However, they can be replaced to the widely used
method eg -

```
property <prop_propertyName>
  @(posedge i_clk) <assert_aseertionName>
endproperty

assert property(<prop_propertyName>);
```

# Makefile

Prerequisites: Verilator, JasperGold FPV

Lint TB and design: `make lint`

Formally verify assertions: `make formal` (all assertions should pass).
