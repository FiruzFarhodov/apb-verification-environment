module top;
  logic        clk = 0;
  logic        rst_n;
  logic        psel;
  logic        penable;
  logic        pwrite;
  logic [31:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic        pready;
    
  always #1 clk = ~clk;
  
	// Instantiating Interface
  apb_if vif(clk);
	// connecting DUT to dut_port
  APB dut (
    .vif(vif.dut_port)
  );
  // connecting testbench to tb_port
  tb test (
    .vif(vif.tb_port) 
  );
  // connecting APB_sva to the sva port
  APB_sva sva_inst (
    .vif(vif.sva_port)
  );
endmodule

interface apb_if(input logic clk);
  logic rst_n;
  logic psel;
  logic penable;
  logic pwrite;
  logic [31:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic 	   pready;
      
  //clocking used in testbench 
  clocking cb @(posedge clk);
    default input #1step output #1;
    output rst_n, psel, penable, pwrite, paddr, pwdata;
    input prdata, pready;
  endclocking 
  //modport to DUT 'APB' module
  modport dut_port(
    input rst_n, psel, penable, pwrite, paddr, pwdata, clk,
    output prdata, pready
  );
  // modport to testbench
  modport tb_port (
    clocking cb,
  	output rst_n
  );  
  //modport for assertion module
  modport sva_port(
    input clk, rst_n, psel, penable, pwrite, paddr, pwdata, prdata, pready
  );
endinterface

//Master
program tb(
	apb_if.tb_port vif
);
  // simple covergroup checking pready
  covergroup apb_cg @(vif.cb);
    option.per_instance = 1;
    
    coverpoint vif.cb.pready {
      bins write_op = {1};
      bins read_op  = {0};
    }
  endgroup
  
  initial begin
    apb_cg cg = new();
    @vif.cb;
    vif.cb.rst_n   <= 0;
    vif.cb.psel    <= 0;
    vif.cb.penable <= 0;
    vif.cb.pwrite  <= 1;
    vif.cb.paddr   <= 32'd34;
    vif.cb.pwdata  <= 32'd197;
    #1
    vif.cb.rst_n   <= 1;
    vif.cb.psel    <= 1;
    vif.cb.penable <= 1;
    #1
    $monitor("prdata: %d | pready: %d | state: %s", vif.cb.prdata, vif.cb.pready, top.dut.current_state);
    #1
    #3
    #5
    vif.cb.penable <= 1;
    vif.cb.pwrite  <= 0;
    vif.cb.paddr   <= 32'd34;
    #10
    $display("Coverage of pready: %0.2f%%", cg.get_inst_coverage());
    $finish;
  end
endprogram

module APB_sva(
  apb_if.sva_port vif
);
  
   property storagein;
     @(posedge vif.clk) 
     !vif.rst_n |-> top.dut.current_state == IDLE;
   endproperty
  
  assert property (storagein)
    $display("CONCURRENT ASSERTION PASSSED: RST_N causes current_state to be IDLE");
    else 
      $display("CONCURRENT ASSERTION FAILED: RST_N did not change current_state");
endmodule

/*

CONCURRENT ASSERTION PASSSED: RST_N causes current_state to be IDLE
prdata:          x | pready: x | state: IDLE
prdata:          0 | pready: 0 | state: SETUP
prdata:          0 | pready: 0 | state: ACCESS
prdata:          0 | pready: 1 | state: ACCESS
prdata:        197 | pready: 1 | state: ACCESS
Coverage: 100.00%


*/

