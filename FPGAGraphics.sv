
module FPGAGraphics (
	input wire logic clk_50,       // input clock (50 MHz)
	input wire logic rst
);


wire clk_pix;
wire clk_pix_locked;

clock_480p pxl_clk 
(
	.clk_50(clk_50),
	.rst(rst),
	.clk_pix(clk_pix),
	.clk_pix_locked(clk_pix_locked)
	
);

endmodule