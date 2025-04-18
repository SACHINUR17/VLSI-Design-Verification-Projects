
# 🔢 32-bit ALU Design & Verification using Verilog + UVM

## 📌 Project Overview
This project implements a 32-bit Arithmetic Logic Unit (ALU) using Verilog and verifies it using Universal Verification Methodology (UVM). The ALU supports 8 arithmetic and logical operations, and the verification environment achieves 100% functional coverage using a modular UVM testbench.

---

## 🧠 ALU Operations
| Op Code | Operation           |
|--------:|----------------------|
| 0000    | Addition             |
| 0001    | Subtraction          |
| 0010    | Multiplication       |
| 0011    | Division             |
| 0100    | Logical Shift Left   |
| 0101    | Logical Shift Right  |
| 0110    | Rotate Left          |
| 0111    | Rotate Right         |

---

## 🛠️ UVM Testbench Components
- `alu_txn` – Transaction class
- `alu_seq` – Sequence generating test cases
- `alu_driver` – Drives inputs to the DUT
- `alu_monitor` – Monitors DUT outputs
- `alu_scoreboard` – Checks DUT outputs vs. expected
- `alu_agent` – Groups driver, monitor, config
- `alu_env` – Environment wrapping agent and scoreboard
- `alu_test` – Top-level test scenario

---

## 🧪 Verification Features
- ✅ Self-checking UVM testbench
- ✅ Assertion-based checking
- ✅ Random stimulus generation
- ✅ 100% functional coverage
- ✅ Scalable modular structure

---

## 🧰 Tools Used
- Verilog/SystemVerilog
- UVM (Universal Verification Methodology)
- ModelSim
- Cadence Xcelium

---

## 📁 Folder Structure
```
📦 alu_uvm_testbench
 ┣ 📂 src         # Verilog ALU design
 ┣ 📂 uvm         # UVM components
 ┣ 📂 tb          # Testbench top module
 ┣ 📜 alu_testplan.pdf  # Test plan
 ┗ 📜 README.md
```

---

## 📸 Sample Output / Waveform
![photo_2025-04-18_21-07-20](https://github.com/user-attachments/assets/5281268f-836d-4d34-9dcd-2cb34dd2b4ff)


---

## 📄 Test Plan
📥 [Download PDF Test Plan](./alu_testplan.pdf)

---

## 👨‍💻 Author
**U R Sachin**  
Electronics & Communication Engineer  
VLSI | UVM | Digital Design Verification Engineer  

[LinkedIn](https://linkedin.com/u-r-sachin) | [GitHub](https://github.com/SACHINUR17) 

---

## ⭐ Star This Repo If You Found It Useful!
