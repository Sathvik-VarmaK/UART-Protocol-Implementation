# UART Protocol Implementation

![Language](https://img.shields.io/badge/Language-Verilog-blue.svg)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen.svg)
![Verification](https://img.shields.io/badge/Verification-Passed-brightgreen.svg)

This repository contains the Verilog source code for a simple UART (Universal Asynchronous Receiver/Transmitter). The design is a standard 8-N-1 (8 data bits, no parity, 1 stop bit) transceiver capable of serial communication. The project includes a synthesizable RTL design and a self-checking testbench for verification.

## Key Features
* **8-N-1 Protocol**: Implements the standard 8-data-bit, no-parity, 1-stop-bit communication frame.
* **Fixed Baud Rate**: Configured for **9600 baud** with a **50 MHz** system clock.
* **Robust Receiver**: Features **16x oversampling** to reliably sample the incoming serial data and reject timing noise.
* **Transmitter and Receiver**: Includes separate modules for transmitting (`uart_tx`) and receiving (`uart_rx`) data.
* **Loopback Testbench**: A self-checking testbench (`uart_tb`) verifies the design by looping the transmitter's output back to the receiver's input.
* **Clean and Synthesizable**: Written in clean, synthesizable Verilog-2001.

## Hardware Architecture

The design consists of a top-level module that integrates a transmitter, a receiver, and the necessary clock generation logic.

### UART Data Frame
The communication follows a standard asynchronous frame format. The line is held high (`1`) during idle. A transmission begins with a low (`0`) start bit, followed by 8 data bits (LSB first), and ends with a high (`1`) stop bit.

```
Idle (1) -> Start Bit (0) -> D0 D1 D2 D3 D4 D5 D6 D7 -> Stop Bit (1) -> Idle (1)
```

### Transmitter (`uart_tx`)
The transmitter is a simple state machine that performs parallel-to-serial conversion. When given an 8-bit byte and a start signal, it generates the complete data frame (start bit, data bits, stop bit) at the specified baud rate.

### Receiver (`uart_rx`)
The receiver is the more complex half of the design. Its state machine listens for a start bit and then begins the reception process. The key feature is the **16x oversampling** mechanism. The receiver samples the input line 16 times per bit period, allowing it to:
1.   reliably detect the start bit.
2.  find the stable center of each data bit, making the design resilient to slight clock frequency mismatches between the sender and receiver.

## Project File Structure
* `uart_tx.v`: Verilog source for the UART Transmitter module.
* `uart_rx.v`: Verilog source for the UART Receiver module with 16x oversampling.
* `uart_top.v`: Top-level module that integrates the TX, RX, and baud rate generators.
* `uart_tb.v`: A self-checking loopback testbench for verification.

## Verification
The design was verified using a loopback testbench (`uart_tb.v`). The testbench instantiates the `uart_top` module and connects its `uart_tx_out` port directly to its `uart_rx_in` port.

The test procedure is as follows:
1.  The testbench sends a predefined 8-bit value to the transmitter.
2.  It waits for the transmitter to send the data, which is then received by the receiver.
3.  When the receiver asserts the `rx_data_valid` signal, the testbench compares the received byte to the original byte.
4.  A `PASS` or `FAIL` message is printed to the console.

A successful simulation run will display the following output:
```
STARTING TESTBENCH...
Sending: 0xa5
PASS: Received 0xa5 successfully.
Sending: 0x5a
PASS: Received 0x5a successfully.
Sending: 0xff
PASS: Received 0xff successfully.
Sending: 0x00
PASS: Received 0x00 successfully.
>> Test Finished.
```

## How to Run the Simulation
1.  Clone the repository to your local machine.
2.  Open your Verilog simulator (e.g., ModelSim, Vivado Simulator, Icarus Verilog).
3.  Add all four `.v` files to your project, ensuring the compilation order is correct:
    1. `uart_tx.v`
    2. `uart_rx.v`
    3. `uart_top.v`
    4. `uart_tb.v`
4.  Set `uart_tb` as the top-level simulation module.
5.  Run the simulation and observe the console output for the `PASS` messages.
