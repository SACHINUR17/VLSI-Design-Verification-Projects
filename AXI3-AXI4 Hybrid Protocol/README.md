# ⚡ AXI Protocol Verification Environment

[![SystemVerilog](https://img.shields.io/badge/SystemVerilog-IEEE_1800-blue.svg)](https://ieeexplore.ieee.org/document/8299595)
[![Protocol](https://img.shields.io/badge/Protocol-AMBA_AXI-orange.svg)](https://developer.arm.com/documentation/ihi0022/b)
[![Methodology](https://img.shields.io/badge/Methodology-Layered_Testbench-purple.svg)](#architecture)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Simulator](https://img.shields.io/badge/Simulator-EDA_Playground-red.svg)](https://edaplayground.com)

> A layered, non-UVM SystemVerilog verification environment for AMBA AXI protocol, targeting an AXI slave with constrained-random stimulus, static mailbox-based IPC, and write/read burst verification.

## 📑 Table of Contents

- [🚀 Overview](#overview)
- [🎯 Features](#features)
- [🏗️ Architecture](#architecture)
- [📁 Directory Structure](#directory-structure)
- [⚡ Quick Start](#quick-start)
- [🔧 Configuration](#configuration)
- [📊 Verification Plan](#verification-plan)
- [🎮 Running Simulations](#running-simulations)
- [🔍 Debug Guide](#debug-guide)
- [🤝 Contributing](#contributing)
- [📄 License](#license)

## 🚀 Overview

This project implements a **layered non-UVM testbench** for verifying AMBA AXI protocol compliance on a slave DUT. Written in pure SystemVerilog, it provides constrained-random stimulus generation, a full bus functional model covering all five AXI channels, and an associative-memory slave model for end-to-end write/read verification.

The project demonstrates the **static mailbox IPC pattern** — a lightweight alternative to UVM's TLM ports — making it an ideal reference for engineers transitioning from basic testbenches toward full UVM methodology.

### Key Highlights
- ✅ **AXI Protocol Compliant** — ARM IHI 0022B specification reference
- 🔄 **5-Channel BFM** — Write Address, Write Data, Write Response, Read Address, Read Data
- 🎲 **Constrained Random Testing** — Smart stimulus with inline constraints
- 📬 **Static Mailbox IPC** — Decoupled generator-to-BFM communication
- 🏗️ **Layered Architecture** — Modular, reusable verification components
- 🧠 **Associative Memory DUT** — Byte-accurate write and read-back model

## 🎯 Features

### Protocol Support
- **Transfer Types**: READ, WRITE
- **Burst Types**: FIXED, INCR, WRAP (RSVD excluded via constraint)
- **Burst Sizes**: 1-Byte through 128-Byte (7 levels)
- **Lock Types**: NORMAL, EXCLUSIVE, LOCKED (RSVD excluded via constraint)
- **Response Types**: OKAY, EXOKAY, SLVERR, DECERR
- **AXI Signals**: AWID, AWLEN, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWPROT, AWQOS, AWREGION + full symmetric read channel

### Verification Capabilities
- 🎲 **Constrained Random Stimulus** — Per-field constraints with soft defaults
- 📬 **Mailbox-Based IPC** — Thread-safe blocking FIFO between generator and BFM
- 🔁 **Write-then-Readback Test** — Address/length-matched read sequences to verify data integrity
- 🧪 **Multi-Test Selection** — Runtime test control via `+testname` plusarg
- 📡 **Virtual Interface Sharing** — Static `vif` handle accessible across all components
- 🧠 **Byte-Accurate Memory Model** — Size-aware byte-lane writes and reads

### Test Scenarios
- `test_5_wr` — 5 fully randomized write transactions
- `test_5_wr_5_rd` — 5 writes followed by 5 reads to the same addresses and lengths, verifying write integrity end-to-end

## 🏗️ Architecture

```
⚡ AXI Verification Environment
├── 🔗 axi_common (Static Shared Resources)
│   ├── 📬 gen2bfm mailbox       (IPC: generator → BFM)
│   ├── 🔌 virtual axi_intf vif  (shared interface handle)
│   └── 🏷️  testname string       (+plusargs test selection)
│
├── 🎲 axi_gen  (Stimulus Generator)
│   └── Constrained random axi_tx → put() to mailbox
│
├── 🚗 axi_bfm  (Bus Functional Model)
│   ├── Write Address Phase  (AWVALID/AWREADY handshake)
│   ├── Write Data Phase     (WVALID/WREADY + WLAST)
│   ├── Write Resp Phase     (BVALID/BREADY)
│   ├── Read Address Phase   (ARVALID/ARREADY handshake)
│   └── Read Data Phase      (RVALID/RREADY + RLAST)
│
├── 👁️  axi_mon  (Monitor — stub)
├── 📊 axi_cov  (Coverage — stub)
│
├── 🏛️  axi_env  (Environment)
│   └── fork: gen.run | bfm.run | mon.run | cov.run (join)
│
├── 📦 axi_tx   (Transaction Item)
│   └── addr, dataQ[$], len, id, wr_rd, brust_size,
│       brust_type, lock, prot, cashe, resp
│
├── 🔌 axi_intf  (AXI Interface)
│   └── All 5 AXI channels: AW · W · B · AR · R
│
├── ✅ axi_slave (DUT — AXI Slave)
│   ├── Associative memory model  mem[int]
│   ├── store_write_data()  — byte-lane accurate writes
│   ├── drive_read_data()   — size-aware burst reads
│   └── write_resp_phase()  — BRESP generation
│
└── 🔍 axi_assertion (SVA Module — stub)
```

### Component Details

| Component | Description | Key Functionality |
|-----------|-------------|-------------------|
| **🔗 axi_common** | Static shared resource hub | Mailbox IPC, virtual interface, testname |
| **📦 axi_tx** | Transaction data item | Constrained-random AXI fields, print() |
| **🎲 axi_gen** | Stimulus generator | Randomizes tx, puts to gen2bfm mailbox |
| **🚗 axi_bfm** | Bus Functional Model | Drives all 5 AXI channel handshakes |
| **👁️ axi_mon** | Protocol monitor | Observes and samples interface (stub) |
| **📊 axi_cov** | Functional coverage | AXI signal coverage collection (stub) |
| **🏛️ axi_env** | Verification environment | Forks all components in parallel |
| **🔌 axi_intf** | SystemVerilog interface | All AXI signals with clk/rst ports |
| **✅ axi_slave** | DUT — AXI slave model | Byte-accurate memory, all handshakes |
| **🔍 axi_assertion** | SVA assertion block | Protocol compliance checks (stub) |

## 📁 Directory Structure

```
📂 axi-protocol-verification/
├── 📄 README.md                        # This file
├── 📄 LICENSE                          # MIT License
├── 📁 src/
│   ├── ⚙️  typedef_enum.sv             # Protocol enums + axi_common class
│   ├── 🔌 axi_interface.sv             # AXI interface (all 5 channels)
│   ├── 📦 axi_tx.sv                    # Transaction class with constraints
│   ├── 🎲 axi_gen.sv                   # Constrained-random generator
│   ├── 🚗 axi_bfm.sv                   # Bus Functional Model
│   ├── 👁️  axi_mon.sv                  # Monitor (stub)
│   ├── 📊 axi_cov.sv                   # Coverage collector (stub)
│   ├── 🏛️  axi_env.sv                  # Verification environment
│   ├── 🔍 axi_assertion.sv             # SVA assertions (stub)
│   └── ✅ axi_slave.sv                 # AXI slave DUT
└── 📁 tb/
    └── 🧪 top.sv                       # Testbench top — clk, reset, env
```

## ⚡ Quick Start

### Prerequisites

Ensure you have the following tools available:

- 🔧 **Simulator**: Synopsys VCS / Cadence Xcelium / EDA Playground (SystemVerilog support)
- 📚 **Language**: SystemVerilog IEEE 1800-2017 (no UVM required)
- 🐧 **OS**: Linux (RHEL/Ubuntu/CentOS) or EDA Playground (browser-based)

### 1️⃣ Clone Repository

```bash
git clone https://github.com/SACHINUR17/axi-protocol-verification.git
cd axi-protocol-verification
```

### 2️⃣ Compile All Files

```bash
# Using VCS
vcs -sverilog \
  src/typedef_enum.sv \
  src/axi_interface.sv \
  src/axi_slave.sv \
  src/axi_tx.sv \
  src/axi_assertion.sv \
  src/axi_gen.sv \
  src/axi_bfm.sv \
  src/axi_mon.sv \
  src/axi_cov.sv \
  src/axi_env.sv \
  tb/top.sv \
  -o simv
```

### 3️⃣ Run a Test

```bash
# Run 5-write test
./simv +testname=test_5_wr

# Run write-then-readback test
./simv +testname=test_5_wr_5_rd

# Expected output:
# axi_gen::run
# axi_bfm::run
# write address phase
# write data phase
# write resp phase
# read address phase
# read data phase
```

### 4️⃣ EDA Playground

This project runs directly on [EDA Playground](https://edaplayground.com):
1. Upload all `.sv` files in include order
2. Set top module to `top`
3. Pass `+testname=test_5_wr` in the run options

## 🔧 Configuration

### Test Selection via Plusarg

```bash
# Select test at runtime — no recompilation needed
+testname=test_5_wr        # 5 randomized write transactions
+testname=test_5_wr_5_rd   # 5 writes + 5 matched reads (write-readback)
```

### Transaction Constraints

The `axi_tx` class uses layered constraints for clean, realistic stimulus:

```systemverilog
// Hard constraints — protocol-illegal values blocked
constraint rsvd_c {
  brust_type != RSVD_BRUSTT;   // No reserved burst type
  lock       != RSVD_LOCKT;    // No reserved lock type
}

// Soft constraints — realistic defaults, overridable inline
constraint soft_c {
  soft resp       == OKAY;      // Normal response
  soft brust_size == 2;         // 4-byte transfers
  soft brust_type == INCR;      // Incrementing burst
  soft prot       == 3'b0;      // Unprivileged, secure, data
  soft cashe      == 4'b0;      // Non-cacheable
  soft lock       == NORMAL;    // Normal access
}

// Burst depth tied to declared length
constraint dataq_c { dataQ.size() == len + 1; }
```

### Adding a New Test

```systemverilog
// In axi_gen.sv — extend the case block
case (axi_common::testname)

  "test_10_wr_rd" : begin
    for (int i = 0; i < 10; i++) begin
      tx = new();
      assert(tx.randomize() with { wr_rd == WRITE; brust_type == INCR; });
      axi_common::gen2bfm.put(tx);
      txQ[i] = new tx;
    end
    for (int i = 0; i < 10; i++) begin
      tx = new();
      assert(tx.randomize() with {
        wr_rd      == READ;
        addr       == txQ[i].addr;
        len        == txQ[i].len;
        brust_size == txQ[i].brust_size;
      });
      axi_common::gen2bfm.put(tx);
    end
  end

endcase
```

## 📊 Verification Plan

### Coverage Goals

| **Coverage Type** | **Target** | **Current** | **Status** |
|-------------------|------------|-------------|------------|
| 📊 Functional Coverage | 90% | Pending | 🔴 Stub |
| 🔍 Code Coverage | 85% | Pending | 🔴 Pending |
| 🎯 Assertion Coverage | 100% | Pending | 🔴 Stub |
| 🌐 Cross Coverage | 80% | Pending | 🔴 Pending |

### Test Scenarios

#### ✅ Basic Protocol Tests
- [x] Single WRITE transaction (address + data + response)
- [x] Single READ transaction (address + data burst)
- [x] WLAST assertion on final beat
- [x] BRESP handshake (BVALID/BREADY)
- [x] RLAST assertion on final read beat

#### 🔄 Advanced Protocol Tests
- [x] Multi-beat INCR burst writes
- [x] Multi-beat INCR burst reads
- [x] Write-then-readback data integrity check
- [ ] FIXED burst type
- [ ] WRAP burst type
- [ ] Interleaved read/write transactions
- [ ] Simultaneous AW + AR channel activity

#### 🚨 Error Scenarios
- [ ] SLVERR response injection
- [ ] DECERR response injection
- [ ] Invalid burst length
- [ ] Protocol violations (WLAST mismatch)
- [ ] Reset during active transaction

#### ⚡ Coverage Improvements
- [ ] Implement axi_mon — sample all 5 channels
- [ ] Implement axi_cov — covergroups per channel
- [ ] Implement axi_assertion — SVA for VALID/READY stability
- [ ] Scoreboard — expected vs actual data comparison

## 🎮 Running Simulations

### Command Line Options

```bash
# Basic run — 5 write transactions
./simv +testname=test_5_wr

# Write-readback integrity test
./simv +testname=test_5_wr_5_rd

# Enable verbose display
./simv +testname=test_5_wr +verbose

# Set random seed for reproducibility
./simv +testname=test_5_wr -svseed 42

# Dump waveforms
./simv +testname=test_5_wr -vcd dump.vcd
```

### Simulation Flow

```
[top] clk gen starts → rst asserted → reset_design_inputs()
       → rst deasserted → axi_common::vif = pif
       → env.run() → fork {gen, bfm, mon, cov} join
       → gen reads +testname → randomizes axi_tx → puts to mailbox
       → bfm gets from mailbox → drives AXI channels → slave responds
       → #2000 $finish
```

## 🔍 Debug Guide

### Common Issues & Solutions

#### ❌ Simulation Hangs at Write Response Phase
```systemverilog
// Root cause: bready never asserted while bvalid is high
// In axi_bfm write_resp_phase — check this logic:
task write_resp_phase(axi_tx tx);
  while (vif.bvalid == 0) begin
    @(posedge vif.aclk);
    vif.bready = 1;         // Assert bready before sampling bvalid
  end
  @(posedge vif.aclk);
  vif.bready = 0;
endtask

// Fix: assert bready early, not gated behind bvalid check
```

#### ❌ Read Data Phase Uses Wrong Ready Signal
```systemverilog
// Bug in axi_bfm read_data_phase:
vif.bready = 0;    // ← WRONG: bready is for write response channel

// Fix:
vif.rready = 0;    // ← CORRECT: use rready for read data channel
```

#### ❌ write_count Not Resetting Between Bursts
```systemverilog
// Bug in axi_slave: write_count is never cleared
// After the first burst, subsequent WLAST checks will fail

// Fix: reset write_count at the start of each burst
if (awvalid == 1) begin
  awready      = 1;
  write_count  = 0;   // ← add this reset here
  awaddr_t     = awaddr;
  // ...
end
```

#### ❌ Test Not Running — Check plusarg
```bash
# Verify plusarg is being passed correctly
./simv +testname=test_5_wr     # ← correct
./simv testname=test_5_wr      # ← missing '+', will not match
```

### Transaction Tracing

```systemverilog
// axi_tx has a built-in print() function — call it after randomization
tx = new();
assert(tx.randomize() with { wr_rd == WRITE; });
tx.print();   // prints addr, data, len, burst type, id, lock, prot, resp
```

### Signal-Level Debug

```systemverilog
// Add to top module for per-cycle signal visibility
always @(posedge clk) begin
  if (pif.awvalid || pif.wvalid || pif.bvalid ||
      pif.arvalid || pif.rvalid) begin
    $display("[%0t] AW:%b W:%b B:%b AR:%b R:%b",
      $time,
      pif.awvalid, pif.wvalid, pif.bvalid,
      pif.arvalid, pif.rvalid);
  end
end
```

## 🤝 Contributing

Contributions from the VLSI verification community are welcome! Here's how to help:

### 🔧 Areas for Contribution

1. **🚀 New Features**
   - Implement `axi_mon` — transaction-level monitoring of all 5 channels
   - Implement `axi_cov` — functional covergroups for burst type, size, length
   - Implement `axi_assertion` — SVA for VALID stability, WLAST accuracy, handshake rules
   - Add scoreboard — write-data vs read-data comparison
   - Add out-of-order transaction support

2. **🐛 Bug Fixes**
   - `write_count` reset between bursts in `axi_slave`
   - `rready` vs `bready` copy-paste fix in `read_data_phase`
   - `fork-join` completion issue caused by stub components

3. **📚 Documentation**
   - Verification plan expansion
   - Waveform annotation examples
   - AXI signal description table

### 📝 Contribution Process

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/add-axi-monitor`)
3. **Commit** your changes (`git commit -m 'Implement axi_mon with 5-channel sampling'`)
4. **Push** to the branch (`git push origin feature/add-axi-monitor`)
5. **Open** a Pull Request

### 🏷️ Coding Standards

- Follow **SystemVerilog Style Guide** (IEEE 1800-2017)
- Use **meaningful signal and task names**
- Include **inline comments** for all protocol-critical logic
- Add **display messages** for each transaction phase
- Update **README** when adding new tests or components

## 📚 Learning Resources

### 📖 Recommended Reading
- [AMBA AXI Protocol Specification — ARM IHI 0022B](https://developer.arm.com/documentation/ihi0022/b)
- [SystemVerilog for Verification — Spear & Tumbush](https://www.springer.com/gp/book/9781461407157)
- [UVM 1.2 User Guide — Accellera](https://www.accellera.org/images/downloads/standards/uvm/uvm_users_guide_1.2.pdf)

### 🛠️ Tools & Resources
- [EDA Playground](https://edaplayground.com) — Browser-based SystemVerilog simulator
- [ARM Developer — AXI Docs](https://developer.arm.com/Architectures/AMBA) — Official AMBA documentation
- [SystemVerilog LRM](https://ieeexplore.ieee.org/document/8299595) — Language reference

## 📞 Support & Community

### 💬 Get Help
- 🐛 **Issues**: [GitHub Issues](https://github.com/SACHINUR17/axi-protocol-verification/issues)
- 📧 **Email**: sachinur17@gmail.com

### 🌟 Show Your Support
If this project helps you in your verification journey, please:
- ⭐ **Star** this repository
- 🍴 **Fork** and contribute
- 📢 **Share** with your VLSI colleagues
- 💖 **Sponsor** the project

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Sachin UR

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

## 🏆 Acknowledgments

- **ARM Ltd.** for the AMBA AXI protocol specification (IHI 0022B)
- **IEEE** for the SystemVerilog language standard (1800-2017)
- **EDA Playground** for accessible browser-based simulation
- **Open Source Community** for feedback and contributions

---

<div align="center">

### ⚡ Ready to Start Verifying?

**[⭐ Star this repo](https://github.com/SACHINUR17/axi-protocol-verification)**

*Built with ❤️ by the VLSI Verification Community*

**Made for VLSI Engineers • Built with SystemVerilog • AMBA AXI Compliant**

</div>
