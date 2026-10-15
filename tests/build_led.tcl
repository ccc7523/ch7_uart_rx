# Run gw_sh from the project root. Outputs are separate from the old echo build.
set project_root [file normalize [file join [file dirname [info script]] ..]]
set constraint_file [open [file join $project_root src uart_rx.cst] r]
set constraint_text [read $constraint_file]
close $constraint_file
if {![regexp -line {^\s*IO_LOC\s+"led\[8\]"\s+\S+;} $constraint_text]} {
    error "LED8 FPGA pin is not confirmed. Add its verified IO_LOC before generating a bitstream."
}
file mkdir [file join $project_root build uart_led]
cd [file join $project_root build uart_led]
set_device -name GW5AT-60B GW5AT-LV60PG484AC1/I0
add_file -type verilog [file join $project_root src uart_byte_rx.v]
add_file -type verilog [file join $project_root src uart_rx_test.v]
add_file -type cst [file join $project_root src uart_rx.cst]
add_file -type sdc [file join $project_root src uart_rx.sdc]
set_option -top_module uart_rx_test
set_option -output_base_name uart_led
set_option -verilog_std v2001
set_option -use_sspi_as_gpio 1
run all
