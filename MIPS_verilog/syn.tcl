####################################################
# Flow for EEE 498
####################################################


puts "EEE498-Info: Running script [info script]\n"


if {![info exists DESIGN ] } {
    puts "ERROR: DESIGN undefined"
    exit
}

if {![info exists VERILOG] } {
    puts "ERROR: VERILOG undefined"
    exit
}
if {![info exists PARAM] } {
    set PARAM ""
}
if {![info exists SYN_TOP_NAME] } {
    puts "ERROR: SYN_TOP_NAME undefined"
    exit
}
if {![info exists SYN_INST_NAME] } {
    puts "ERROR: SYN_INST_NAME undefined"
    exit
}



# The target clock period and area in library units (nS)
if {![info exists CLK_PERIOD]} {
	set CLK_PERIOD 1.0
}

file mkdir reports


#####################
# Init Our Empty Design
#####################
remove_design -all
define_design_lib $DESIGN -path ./$DESIGN
saif_map -start


#####################
# Config Variables
#####################
# The clock input signal name.
set CLK  "clk"
# The reset input signal name.
set RST  "rst"

#######################
# Setup Our Libraries
#######################
set SYN /usr/local/synopsys/starrc_2015.06/libraries/syn/
set EEE_498 /afs/asu.edu/class/e/e/e/eee333/2016_01_SPR-Brun
#set SYN /cad/synopsys/syn_vJ-2014.09-SP5/libraries/syn/
#set EEE_498 /cad/synopsys_cell_lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/

set link_library { * saed32hvt_tt0p85v25c.db  dw_foundation.sldb}
set target_library "saed32hvt_tt0p85v25c.db"
set synthetic_library [list  dw_foundation.sldb]
set dw_lib     $SYN
set sym_lib    $EEE_498
set target_lib $EEE_498

set search_path [list ./ ../ ../src/  $dw_lib $target_lib $sym_lib]




################################
# Parse the Verilog
################################
puts "EEE498-Info: Analyzing and Elaborating ${DESIGN}\n"
analyze -library $DESIGN -format sverilog $VERILOG
elaborate $DESIGN -architecture verilog -library $DESIGN -param $PARAM

# set PARAM " \"24,10,3,3,3,3,1,2,4,4\""


############################
## Check design for eRRors
############################
puts "EEE498-Info: Checking Design\n"
check_design -summary
check_design > reports/${DESIGN}.mapped.check_design_PreCompile.rpt
check_error -verbose >  reports/${DESIGN}.mapped.check_error_PreCompile.rpt
check_library > reports/${DESIGN}.mapped.check_libs_PreCompile.rpt
list_libs > reports/${DESIGN}.mapped.list_libs_PreCompile.rpt


##################################
# Design Optimization Constraints
##################################

if { $COMB } {

	# Tell the tool that clk has a period
	create_clock $CLK -period $CLK_PERIOD

	# Set the output delay constraint as 10% before the clock period
	set_output_delay [ expr $CLK_PERIOD*0.0 ] -max -clock $CLK  [get_ports "*" -filter {@port_direction == out} ]

	# Set the input delay as 90% after the rising edge
	set all_inputs_wo_rst_clk [remove_from_collection [remove_from_collection [all_inputs] [get_port $CLK]] [get_port $RST]] 
	set_input_delay [ expr $CLK_PERIOD*0.0 ] -clock $CLK  $all_inputs_wo_rst_clk

	set_max_fanout 10 [current_design]
	set_max_transition [ expr $CLK_PERIOD*0.3 ] -data_path [get_clocks $CLK]

} else {

	# Tell the tool that clk has a period
	create_clock $CLK -period $CLK_PERIOD

	# Set the output delay constraint as 10% before the clock period
	set_output_delay [ expr $CLK_PERIOD*0.9 ] -max -clock $CLK  [get_ports "*" -filter {@port_direction == out} ]

	# Set the input delay as 90% after the rising edge
	set all_inputs_wo_rst_clk [remove_from_collection [remove_from_collection [all_inputs] [get_port $CLK]] [get_port $RST]] 
	set_input_delay [ expr $CLK_PERIOD*0.9 ] -clock $CLK  $all_inputs_wo_rst_clk

	set_max_fanout 10 [current_design]
	set_max_transition [ expr $CLK_PERIOD*0.3 ] -data_path [get_clocks $CLK]

}

remove_driving_cell $RST
set_drive 0 $RST
set_dont_touch_network $RST


##########################################
# Synthesize Design (Optimize for Timing)
##########################################
#ungroup -flatten -all
set_optimize_registers false -design ${DESIGN}
#compile_ultra -no_autoungroup -no_boundary_optimization -no_seq_output_inversion -check_only
compile_ultra -no_autoungroup -no_boundary_optimization -no_seq_output_inversion -exact_map 
#optimize_netlist -area


######################################################################################
# Write the designs
######################################################################################
write -format verilog  -hierarchy -output ${DESIGN}.v
write -format svsim   -hierarchy -output ${DESIGN}.sv
write -format ddc ${DESIGN}.ddc 

check_design -summary > reports/${DESIGN}.mapped.CheckDesign.rpt
check_design > reports/${DESIGN}.mapped.CheckDesign.rpt
check_error -verbose > reports/${DESIGN}.mapped.error.rpt


#####################
# Start the analysis
#####################
read_saif -auto_map_names -instance ${SYN_TOP_NAME}/${SYN_INST_NAME} -input "../top.saif" -verbose
report_saif

report_timing -significant_digits 4 -transition_time -nets -attributes -nosplit > reports/${DESIGN}.mapped.timing.rpt
report_area -physical -nosplit > reports/${DESIGN}.mapped.area.rpt
report_area -physical -nosplit -hierarchy > reports/${DESIGN}.mapped.areaHier.rpt
report_power -analysis_effort high -nosplit > reports/${DESIGN}.mapped.power.rpt

# All Done
puts "SEEC-Info: Completed script [info script]\n"
exit




