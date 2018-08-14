RFNOC_PATH 		:= ~/rfnoc

all:copy_xml install

copy_xml:
	@cp rfnoc/blocks/Latencytest.xml $(RFNOC_PATH)/share/uhd/rfnoc/blocks/
	@cp grc/kwan_cross_Latencytest.xml $(RFNOC_PATH)/share/gnuradio/grc/blocks/


copy_bitstream:
	@cp $(RFNOC_PATH)/src/uhd-fpga/usrp3/top/x300/build/usrp_x310_fpga_RFNOC_HG.bit ./

install:
	mkdir build
	cd	./build	&&	cmake ../
	make
	make test_tb
	make install	

compile:
	(cd ~/rfnoc/src/uhd-fpga/usrp3/tools/scripts && python uhd_image_builder.py Latencytest -I $(RFNOC_PATH)/src/rfnoc-kwan_cross/ -d x310 -t X310_RFNOC_HG -m 2  --fill-with-fifos)

compile-debug:
	(cd ~/rfnoc/src/uhd-fpga/usrp3/tools/scripts && python uhd_image_builder.py Latencytest ddc --GUI -I $(RFNOC_PATH)/src/rfnoc-kwan_cross/)

compile-all:
	(cd ~/rfnoc/src/uhd-fpga/usrp3/tools/scripts && python uhd_image_builder.py Latencytest -I $(RFNOC_PATH)/src/rfnoc-kwan_cross/ -d x310 -t X310_RFNOC_HG -m 2  --fill-with-fifos --clean-all)

sim:
	cd ./build && make noc_block_Latencytest_tb

download:
	uhd_image_loader --args "type=x300,addr=192.168.10.2" --fpga-path ./usrp_x310_fpga_RFNOC_HG.bit

detect:
	uhd_usrp_probe --args addr=192.168.10.2

create_test_input:
	rm create_input
	gcc -o create_input create_input.cpp && ./create_input && hexdump test_in.bin

extract_lib_file: 
	@cp -r ~/rfnoc/src/uhd-fpga/usrp3/lib/radio/ ./modified-lib-file/
	@cp -r ~/rfnoc/src/uhd-fpga/usrp3/lib/rfnoc/ ./modified-lib-file/


overwrite_lib_file: 
	@cp -r ./modified-lib-file/radio/ ~/rfnoc/src/uhd-fpga/usrp3/lib/
	@cp -r ./modified-lib-file/rfnoc/ ~/rfnoc/src/uhd-fpga/usrp3/lib/

install-background:
	sudo apt-get install git
	sudo apt-get install python-setuptools python-dev python-pip build-essential
	sudo pip install git+https://github.com/gnuradio/pybombs.git
	pybombs recipes add gr-recipes git+https://github.com/gnuradio/gr-recipes.git
	pybombs recipes add ettus git+https://github.com/EttusResearch/ettus-pybombs.git
	pybombs prefix init ~/rfnoc -R rfnoc -a rfnoc
 
clean-all:
	cd ./build make uninstall
	cd ../
	rm -rf ./build
	rm -rf ./rfnoc/testbenchs/noc_block_Latencytest_tb/xsim_proj/