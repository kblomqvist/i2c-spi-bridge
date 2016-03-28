action = "simulation"
sim_tool = "ghdl"
top_module = "i2c_master_tb"

sim_post_cmd = "ghdl -r i2c_master_tb --stop-time=1ms --vcd=i2c_master_tb.vcd; gtkwave i2c_master_tb.vcd"

modules = {
  "local" : [ "../testbench/i2c_master_tb" ],
}
