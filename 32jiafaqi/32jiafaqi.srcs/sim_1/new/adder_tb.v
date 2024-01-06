//一位全加器测试代码
`timescale 1ns/1ns
module adder_tb;

    reg x;
	reg y;
	reg cin;
	wire f;
	wire cout;
		
	 adder adder(
	            .X(x),
	            .Y(y),
				.Cin(cin),
				.F(f),
				.Cout(cout)
			);

 initial begin 
    
	 x = 0;
	 y = 0;
	 cin = 0;
	 
  #5  x = 0;y = 1;cin = 1;
  #5  x = 1;y = 0;cin = 1;
  #5  x = 1;y = 0;cin = 0;	 
 end
endmodule 
