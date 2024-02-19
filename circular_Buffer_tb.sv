
`timescale 1ns/1ps

import  params_noc::*;
//include "params.sv";

module circular_Buffer_tb #(parameter BUFFER_SIZE = 8);

  int i, j, op_Num;
  logic clk;
  logic rst_n;
  logic read_i;
  logic write_i;
  flit_Data_noVC input_Data;
  flit_Data_noVC output_Data;
  flit_Data_noVC flit_read;
  flit_Data_noVC flit_write;
  flit_Data_noVC new_Flit;
  flit_Data_noVC flit_Queue[$];
  logic buf_empty;
  logic buf_full;
  logic buf_On_Off;

 //clock generation  
  always #1 clk = ~clk; 
 

//Simple test case 
  /*initial begin 
    initialize();
    createflit();
    @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);
    write_i = 1'b1;
    input_Data = new_Flit;
    @(posedge clk);
    write_i = 1'b0;
    createflit1();
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
  end*/ 

initial begin 

  initialize();
  @(posedge clk);
  rst_n = 1'b1;
  fork 
    $display("started doing randomn operations");
    repeat(5) rand_Op();
  join 
  $display("Finished performing the tasks");
  $finish();
   
end
 

  circular_Buffer #(.BUFFER_SIZE(BUFFER_SIZE)) cirbuf (.clk(clk), .rst_n(rst_n), .input_Data(input_Data), .output_Data(output_Data), .read_i(read_i), .write_i(write_i),
  .buf_empty(buf_empty), .buf_full(buf_full), .buf_On_Off(buf_On_Off));

//performing randomn operations 
  task rand_Op();
    j = $urandom_range(0,10);
    if(j==8)
      read_Flit();
    else if(j>=3 & j<8)
      write_Flit();
    else 
      read_Write_Flit();
  endtask
  
//Reading Flit
  task read_Flit();
    flit_read = flit_Queue.pop_front();
    @(posedge clk);
    read_i = 1;
    write_i= 0;
    op_Num = op_Num + 1;
    @(negedge clk);
    flit_Verify(); 
  endtask

//Writing Flit
  task write_Flit();
    createflit();
    @(posedge clk);
    read_i = 0;
    write_i= 1;
    input_Data = new_Flit;
    flit_Queue.push_back(new_Flit);
    op_Num = op_Num + 1;
  endtask

//Read Write Flit
  task read_Write_Flit();
    flit_read = flit_Queue.pop_front();
    createflit1();
    @(posedge clk);
    read_i = 1;
    write_i= 1;
    input_Data = new_Flit;
    flit_Queue.push_back(new_Flit);
    op_Num = op_Num + 1;
    @(negedge clk);
    flit_Verify(); 
  endtask

  task initialize();
    clk = 1'b1;
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
  
  task createflit1();
    new_Flit.flit_DataLabel                    	<= BODY;
    new_Flit.data.head_Data.x_Dest          <= {5{op_Num}};
    new_Flit.data.head_Data.y_Dest          <= {5{op_Num}};
    new_Flit.data.head_Data.head_Payload    <= {header_Payloadsize{op_Num}};
  endtask
  
  task flit_Verify();
    if(flit_read == output_Data)
      $display("We got correct output as %h = %h",flit_read, output_Data);
    else 
      $display("Incorrect output as %h != %h", flit_read, output_Data);
  endtask

endmodule