// AstroTinker Bot : Task 2A : UART Receiver
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to receive UART Rx data packet from receiver line and then update the rx_msg and rx_complete data lines.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Receiver

Input:  clk_50M - 50 MHz clock
        rx      - UART Receiver

Output: rx_msg      - read incoming message
        rx_complete - message received flag
*/

// module declaration
module uart_rx (
  input clk_50M, rx,
  output reg [7:0] rx_msg,
  output reg rx_complete
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

parameter CLKS_PER_BIT = 433;
parameter IDLE_STATE = 2'b00;
parameter START_STATE = 2'b01;
parameter GET_BIT_STATE = 2'b10;
parameter STOP_STATE = 2'b11;

reg rx_buffer;
reg rx_bit;
reg [7:0] rx_data;
reg [1:0] state;
reg [15:0] counter;
reg [3:0] bit_index;

initial begin

rx_msg = 0;
rx_data =0;
rx_complete = 0;
rx_buffer =1'b1;
rx_bit =1'b1;
state =0;
counter =0;
bit_index =0;

end

always@(posedge clk_50M)
	begin
		rx_buffer <= rx;
		rx_bit <= rx_buffer;
	end
	
always@(posedge clk_50M)
	begin
		case(state)			
			START_STATE :
			begin
				rx_complete <=0;
				counter <=0;
				bit_index <=0;
				if(counter == (CLKS_PER_BIT -1))
				begin
					if(rx_bit==0)
					begin
						counter <= 0;
						state <= GET_BIT_STATE;
					end
					else
					begin
						state <= START_STATE;
					end
				end
				else
				begin
					counter <= counter + 16'b1;
					state <= START_STATE;
				end
			end
			
			GET_BIT_STATE:
			begin
				if(counter < CLKS_PER_BIT-1)
				begin
					counter <= counter + 16'b1;
					state <= GET_BIT_STATE;
				end
				else
				begin
					counter <=0;
					rx_data[7-bit_index] <= rx_bit;
					if((7-bit_index) > 0)
					begin
						bit_index <= bit_index + 3'b1;
						state <= GET_BIT_STATE;
					end
					else
					begin
						bit_index <= 1;
						state <= STOP_STATE;
					end
				end
			end
			
			STOP_STATE :
			begin
				if(counter < (CLKS_PER_BIT-1))
				begin
					counter <= counter +16'b1;
					state <= STOP_STATE;
				end
				else
				begin
					if (rx_data > 0)
					begin
						rx_complete <= 1;
					end
					rx_msg<=rx_data;
					counter <=0;
					state <= START_STATE;
				end
			end
			
			default :
			state <= START_STATE;
		endcase
	end
//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule