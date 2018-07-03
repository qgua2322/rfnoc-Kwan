#!/bin/bash -f
xv_path="/opt/Xilinx/Vivado/2015.4"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 573e4984b7e54422ba7dbec5fb02e4cf -m64 --debug all --relax --mt 8 -d "WORKING_DIR="/home/vivado/rfnoc/src/rfnoc-Kwan/rfnoc/testbenches/noc_block_latencytest_tb"" -L work -L unisims_ver -L unimacro_ver -L secureip --snapshot noc_block_latencytest_tb_behav work.noc_block_latencytest_tb work.glbl -log elaborate.log -timescale 1ns/1ns
