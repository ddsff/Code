//
// Template for UVM-compliant sequence library
// <SCEN>       Name of sequence library 
// <TR>         Name of transaction descriptor class
// [filename]   SCEN
//


`ifndef SCEN__SV
`define SCEN__SV


typedef class TR;

class SCEN extends uvm_sequence_library # (TR);
  
  `uvm_object_utils(SCEN)
  `uvm_sequence_library_utils(SCEN)

  function new(string name = "simple_seq_lib");
    super.new(name);
    init_sequence_library();
  endfunction

endclass  

class base_sequence extends uvm_sequence #(TR);
  `uvm_object_utils(base_sequence)

  function new(string name = "base_seq");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  `ifdef UVM_VERSION_1_0
  virtual task pre_body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);
  endtask:pre_body

  virtual task post_body();
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask:post_body
  `endif
  
  `ifdef UVM_VERSION_1_1
  virtual task pre_start();
    if((get_parent_sequence() == null) && (starting_phase != null))
      starting_phase.raise_objection(this, "Starting");
  endtask:pre_start

  virtual task post_start();
    if ((get_parent_sequence() == null) && (starting_phase != null))
      starting_phase.drop_objection(this, "Ending");
  endtask:post_start
  `endif
endclass

class sequence_0 extends base_sequence;
  `uvm_object_utils(sequence_0)
  `uvm_add_to_seq_lib(sequence_0,SCEN)

  function new(string name = "seq_0");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    repeat(10) begin
      `uvm_do(req);
    end
  endtask
endclass

class sequence_1 extends base_sequence;
  `uvm_object_utils(sequence_1)
  `uvm_add_to_seq_lib(sequence_1, SCEN)

  function new(string name = "seq_1");
    super.new(name);
	`ifdef UVM_POST_VERSION_1_1
     set_automatic_phase_objection(1);
    `endif
  endfunction:new

  virtual task body();
    repeat(10) begin
      `uvm_do_with(req, { sa == 3; } );
    // ToDo: User can add implementation here
	#100; //Dummy delay added here for test run
    end
  endtask
endclass

`endif // SCEN__SV
