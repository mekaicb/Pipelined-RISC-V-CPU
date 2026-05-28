transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/Mekai/Desktop/Projects/RISC-V_CPU/Verilog/hdl {C:/Users/Mekai/Desktop/Projects/RISC-V_CPU/Verilog/hdl/control_unit.sv}

