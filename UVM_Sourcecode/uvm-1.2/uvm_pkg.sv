//
//----------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
//   Copyright 2007-2010 Cadence Design Systems, Inc. 
//   Copyright 2010-2011 Synopsys, Inc.
//   Copyright 2013      NVIDIA, Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------
`ifndef UVM_PKG_SV
`define UVM_PKG_SV

`include "uvm_macros.svh"

`ifdef UVM_DIRECTC_OPTS
  `include "directc/uvm_directc.svh"  
 `endif

package uvm_pkg;

  `include "dpi/uvm_dpi.svh"
  `include "base/uvm_base.svh"
  `include "dap/uvm_dap.svh"
  `include "tlm1/uvm_tlm.svh"
  `include "comps/uvm_comps.svh"
  `include "seq/uvm_seq.svh"
  `include "tlm2/uvm_tlm2.svh"
  `include "reg/uvm_reg_model.svh"

endpackage

`endif

