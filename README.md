# Asynchronous FIFO in Verilog


## Overview
This project implements an Asynchronous FIFO (First In First Out) buffer in Verilog HDL with Gray code pointer synchronization to handle clock domain crossing. It supports configurable data width and depth using parameters and includes full/empty flag logic.

## Features
Parameterized DATA_WIDTH and ADDR_WIDTH.

Binary to Gray code conversion for pointer synchronization.

Full and empty detection.

Synchronous write and read logic for separate clock domains.

Testbench included for simulation.

## File Structure
bash
Copy
Edit
├── src/
│   ├── async_fifo.v          # Main FIFO module
│   ├── async_fifo_tb.v       # Testbench
├── constraints/
│   ├── fifo_constraints.xdc  # FPGA pin mapping
├── README.md                 # Project documentation

## Tools Used
Xilinx Vivado – for synthesis, implementation, simulation, and bitstream generation.

## Hardware Description Language Used
Verilog HDL

## How It Works
The FIFO uses two separate pointers (write pointer & read pointer) in Gray code format to avoid metastability issues during clock domain crossing.

## Full condition:

verilog
Copy
Edit
assign full = (wr_ptr_gray == {~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1],
                               rd_ptr_gray_sync2[ADDR_WIDTH-2:0]});
## Empty condition:

verilog
Copy
Edit
assign empty = (wr_ptr_gray_sync2 == rd_ptr_gray);

## Simulation
To run the testbench:

Open Vivado or any Verilog simulator.

Add async_fifo.v and async_fifo_tb.v.

Run the simulation and observe the waveforms for write/read operations.

## FPGA Implementation
Create a Vivado project.

Add async_fifo.v to design sources.

Add fifo_constraints.xdc to constraints.

Run synthesis, implementation, and generate the bitstream.

Program the FPGA.

<img width="1920" height="1080" alt="Screenshot 2025-08-25 171849" src="https://github.com/user-attachments/assets/2b6abdee-55fa-4fb9-90fd-49f8f7f1f20d" />
Here is the waveform generated for the testbench used.




