# gr-kwan_cross
Integrating UHD and fpga files into one directory

IP block: noc_block_Latencytest.v
Usetage: Report aveage sample latency and packet latency (Both average window can be set by setting register)

##Install

```
mkdir build
cd build
cmake ..
make 
make install
```

###Importance file:
GNU Radio block decleartion                 : ./grc/ 
Modified USRP3 lib                          : ./modified-lib-file/ 
UHD block decleartion                       : ./rfnoc/blocks/ 
Latencytest IP & simulation lib             : ./rfnoc/fpga-src/
Testbench file                              : ./rfnoc/testbenches/