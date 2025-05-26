`timescale 1ns/1ps;
import params_noc::*;
module Status_buf_tb #(parameter BUFFER_SIZE = 8);


//instantiating status buffer module
status_Buffer #(.BUFFER_SIZE(BUFFER_SIZE))stbuf (.clk(clk),rst_n(rst_n), .read_i(read_i), .write_i(write_i), .buf_empty(buf_empty), .buf_full(buf_full),
.buf_On_Off(buf_On_Off), .input_Data(input_Data), .output_Data(output_Data), .port_i(port_i), .port_o(port_o), .vc_New(vc_New), .vc_Val(vc_Val),
.vc_Req(vc_Req), .vc_Alloc(vc_Alloc), .switch_Req(switch_Req), .err(err), .downstream_Vc(downstream_Vc));

always #5 clk = ~clk;

initial begin 


end 

endmodule