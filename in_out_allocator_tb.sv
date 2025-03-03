import params_noc::*;
`timescale 1ns/1ps

module in_out_allocator_tb#(parameter vc_Num =4);

    logic clk, rst_n;                                               //clock, reset
    logic [in_Port_Cnt-1:0][vc_Num-1:0] request_in;                 //input port
    inout_Port [vc_Num-1:0] out_port_cmd [in_Port_Cnt-1:0];             //output port
    localparam [31:0] AGENTS_PTR_SIZE_IN = $clog2(vc_Num);          //
    localparam [31:0] AGENTS_PTR_SIZE_OUT = $clog2(in_Port_Cnt);
    logic [in_Port_Cnt-1:0][AGENTS_PTR_SIZE_IN-1:0] curr_highest_priority_vc, next_highest_priority_vc;
    logic [in_Port_Cnt-1:0][AGENTS_PTR_SIZE_OUT-1:0] curr_highest_priority_ip, next_highest_priority_ip;   
    logic [in_Port_Cnt-1:0][vc_Num-1:0] vc_grant_gen;
    logic [in_Port_Cnt-1:0][in_Port_Cnt-1:0] ip_grant_gen; 
    logic [in_Port_Cnt-1:0][in_Port_Cnt-1:0] out_request_gen;
    logic [in_Port_Cnt-1:0][vc_Num-1:0] grant_o_gen;
    wire [in_Port_Cnt-1:0][vc_Num-1:0] grants;
    inout_Port [in_Port_Cnt-1:0] ports = {LOCAL, NORTH, SOUTH, WEST, EAST};

  always #5 clk= ~clk;

  in_out_allocator(.vc_Num(vc_Num)) iobuff (.clk(clk), .rst_n(rst_n), .request_in(request_in), .inports_Out(out_port_cmd), .grant_o(grants);)
endmodule

