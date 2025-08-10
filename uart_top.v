module uart_top(
    input             clk,
    input             rst_n,
    input             tx_start,
    input      [7:0]  tx_data_in,
    output            tx_busy,
    output     [7:0]  rx_data_out,
    output            rx_data_valid,
    output            uart_tx_out,
    input             uart_rx_in
    );

    wire baud_tick, rx_tick;
    reg [12:0] baud_count = 0;
    reg [8:0]  rx_count = 0;

    assign baud_tick = (baud_count == 5207);
    always @(posedge clk) baud_count <= baud_tick ? 0 : baud_count + 1;

    assign rx_tick = (rx_count == 325);
    always @(posedge clk) rx_count <= rx_tick ? 0 : rx_count + 1;

    uart_tx U_TX (.clk, .rst_n, .baud_tick, .tx_data_in, .tx_start, .tx_busy, .uart_tx_out);
    uart_rx U_RX (.clk, .rst_n, .rx_tick, .uart_rx_in, .rx_data_out, .rx_data_valid);

endmodule
