# APB Verification Environment

A SystemVerilog testbench environment created to verify an AMBA APB (Advanced Peripheral Bus) slave module. This project demonstrates protocol-compliant stimulus generation, signal directional control via modports, clocking block timing abstractions, SystemVerilog Assertions (SVA), and functional coverage.

---

## 📌 Features

* **Modular SystemVerilog Interface (`apb_if`):** Uses `modport` constructs (`dut_port`, `tb_port`, `sva_port`) to enforce directionality and signal access control across testbench components.
* **Synchronized Timing:** Employs SystemVerilog `clocking` blocks (`cb`) to manage input setup (`1step`) and output hold times (`#1`) for race-free simulation.
* **Concurrent Assertions (SVA):** Monitors protocol rules (such as reset behavior and state transitions) concurrently during simulation runtimes.
* **Functional Coverage:** Tracks coverage metrics using `covergroup` to sample control signals (such as `pready`) across test sequences.
* **Separated Test Execution:** Implements a `program` block (`tb`) for testbench logic to prevent design-testbench race conditions.

---

## 📁 Repository Structure

```text
.
├── design.sv       # APB Slave Design-Under-Test (DUT) state machine & logic
└── testbench.sv    # Top module, interface (apb_if), test program (tb), SVA, & coverage
