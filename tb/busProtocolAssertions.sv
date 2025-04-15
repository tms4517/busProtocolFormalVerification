`default_nettype none

  module busProtocolAssertions
  ( input var logic i_clk
  , input var logic i_arst_n

  , input var logic i_req
  , input var logic i_readWrite_n          // Read = '1, Write = '0
  , input var logic i_addressAck
  , input var logic i_readAck
  , input var logic i_writeAck
  );

  // {{{ Stimulus
  // {{{ Auxiliary logic
  // Track the number of pending read transactions.
  logic [2:0] pendingReadTransactions_d, pendingReadTransactions_q;

  always_ff @(posedge i_clk, negedge i_arst_n)
    if (!i_arst_n)
      pendingReadTransactions_q <= '0;
    else
      pendingReadTransactions_q <= pendingReadTransactions_d;

  always_comb
    if (i_req && i_readWrite_n && i_addressAck && !i_readAck)
      pendingReadTransactions_d = pendingReadTransactions_q + 1'b1;
    else if (!(i_req && i_readWrite_n && i_addressAck) && i_readAck)
      pendingReadTransactions_d = pendingReadTransactions_q - 1'b1;
    else
      pendingReadTransactions_d = pendingReadTransactions_q;

  // Track the number of pending write transactions.
  logic [2:0] pendingWriteTransactions_d, pendingWriteTransactions_q;

  always_ff @(posedge i_clk, negedge i_arst_n)
    if (!i_arst_n)
      pendingWriteTransactions_q <= '0;
    else
      pendingWriteTransactions_q <= pendingWriteTransactions_d;

  always_comb
    if (i_req && !i_readWrite_n && i_addressAck && !i_writeAck)
      pendingWriteTransactions_d = pendingWriteTransactions_q + 1'b1;
			else if (!(i_req && !i_readWrite_n && i_addressAck) && i_writeAck)
      pendingWriteTransactions_d = pendingWriteTransactions_q - 1'b1;
    else
      pendingWriteTransactions_d = pendingWriteTransactions_q;

  logic [2:0] pendingTransactions;

  always_comb
    pendingTransactions =pendingReadTransactions_q + pendingWriteTransactions_q;
  // }}} Auxiliary logic

  // 'addressAck' should only be asserted if the pipeline is not full.
  // NOTE: There is a genuine bug in the RTL.
  logic assert_addressAckWhenPipelineNotFull;

  always_comb
    assert_addressAckWhenPipelineNotFull =
      |{!i_arst_n
      , !i_addressAck
      , i_addressAck && (pendingTransactions <= 3'd4)
      };

  assert property (@(posedge i_clk) assert_addressAckWhenPipelineNotFull);

  // 'readAck' should only be asserted if there are pending read transactions.
  logic assert_readAckOnlyWhenPendingReadTransactions;

  always_comb
    assert_readAckOnlyWhenPendingReadTransactions =
      |{!i_arst_n
      , !i_readAck
      , i_readAck && (pendingReadTransactions_q != '0)
      };

  assert property (@(posedge i_clk) assert_readAckOnlyWhenPendingReadTransactions);

  // 'writeAck' should only be asserted if there are pending write transactions
  // or a write transaction is taking place on the same cycle.
  logic assert_witeAckOnlyWhenPendingWriteTransactions;

  always_comb
    assert_witeAckOnlyWhenPendingWriteTransactions =
    |{!i_arst_n
    , !i_writeAck
    , i_writeAck && (pendingWriteTransactions_q != '0)
    , i_writeAck && i_addressAck && i_req && !i_readWrite_n
    };

  assert property (@(posedge i_clk) assert_witeAckOnlyWhenPendingWriteTransactions);
  // }}} Stimulus

  // {{{ Response
  // {{{ If the bus is requested, eventually it must be acknowledged.
  logic reqReceived_q;

  always_ff @(posedge i_clk, negedge i_arst_n)
    if (!i_arst_n)
      reqReceived_q <= '0;
    else if (i_req)
      reqReceived_q <= '1;
    else
      reqReceived_q <= reqReceived_q;

  logic addressAckAfterReqReceived_q, addressAckAfterReqReceived_d;

  always_ff @(posedge i_clk, negedge i_arst_n)
    if (!i_arst_n)
      addressAckAfterReqReceived_q <= '0;
    else
      addressAckAfterReqReceived_q <= addressAckAfterReqReceived_d;

  always_comb
    if (reqReceived_q && i_addressAck)
      addressAckAfterReqReceived_d = '1;
    else
      addressAckAfterReqReceived_d = addressAckAfterReqReceived_q;

  logic assert_reqAcknowledged;

  always_comb
    assert_reqAcknowledged = |{!i_arst_n
                             , !reqReceived_q
                             , reqReceived_q && !i_addressAck
                             , i_addressAck
                             , addressAckAfterReqReceived_q
                             };

  assert property (@(posedge i_clk) assert_reqAcknowledged);
  // }}} If the bus is requested, eventually it must be acknowledged.

  // {{{ If a read transaction is in flight then eventually read acknowledge
  // should be asserted.
  logic readTransactionAcknowledged_q;

  always_ff @(posedge i_clk, negedge i_arst_n)
    if (i_arst_n)
      readTransactionAcknowledged_q <= '0;
    else if ((pendingReadTransactions_q != 0) && i_readAck)
      readTransactionAcknowledged_q <= '1;
    else
      readTransactionAcknowledged_q <= readTransactionAcknowledged_q;

  logic assert_readTransactionAcknowledged;

  always_comb
    assert_readTransactionAcknowledged =
      |{!i_arst_n
      , (pendingReadTransactions_q == 0)
      , (pendingReadTransactions_q != 0) && !i_readAck
      , i_readAck
      , readTransactionAcknowledged_q
      };

  assert property (@(posedge i_clk) assert_readTransactionAcknowledged);
  // }}} If a read transaction is in flight then eventually read acknowledge
  // should be asserted.

  // {{{ If a write transaction is in flight then eventually write acknowledge
  // should be asserted.
  logic writeTransactionAcknowledged_q;

  always_ff @(posedge i_clk, negedge i_arst_n)
    if (i_arst_n)
      readTransactionAcknowledged_q <= '0;
    else if ((pendingWriteTransactions_q != 0) && i_writeAck)
      writeTransactionAcknowledged_q <= '1;
    else
      writeTransactionAcknowledged_q <= writeTransactionAcknowledged_q;

  logic assert_writeTransactionAcknowledged;

  always_comb
    assert_writeTransactionAcknowledged =
      |{!i_arst_n
      , (pendingWriteTransactions_q == 0)
      , (pendingWriteTransactions_q != 0) && !i_writeAck
      , i_writeAck
      , writeTransactionAcknowledged_q
      };

  assert property (@(posedge i_clk) assert_writeTransactionAcknowledged);
  // }}} If a write transaction is in flight then eventually write acknowledge
  // should be asserted.
  // }}} Response

  endmodule

`resetall
