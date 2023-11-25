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
set ::env(DIE_AREA) "0 0 400 400"


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
