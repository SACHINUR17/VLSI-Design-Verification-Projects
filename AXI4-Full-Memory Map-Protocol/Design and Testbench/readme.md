# 🚀 AXI4-Full Protocol UVM Verification Environment

[![SystemVerilog](https://img.shields.io/badge/SystemVerilog-IEEE_1800-blue.svg)](https://ieeexplore.ieee.org/document/8299595)
[![UVM](https://img.shields.io/badge/UVM-1.2-green.svg)](https://www.accellera.org/downloads/standards/uvm)
[![Protocol](https://img.shields.io/badge/Protocol-AXI4__Full-orange.svg)](https://developer.arm.com/documentation/ihi0022/b/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Simulator](https://img.shields.io/badge/Simulator-Questa%20%2F%20ModelSim-red.svg)](https://www.intel.com)

> A comprehensive, production-grade Universal Verification Methodology (UVM) environment built to thoroughly verify an AMBA AXI4-Full Slave memory-mapped interface. The environment validates multi-burst transactions, unaligned memory addresses, out-of-order execution, and interleaving delay combinations.

---

## 📑 Table of Contents

- [🚀 Overview](#-overview)
- [🎯 Features](#-features)
- [🏗️ Architecture](#%EF%B8%8F-architecture)
- [📁 Directory Structure](#-directory-structure)
- [🔧 Interface & Channels](#-interface--channels)
- [📊 Verification Plan & Testcases](#-verification-plan--testcases)
- [📈 Scoreboard & Coverage](#-scoreboard--coverage)
- [🎮 Running Simulations](#-running-simulations)
- [🔍 Assertion Checks (SVA)](#-assertion-checks-sva)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## 🚀 Overview

This repository features a robust, scalable, and highly configurable **UVM 1.2 Verification Environment** for the **AMBA AXI4 (Full) Specification**. Designed to achieve maximum structural and functional coverage, this verification intellectual property (VIP) tests a high-performance memory-mapped AXI4 Slave DUT.

The testbench incorporates **Concurrent SystemVerilog Assertions (SVA)** for hard protocol compliance, specialized structural agents for data driving/monitoring, and a dynamic configuration channel (`c_agent`) to stress-test arbitrary slave response latencies, out-of-order execution depths, and interleaving configurations.

---

## 🎯 Features

* **Full AXI4 Protocol Support:** Verifies memory-mapped operations supporting multi-beat burst lengths up to **256 beats** (`awlen/arlen` up to 255) and varied burst types (**INCR, FIXED, WRAP**).
* **Advanced Transaction Control:** Simulates realistic bus traffic with outstanding transaction reordering (`awid/arid`), out-of-order execution, and write interleaving logic.
* **Dynamic Delay Injector:** A dedicated Control Agent (`c_agent`) programs configuration settings mid-simulation (`min_req_delay`, `max_rsp_delay`, etc.) to evaluate slave behavior under diverse backpressure configurations.
* **Active Memory Subsystem:** Built-in verification memory model utilizing an associative array tracking sparse and dense storage setups.
* **Functional Coverage & SVA:** Object-oriented covergroups checking cross-coverage of frequencies, bursts, widths, and addresses alongside low-latency protocol checking.

---

## 🏗️ Architecture

The block diagram below conceptualizes the structural partitioning of the UVM components. The environment encapsulates an executive layer running virtual sequences down to individual point-to-point interface drivers.

```
                            +-----------------------------------+
                            |             base_test             |
                            +-----------------------------------+
                                              |
                            +-----------------------------------+
                            |        virtual_sequencer          |
                            +-----------------------------------+
                                              |
                     +------------------------+------------------------+
                     |                        |                        |
           +------------------+     +------------------+     +------------------+
           |     w_agent      |     |     r_agent      |     |     c_agent      |
           |  (Active/Pass)   |     |  (Active/Pass)   |     |  (Active/Pass)   |
           +------------------+     +------------------+     +------------------+
           | - w_sequencer    |     | - r_sequencer    |     | - c_sequencer    |
           | - w_driver       |     | - r_driver       |     | - c_driver       |
           | - w_monitor      |     | - r_monitor      |     | - c_monitor      |
           +--------+---------+     +--------+---------+     +--------+---------+
                    |                        |                        |
                    +------------------------+------------------------+
                                             |
                     +-----------------------+------------------------+
                     |                                                |
           +------------------+                             +------------------+
           |    scoreboard    |                             |     coverage     |
           |  (In-order Mem)  |                             |  (Functional CG) |
           +------------------+                             +------------------+
                     |                                                |
  ===================+=======================+========================+===================
                                       Virtual Interface
  ===================+=======================+========================+===================
                     |                                                |
           +------------------+                             +------------------+
           |     SVA Bind     |                             |    AXI4 Slave    |
           |  (SVA Assertions)|                             |    (RTL DUT)     |
           +------------------+                             +------------------+
```

---

## 📁 Directory Structure

```
├── tb/
│   ├── env_pkg.sv              # Package wrapping all classes, parameters, and files
│   ├── interface.sv            # AXI4 Interface enclosing clocking blocks & modports
│   ├── config_obj.sv           # Agent active/passive configurations & interface hooks
│   ├── w_seq_item.sv           # Write channel transaction sequence items
│   ├── r_seq_item.sv           # Read channel transaction sequence items
│   ├── c_seq_item.sv           # Control knobs / configurations transaction item
│   ├── w_driver.sv             # Drives Write Address, Write Data & Response channels
│   ├── r_driver.sv             # Drives Read Address & Read Response handshakes
│   ├── c_driver.sv             # Drives dynamically updated configuration settings
│   ├── w_monitor.sv            # Captures write interface activity for SCB and COV
│   ├── r_monitor.sv            # Captures read interface activity for SCB and COV
│   ├── c_monitor.sv            # Tracks configuration signal changes
│   ├── w_seqr.sv / r_seqr.sv   # Channel sequencers
│   ├── virtual_sequencer.sv    # Virtual Sequencer managing multi-agent sequences
│   ├── scoreboard.sv           # Golden reference checking memory integrity 
│   ├── coverage.sv             # Captures cross-functional coverage metrics
│   ├── virtual_seq.sv          # Coordinates synchronized write/read traffic patterns
│   ├── env.sv                  # Instantiates and hooks up agents, SCB, and Coverage
│   ├── test.sv                 # Base Test and specialized test derivations
│   └── axi_top.sv              # Global Module Top binding design, clk, and test configuration
├── rtl/
│   ├── axi_slave_write.sv      # Slave Write Memory handling & handshake pipeline RTL
│   └── axi_slave_read.sv       # Slave Read Pipeline & Interleaving responder RTL
└── sim/
    └── dump.vcd                # Captured wave log for structural design debugging
```

---

## 🔧 Interface & Channels

The testbench controls transactions across five dedicated async streams isolated through standard system constraints:

1. **Write Address (`AW`):** `awid`, `awaddr`, `awlen`, `awsize`, `awburst`, `awvalid`, `awready`
2. **Write Data (`W`):** `wdata`, `wstrb`, `wlast`, `wvalid`, `wready`
3. **Write Response (`B`):** `bid`, `bresp`, `bvalid`, `bready`
4. **Read Address (`AR`):** `arid`, `araddr`, `arlen`, `arsize`, `arburst`, `arvalid`, `arready`
5. **Read Data & Response (`R`):** `rid`, `rdata`, `rresp`, `rlast`, `rvalid`, `rready`

### Clocking Blocks
To safeguard against structural race conditions, input sampling and output driving are synchronized to clocking blocks using specified skew metrics:
```systemverilog
clocking w_drv_cb @(posedge clk);
   default input #1 output #0;
   output awid, awaddr, awlen, awsize, awburst, awvalid;
   input  awready;
   output wdata, wstrb, wlast, wvalid;
   input  wready;
   output bready;
   input  bvalid;
endclocking
```

---

## 📊 Verification Plan & Testcases

The environment executes specialized verification routines driven by synchronized virtual sequences:

* **`random_wr_test`:** Generates uniform random distribution traffic on writes and reads spanning small linear strides (`awaddr < 15`, `awlen < 5`) with single-cycle interface delays.
* **`single_wr_test`:** Targets specific deterministic standard conditions (`awaddr == 6`, `awlen == 2`) to ensure perfect address aligned word mapping.
* **`burst_wr_test`:** Drives extended randomized bursts spanning large dynamic windows (`awaddr < 31`, `awlen < 6`) to check performance margins and FIFO storage limits.

---

## 📈 Scoreboard & Coverage

### Memory Model Scoreboard
The Scoreboard implements a tracking system utilizing a sparse SystemVerilog associative array mapping data blocks precisely:
```systemverilog
bit [0:63] data_fifo[int]; // Associative Reference Memory Tracking
```
* On Write transfers, the address and sequential tracking offset write raw bus values directly into the map.
* On Read cycles, sampled packet properties verify the target cell, evaluating returned values against expected memory data across different verbosity thresholds (`UVM_MEDIUM`, `UVM_HIGH`).

### Functional Coverage Metric Tracker
The `coverage` sub-component samples five comprehensive covergroups covering full architectural targets:
* **Write Command Coverage:** Crosses `awid`, `awburst`, `awsize`, and address boundaries.
* **Write Data/Response Coverage:** Checks byte lane utilization on `wstrb` patterns and ensures proper `bresp` decoding (OKAY, SLVERR, DECERR).
* **Read Interleaving & Out-Of-Order Verification:** Dynamically measures out-of-order latency offsets by maintaining historical sequence tracking lists (`r_command_queue`, `r_data_queue`).

---

## 🎮 Running Simulations

The test environment is tuned for multi-tool operations like QuestaSim or ModelSim. Ensure the source tree directory layout is maintained.

### Running a Burst Transaction Test via Command Line:
```bash
# Compile and optimize the complete verification library infrastructure
vlog -f run.f
vsim -c axi_top +UVM_TESTNAME=burst_wr_test -do "run -all; quit;"
```

### Argument Simulation Switches:
* `+UVM_TESTNAME=random_wr_test` : Starts arbitrary mixed write and read iterations.
* `+UVM_TESTNAME=single_wr_test` : Executes short address diagnostics.
* `+UVM_TESTNAME=burst_wr_test`  : Launches aggressive full block loop configurations.

---

## 🔍 Assertion Checks (SVA)

Hard-wired protocol check rules are cleanly bound to the slave interfaces to capture any physical signal violations instantly:

* **`arvalid_arready1` / `awvalid_awready1`:** Validates handshaking metrics; once valid roses, it must sustain structural state until clean deassertion occurs.
* **Address Stability Checks:** Guarantees command properties (`awaddr` and `araddr`) persist without any clock fluctuation until the handshake captures cleanly.
* **`wvalid_wready` SVA:** Enforces that data burst boundaries obey standard control transitions without premature dropouts before a burst terminates via `wlast`.

---

## 🤝 Contributing

Contributions are welcome! If you want to optimize the driver pipes, expand coverage groups, or include new error injection test scenarios:
1. Fork the project repository.
2. Form an isolated descriptive feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit adjustments cleanly (`git commit -m 'Add support for unaligned access exceptions'`).
4. Push onto your branch workspace (`git push origin feature/AmazingFeature`).
5. Open an official Pull Request for evaluation.

---

## 📄 License

Distributed under the **MIT License** — view the `LICENSE` document for legal access boundaries.

---

<div align="center">

### Developed with 💖 by [Sachin](https://github.com/SACHINUR17)
*Specialized Design Verification Engineer*

</div>
