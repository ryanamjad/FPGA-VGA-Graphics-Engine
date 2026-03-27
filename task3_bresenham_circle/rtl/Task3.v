module Task3(KEY, CLK50, SW, VGA_R, VGA_G, VGA_B,
				 VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);

	parameter xc = 80, yc = 60;//as given in question
	parameter BLK = 3'b000;

	input [3:0] KEY;
	input [9:0] SW;
	input CLK50;
	wire RST = KEY[0];
	wire [5:0] RAD = (SW[8:3]>59)? 59:SW[8:3];
	wire str;
	wire clr_in;
	assign clr_in = SW [2:0];
	assign str  = KEY[3];
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK_N;
	output VGA_SYNC_N;
	output VGA_CLK;
	output [9:0] VGA_R;
	output [9:0] VGA_G;
	output [9:0] VGA_B;

	
	reg [7:0] x;
	reg [6:0] y;
	reg fg;
	reg row_fg;
	reg [7:0] xr;
	reg [6:0] yr;
	reg signed [8:0] d;
	reg blank_fg;
	reg [2:0] COLOR;
	reg draw;
	
	
	vga_adapter VGA(
			.resetn(RST),
			.clock(CLK50),
			.colour(COLOR),
			.x(x),
			.y(y),
			.plot(draw),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";
	
	
	reg [3:0]	STATE;
//State declaration
	parameter RESET = 0, BLANK = 1, HOLD = 2, INITIAL = 3,STOP = 4,
				 STATE1 = 5,
				 STATE2 = 6,
				 STATE3 = 7,
				 STATE4 = 8,
				 STATE5 = 9,
				 STATE6 = 10,
				 STATE7 = 11,
				 STATE8 = 12;

//this determines the next state
	always @ (posedge CLK50 or negedge RST) begin
		if (~RST)
			STATE <= RST;
			
		else
			case (STATE)
				RESET:
				begin
					STATE <= BLANK;	
				end
					
				BLANK:
				begin
					if (blank_fg)
						STATE <= STOP;
					else					
						STATE <= BLANK;	
				end
					
				STOP:
				begin
					if ((xr <= yr) & ~str)
						STATE <= INITIAL;
					else
						STATE <= STOP;
				end
				
				INITIAL:
				begin
					STATE <= STATE1;
				end
				
				HOLD:
				begin
					if (xr > yr)
						STATE <= STOP;
					else
						STATE <= STATE1;
				end
				
				STATE1: STATE <= STATE2;
				STATE2: STATE <= STATE3;
				STATE3: STATE <= STATE4;
				STATE4: STATE <= STATE5;
				STATE5: STATE <= STATE6;
				STATE6: STATE <= STATE7;
				STATE7: STATE <= STATE8;
				STATE8: 
				begin
					if (xr > yr)
						STATE <= STOP;
					else
						STATE <= STATE1;
				end
				
				default: STATE <= RESET;
				
			endcase
	end
	
	always @ (posedge CLK50) begin
	
		row_fg <= x / 159;
		
		case (STATE)
		RESET:
		begin
			fg <= 0;
			row_fg <= 0;
			blank_fg <= 0;
			x <= 0;
			y <= 0;
			draw <= 0;
			
			xr <= 0;
			yr <= RAD;
			d <= 3 - 2*RAD;
		end
		
		INITIAL:
		begin
			xr <= 0;
			yr <= RAD;
			d <= 3 - 2*RAD;
			draw <= 0;
			COLOR <= SW[2:0];
		end
		
		BLANK:
		begin
			x <= (x + 1) % 160;
			draw <= 1;
			COLOR <= BLK;
			
			if (row_fg)
			begin
				y <= (y + 1) % 120;
				blank_fg <= y / 119;
			end
		end
	
		STOP:
		begin
			draw <= 0;
			xr <= 0;
			yr <= RAD;
			d <= 3 - 2*RAD;
			COLOR <= SW [2:0];
		end
		
		HOLD:
		begin
			draw <= 1;
			if (d<0)
				d <= d+4*xr+6;
			else
			begin
				d <= d + 4*(xr-yr)+10;
				yr <= yr -1;
			end
		end
		
		STATE1:
		begin
			draw <= 1;
			x <= xc + xr;
			y <= yc + yr;
		end
		
		STATE2:
		begin
			draw <= 1;
			x <= xc - xr;
			y <= yc + yr;
		end
		
		STATE3:
		begin
			draw <= 1;
			x <= xc + xr;
			y <= yc - yr;
		end
		
		STATE4:
		begin
			draw <= 1;
			x <= xc - xr;
			y <= yc - yr;
		end
		
		STATE5:
		begin
			x <= xc + yr;
			y <= yc + xr;
		end
		
		STATE6:
		begin
			draw <= 1;
			x <= xc - yr;
			y <= yc + xr;
		end
		
		STATE7:
		begin
			draw <= 1;
			x <= xc + yr;
			y <= yc - xr;
		end
		
		STATE8:
		begin
			draw <= 1;
			x <= xc - yr;
			y <= yc - xr;
			xr <= xr + 1;
			
			if (d<0)
				d <= d+4*xr+6;
			else
			begin
				d <= d + 4*(xr-yr)+10;
				yr <= yr -1;
			end
		end
		
		endcase
		
	end

endmodule