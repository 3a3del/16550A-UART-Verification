package my_package;
// LCR 0xc 8 R/W Line Control Register
// the LCR defines the character length, stop bits, and parity options, and even provides a break control function.
	class LineControlTransaction;
  // Randomized 8-bit LCR value:
  // Bit assignments (for example):
  // [1:0] - Word Length (00: 5 bits, 01: 6 bits, 10: 7 bits, 11: 8 bits)
  // [2]   - Stop Bits (0: 1 stop bit, 1: 2 stop bits)
  // [3]   - Parity Enable (0: disabled, 1: enabled)
  // [4]   - Even Parity (if parity enabled; 0: odd, 1: even)
  // [5]   - Stick Parity
  // [6]   - Break Control
  rand reg  [7:0]  data_in, 
  rand logic [7:0] lcr_value;
  bit clk;
  // Constraint: force the word-length field to one of the 4 valid values.
  constraint valid_word_length {
    lcr_value[1:0] inside {2'b00, 2'b01, 2'b10, 2'b11};
  }
  constraint reserved_bit_c {
    lcr_value[7] == 1'b0; // so that it is never randomized to an illegal value
  }
    
    covergroup lcr_cg @(posedge clk);
    // Word Length coverpoint (bits [1:0])
    cp_word_length: coverpoint lcr_value[1:0] {
      bins word_5 = {2'b00};
      bins word_6 = {2'b01};
      bins word_7 = {2'b10};
      bins word_8 = {2'b11};
    }
    // Stop Bits coverpoint (bit 2)
      cp_stop_bits: coverpoint ( (lcr_value[2]==1'b0) ? 2 : ((lcr_value[1:0] == 2'b00) ? 3 : 4) ) {
        bins one_stop = {2};
        bins one_half_stop = {3};
        bins two_stop = {4};
    }
    // Parity Enable coverpoint (bit 3)
    cp_parity_enable: coverpoint lcr_value[3] {
      bins parity_disabled = {1'b0};
      bins parity_enabled  = {1'b1};
    }
    // Even Parity Select coverpoint (bit 4)
    cp_even_parity: coverpoint lcr_value[4] {
      bins odd_parity  = {1'b0};
      bins even_parity = {1'b1};
    }
    // Stick Parity coverpoint (bit 5)
    cp_stick_parity: coverpoint lcr_value[5] {
      bins stick_disabled = {1'b0};
      bins stick_enabled  = {1'b1};
    }
    // Break Control coverpoint (bit 6)
    cp_break_ctrl: coverpoint lcr_value[6] {
      bins break_off = {1'b0};
      bins break_on  = {1'b1};
    }

      cp_parity_cross: cross cp_even_parity, cp_stick_parity,cp_parity_enable {
        bins Even_Parity_Selected_only = binsof(cp_parity_enable.parity_enabled) && binsof(cp_even_parity.even_parity) &&                                                  binsof(cp_stick_parity.stick_disabled);
        bins Odd_Parity_Selected_only = binsof(cp_parity_enable.parity_enabled) && binsof(cp_even_parity.odd_parity) &&                                                  binsof(cp_stick_parity.stick_disabled);        
        bins Even_Parity_stick_Selected = binsof(cp_parity_enable.parity_enabled) && binsof(cp_even_parity.even_parity) &&                                                  binsof(cp_stick_parity.stick_enabled);        
        bins Odd_Parity_stick_Selected = binsof(cp_parity_enable.parity_enabled) && binsof(cp_even_parity.odd_parity) &&                                                  binsof(cp_stick_parity.stick_enabled);         
      }
  endgroup

  // Constructor: create the covergroup instance
  function new();
    lcr_cg = new();
  endfunction
endclass
endpackage