# Asynchronous_FIFO_Project
 Designed and implemented an asynchronous FIFO using Verilog on Vivado.
 
 Verified functionality through testbench simulation and synthesized netlist for hardware validation. 
 
 Tools Used:  Xilinx Vivado, Verilog HDL
# Asynchronous FIFO in Verilog

## 📌 Overview
This project implements an **Asynchronous FIFO** in Verilog, designed to safely transfer data between two independent clock domains (`wr_clk` and `rd_clk`).  
It uses **binary-to-Gray conversion** for pointer synchronization and supports configurable data width and FIFO depth.

---

## ✨ Features
- **Fully parameterized**: Configurable `DATA_WIDTH` and `ADDR_WIDTH`
- **Dual-clock support**: Separate write and read clocks
- **Binary-to-Gray pointer conversion** for metastability protection
- **Full & Empty flag generation** with safe clock domain crossing
- **Synthesizable** for FPGA deployment (tested on Xilinx boards)
- **Simulation testbench** included (covers full condition)

---

## 🛠 Parameters
| Parameter     | Description                              | Example |
|---------------|------------------------------------------|---------|
| `DATA_WIDTH`  | Width of the data word                   | 8       |
| `ADDR_WIDTH`  | Address width for FIFO depth calculation | 4       |
| `DEPTH`       | FIFO depth = `2^ADDR_WIDTH`              | 16      |

---

## 🔍 How It Works
1. **Write Side**:
   - Data is written when `wr_en` is high and FIFO is not `full`.
   - Write pointer is maintained in **binary** and converted to **Gray** code for safe synchronization.

2. **Read Side**:
   - Data is read when `rd_en` is high and FIFO is not `empty`.
   - Read pointer follows the same binary-to-Gray synchronization process.

3. **Full Detection**:
   - The FIFO is `full` when the write pointer in Gray code equals the read pointer (Gray) with the **two MSBs inverted**.

---

## 📜 Example Full Condition
```verilog
assign full = (wr_ptr_gray == 
               {~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1],
                 rd_ptr_gray_sync2[ADDR_WIDTH-2:0]});

---
##  Tools Used
Xilinx Vivado – Design, synthesis, implementation, and simulation

Verilog HDL – Hardware description language for implementation

