set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports CLK]
create_clock -add -period 10.000 -name CLK -waveform {0.000 5.000} [get_ports CLK]

set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports RST]

set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports Output[7]]
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports Output[6]]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports Output[5]]
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports Output[4]]
set_property -dict {PACKAGE_PIN W3 IOSTANDARD LVCMOS33} [get_ports Output[3]]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports Output[2]]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports Output[1]]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports Output[0]]