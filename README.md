# Caravel User Project

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml) [![Caravel Build](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml)

## Changes to be made in the files
<details>
  
<summary><b> user_project_wrapper.v </b></summary>

Add the system verilog of design at the end of the **user_project_wrapper**. When design is called inside the system verilog code, ensure that inputs are given without the index as **fp_division** has 2 32-bit inputs and 1 32-bit output.
```
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
```
</details>

<details>
  
<summary><b> config.tcl </b></summary>


```
# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

set script_dir $::env(DESIGN_DIR)


# Area Configurations. DON'T TOUCH.
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 800 800"


# Pin Configurations. DON'T TOUCH
set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(DESIGN_NAME) user_project_wrapper
#section end

# User Configurations

## Source Verilog Files
set ::env(VERILOG_FILES) "\
    $script_dir/src/defines.v \
    $script_dir/src/user_project_wrapper.v"

## Clock configurations
set ::env(CLOCK_PORT) "clk"

set ::env(CLOCK_NET) "clk"

set ::env(CLOCK_PERIOD) "25"

### Black-box verilog and views
set ::env(VERILOG_FILES_BLACKBOX) "\
    $script_dir/src/defines.v\
    $script_dir/src/fp_division.v"

set ::env(EXTRA_LEFS) $script_dir/macros/fp_division.lef

set ::env(EXTRA_GDS_FILES) $script_dir/macros/fp_division.gds
set ::env(SYNTH_NO_FLAT) 1
```
</details>

<details>
  
<summary><b> macros </b></summary>

Create a folder containing the **lef** and **gds** files of the design which was run on OpenLane.

</details>

<details>
  
<summary><b> pin_order.config </b></summary>

```
#BUS_SORT
#NR
analog_io\[8\]
io_in\[15\]
io_out\[15\]
io_oeb\[15\]
analog_io\[9\]
io_in\[16\]
io_out\[16\]
io_oeb\[16\]
analog_io\[10\]
io_in\[17\]
io_out\[17\]
io_oeb\[17\]
analog_io\[11\]
io_in\[18\]
io_out\[18\]
io_oeb\[18\]
analog_io\[12\]
io_in\[19\]
io_out\[19\]
io_oeb\[19\]
analog_io\[13\]
io_in\[20\]
io_out\[20\]
io_oeb\[20\]
analog_io\[14\]
io_in\[21\]
io_out\[21\]
io_oeb\[21\]
analog_io\[15\]
io_in\[22\]
io_out\[22\]
io_oeb\[22\]
analog_io\[16\]
io_in\[23\]
io_out\[23\]
io_oeb\[23\]

#S
wb_.*
wbs_.*
la_.*
user_clock2
user_irq.*

#E
io_in\[0\]
io_out\[0\]
io_oeb\[0\]
io_in\[1\]
io_out\[1\]
io_oeb\[1\]
io_in\[2\]
io_out\[2\]
io_oeb\[2\]
io_in\[3\]
io_out\[3\]
io_oeb\[3\]
io_in\[4\]
io_out\[4\]
io_oeb\[4\]
io_in\[5\]
io_out\[5\]
io_oeb\[5\]
io_in\[6\]
io_out\[6\]
io_oeb\[6\]
analog_io\[0\]
io_in\[7\]
io_out\[7\]
io_oeb\[7\]
analog_io\[1\]
io_in\[8\]
io_out\[8\]
io_oeb\[8\]
analog_io\[2\]
io_in\[9\]
io_out\[9\]
io_oeb\[9\]
analog_io\[3\]
io_in\[10\]
io_out\[10\]
io_oeb\[10\]
analog_io\[4\]
io_in\[11\]
io_out\[11\]
io_oeb\[11\]
analog_io\[5\]
io_in\[12\]
io_out\[12\]
io_oeb\[12\]
analog_io\[6\]
io_in\[13\]
io_out\[13\]
io_oeb\[13\]
analog_io\[7\]
io_in\[14\]
io_out\[14\]
io_oeb\[14\]

#WR
analog_io\[17\]
io_in\[24\]
io_out\[24\]
io_oeb\[24\]
analog_io\[18\]
io_in\[25\]
io_out\[25\]
io_oeb\[25\]
analog_io\[19\]
io_in\[26\]
io_out\[26\]
io_oeb\[26\]
analog_io\[20\]
io_in\[27\]
io_out\[27\]
io_oeb\[27\]
analog_io\[21\]
io_in\[28\]
io_out\[28\]
io_oeb\[28\]
analog_io\[22\]
io_in\[29\]
io_out\[29\]
io_oeb\[29\]
analog_io\[23\]
io_in\[30\]
io_out\[30\]
io_oeb\[30\]
analog_io\[24\]
io_in\[31\]
io_out\[31\]
io_oeb\[31\]
analog_io\[25\]
io_in\[32\]
io_out\[32\]
io_oeb\[32\]
analog_io\[26\]
io_in\[33\]
io_out\[33\]
io_oeb\[33\]
analog_io\[27\]
io_in\[34\]
io_out\[34\]
io_oeb\[34\]
analog_io\[28\]
io_in\[35\]
io_out\[35\]
io_oeb\[35\]
io_in\[36\]
io_out\[36\]
io_oeb\[36\]
io_in\[37\]
io_out\[37\]
io_oeb\[37\]
```

</details>

## GDS Generation
![image](https://github.com/ks-vandana/fp_division_tapeout/assets/116361300/36818bd6-1bc3-4be1-93d7-9c8127e690bf)

## Layout images

![Screenshot from 2023-11-26 13-12-09](https://github.com/ks-vandana/fp_division_tapeout/assets/116361300/6fae3ba3-3a8e-4050-9590-5ee7f2238335)

![Screenshot from 2023-11-26 13-06-16](https://github.com/ks-vandana/fp_division_tapeout/assets/116361300/acbf8eac-377c-44ee-ad73-54d6e21d3613)

![Screenshot from 2023-11-26 13-05-14](https://github.com/ks-vandana/fp_division_tapeout/assets/116361300/e82a1d89-a136-4105-8361-74c9f5be1152)

![Screenshot from 2023-11-26 13-05-38](https://github.com/ks-vandana/fp_division_tapeout/assets/116361300/5c054ec9-3809-4de8-841f-00e85020087a)

![Screenshot from 2023-11-26 13-05-46](https://github.com/ks-vandana/fp_division_tapeout/assets/116361300/688a6dbe-e839-4830-94ab-722852d10a0b)

![Screenshot from 2023-11-26 13-06-42](https://github.com/ks-vandana/fp_division_tapeout/assets/116361300/f419e629-8a68-47f8-8825-f0e0d461e527)

