// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0
`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(
    parameter BITS = 32
) (
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

/*--------------------------------------*/
/* User project is instantiated  here   */
/*--------------------------------------*/

fp_division fd(
`ifdef USE_POWER_PINS
	.vccd1(vccd1),	// User area 1 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
`endif

    .clk(wb_clk_i),

    // MGMT SoC Wishbone Slave
/*
    .wbs_cyc_i(wbs_cyc_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_we_i(wbs_we_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_dat_i(wbs_dat_i),
    .wbs_ack_o(wbs_ack_o),
    .wbs_dat_o(wbs_dat_o),

    // Logic Analyzer

    .la_data_in(la_data_in),
    .la_data_out(la_data_out),
    .la_oenb (la_oenb),
*/
    // IO Pads

    .a1 (io_in),
    .b1 (io_in),
    .c(io_out)

    // IRQ
    //.irq(user_irq)
);

endmodule	// user_project_wrapper

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
`default_nettype wire
