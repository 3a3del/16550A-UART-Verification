module lcr_assertions(
    input  bit        clk,
    output  logic [7:0]  lcr   // LCR register value
);
  //--------------------------------------------------------------------------
  // Property: Word Length [1:0] must be one of the valid values.
  // '00': 5 bits, '01': 6 bits, '10': 7 bits, '11': 8 bits.
  //--------------------------------------------------------------------------
  property valid_word_length_prop;
    @(posedge clk)
    (lcr[1:0] inside {2'b00, 2'b01, 2'b10, 2'b11});
  endproperty

  assert property (valid_word_length_prop)
    else $error("LCR: Invalid word length (bits [1:0] must be 00, 01, 10, or 11)");

  //--------------------------------------------------------------------------
  // Property: Reserved bit (bit 7) must always be 0.
  //--------------------------------------------------------------------------
  property reserved_bit_prop;
    @(posedge clk)
      (lcr[7] == 1'b0);
  endproperty

  assert property (reserved_bit_prop)
    else $error("LCR: Reserved bit (bit 7) is not 0");

  //--------------------------------------------------------------------------
  // Helper function: Compute encoded effective stop bits.
  // Encoding:
  //   1 stop bit    -> 2'd1
  //   1.5 stop bits -> 2'd2
  //   2 stop bits   -> 2'd3
  //--------------------------------------------------------------------------
  function automatic logic [1:0] expected_stop_bits(input logic [7:0] lcr_val);
    if (lcr_val[2] == 1'b0)
      expected_stop_bits = 2'd1;          // 1 stop bit
    else if (lcr_val[1:0] == 2'b00)
      expected_stop_bits = 2'd2;          // 1.5 stop bits for 5-bit characters
    else
      expected_stop_bits = 2'd3;          // 2 stop bits for 6,7,8-bit characters
  endfunction

  //--------------------------------------------------------------------------
  // Property: If bit 2 is 0, then effective stop bits must be 1 stop bit.
  //--------------------------------------------------------------------------
  property stop_bits_prop1_OneStopBit;
    @(posedge clk)
      (lcr[2] == 1'b0) |-> (expected_stop_bits(lcr) == 2'd1);
  endproperty

  assert property (stop_bits_prop1_OneStopBit)
    else $error("LCR: Stop bits assertion failed (expected 1 stop bit when lcr[2]==0)");

  //--------------------------------------------------------------------------
  // Property: If bit 2 is 1 and word length is 5 bits, then effective stop bits
  // must be 1.5 stop bits.
  //--------------------------------------------------------------------------
  property stop_bits_prop2_HalfOneStopBit;
    @(posedge clk)
      ((lcr[2] == 1'b1) && (lcr[1:0] == 2'b00)) |-> (expected_stop_bits(lcr) == 2'd2);
  endproperty

  assert property (stop_bits_prop2_HalfOneStopBit)
    else $error("LCR: Stop bits assertion failed (expected 1.5 stop bits for 5-bit character)");

  //--------------------------------------------------------------------------
  // Property: If bit 2 is 1 and word length is NOT 5 bits, then effective stop
  // bits must be 2 stop bits.
  //--------------------------------------------------------------------------
  property stop_bits_prop3_TwoStopBit;
    @(posedge clk)
      ((lcr[2] == 1'b1) && (lcr[1:0] != 2'b00)) |-> (expected_stop_bits(lcr) == 2'd3);
  endproperty

  assert property (stop_bits_prop3_TwoStopBit)
    else $error("LCR: Stop bits assertion failed (expected 2 stop bits for 6-,7-,8-bit character)");


//	Bit 5	Bit 4	Bit 3	Parity Select
//	X		X	0	No Parity
//	0		0	1	Odd Parity
//	0		1	1	Even Parity
//	1		0	1	High Parity (Sticky)
//	1		1	1	Low Parity (Sticky)  
    property odd_parity_without_stick;
    @(posedge clk)
      ((lcr[3] == 1'b1) && (lcr[4] == 1'b0)&& (lcr[5] == 1'b0)) |-> (^lcr == 1'd0);
  endproperty

  assert property (odd_parity_without_stick)
    else $error("Odd Parity without stick parity failed");  
    /////////////////////////////////////////////
    property even_parity_without_stick;
    @(posedge clk)
      ((lcr[3] == 1'b1) && (lcr[4] == 1'b1)&& (lcr[5] == 1'b0)) |-> (^lcr == 1'd1);
  endproperty

  assert property (odd_parity_without_stick)
    else $error("Even Parity without stick parity failed");   
    /////////////////////////////////////////////
    property odd_parity_with_stick;
    @(posedge clk)
      ((lcr[3] == 1'b1) && (lcr[4] == 1'b0) && (lcr[5] == 1'b1)) |-> (^lcr == 1'd1);
  endproperty

  assert property (odd_parity_with_stick)
    else $error("Odd Parity with stick parity failed");    
     /////////////////////////////////////////////
    property even_parity_with_stick;
    @(posedge clk)
      ((lcr[3] == 1'b1) && (lcr[4] == 1'b1)&& (lcr[5] == 1'b1)) |-> (^lcr == 1'd0);
  endproperty

  assert property (odd_parity_without_stick)
    else $error("Even Parity with stick parity failed");    
    
    
    
endmodule
