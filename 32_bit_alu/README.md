
# 🔢 Design & Verification of 32-bit ALU using Verilog + UVM testbench

## 📌 Project Overview
This project implements a 32-bit Arithmetic Logic Unit (ALU) using Verilog and verifies it using Universal Verification Methodology (UVM). The ALU supports 8 arithmetic and logical operations, and the verification environment achieves 100% functional coverage using a modular UVM testbench.
![capture1](https://github.com/user-attachments/assets/2647de5e-b424-4296-bb4c-71620ac847f2)
![capture11](https://github.com/user-attachments/assets/2f6c82fa-e0b8-4c72-bcfd-98b5b49f9d96)
![IMG_20250418_211459](https://github.com/user-attachments/assets/f676b002-7022-466a-ad80-8ece21da554f)

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
![IMG_20250418_211311](https://github.com/user-attachments/assets/912f7af2-7ad4-4172-ba9c-3c7c716b95af)



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
