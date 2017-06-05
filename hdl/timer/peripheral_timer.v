//---------------------------------------------------------------------------
//
// Timer
//
// Register Description:
//
//    0x00 ENABLE
//    0x02 MATCH
//    0x04 COMPARE
//    0x06 COUNTER
//
//   EN i  (rw)   if set to '1', COUNTERX counts upwards until it reaches
//                COMPAREX
//
//---------------------------------------------------------------------------

module peripheral_timer #(
	parameter          clk_freq = 100000000
) ( clk, reset, d_in, cs, addr, rd, wr, d_out);
	input              clk;
	input              reset;
	input [15:0] d_in;
	input cs;
	input [3:0] addr; // 4 LSB from j1_io_addr
  input rd;
  input wr;
  output reg [15:0] d_out;

//---------------------------------------------------------------------------
//
//---------------------------------------------------------------------------

reg  [15:0] counter0;

reg  [15:0] compare0;



wire match0 = (counter0 == compare0);
reg ar0 = 0; // no se autorecarga
reg ack;
reg en0;
wire p_rd;
wire p_wr;

assign p_rd =  rd & ~ack & cs;
assign p_wr =  wr & ~ack & cs;

always @(posedge clk)
begin
	if (reset) begin
		en0      <= 0;
		ack      <= 0;
		counter0 <= 0;
		compare0 <= 16'hFFFF;


	end else begin

	  if ( en0 & ~match0) counter0 <= counter0 + 1;
  	if ( ar0 &  match0) counter0 <= 1;
		if (~ar0 &  match0) en0      <= 0;



		ack    <= 0;

		if (p_rd) begin           // read cycle
			ack <= 1;

			case (addr[3:0])
			'h02: d_out <= match0;
			'h04: d_out <= compare0;
			'h06: d_out <= counter0;
			default: d_out <= 16'b0;
			endcase
		end else if (p_wr) begin // write cycle
			ack <= 1;

			case (addr[3:0])
			'h00: en0 <= 1;
			'h04: compare0 <= d_in;
			'h06: counter0 <= d_in;
			endcase
		end
	end
end


endmodule
