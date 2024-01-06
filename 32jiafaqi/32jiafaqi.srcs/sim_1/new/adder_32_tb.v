`timescale  1ns/1ns
module adder32_tb;

  reg [32:1] A;
  reg [32:1] B;
  wire [32:1] S;
  wire c32;
 
  adder32 adder_32(
        .X(A),
		  .Y(B),
		  .S(S),
		  .c32(c32)
		 );
		 
  initial begin
     A = 32'd0; B = 32'd0;
	 for (A = 32'd15; A <= 32'd294967296; A = A * 32'd16) begin
      for (B = 32'd15; B <= 32'd294967296; B = B * 32'd16) begin
        #5; 
      end
     end
	
  end
endmodule 
