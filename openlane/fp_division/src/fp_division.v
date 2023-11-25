module fp_division(
	`ifdef USE_POWER_PINS
	inout vccd1,
	inout vssd1,
	`endif
	input wire clk,
	input wire [31:0] a1,
	input wire [31:0] b1,
	output reg [31:0] c
);
	
	reg [31:0] a;
	reg [31:0] b;
	reg sa;
	reg sb;
	reg sc;
	reg [7:0] ea;
	reg [7:0] eb;
	reg [7:0] ec;
	reg [23:0] ma;
	reg [23:0] mb;
	reg [23:0] mc;
	reg [49:0] rq;
	always @(posedge clk) begin
		a <= a1;
		b <= b1;
		c[31] <= sc;
		c[30:23] <= ec;
		c[22:0] <= mc[22:0];
	end
	always @(*) begin : sv2v_autoblock_1
		reg [0:1] _sv2v_jump;
		_sv2v_jump = 2'b00;
		sa = a[31];
		sb = b[31];
		sc = sa ^ sb;
		ea = a[30:23];
		eb = b[30:23];
		ec = (ea - eb) + 8'b01111111;
		ma = 24'b000000000000000000000000 + a[22:0];
		mb = 24'b000000000000000000000000 + b[22:0];
		mc = 24'b000000000000000000000000;
		rq = 50'b00000000000000000000000000000000000000000000000000;
		ma[23] = 1;
		mb[23] = 1;
		rq[46:23] = ma[23:0];
		begin : sv2v_autoblock_2
			reg signed [31:0] t;
			for (t = 0; t < 24; t = t + 1)
				begin
					rq = rq << 1;
					rq[49] = 0;
					rq[49:24] = rq[49:24] - mb[23:0];
					if (rq[49] == 1)
						rq[49:24] = rq[49:24] + mb[23:0];
					else
						rq[0] = 1;
				end
		end
		mc = rq[23:0];
		begin : sv2v_autoblock_3
			reg signed [31:0] l;
			begin : sv2v_autoblock_4
				reg signed [31:0] _sv2v_value_on_break;
				for (l = 0; l < 25; l = l + 1)
					if (_sv2v_jump < 2'b10) begin
						_sv2v_jump = 2'b00;
						if (~mc[23]) begin
							if (mc != 0) begin
								mc = mc << 1;
								ec = ec - 1;
								if (mc[23])
									_sv2v_jump = 2'b10;
							end
							else
								mc = mc;
						end
						_sv2v_value_on_break = l;
					end
				if (!(_sv2v_jump < 2'b10))
					l = _sv2v_value_on_break;
				if (_sv2v_jump != 2'b11)
					_sv2v_jump = 2'b00;
			end
		end
	end
endmodule
