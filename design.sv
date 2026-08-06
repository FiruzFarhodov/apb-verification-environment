typedef enum logic [1:0]{
  IDLE   = 2'b00,
  SETUP	 = 2'b01,
  ACCESS = 2'b10
} states;

//Slave
module APB (
  apb_if.dut_port vif
);
  
  states current_state, next_state;
  
  bit [31:0] storage [0:255]; // addr and 
  
  always_comb begin
    case(current_state)  
    
      IDLE : begin
        if(vif.psel) begin
          vif.prdata     = 0;
     	  vif.pready     = 0;
          next_state = SETUP;
        end else begin
          next_state = IDLE;
        end
      end
      
      SETUP : begin
          next_state = ACCESS;
      end

      ACCESS : begin
        if(vif.penable) begin
          vif.pready = 1;
        // write functionality
          if(vif.pwrite) begin
            storage[vif.paddr] = vif.pwdata;
          //read functionality 
        end else begin
          vif.prdata = storage[vif.paddr];
        end
        end else begin
          $error("ERROR: PENABLE = 0");
        end
      end
    endcase
  end
  
  always_ff @(posedge vif.clk or negedge vif.rst_n) begin
  	current_state <= next_state;
    if(!vif.rst_n) begin
      current_state <= IDLE;
    end
  
  end  
endmodule
