module uart_tx(
    input             clk,
    input             rst_n,
    input             baud_tick,
    input      [7:0]  tx_data_in,
    input             tx_start,
    output            tx_busy,
    output reg        uart_tx_out
    );

    localparam IDLE      = 2'b00;
    localparam TX_START  = 2'b01;
    localparam TX_DATA   = 2'b10;
    localparam TX_STOP   = 2'b11;

    reg [1:0] state = IDLE;
    reg [2:0] bit_count = 0;
    reg [7:0] tx_shift_reg = 8'b0;

    assign tx_busy = (state != IDLE);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            uart_tx_out <= 1'b1;
            bit_count <= 0;
        end
        else begin
            case(state)
                IDLE: begin
                    uart_tx_out <= 1'b1;
                    if (tx_start) begin
                        tx_shift_reg <= tx_data_in;
                        state <= TX_START;
                    end
                end
                TX_START: begin
                    if (baud_tick) begin
                        uart_tx_out <= 1'b0;
                        state <= TX_DATA;
                    end
                end
                TX_DATA: begin
                    if (baud_tick) begin
                        uart_tx_out <= tx_shift_reg[0];
                        tx_shift_reg <= tx_shift_reg >> 1;
                        if (bit_count < 7) begin
                            bit_count <= bit_count + 1;
                        end else begin
                            state <= TX_STOP;
                        end
                    end
                end
                TX_STOP: begin
                    if (baud_tick) begin
                        uart_tx_out <= 1'b1;
                        state <= IDLE;
                        bit_count <= 0;
                    end
                end
            endcase
        end
    end
endmodule
