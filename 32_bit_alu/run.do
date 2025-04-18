
vlib work
vmap work work

vlog rtl/ALU.v
vlog rtl/alu_if.sv

vlog tb/alu_txn.sv
vlog tb/alu_monitor.sv
vlog tb/alu_driver.sv
vlog tb/alu_scoreboard.sv
vlog tb/alu_agent.sv
vlog tb/alu_env.sv
vlog tb/alu_sequence.sv
vlog tb/alu_test.sv
vlog tb/top_tb.sv

vsim -uvm work.top_tb
add wave -r /*
run -all
