
`timescale 1ns/1ps

import  params_noc::*;
//include "params.sv";

module circular_Buffer_tb #(parameter BUFFER_SIZE = 8);


  int i, op_Num;
  logic clk;
  logic rst_n;
  logic read_i;
  logic write_i;
  flit_Data_noVC input_Data;
  flit_Data_noVC output_Data;
  flit_Data_noVC new_Flit;
  logic buf_empty;
  logic buf_full;
  logic buf_On_Off;

 //clock generation  
  always #1 clk = ~clk; 
 
initial begin 

clk = 1'b1;

end 
  initial begin 
    initialize();
    createflit();
    @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);
    write_i = 1'b1;
    input_Data = new_Flit;
    @(posedge clk);
    write_i = 1'b0;
    createflit();
    @(posedge clk);
    write_i = 1'b1;
    input_Data = new_Flit;
    @(posedge clk);
    write_i = 1'b0;
    read_i = 1'b1;
    $display("output data is %h", output_Data);
    @(posedge clk);
    read_i = 1'b0;
    rst_n = 1'b0;
    $finish();
  end 

 

  circular_Buffer #(.BUFFER_SIZE(BUFFER_SIZE)) cirbuf (.clk(clk), .rst_n(rst_n), .input_Data(input_Data), .output_Data(output_Data), .read_i(read_i), .write_i(write_i),
  .buf_empty(buf_empty), .buf_full(buf_full), .buf_On_Off(buf_On_Off));


  task initialize();
    rst_n   = 1'b0;
    i	    = 0;
    op_Num  = 0;
    write_i = 0;
    read_i  = 0;
  endtask

  task createflit();
    new_Flit.flit_DataLabel                    	<= HEAD;
    new_Flit.data.head_Data.x_Dest          <= {x_Des{op_Num}};
    new_Flit.data.head_Data.y_Dest          <= {y_Des{op_Num}};
    new_Flit.data.head_Data.head_Payload    <= {header_Payloadsize{op_Num}};
  endtask
 

endmodule