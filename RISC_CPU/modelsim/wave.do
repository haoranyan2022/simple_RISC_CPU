onerror {resume}
quietly set dataset_list [list vsim sim]
if {[catch {datasetcheck $dataset_list}]} {abort}
quietly WaveActivateNextPane {} 0
add wave -noupdate sim:/cputop/t_cpu/m_alu/clk
add wave -noupdate sim:/cputop/t_cpu/m_alu/alu_ena
add wave -noupdate sim:/cputop/t_cpu/m_alu/opcode
add wave -noupdate sim:/cputop/t_cpu/m_alu/data
add wave -noupdate sim:/cputop/t_cpu/m_alu/accum
add wave -noupdate sim:/cputop/t_cpu/m_alu/zero
add wave -noupdate sim:/cputop/t_cpu/m_alu/alu_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8590 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 217
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {117666 ns} {121474 ns}
