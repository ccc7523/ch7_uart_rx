module uart_rx_test(
    input  clk,
    input  reset_n,
    input  uart_rx,
    output uart_tx,
    output reg [8:0] led
);
    wire [7:0] data_byte_rx;
    wire rx_done;

    // LED0 is disabled. ASCII '1'..'7' select LED1..LED7.
    // ASCII '0' clears LED1..LED7; LED8 toggles on every digit '0'..'7'.
    // LED outputs are active high. TX stays at its idle level.
    assign uart_tx = 1'b1;

    always@(posedge clk or negedge reset_n)
    if(!reset_n) begin
        led <= 9'd0;
    end
    else if(rx_done && data_byte_rx >= 8'h30 && data_byte_rx <= 8'h37) begin
        // Each valid ASCII digit selects one lamp and toggles LED8 once.
        // Repeated digits are commands too. CR/LF and other bytes are ignored.
        led[7:0] <= (8'b00000001 << (data_byte_rx - 8'h30)) & 8'hFE;
        led[8] <= ~led[8];
    end
    uart_byte_rx uart_byte_rx(
        .clk(clk),
        .reset_n(reset_n),

        .baud_set(3'd0),
        .uart_rx(uart_rx),

        .data_byte(data_byte_rx),
        .rx_done(rx_done)

        //尝试
    );
endmodule
