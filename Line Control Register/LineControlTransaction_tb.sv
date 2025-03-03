import my_package::*;

module LineControlTransaction_tb;
    reg         clk,         // Clock signal
    reg  [7:0]  data_in,     // Data to be loaded into the register
    wire [7:0] lcr      // Line Control Register output
    //////////////////////////////////////
  //AdvancedCounter DUT (clk,rst,en_inc,en_dec,load,hold,load_value,count);
  lcr_assertions Assert (.clk(clk),.lcr(lcr));
  integer error_count , correct_count;
  reg [3:0] load_value_prev;
  LineControlTransaction tr;
  //////////////////////////////////////
  initial begin
    $dumpfile("Waveform.vcd"); // Specify VCD file for waveform analysis
    $dumpvars(0, LineControlTransaction_tb); // Dump all variables
    error_count <= 0;
    correct_count <= 0;
    clk <= 1'b0;
    forever begin
      #5
      clk <= ~clk;
	  tr.clk = clk;
	  tr.lcr_value = lcr;
    end
  end
  //////////////////////////////////////
  initial begin
  tr = new();

  
  
    
    
    
  
  
  end

  task check_display(input [7:0] expected_LineControl, input [7:0] predicted_LineControl);
   
    if (expected_LineControl !== predicted_LineControl) begin
    error_count = error_count + 1;
      $display("%0t: An Error: Break Control Expected = %0d, Stick Parity Expected= %0d, Even Parity Expected= %0d, Parity Enable Expected = %0d, Stop Bits Expected = %0d, Word Length Expected = %0d",$realtime, expected_LineControl[6], expected_LineControl[5], expected_LineControl[4], expected_LineControl[3], expected_LineControl[2], expected_LineControl[1:0]);
      $display("Break Control Predicted = %0d, Stick Parity Predicted= %0d, Even Parity Predicted= %0d, Parity Enable Predicted = %0d, Stop Bits Predicted = %0d, Word Length Predicted = %0d",predicted_LineControl[6], predicted_LineControl[5], predicted_LineControl[4], predicted_LineControl[3], predicted_LineControl[2], predicted_LineControl[1:0]);
    end
    else 
    correct_count = correct_count + 1;
  endtask
  
endmodule