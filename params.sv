// Verilog file to declare all the params 
package params;

//X x Y mesh size
logic mesh_Size_X;
logic mesh_Size_Y;

//no of bits to assign to x and y coordinates of the destination to be stored in flit header 
logic x_Des = clog2(mesh_Size_X);
logic y_Des = clog2(mesh_Size_Y);

//payload size of the header
logic head_Payloadsize = 16;

//Flit package size 
logic flit_Size = x_Des + y_Des + head_Payloadsize

//flit_Data_Label to label which type of flit data is it 
typedef enum logic [1:0] {HEAD, BODY, TAIL, HEADTAIL} flit_Data_Label;

//structure to store header data 
typedef struct packed
{
	logic [x_Des-1:0] x_Dest;
	logic [y_Des-1:0] y_Dest;
	logic [head_Payloadsize-1:0] head_Payload;
} packet_Head;

typedef struct packed 
{
	flit_Data_Label flit_DataLabel_inst;
	#for union only one data type can be accessed at a time as the storage is allocated only for one data type
	union packed 
	{
		packet_Header head_Data;
		logic [flit_Size-1:0] flit;
	}data;
} flit_Data;

endpackage		  	


