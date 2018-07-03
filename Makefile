RFNOC_PATH 		:= /home/vivado/rfnoc
RFNOC_PATH_PHWL		:= /home/phwl/rfnoc

all:copy_xml install

copy_xml:
	@cp rfnoc/blocks/latencytest.xml $(RFNOC_PATH)/share/uhd/rfnoc/blocks/
	@cp grc/Kwan_latencytest.xml $(RFNOC_PATH)/share/gnuradio/grc/blocks/

copy_xml_phwl:
	@cp rfnoc/blocks/latencytest.xml $(RFNOC_PATH_PHWL)/share/uhd/rfnoc/blocks/
	@cp grc/Kwan_latencytest.xml $(RFNOC_PATH_PHWL)/share/gnuradio/grc/blocks/

copy_bitstream:
	@cp $(RFNOC_PATH)/src/uhd-fpga/usrp3/top/x300/build/usrp_x310_fpga_RFNOC_HG.bit ./

install:
	rm -rf ./build
	mkdir build
	cd	./build	&&	cmake ../
	make
	make test_tb
	make install	

compile:
	(cd ~/rfnoc/src/uhd-fpga/usrp3/tools/scripts && python uhd_image_builder.py latencytest -I $(RFNOC_PATH)/src/rfnoc-Kwan/ -d x310 -t X310_RFNOC_HG -m 2  --fill-with-fifos)

compile-all:
	(cd ~/rfnoc/src/uhd-fpga/usrp3/tools/scripts && python uhd_image_builder.py latencytest -I $(RFNOC_PATH)/src/rfnoc-Kwan/ -d x310 -t X310_RFNOC_HG -m 2  --fill-with-fifos --clean-all)

sim:
	cd ./build && make noc_block_latencytest_tb

download:
	uhd_image_loader --args "type=x300,addr=192.168.10.2" --fpga-path ./usrp_x310_fpga_RFNOC_HG.bit

detect:
	uhd_usrp_probe

create_test_input:
	rm create_input
	gcc -o create_input create_input.cpp && ./create_input && hexdump test_in.bin