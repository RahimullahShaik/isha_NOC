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
  input [VC_Size-1:0] vc_New,			                //New vc available at the downstream router for allocation 
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
circular_Buffer #(.BUFFER_SIZE(BUFFER_SIZE)) cirbuf (.clk(clk), .rst_n(rst_n), .input_Data(input_Data), .output_Data(output_Data), .read_i(read_Cmd), .write_i(write_Cmd),
  .buf_empty(buf_empty), .buf_full(buf_full), .buf_On_Off(buf_On_Off));

// //FSM logic 
 always@(*) begin 
   nxt_state = p_state;
   downstream_Vc_Next = downstream_Vc;
   read_Cmd = 0;
   write_Cmd = 0;
   end_Packet_Next = end_Packet;
   vc_Alloc_next = 0;
   switch_Req = 0;
   port_o_Next = port_o;
   err_Next = 0; 



  case(p_state)
    IDLE: begin
      //if buffer is empty and the transaction is write and only if the flit is head or headtail, we should be in IDLE state and allocate the data into the circular buffer
      if((input_Data.flit_Data_Label = HEAD | input_Data.flit_Data_Label = HEADTAIL) & write_i & buf_empty)begin 
        nxt_state = VC;
        port_o_Next = port_o;
        write_Cmd = 1;
      end 
      //if the flit is Head's tail it means flit should end this is the last beat
      if(write_i & input_Data.flit_Data_Label = HEADTAIL) begin
        end_Packet = 1;
      end

      //if vc_Val gets asserted which should ideally get asserted in vc allocation state or if we are trying to read from the buffer or if the buffer is empty or if the 
      //flits are Body and tail then err should be asserted.
      if(vc_Val | read_i | ~buf_empty | ((input_Data.flit_Data_Label = BODY | input_Data.flit_Data_Label = TAIL) & write_i)) begin
        err_Next = 1;
      end
          end

    //start the vc allocation and wait for the body and tail packets to arrive  
     VC: begin 
      vc_Req = 1;                   //sending vc allocation request to vc allocator module to get the next available free vc at the downstream router
      if() 
      if(input_Data.flit_Data_Label = HEAD)
        err = 1;
      end  
      if
    SWITCH: begin 
      end 
   endcase
 end

endmodule