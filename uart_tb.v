`timescale 1ns / 1ps
module uart_tb;

    reg clk = 0;
    reg rst_n;
    reg [7:0] tx_data_in;
    reg tx_start;
    wire uart_tx_out;
    wire [7:0] rx_data_out;
    wire rx_data_valid;
    wire tx_busy;

    uart_top UUT (.*, .uart_rx_in(uart_tx_out));

    always #10 clk = ~clk;

    initial begin
        rst_n = 0; #20; rst_n = 1; #50;

        send_and_check_byte(8'hA5);
        send_and_check_byte(8'h5A);
        send_and_check_byte(8'hFF);
        send_and_check_byte(8'h00);

        $display(">> Test Finished.");
        $finish;
    end

    task send_and_check_byte(input [7:0] data_to_send);
    begin
        @(negedge tx_busy);
        $display("Sending: 0x%h", data_to_send);
        tx_data_in <= data_to_send;
        tx_start <= 1; @(posedge clk); tx_start <= 0;

        @(posedge rx_data_valid);
        if (rx_data_out == data_to_send)
            $display("PASS: Received 0x%h", rx_data_out);
        else
            $display("FAIL: Sent 0x%h, Received 0x%h", data_to_send, rx_data_out);
    end
    endtask

endmodule
