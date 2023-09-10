import params;
module circular_Buffer #(parameter buf_Size=8)(

	input flit_Data input_Data;		//input packet to the buf 
	input read_i;				//gets asserted if we are reading data from the buf
	input write_i;				//gets asserted if we are writing data to the buf 
	input clk;				//clock
	input rst;				//reset
	output flit_Data output_Data;		//output packet from the buf 
	output buf_empty;			//gets asserted when buf is empty
	output buf_full;			//gets asserted when buf is full
	output buf_On_Off;			//signal to allow and disallow the incoming flits depending on the threshold set by us 
	);


