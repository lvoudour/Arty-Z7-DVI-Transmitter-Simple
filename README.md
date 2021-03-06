# Arty Z7 Simple DVI Transmitter
​
## Overview

Simple DVI transmitter for the Digilent Arty Z7 board. 

##### Features

* No Zynq
* Fixed display resolution 1080p (1920x1080 @ 60Hz)
* Simple output pattern (alternating colors every ~2 sec)
* No [HDCP](https://en.wikipedia.org/wiki/High-bandwidth_Digital_Content_Protection)
* No [DDC](https://en.wikipedia.org/wiki/Display_Data_Channel)

Code is part of a series of blog posts at [lvoudouris.com](https://www.lvoudouris.com):
​
1. [Intro and DVI Primer](https://lvoudouris.com/arty-z7-simple-dvi-transmitter-part-1/)
2. [Design Overview](https://lvoudouris.com/arty-z7-simple-dvi-transmitter-part-2/)
3. TODO

## Simulate and Build

Tested with

* Ubuntu 17.1
* Xilinx Vivado 2016.4
* Modelsim 10.5b Intel FPGA starter edition
* ghdl 0.36 (compiled from source) + GTKWave 3.3.79

Didn't test on Windows (will do at some point) so no guarantees. 
​
Before generating the bitstream first setup the board jumpers as in the following picture:

![dvi_setup_arty](https://www.lvoudouris.com/content/images/2018/01/dvi_setup_arty.jpg)

You will also need to:

* Connect the board with a USB cable to your PC
* Connect the HDMI OUT port of the board to the HDMI port of your monitor

In the top directory open a terminal and run `make build`. This will generate the bitstream in the build/bit directory. 

Then, with the Arty connected to your PC run `make program`.

[You should see 4 different colors alternating every ~2 seconds](https://lvoudouris.com/content/images/2018/01/dvi_demo.webm)

![dvi_demo](https://i.imgur.com/cLzIsML.jpg)

## Makefile options

`make build`

* Builds the bitstream. The bitstream will be located in the build/bit folder. Generated reports are placed in build/reports

`make program`

* Program the FPGA with the generated bitstream (you must first run `make build` to generate it). The Arty must be connected to the PC through the USB JTAG port.

`make vsim`

* Simulates the design with Modelsim. Modelsim binaries must be in the PATH

`make xsim`

* Simulates the design with Vivado xsim. Vivado binaries must be in the PATH

`make ghld-gtkwave`

* Simulates the design with GHDL and loads it in the GTKWave viewer. Both GHDL and GTKWave binaries must be in the PATH

`make clean`

* Cleans intermediate files generated by the tools. Doesn't clean the bit and reports folders

`make lint`

* Disregard that option, it's just for personal use (linting code in Sublime text editor)
