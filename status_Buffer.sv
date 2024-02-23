import params_noc::*;

//Status Buffer verilog code which tells us about the status of the current flit 
module status_Buffer #(parameter BUFFER_SIZE = 8)

(
  input clk,					//clk
  input rst_n,					//reset
  input read_i,					//read input signal 
  input write_i,				//write input signal
  output logic buf_empty,			//buffer empty
  output logic buf_full,			//buffer full
  output logic buf_On_Off,			//Buffer on and off threshold 
  input flit_Data_noVC input_Data,		//input flit
  output flit_Data_withvc output_Data,		//output flit 
  input inout_Port port_i;			//port input 
  output inout_Port port_o;			//port output 
  input [VC_Size-1:0] vc_New;			//Vc allocation 
  input vc_Val;					//Vc valid 
  output logic vc_Req;				//Vc allocationn request
  output logic vc_Alloc;			//Vc allocation for the next flit sent to the upstream router 
  output logic switch_Req;			// switch allocation request
  output logic err;				//error
  output logic [VC_Size-1:0] downstream_Vc;	//signal to tell if vc is available in down stream router 
);

typedef enum logic [1:0] { IDLE, VC, SWITCH } state;
state p_state, nxt_state;

always@(posedge clk, negedge rst_n) begin 
  if(!rst_n)begin
    p_state <= IDLE;
    
  else 
    p_state <= nxt_state;
end 
    

//Circular Buffer instantiation
circular_Buffer #(.BUFFER_SIZE(BUFFER_SIZE)) cirbuf (.clk(clk), .rst_n(rst_n), .input_Data(input_Data), .output_Data(output_Data), .read_i(read_i), .write_i(write_i),
  .buf_empty(buf_empty), .buf_full(buf_full), .buf_On_Off(buf_On_Off));

//FSM logic 
always@(*) begin 

case(state):

  default: begin 
    end 
  IDLE: begin 
    end 
  VC: begin 
    end 
  SWITCH: begin 
    end 

end

endmodule