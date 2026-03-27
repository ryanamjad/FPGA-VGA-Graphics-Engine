module Task2(CLK50,SW,LEDR,VGA_R, VGA_G, VGA_B,VGA_HS,
				VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK);
	
	input CLK50;	
	input [0:0] SW;
	
	reg [7:0] X = 0;
	reg [6:0] Y = 0;
	reg [2:0] COLOR = 0;
   reg FILL = 1;
	reg [1:0]STATE = 0;
	reg RST = 0;

	wire RSTN = SW[0];
	
	assign LEDR[0] = FILL;
	assign LEDR[1] = ~RST;
	assign LEDR[2] = ~STATE;
	
	output [3:0] VGA_R;
	output [3:0] VGA_G;
	output [3:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK;
	output VGA_SYNC;
	output VGA_CLK;
	output [2:0]LEDR;
	
	

//required for display on screen using vga port

	vga_adapter VGA(
			.resetn(RSTN),
			.clock(CLK50),
			.colour(COLOR),
			.x(X),
			.y(Y),
			.plot(FILL),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
			
			
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";
		defparam VGA.USING_DE1 = "TRUE";

parameter STATE0 = 2'b00, STATE1 = 2'b01;
//FSM states

always @(posedge CLK50)
begin
case (STATE)
	STATE0:  //it do nothing
	begin
			if(RSTN ~^ RST)   
				 STATE <= STATE1;
			else    
				 STATE <= STATE0;   		 
	end

	STATE1:  //the screen will get filled when in this state
	begin
	     if(RSTN ~^ RST)   
				 STATE <= STATE1;
			else    
				 STATE <= STATE0;    
	end 
endcase
end


//for filling the screen with colors 

always @(*)
begin
case (STATE)
	STATE0:
		FILL = 0; // it do nothing
	STATE1:
	begin
		FILL = 1;
		if(!RSTN)
		begin
			COLOR = 3'b000; //initializing with black screen as required
			if(X==159 && Y==119)
				 RST = 1; //gets reset when reaches last pixel
		end
		else
		begin
			COLOR = Y % 8; //taking remainder when divided by 8, as colors are also 8
			if(X==159 && Y==119)
				 RST = 0;
		end
			
	end
endcase
end

always @(posedge CLK50)
begin
case (STATE)

	STATE0:  //do nothing
		begin
			X <= 0;
			Y <= 0;
		end	  
	STATE1: //the screen will only get filled when in this state
		begin
			X <= X + 1;
			if(X==159)
			begin
				 X <=0;
				 Y <= Y + 1;
			end
		end	
		
endcase
end


endmodule
