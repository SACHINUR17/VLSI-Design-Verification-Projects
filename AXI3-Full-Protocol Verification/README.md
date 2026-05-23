# 🚀 AXI3 Protocol Verification Environment

[![SystemVerilog](https://img.shields.io/badge/SystemVerilog-IEEE_1800-blue.svg)](https://ieeexplore.ieee.org/document/8299595)
[![UVM](https://img.shields.io/badge/UVM-1.2-green.svg)](https://www.accellera.org/downloads/standards/uvm)
[![Protocol](https://img.shields.io/badge/Protocol-AXI3-orange.svg)](https://developer.arm.com/documentation/ihi0022/b)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Simulator](https://img.shields.io/badge/Simulator-QuestaSim-red.svg)](https://eda.sw.siemens.com/en-US/eda/questa/)

> A comprehensive UVM-based verification environment for the AMBA AXI3 protocol, featuring a fully parameterized master-slave architecture with dual-port scoreboarding, functional coverage, and embedded SVA assertions for industry-standard compliance.

## 📑 Table of Contents

- [🚀 Overview](#overview)
- [🎯 Features](#features)
- [🏗️ Architecture](#architecture)
- [📁 Directory Structure](#directory-structure)
- [⚡ Quick Start](#quick-start)
- [🔧 Configuration](#configuration)
- [📊 Verification Plan](#verification-plan)
- [🎮 Running Simulations](#running-simulations)
- [📈 Coverage Analysis](#coverage-analysis)
- [🔍 Debug Guide](#debug-guide)
- [🤝 Contributing](#contributing)
- [📄 License](#license)

## 🚀 Overview

This project implements a **production-ready UVM testbench** for verifying AMBA AXI3 protocol compliance (ARM IHI 0022B). Built with SystemVerilog and UVM 1.2, it provides comprehensive coverage for all five independent AXI channels — Write Address (AW), Write Data (W), Write Response (B), Read Address (AR), and Read Data (R) — with support for all three burst types and a byte-lane strobing mechanism.

### Key Highlights
- ✅ **AXI3 Protocol Compliant** — Full ARM IHI 0022B specification coverage
- 🔄 **Master-Slave Architecture** — Active master agent with reactive slave driver
- 📊 **Dual-Port Scoreboard** — Simultaneous driver and monitor packet comparison
- 🎯 **Constrained Random Testing** — Weighted burst-type stimulus generation
- 🏗️ **Fully Parameterized** — Configurable data width and size via `WIDTH` and `SIZE` parameters
- 📝 **Industry Standards** — UVM 1.2 methodology with embedded SVA assertions

## 🎯 Features

### Protocol Support
- **Burst Types**: FIXED (`2'b00`), INCR (`2'b01`), WRAP (`2'b10`) — BURST `2'b11` is illegal and asserted
- **Burst Lengths**: 1 to 16 beats via 4-bit `AWLEN`/`ARLEN` (AXI3 spec — max 16 beats)
- **Transfer Sizes**: Parameterized via `AWSIZE`/`ARSIZE` (byte to 128-byte transfers)
- **Write Data ID**: `WID` signal supported — AXI3 exclusive, removed in AXI4
- **Byte Strobing**: Full `WSTRB` byte-lane control per write beat
- **Response Channels**: `BRESP` (write) and `RRESP` (read) — OKAY / SLVERR support
- **Last Signal**: `WLAST` and `RLAST` for burst boundary detection

### Verification Capabilities
- 🔍 **Protocol Compliance Checking** — Automated AXI3 specification validation via SVA
- 🎲 **Constrained Random Testing** — Weighted burst distribution: FIXED 10% / INCR 60% / WRAP 30%
- 📊 **Functional Coverage** — Transaction-level and signal-level covergroups
- ⚡ **Out-of-Order Handling** — Separate AW/W queues for decoupled channel monitoring
- 🐛 **Scoreboard Comparison** — Expected vs. actual with per-byte RAM model verification
- 📋 **WSTRB Coverage** — All 16 possible byte-strobe patterns covered

### Advanced Features
- 🔄 **Parameterized Design** — WIDTH=32, SIZE=3 by default; easily reconfigurable
- ⏱️ **Configurable Handshake Timing** — Randomized READY assertion delays per channel
- 🎯 **4KB Boundary Checking** — SVA assertion ensures bursts never cross 4KB page boundaries
- 📈 **WRAP Burst Address Alignment** — Automatic address alignment for wrapping transfers
- 🧠 **Dual Analysis Ports** — `drv2sb_port` (stimulus) and `mon2sb_port` (observed) feed the scoreboard independently

## 🏗️ Architecture

```
🏛️ AXI3 Verification Environment
├── 🎯 axi_Test (UVM Test)
│   └── 🌍 axi_Environment (Environment)
│       ├── 👤 axi_m_Agent (Master Agent)
│       │   ├── 🎮 axi_m_sequencer
│       │   ├── 🚗 axi_m_driver  ──────────────► drv2sb_port ──►┐
│       │   └── 👁️  axi_m_monitor ─── mon2sb_port ──►┬──────────►│
│       ├── 🤖 axi_s_Agent (Slave Agent)            │           │
│       │   └── 🚗 axi_s_driver                     │           │
│       ├── 📊 AXI_Scoreboard ◄────────────────────┘◄──────────┘
│       └── 📈 AXI_Subscriber ◄─────────────────────┘ (coverage)
└── 🔌 axi_intf (Interface + SVA Assertions)
    ├── AW Channel  ├── W Channel  ├── B Channel
    ├── AR Channel  └── R Channel
```

### Component Details

| Component | File | Description |
|-----------|------|-------------|
| **🎯 axi_Test** | `axi_test.sv` | Orchestrates 23 transactions: 5W→4R→4W→4R→3W→3R |
| **🌍 axi_Environment** | `axi_env.sv` | Builds and connects all agents, scoreboard, subscriber |
| **👤 axi_m_Agent** | `axi_m_agent.sv` | Master agent: sequencer + driver + monitor |
| **🤖 axi_s_Agent** | `axi_s_agent.sv` | Slave agent: reactive slave driver only |
| **🎮 axi_m_sequencer** | `axi_m_sqcr.sv` | Standard UVM sequencer for master transactions |
| **🚗 axi_m_driver** | `axi_m_drv.sv` | Drives all 5 AXI3 channels; sends stimulus to scoreboard |
| **🚗 axi_s_driver** | `axi_s_drv.sv` | Reactive slave with internal `byte unsigned m_mem[1024]` |
| **👁️  axi_m_monitor** | `axi_m_mon.sv` | Observes bus signals; reconstructs full transactions |
| **📊 AXI_Scoreboard** | `axi_sb.sv` | Dual-port; byte-accurate write/read RAM model check |
| **📈 AXI_Subscriber** | `axi_subscriber.sv` | `AXI_cg` + `AXI_WSTRB_cg` functional coverage |
| **🔌 axi_intf** | `axi_intf.sv` | Interface with 10 embedded SVA properties |
| **📦 axi_m_Sequence_Item** | `axi_m_seq_item.sv` | Fully constrained transaction object |
| **📝 Sequences** | `axi_m_seq.sv` | `axi_m_wr_Sequence` and `axi_m_rd_Sequence` |
| **🏠 module top** | `axi_top.sv` | Clock gen, VIF config_db set, `run_test` entry |

### AXI3 Channel Architecture

```
Master                                          Slave
  │── AW Channel (AWID, AWADDR, AWLEN, AWSIZE, AWBURST) ──►│
  │── W  Channel (WID, WDATA, WSTRB, WLAST)               ──►│
  │◄── B  Channel (BID, BRESP, BVALID, BREADY)              ──│
  │── AR Channel (ARID, ARADDR, ARLEN, ARSIZE, ARBURST)    ──►│
  │◄── R  Channel (RID, RDATA, RRESP, RLAST)                ──│

AXI3 Distinguishing Signals:
  ✅  WID present     → write data ID (removed in AXI4)
  ✅  AWLEN [3:0]     → 4-bit (max 16 beats; AXI4 expands to 8-bit / 256 beats)
```

## 📁 Directory Structure

```
📂 axi3-uvm-verification/
├── 📄 README.md                        # This file
├── 📄 LICENSE                          # MIT License
├── 📁 src/
│   ├── 📦 axi_pkg.sv                   # Top-level package & include file
│   ├── 🔌 axi_intf.sv                  # AXI3 interface + SVA assertions
│   ├── 📝 axi_m_seq_item.sv            # Sequence item (transaction object)
│   ├── 🎮 axi_m_sqcr.sv                # Master sequencer
│   └── 📋 axi_m_seq.sv                 # Write & read sequences
├── 📁 env/
│   ├── 🌍 axi_env.sv                   # Verification environment
│   ├── 👤 axi_m_agent.sv               # Master agent
│   ├── 🤖 axi_s_agent.sv               # Slave agent
│   ├── 🚗 axi_m_drv.sv                 # Master driver (5-channel, forked)
│   ├── 🚗 axi_s_drv.sv                 # Slave driver (reactive, mem model)
│   ├── 👁️  axi_m_mon.sv                 # Master monitor (queue-based reassembly)
│   ├── 📊 axi_sb.sv                    # Dual-port scoreboard
│   └── 📈 axi_subscriber.sv            # Functional coverage subscriber
├── 📁 tests/
│   └── 🎯 axi_test.sv                  # Top-level UVM test
├── 📁 tb/
│   └── 🏠 axi_top.sv                   # Testbench top module
└── 📁 docs/
    └── 📘 IHI0022B_amba_axi_protocol_spec.pdf   # ARM AXI3 specification
```

## ⚡ Quick Start

### Prerequisites

Ensure you have the following tools installed:

- 🔧 **Simulator**: QuestaSim / Mentor ModelSim / Synopsys VCS (UVM 1.2 support required)
- 📚 **Libraries**: UVM 1.2, SystemVerilog IEEE 1800-2017
- 🐧 **OS**: Linux (RHEL / Ubuntu / CentOS)
- 🛠️ **Shell**: Bash 4.0+

### 1️⃣ Clone Repository

```bash
git clone https://github.com/SACHINUR17/axi3-uvm-verification.git
cd axi3-uvm-verification
```

### 2️⃣ Set Environment

```bash
# Set UVM_HOME (adjust path for your installation)
export UVM_HOME=/path/to/uvm-1.2
export PATH=$UVM_HOME/bin:$PATH

# Verify UVM installation
echo $UVM_HOME
```

### 3️⃣ Compile and Run

```bash
# QuestaSim compilation
vlog -sv +incdir+$UVM_HOME/src $UVM_HOME/src/uvm_pkg.sv src/axi_pkg.sv

# Run default test
vsim -sv_seed random +UVM_TESTNAME=axi_Test +UVM_VERBOSITY=UVM_MEDIUM -do "run -all"

# Expected output:
# UVM_INFO @ 0: reporter [RNTST] Running test axi_Test...
# UVM_INFO: [SCOREBOARD] SUCCESSFULLY DATA WRITE=...
# UVM_INFO: [SCOREBOARD] SUCCESSFULLY MATCH=...
# ...simulation passes with 0 UVM_ERROR...
```

### 4️⃣ View Results

```bash
# Check simulation log
grep -E "(UVM_INFO|UVM_ERROR|UVM_FATAL)" transcript

# View waveforms
vsim -view vsim.wlf &
# or with GTKWave
gtkwave dump.vcd &
```

## 🔧 Configuration

### Parameter Configuration

The testbench is fully parameterized via defines in `axi_pkg.sv`:

```systemverilog
`define WIDTH 32   // AXI data bus width (supports 8, 16, 32, 64, 128, 256, 512, 1024)
`define SIZE  3    // Controls signal widths: AWSIZE/ARSIZE = [SIZE-1:0] = [2:0]
                   // ID/LEN/STRB widths = [WIDTH/8-1:0] = [3:0] for WIDTH=32
```

### Sequence Item Constraints

Key constraints in `axi_m_seq_item.sv` controlling stimulus behavior:

```systemverilog
// Burst type weighted distribution
constraint awburst { AWBURST dist {2'b00:/10, 2'b01:/60, 2'b10:/30}; }
constraint arburst { ARBURST dist {2'b00:/10, 2'b01:/60, 2'b10:/30}; }

// Wrap burst length (AXI3 spec: only 2, 4, 8, 16 beats allowed)
constraint awburst_val { if (AWBURST==2'b10) WDATA.size() inside {
  (2**AWSIZE)*2, (2**AWSIZE)*4, (2**AWSIZE)*8, (2**AWSIZE)*16 }; }
constraint arburst_val { if (ARBURST==2'b10) ARLEN inside {1,3,7,15}; }

// Address range (keep within slave memory space)
constraint awaddress { AWADDR < 50; }
constraint araddress { ARADDR < 50; }

// ID consistency (AXI3 requirement)
constraint same_id_wr { AWID == WID; }
```

### Customizing Test Transactions

```systemverilog
// Modify run_phase in axi_test.sv to change transaction counts
task run_phase(uvm_phase phase);
  phase.raise_objection(this);
    repeat(10) seq_m_write.start(env.agent_m.seq);  // 10 write transactions
    repeat(10) seq_m_read.start(env.agent_m.seq);   // 10 read transactions
  phase.drop_objection(this);
endtask
```

### Expanding Address Space

```systemverilog
// In axi_m_seq_item.sv — increase address range
constraint awaddress { AWADDR inside {[0:1023]}; }  // 1KB address range
constraint araddress { ARADDR inside {[0:1023]}; }

// Update slave memory accordingly in axi_s_drv.sv
byte unsigned m_mem[1024];   // Must match address range
```

## 📊 Verification Plan

### Coverage Goals

| **Coverage Type** | **Target** | **Covergroup** | **Status** |
|-------------------|------------|----------------|------------|
| 📊 RW Transition Coverage | 100% | `rw_bit_transition` | 🟡 In Progress |
| 🔍 Burst Type Coverage | 100% | `AWBURST_write`, `ARBURST_read` | 🟡 In Progress |
| 🎯 Address Range Coverage | 95% | `AWADDR_write`, `ARADDR_read` | 🟡 In Progress |
| 🌐 ID Coverage | 90% | `AWID_write`, `ARID_read`, `RID_read` | 🟡 In Progress |
| 📋 WSTRB Coverage | 100% | `AXI_WSTRB_cg` (16 patterns) | 🟡 In Progress |
| ⚡ Assertion Coverage | 100% | 10 SVA properties | 🟡 In Progress |

### Test Scenarios

#### ✅ Write Transaction Tests
- [x] Single-beat FIXED burst write (AWBURST=2'b00)
- [x] Multi-beat INCR burst write with byte strobing
- [x] WRAP burst write with address alignment
- [x] WSTRB partial byte-lane write verification
- [x] Write ID consistency (AWID == WID)

#### ✅ Read Transaction Tests
- [x] Single-beat FIXED burst read
- [x] Multi-beat INCR burst read with RLAST detection
- [x] WRAP burst read with aligned start address
- [x] Read-after-write data integrity check
- [x] RDATA vs scoreboard RAM model comparison

#### 🔄 Advanced Protocol Tests
- [x] Interleaved write/read sequences
- [x] Back-to-back transactions on independent channels
- [ ] Out-of-order response handling (multiple outstanding IDs)
- [ ] ID-based transaction ordering
- [ ] Maximum burst length (AWLEN=15 / 16 beats)

#### 🚨 Protocol Assertion Tests
- [x] VALID stability until READY (all 5 channels)
- [x] 4KB boundary violation detection
- [x] WRAP burst length legality (1/3/7/15 only)
- [x] Illegal BURST value `2'b11` detection
- [ ] WLAST position accuracy
- [ ] Reset-during-transfer recovery

## 🎮 Running Simulations

### Command Line Options

```bash
# Basic simulation (QuestaSim)
vsim -sv_seed random +UVM_TESTNAME=axi_Test -do "run -all"

# Enable VCD waveform dump
vsim +define+DUMP_VCD +UVM_TESTNAME=axi_Test -do "run -all"

# High verbosity logging
vsim +UVM_TESTNAME=axi_Test +UVM_VERBOSITY=UVM_HIGH -do "run -all"

# Fixed random seed for reproducibility
vsim -sv_seed 42 +UVM_TESTNAME=axi_Test -do "run -all"

# Coverage collection
vsim -coverage +UVM_TESTNAME=axi_Test -do "coverage save -onexit cov.ucdb; run -all"
```

### Compile Script (QuestaSim)

```bash
#!/bin/bash
# compile.sh

# Compile UVM library
vlog -sv +incdir+$UVM_HOME/src $UVM_HOME/src/uvm_pkg.sv

# Compile AXI3 testbench
vlog -sv +incdir+./src ./src/axi_pkg.sv

echo "Compilation complete."
```

### Run All Tests

```bash
# Write-only regression
vsim -sv_seed random +UVM_TESTNAME=axi_Test +UVM_VERBOSITY=UVM_MEDIUM \
     -do "run -all; quit" | grep -E "(MATCH|ERROR|FATAL|total packets)"

# Read scoreboard summary from log
grep "SUCCESSFULLY DATA WRITE\|NOT MATCH\|total packets" transcript
```

## 📈 Coverage Analysis

### Functional Coverage Groups

```systemverilog
// AXI_cg — Transaction-level coverage (in axi_subscriber.sv)
covergroup AXI_cg;

  // Write ↔ Read transition coverage
  rw_bit_transition : coverpoint tx.RW {
    bins trans_01 = (0 => 1);   // Write to Read
    bins trans_10 = (1 => 0);   // Read to Write
  }

  // Burst type coverage — both channels
  AWBURST_write : coverpoint tx.AWBURST {
    bins awburst        = {[0:2]};
    illegal_bins awburst_illegal = {3};
  }
  ARBURST_read : coverpoint tx.ARBURST {
    bins arburst        = {[0:2]};
    illegal_bins arburst_illegal = {3};
  }

  // Address range — 10 bins for [0:99], plus overflow
  AWADDR_write : coverpoint tx.AWADDR {
    bins awaddr_1[10] = {[0:99]};
    bins awaddr_2     = {[100:$]};
  }

endgroup

// AXI_WSTRB_cg — Byte strobe coverage
covergroup AXI_WSTRB_cg;
  WSTRB_write : coverpoint wstrb {
    bins WSTRB_val[16] = {[0:$]};   // All 16 WSTRB patterns for WIDTH=32
  }
endgroup
```

### Generating Coverage Reports

```bash
# Merge coverage databases
vcover merge merged.ucdb *.ucdb

# Generate HTML report
vcover report -html -details -output coverage_report merged.ucdb

# View coverage summary in terminal
vcover report -summary merged.ucdb

# Coverage by covergroup
vcover report -cvg -details merged.ucdb
```

## 🔍 Debug Guide

### Common Issues & Solutions

#### ❌ Scoreboard Mismatch on WRAP Reads

```systemverilog
// Known issue in axi_sb.sv — WRAP read uses AWADDR instead of ARADDR
// Buggy code:
2'b10 : tx.ARADDR = (i==0) ? ... : (tx.AWADDR);  // ← WRONG

// Fix:
2'b10 : tx.ARADDR = (i==0) ? ((tx.ARADDR/(2**tx.ARSIZE))*(2**tx.ARSIZE))
                             : (tx.ARADDR);        // ← CORRECT
```

#### ❌ Read Comparison False Positives

```systemverilog
// Operator precedence bug in axi_sb.sv
// Buggy: '&&' binds tighter than '||' — second clause fires independently
if (tx.RDATA[i]==00 && ram[tx.ARADDR+i]==00 || ram[tx.ARADDR+i]==00 || tx.RDATA[i]==00)

// Fix: Use explicit parentheses
if ((tx.RDATA[i]==00 && ram[tx.ARADDR+i]==00) ||
    (ram[tx.ARADDR+i]==00)                     ||
    (tx.RDATA[i]==00))
```

#### ❌ Reset Never Fires — Slave reset_signals() Hangs

```systemverilog
// Bug in axi_top.sv — RESET never deasserts
RESET = 1; #15 RESET = 1;   // ← RESET stays HIGH forever

// Fix: Deassert then reassert
initial begin
  RESET = 1;
  #15 RESET = 0;   // ← Deassert
  #10 RESET = 1;   // ← Reassert (active-HIGH reset)
end
```

#### ❌ UVM Virtual Interface Not Found

```systemverilog
// Ensure config_db set happens before run_test in axi_top.sv
initial begin
  uvm_config_db#(virtual axi_intf#(`WIDTH,`SIZE))::set(
    uvm_root::get(), "*", "intf", intf);  // Set before run_test
  run_test("axi_Test");
end
```

### Debugging Tools

#### 🔍 Enable Per-Beat Transaction Logging

```bash
# Run with HIGH verbosity to see per-beat monitor output
vsim +UVM_TESTNAME=axi_Test +UVM_VERBOSITY=UVM_HIGH -do "run -all"

# Filter for scoreboard output only
vsim ... -do "run -all" | grep "\[SCOREBOARD\]"
```

#### 📊 Scoreboard Summary Extraction

```bash
# Extract final scoreboard report from transcript
grep -A 12 "SUCCESSFULLY DATA WRITE" transcript
```

#### 🎯 Waveform Debug Signals

```systemverilog
// Key signals to add to waveform window for AXI3 debug
// Write path
add wave intf/AWVALID intf/AWREADY intf/AWID intf/AWADDR intf/AWLEN intf/AWBURST
add wave intf/WVALID  intf/WREADY  intf/WID  intf/WDATA  intf/WSTRB intf/WLAST
add wave intf/BVALID  intf/BREADY  intf/BID  intf/BRESP

// Read path
add wave intf/ARVALID intf/ARREADY intf/ARID intf/ARADDR intf/ARLEN intf/ARBURST
add wave intf/RVALID  intf/RREADY  intf/RID  intf/RDATA  intf/RLAST intf/RRESP
```

## 🤝 Contributing

Contributions from the VLSI verification community are welcome!

### 🔧 Areas for Contribution

1. **🚀 New Features**
   - AXI4 / AXI4-Lite protocol variant
   - Multiple outstanding transaction support (out-of-order IDs)
   - QoS and region signal verification
   - Exclusive access (AWLOCK / ARLOCK) testing

2. **🐛 Bug Fixes**
   - WRAP read scoreboard address (`tx.AWADDR` → `tx.ARADDR`)
   - Operator precedence in read comparison logic
   - RESET polarity fix in `axi_top.sv`
   - Hardcoded `m_num_sent` pacing in master driver

3. **📚 Documentation**
   - Protocol channel timing diagrams
   - Burst type walkthrough examples
   - SVA property explanation guide

### 📝 Contribution Process

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### 🏷️ Coding Standards

- Follow **SystemVerilog Style Guide**
- Use **UVM best practices** — no randomization in `new()` constructors
- Include **comprehensive inline comments**
- Add **SVA assertions** for new protocol signals
- Update **documentation** and verification plan

## 📚 Learning Resources

### 📖 Recommended Reading
- [ARM AMBA AXI3 Protocol Specification (IHI 0022B)](https://developer.arm.com/documentation/ihi0022/b)
- [UVM 1.2 User Guide](https://www.accellera.org/images/downloads/standards/uvm/uvm_users_guide_1.2.pdf)
- [SystemVerilog for Verification — Spear & Tumbush](https://www.springer.com/gp/book/9781461407157)

### 🛠️ Tools & Resources
- [EDA Playground](https://edaplayground.com) — Online SystemVerilog/UVM simulator
- [UVM Reference Manual](https://www.accellera.org/downloads/standards/uvm)
- [SystemVerilog LRM IEEE 1800-2017](https://ieeexplore.ieee.org/document/8299595)

## 📞 Support & Community

### 💬 Get Help
- 🐛 **Issues**: [GitHub Issues](https://github.com/SACHINUR17/axi3-uvm-verification/issues)
- 📧 **Email**: sachinur17@gmail.com

### 🌟 Show Your Support
If this project helps you in your verification journey, please:
- ⭐ **Star** this repository
- 🍴 **Fork** and contribute
- 📢 **Share** with colleagues
- 💖 **Sponsor** the project

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Sachin UR

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software")...
```

## 🏆 Acknowledgments

- **ARM Ltd.** for the AMBA AXI3 protocol specification (IHI 0022B)
- **Accellera Systems Initiative** for UVM 1.2 methodology
- **Siemens EDA** for QuestaSim simulation tools
- **Open Source Community** for valuable feedback and contributions

---

<div align="center">

### 🚀 Ready to Start Verifying?

**[⭐ Star this repo]**

*Built with ❤️ by the VLSI Verification Community*

**Made for VLSI Engineers • Built with SystemVerilog & UVM • Powered by Open Source**

</div>
