**AHB Protocol Design and UVM-Based Verification**

**Overview**
This project presents the RTL design and SystemVerilog UVM-based verification of the AMBA Advanced High-performance Bus (AHB) Protocol—a widely-used ARM SoC bus standard optimized for high-speed, pipelined communication between CPUs, memory, and peripherals.


The verification infrastructure leverages randomized constrained stimulus, functional coverage, protocol assertions, and layered UVM architecture to ensure protocol correctness and robustness.


**Features**
AHB Slave RAM Design:

Synchronous RAM (32 × 32-bit) with support for pipelined read/write operations.

FSM-based control with states: Idle, Address, Data, Response.

Error detection and handling for invalid addresses (HRESP=ERROR).


**Tools or Simulators used:**
- Cadence Xcelium


**AMBA AHB Protocol Support:**

Single and burst (incrementing/optional wrapping) transfers.

Pipelined address and data phase operation.

Complete set of AHB signals: HADDR, HWRITE, HTRANS, HSIZE, HBURST, HPROT, HWDATA, HRDATA, HREADY, HRESP, HSEL, HMASTLOCK.


**UVM-based Verification Environment:**

Constrained-random stimulus for protocol-compliant scenarios and corner-case coverage.

Assertion-based protocol checking (SystemVerilog SVA).

Functional coverage for transaction types, error/OKAY responses, and wait states.

Scoreboard for automatic DUT vs. reference output comparison.

Comprehensive console/waveform debug for each transfer.


**/rtl**
  - ahb_slave_ram.sv         # AHB slave RAM RTL code
  - ahb_if.sv                # AHB bus interface definition

**/uvm_tb**
  - ahb_pkg.sv               # Testbench package and type definitions
  - ahb_env.sv               # UVM environment
  - ahb_agent.sv             # UVM agent, driver, sequencer, monitor
  - ahb_seq_item.sv          # Sequence item (transaction model)
  - ahb_test.sv              # Test(s) and stimulus generators
  - ahb_scoreboard.sv        # Scoreboard/checker

**/sim**
  - testbench.sv             # Top-level testbench module
  - run.sh                   # Simulation/run scripts

**/docs**
  - AHB-Protocol-Specification.pdf     # Protocol architecture
  - waveform.png             # Example result waveforms
  - Log                      #output result
  - README.md


**Examine Results:**

Check generated waveform files (dump.vcd) in your simulator’s viewer.

Inspect console logs for detailed transaction traces and protocol checks.

Review coverage and assertion reports for verification completeness.

**Documentation:**
AHB Protocol Specifications (ARM)

See /docs/AHB-Protocol-Specification.pdf for a detailed architecture, methodology, waveforms, and results.

**Project Highlights:**
Industry-standard UVM methodology for reusable, scalable SoC verification.

Randomized stimuli and protocol assertions for thorough coverage and bug-finding.

Clean, readable code and modular structure for easy adaptation and reuse.

Demonstrates best practices in design, verification, and reporting for VLSI/bus protocols.

**License**
This repository is released under the MIT License. See LICENSE for details.
