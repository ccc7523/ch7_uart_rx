# Run from the project root: vsim -c -do tests/run_led.do
onerror {quit -code 1 -f}
onbreak {quit -code 1 -f}
file mkdir tmp
vlib tmp/led_sim_work
vlog -work tmp/led_sim_work src/uart_byte_rx.v src/uart_rx_test.v tests/uart_led_tb.v
vsim tmp/led_sim_work.uart_led_tb
run -all
quit -code 0 -f
