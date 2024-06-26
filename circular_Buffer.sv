import params_noc::*;

module circular_Buffer #(parameter BUFFER_SIZE = 8)
(
	input flit_Data_noVC input_Data,		//input packet to the buf 
	input read_i,							//gets asserted if we are reading data from the buf
	input write_i,							//gets asserted if we are writing data to the buf 
	input clk,								//clock
	input rst_n,							//reset
	output flit_Data_noVC output_Data,		//output packet from the buf 
	output logic buf_empty,						//gets asserted when buf is empty
	output logic buf_full,						//gets asserted when buf is full
	output logic buf_On_Off						//signal to allow and disallow the incoming flits depending on the threshold set by us 
	);

localparam on_Off_threshold = 2;		//this is the threshold value which should, on and off the buffer i.e, if the count is 1 then we should
						//start accepting the flits and if the count is 7 then we should stop accepting the flits
localparam [31:0]pointer_Size = $clog2(BUFFER_SIZE);//pointer size of the buffer 

logic [pointer_Size-1:0] wr_Ptr;		//write pointer 
logic [pointer_Size-1:0] rd_Ptr;		//Read pointer 

logic [pointer_Size-1:0] wr_Ptr_Next;		//write pointer to be written next
logic [pointer_Size-1:0] rd_Ptr_Next;		//read pointer to be read next 

localparam buf_Depth = 1 << pointer_Size;	//FIFO depth 

//memory declaration
flit_Data_noVC memory[buf_Depth-1:0];

logic buf_Full_Next;		//Assers when the buf is becoming full in the next clock cycle
logic buf_Empty_Next;		//Asserts when the buf is becoming empty in the next clock cycle 
logic buf_On_Off_Next;		//status of buf whether it should be on or off in the next clock cycle 

logic [pointer_Size:0] num_Flits;		//number of flits in the buffer 
logic [pointer_Size:0] num_Flits_Next;	//number of flits in the buffer in the next clock cycle 

always@(posedge clk, negedge rst_n)begin 

	if(rst_n==0)begin 

		wr_Ptr 			<= 0;
		rd_Ptr 			<= 0;
		buf_full		<= 0;
		buf_empty		<= 1;
		num_Flits		<= 0;
		buf_On_Off		<= 1;

	end
	//if reset is deasserted then assigning the updated values to wr_Ptr, rd_Ptr, buf_full, buf_empty, num_Flits, buf_On_Off 
	else begin 
		
		wr_Ptr 			<= wr_Ptr_Next;
		rd_Ptr 			<= rd_Ptr_Next;
		buf_full		<= buf_Full_Next;
		buf_empty		<= buf_Empty_Next;
		num_Flits		<= num_Flits_Next;
		buf_On_Off		<= buf_On_Off_Next;
		if((read_i & write_i) | (~read_i & write_i & buf_full!=1))
			memory[wr_Ptr] <= input_Data;

	end 

end 

always_comb begin
	output_Data	= memory[rd_Ptr];
	unique if(read_i & ~write_i & ~buf_empty) begin
		//read flit from the buf when it is not empty 
		rd_Ptr_Next    = update_Ptr(rd_Ptr);
		wr_Ptr_Next    = wr_Ptr;
		buf_Empty_Next = isBufEmpty(rd_Ptr_Next, wr_Ptr);
		buf_Full_Next  = 0;
		num_Flits_Next = num_Flits - 1;
	end 
	//Write flit to a non empty buffer 
	else if (write_i & ~read_i & buf_full!=1) begin
		rd_Ptr_Next    = rd_Ptr;
		wr_Ptr_Next    = update_Ptr(wr_Ptr);
		buf_Empty_Next = 0;
		buf_Full_Next  = isBufFull(wr_Ptr_Next, rd_Ptr);
		num_Flits_Next = num_Flits + 1;
	end
	//Read Modify Write
	else if (write_i & read_i) begin
		rd_Ptr_Next    = update_Ptr(rd_Ptr);
		wr_Ptr_Next    = update_Ptr(wr_Ptr);
		buf_Empty_Next = buf_empty;
		buf_Full_Next  = buf_full;
		num_Flits_Next = num_Flits;
	end
        else begin 
                rd_Ptr_Next    = rd_Ptr;
		wr_Ptr_Next    = wr_Ptr;
		buf_Empty_Next = buf_empty;
		buf_Full_Next  = buf_full;
		num_Flits_Next = num_Flits;
        end

	//on_Off Algorithm logic, buffer is turned on when number of flits is less than threshold 
	if((num_Flits_Next < num_Flits) & (num_Flits_Next < on_Off_threshold)) begin 
		buf_On_Off_Next = 1;
	end
	//Buffer turned off when number of flits is greater than the threshold 
	else if ((num_Flits_Next > num_Flits) & (num_Flits_Next > BUFFER_SIZE - on_Off_threshold)) begin
		buf_On_Off_Next = 0;
	end
	else begin
		buf_On_Off_Next = buf_On_Off;
	end
end

function logic[pointer_Size-1:0] update_Ptr(input logic [pointer_Size:0]ptr);
begin 
	if(ptr == BUFFER_SIZE-1)
		ptr = 0;
	else 
		ptr = ptr + 1;
end 
return ptr;
endfunction 


function logic isBufFull(input logic [pointer_Size:0]rd_Ptr, input logic [pointer_Size:0]wr_Ptr_Next); begin 
	if(wr_Ptr_Next == rd_Ptr)
		buf_Full_Next = 1;
	else 
		buf_Full_Next = 0;
end
return buf_Full_Next;
endfunction

function logic isBufEmpty(input logic [pointer_Size:0]rd_Ptr_Next, input logic [pointer_Size:0]wr_Ptr); begin
	if(wr_Ptr == rd_Ptr_Next)
		buf_Empty_Next = 1;
	else 
		buf_Empty_Next = 0;
end
return buf_Empty_Next;
endfunction 

endmodule 

