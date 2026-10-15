`timescale 1ns/1ns
module uart_led_tb;
    reg clk = 1'b0;
    reg reset_n = 1'b0;
    reg uart_rx = 1'b1;
    wire uart_tx;
    wire [8:0] led;
    reg [8:0] expected = 9'd0;
    integer i;
    integer commands = 0;
    integer changes = 0;
    // 50 MHz clock, independent UART source at nominal 9600 baud.
    localparam BIT_NS = 104167;
    always #10 clk = ~clk;
    uart_rx_test dut(.clk(clk), .reset_n(reset_n),
                     .uart_rx(uart_rx), .uart_tx(uart_tx), .led(led));

    always @(led) if(reset_n) changes = changes + 1;

    task send_byte;
        input [7:0] value;
        integer b;
        begin
            uart_rx = 1'b0;
            #BIT_NS;
            for(b = 0; b < 8; b = b + 1) begin
                uart_rx = value[b];
                #BIT_NS;
            end
            uart_rx = 1'b1;
            #BIT_NS;
            if(value >= 8'h30 && value <= 8'h37) begin
                expected[7:0] = 8'b1 << (value - 8'h30);
                expected[8] = ~expected[8];
                commands = commands + 1;
            end
            if(led !== expected || changes != commands || uart_tx !== 1'b1) begin
                $display("FAIL byte=%h expected=%h actual=%h changes=%0d commands=%0d",
                         value, expected, led, changes, commands);
                $fatal(1);
            end
        end
    endtask

    initial begin
        #201;
        if(led !== 9'd0) $fatal(1, "Reset must extinguish all lamps");
        reset_n = 1'b1;
        #1000;
        // No extra idle gap between bytes: exercise a continuous command stream.
        for(i = 0; i <= 7; i = i + 1) send_byte(8'h30 + i);
        send_byte("7");
        send_byte("7");
        send_byte(8'h0d);
        send_byte(8'h0a);
        send_byte("0");
        send_byte("0");
        send_byte("8");
        send_byte("9");
        send_byte("x");
        send_byte(8'h01); // Binary 1 is not ASCII '1'.
        send_byte("1");
        send_byte("7");
        reset_n = 1'b0;
        #201;
        if(led !== 9'd0) $fatal(1, "Reset after commands failed");
        expected = 9'd0;
        commands = 0;
        changes = 0;
        reset_n = 1'b1;
        #1000;
        send_byte("3");
        $display("PASS: all digits, consecutive bytes, repeats, invalid bytes, and reset");
        $finish;
    end
    initial begin
        #30000000;
        $fatal(1, "Simulation timeout");
    end
endmodule
