// AstroTinker Bot : Task 2A : UART Transmitter
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to generate UART Tx data packet to transmit the messages based on the input data.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Transmitter

Input:  clk_50M - 50 MHz clock
        data    - 8-bit data line to transmit
Output: tx      - UART Transmission Line
*/

// module declaration
module uart_tx(
    input  clk_50M,
    input  [7:0] data,
    output reg tx
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////
parameter	TX_START_BIT = 2'b00,
				TX_DATA_BITS = 2'b01,
				TX_STOP_BIT = 2'b10;
			 
reg [2:0] Bit_Index ;
reg [1:0] State ;
reg [7:0] r_tx_data;
integer counter ;
integer Clk_Cyc_per_Bit;

initial begin
	 tx = 0; 
	 Bit_Index =0;
	 State = TX_START_BIT;
	 counter =0;
	 Clk_Cyc_per_Bit =433;
end

always @(posedge clk_50M) 
begin
	case (State)
	
	TX_START_BIT:
	begin
		if (data>0)
		begin
			if(counter < Clk_Cyc_per_Bit)
			begin
				tx <=0;
				State <= TX_START_BIT;
				counter <= counter +1;
			end
			else
			begin
				r_tx_data <= data;
				counter<=0;
				State <= TX_DATA_BITS;
			end
		end
		else
		begin
			tx <=1;
			State <= TX_START_BIT;
		end
	end
	
	TX_DATA_BITS:
	begin
		if(Bit_Index < 7)
		begin
			if(counter < Clk_Cyc_per_Bit)
			begin
				tx <= r_tx_data[Bit_Index];
				counter <= counter +1;
			end
			else
			begin
				counter =0;
				Bit_Index<= Bit_Index +1;
			end
		end
		else
		begin
			if(counter < Clk_Cyc_per_Bit)
			begin
				tx<= r_tx_data[Bit_Index];
				counter <= counter +1;
			end
			else
			begin
				counter <= 0;
				State <= TX_STOP_BIT;
			end
		end
	end
	TX_STOP_BIT:
	begin
		if(counter < Clk_Cyc_per_Bit)
		begin
			tx <= 1;
			State <= TX_STOP_BIT;
			counter <= counter +1;
		end
		else
		begin
			State <=TX_START_BIT;
			counter <=0;
			Bit_Index <=0;
		end
	end
	endcase
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule