//四位并行进位加法器测试代码
`timescale 1ns/1ns
module adder_4_tb;

    reg [4:1] x;
	reg [4:1] y;
	reg c0;
	wire c4;
	wire [4:1] F;
	integer i,j;

  adder_4 adder_4(
	  .x(x),
	  .y(y),
	  .c0(c0),
	  .c4(c4),
	  .F(F),
	  .Pm(),
	  .Gm()
  );
  
  
  initial begin
    x = 4'd0; y = 4'd0; c0 = 0;
	 
	#5;
	for (i = 0; i < 16; i = i + 1)begin
	    for (j = 0 ; j < 16; j = j + 1) begin
		     y = y + 1;
			  #5;
		 end
		 
		 x = x + 1;
		 #5;
	end	
	
	#5; c0 = 1; x = 4'd0; y = 4'd0;
	for (i = 0; i < 16; i = i + 1)begin
	    for (j = 0 ; j < 16; j = j + 1) begin
		     y = y + 1;
			  #5;
		 end
		 
		 x = x + 1;
		 #5;
	end
	$stop;   
  end
endmodule 
