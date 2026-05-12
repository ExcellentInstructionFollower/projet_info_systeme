set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports CLK]
create_clock -add -period 10.000 -name CLK -waveform {0.000 5.000} [get_ports CLK]

set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports RST]

set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports Output]