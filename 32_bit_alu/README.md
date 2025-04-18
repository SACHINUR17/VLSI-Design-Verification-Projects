# 🔧 32-bit ALU Design & Verification using UVM

![CI](https://img.shields.io/badge/build-passing-brightgreen)  
![License](https://img.shields.io/badge/license-MIT-blue)  
![Language](https://img.shields.io/badge/language-SystemVerilog-orange)

Welcome to the repository for the **Design and Verification of a 32-bit ALU** using **Verilog** and the **Universal Verification Methodology (UVM)**.  
This project demonstrates both RTL design and robust testbench creation using industry-grade verification techniques.

---

## 📁 Directory Structure

```bash
.
├── rtl/                # RTL Design files
│   ├── ALU.v           # 32-bit ALU implementation
│   └── alu_if.sv       # Interface connecting DUT and TB
│
├── tb/                 # UVM Testbench files
│   ├── alu_txn.sv
│   ├── alu_monitor.sv
│   ├── alu_driver.sv
│   ├── alu_scoreboard.sv
│   ├── alu_agent.sv
│   ├── alu_env.sv
│   ├── alu_sequence.sv
│   ├── alu_test.sv
│   └── top_tb.sv       # Top module instantiating DUT & TB
│
├── run.do              # QuestaSim/ModelSim simulation script
├── waveform/           # Waveform screenshots
│   ├── add_operation.png
│   └── zero_flag_check.png
├── demo/               # GIF demos of waveform
│   └── alu_demo.gif
```

---

## 💡 ALU Functionality

The 32-bit ALU performs the following operations based on a 3-bit function select line:
- `000` → AND  
- `001` → OR  
- `010` → ADD  
- `110` → SUB  
- `111` → SLT (Set on Less Than)

Additional outputs:
- `Zero Flag`: Indicates result is zero
- `Overflow`: Detects signed overflow
- `Carry Out`: From the MSB

---

## 🧪 Verification Features

✅ **UVM-Based Testbench**  
✅ **Functional Coverage**  
✅ **Scoreboarding & Result Comparison**  
✅ **Constrained Randomization**  
✅ **Self-checking Testcases**  
✅ **Assertions Ready (Future Scope)**

---

## ▶️ How to Run

### 🛠️ Prerequisites
- [QuestaSim / ModelSim](https://eda.sw.siemens.com/en-US/ic/modelsim/)
- UVM Library (pre-installed with most EDA tools)

### 🚀 Simulation Steps

```bash
# From the project root:
vsim -do run.do
```

This will:
- Compile RTL and TB
- Launch simulation
- Display waveform viewer (GUI) or log (CLI)

---

## 🖼️ Waveform Snapshots

| ADD Operation with Carry | Zero Flag after AND |
|--------------------------|---------------------|
| ![ADD](waveform/add_operation.png) | ![Zero](waveform/zero_flag_check.png) |

---

## 🎞️ Demo GIF

![ALU Demo](demo/alu_demo.gif)

---

## 📈 Future Improvements
- Add assertions using SystemVerilog `assert`
- Include Scoreboard enhancements with coverage analysis
- Integrate with GitHub Actions for CI (continuous integration)

---

## 🤝 Contribution

Feel free to raise issues or submit pull requests.  
For feature requests or bug fixes, contact me via [LinkedIn](https://linkedin.com/in/yourprofile) or open a GitHub issue!

---

## 📜 License

This project is open-sourced under the [MIT License](LICENSE).

---

> Created with 💻 by [Your Name] | Electronics & Communication | VLSI Enthusiast
