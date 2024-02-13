
`timescale 1ns/1ps

//import  params_noc::*;
include "params.sv";

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

  
  initial begin 
    output_VCD();
    initialize();
    createflit();
    rst_n = 1'b1;
    @(posedge clk);
    write_i = 1'b1;
    input_Data = new_Flit;
    @(posedge clk);
    createflit();
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

  //clock generation  
  always #5 clk = ~clk;

  circular_Buffer #(.BUFFER_SIZE(BUFFER_SIZE)) cirbuf (.clk(clk), .rst_n(rst_n), .input_Data(input_Data), .output_Data(output_Data), .read_i(read_i), .write_i(write_i),
  .buf_empty(buf_empty), .buf_full(buf_full), .buf_On_Off(buf_On_Off));

  

  task output_VCD();
    //this is the file where simulation output will be dumped during the simulation
    $dumpfile ("circ_Buff_Out.vcd");
    //dump all the variables in the top level module here 0 represents the dumping mode i.e, it dumps the current values of the specified variables.
    //1: Dumps the changes to the specified variables since the last dump operation.
    $dumpvars (0, circular_Buffer_tb);
    for(i=0; i<BUFFER_SIZE; i++)
        $dumpvars (0, cirbuf.memory[i]);
    i=0;  
  endtask

  task initialize();
    clk     = 1'b1;
    rst_n   = 1'b0;
    i	    = 0;
    op_Num  = 0;
  endtask

  task createflit();
    new_Flit.flit_Data_Label                    <= HEAD;
    new_Flit.data.packet_Header.x_Dest          <= {x_Des{op_Num}};
    new_Flit.data.packet_Header.y_Dest          <= {y_Des{op_Num}};
    new_Flit.data.packet_Header.head_Payload    <= {header_Payloadsize{op_Num}};
  endtask
 

endmodule