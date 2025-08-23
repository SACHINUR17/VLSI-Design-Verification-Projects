#!/bin/bash

# xrun -Q -unbuffered '-timescale' '1ns/1ns' '-sysv' 'ahb_pkg.sv' '-access' '+rw' -uvmnocdnsextra -uvmhome $UVM_HOME $UVM_HOME/src/uvm_macros.svh design.sv testbench.sv  

xrun -Q -unbuffered -timescale 1ns/1ps -sysv  -access +rw \
    -uvm -uvmnocdnsextra -disable_sem2009  -nowarn RNDXCELON -svseed 1234 \
    -define DUMP_VCD \
    vutils_pkg.sv ahb_if.sv ahb_pkg.sv testbench.sv  +UVM_TESTNAME=ahb_test
