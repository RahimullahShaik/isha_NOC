import params_noc::*; 

//Status Buffer verilog code which tells us about the status of the current flit 
module status_Buffer #(parameter BUFFER_SIZE = 8)

(
  input clk,					                            //clk
  input rst_n,					                          //reset
  input read_i,					                          //read signal 
  input write_i,				                          //write signal
  output logic buf_empty,			                    //buffer empty
  output logic buf_full,			                    //buffer full
  output logic buf_On_Off,			                  //Buffer on and off signal 
  input flit_Data_noVC input_Data,	              //input flit without vc info
  output flit_Data_withvc output_Data,		        //output flit after being assigned to a vc 
  input inout_Port port_i,			                  //input port
  output inout_Port port_o,			                  //output port for the next hop we get the next hop info from the Route computation block 
  input [VC_Size-1:0] vc_New,			                //Vc allocation 
  input vc_Val,					                          //Vc valid 
  output logic vc_Req,				                    //Vc allocationn request
  output logic vc_Alloc,			                    //Vc allocation for the next flit sent to the upstream router 
  output logic switch_Req,			                  // switch allocation request
  output logic err,				                        //error
  output logic [VC_Size-1:0] downstream_Vc	      //signal to tell if vc is available in down stream router 
);

  
  logic [VC_Size-1:0] downstream_Vc_Next;
  logic read_Cmd, write_Cmd;
  logic end_Packet, end_Packet_Next;
  logic vc_Alloc_next;
  logic err_Next;
  flit_Data_noVC read_flit;
  inout_Port port_o_Next;
  
  typedef enum logic [1:0]{IDLE, VC, SWITCH} state_t;
  state_t p_state, nxt_state;

always@(posedge clk, negedge rst_n) begin 
  if(!rst_n)begin
    p_state 		<= IDLE;
    port_o  		<= LOCAL;
    downstream_Vc     	<= 0;
    end_Packet          <= 0;
    vc_Alloc    	<= 0;
    err             	<= 0;
  end
  else begin
    p_state 		<= nxt_state;
    port_o          	<= port_o_Next;
    downstream_Vc     	<= downstream_Vc_Next;
    end_Packet          <= end_Packet_Next;
    vc_Alloc    	<= vc_Alloc_next;
    err             	<= err_Next;
  end
end 
    

//Circular Buffer instantiation
circular_Buffer #(.BUFFER_SIZE(BUFFER_SIZE)) cirbuf (.clk(clk), .rst_n(rst_n), .input_Data(input_Data), .output_Data(output_Data), .read_i(read_i), .write_i(write_i),
  .buf_empty(buf_empty), .buf_full(buf_full), .buf_On_Off(buf_On_Off));

// //FSM logic 
 always@(*) begin 
   nxt_state = p_state;
   downstream_Vc_Next = downstream_Vc;
   read_i = 0
   write_i = 0
   end_Packet_Next = end_Packet


  case(p_state)
    IDLE: begin
      //if buffer is empty and the transaction is write and only if the flit is head or headtail, we should allocate it in buffer
      //the next hop output port is loaded  
      if((input_Data.flit_Data_Label = HEAD | input_Data.flit_Data_Label = HEADTAIL) & write_i & buf_empty)begin 
        nxt_state = VC;
        port_o_Next = port_o;
        write_Cmd = 1;
      end 
      //if the flit is Head's tail it means flit should end this is the last beat
      if(write_i & input_Data.flit_Data_Label = HEADTAIL) begin
        end_Packet = 1
      end


        end 
     VC: begin 
      end 
//     VC: begin 
//     end 
//     SWITCH: begin 
//     end 
   endcase
 end

endmodule