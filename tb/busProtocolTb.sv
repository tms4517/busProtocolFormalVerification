`default_nettype none
/* verilator lint_off UNUSED */

module busProtocolTb
#(parameter int unsigned AWIDTH = 8
, parameter int unsigned DWIDTH = 8
);

  logic clk_bus, clk_pkt;
  logic arst_n;
  logic req;
  logic readWrite_n;
  logic [AWIDTH-1:0] addr;
  logic [DWIDTH-1:0] wdata;
  logic addressAck;
  logic readAck;
  logic writeAck;

  te u_te
  ( .clk_pkt (clk_pkt)
  , .clk_bus (clk_bus)
  , .rst_n   (arst_n)

  , .bm_rdata ('0)
  , .bm_addr  ()
  , .bm_we    ()
  , .bm_wdata ()

  , .tc_req   (req)
  , .tc_rnw   (readWrite_n)
  , .tc_addr  (addr)
  , .tc_wdata (wdata)
  , .tc_aack  (addressAck)
  , .tc_wack  (writeAck)
  , .tc_rack  (readAck)
  , .tc_rdata ()

  , .da_wrdy    ('0)
  , .da_rrdy    ('0)
  , .da_req     ()
  , .da_rnw     ()
  , .da_bytecnt ()
  , .da_addr    ()
  , .da_wdata   ()
  , .da_rdata   ()

  , .pktib_sop  ('0)
  , .pktib_data ('0)
  , .pktob_sop  ()
  , .pktob_data ()
  );

  busProtocolAssertions u_busProtocolAssertions
  ( .i_clk    (clk_bus)
  , .i_arst_n (arst_n)

  , .i_req         (req)
  , .i_readWrite_n (readWrite_n)
  , .i_addressAck  (addressAck)
  , .i_writeAck    (writeAck)
  , .i_readAck     (readAck)
  );

endmodule

`resetall
