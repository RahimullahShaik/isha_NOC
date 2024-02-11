
`timescale 1ns/1ps

import  params::*;

module circular_Buffer_tb #(parameter BUFFER_SIZE = 8);

  logic clk;
  logic rst_n;
  logic read_i;
  logic write_i;
  flit_Data_noVC input_Data;
  flit_Data_noVC output_Data;
  logic buf_empty;
  logic buf_full;


  //clock generation  
  always #5 clk = ~clk;

  circular_Buffer #(.BUFFER_SIZE(BUFFER_SIZE)) cirbuf (.clk(clk), .rst_n(rst_n), .input_Data(input_Data), .output_Data(output_Data), .read_i(read_i), .write_i(write_i),
  .buf_empty(buf_empty), .buf_full(buf_full), .buf_On_Off(buf_On_Off));


endmodule