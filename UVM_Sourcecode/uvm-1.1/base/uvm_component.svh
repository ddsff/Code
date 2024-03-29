//------------------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
//   Copyright 2007-2011 Cadence Design Systems, Inc.
//   Copyright 2010-2011 Synopsys, Inc.
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
//------------------------------------------------------------------------------

typedef class uvm_objection;
typedef class uvm_sequence_base;
typedef class uvm_sequence_item;
// Modified by Verdi
typedef class uvm_port_component_base;
//
//------------------------------------------------------------------------------
//
// CLASS: uvm_component
//
// The uvm_component class is the root base class for UVM components. In
// addition to the features inherited from <uvm_object> and <uvm_report_object>,
// uvm_component provides the following interfaces:
//
// Hierarchy - provides methods for searching and traversing the component
//     hierarchy.
//
// Phasing - defines a phased test flow that all components follow, with a
//     group of standard phase methods and an API for custom phases and
//     multiple independent phasing domains to mirror DUT behavior e.g. power
//
// Configuration - provides methods for configuring component topology and other
//     parameters ahead of and during component construction.
//
// Reporting - provides a convenience interface to the <uvm_report_handler>. All
//     messages, warnings, and errors are processed through this interface.
//
// Transaction recording - provides methods for recording the transactions
//     produced or consumed by the component to a transaction database (vendor
//     specific). 
//
// Factory - provides a convenience interface to the <uvm_factory>. The factory
//     is used to create new components and other objects based on type-wide and
//     instance-specific configuration.
//
// The uvm_component is automatically seeded during construction using UVM
// seeding, if enabled. All other objects must be manually reseeded, if
// appropriate. See <uvm_object::reseed> for more information.
//
//------------------------------------------------------------------------------

virtual class uvm_component extends uvm_report_object;
`ifdef UVM_VCS_RECORD
  string tr_args[$];
  static int m_phase_record_ref_count[integer];
  static int m_phase_record_enabled = -1;
`endif

  // Function: new
  //
  // Creates a new component with the given leaf instance ~name~ and handle to
  // to its ~parent~.  If the component is a top-level component (i.e. it is
  // created in a static module or interface), ~parent~ should be null.
  //
  // The component will be inserted as a child of the ~parent~ object, if any.
  // If ~parent~ already has a child by the given ~name~, an error is produced.
  //
  // If ~parent~ is null, then the component will become a child of the
  // implicit top-level component, ~uvm_top~.
  //
  // All classes derived from uvm_component must call super.new(name,parent).

  extern function new (string name, uvm_component parent);


  //----------------------------------------------------------------------------
  // Group: Hierarchy Interface
  //----------------------------------------------------------------------------
  //
  // These methods provide user access to information about the component
  // hierarchy, i.e., topology.
  // 
  //----------------------------------------------------------------------------

  // Function: get_parent
  //
  // Returns a handle to this component's parent, or null if it has no parent.

  extern virtual function uvm_component get_parent ();


  // Function: get_full_name
  //
  // Returns the full hierarchical name of this object. The default
  // implementation concatenates the hierarchical name of the parent, if any,
  // with the leaf name of this object, as given by <uvm_object::get_name>. 

  extern virtual function string get_full_name ();


  // Function: get_children
  //
  // This function populates the end of the ~children~ array with the 
  // list of this component's children. 
  //
  //|   uvm_component array[$];
  //|   my_comp.get_children(array);
  //|   foreach(array[i]) 
  //|     do_something(array[i]);

  extern function void get_children(ref uvm_component children[$]);


  // Function: get_child
  extern function uvm_component get_child (string name);

  // Function: get_next_child
  extern function int get_next_child (ref string name);

  // Function: get_first_child
  //
  // These methods are used to iterate through this component's children, if
  // any. For example, given a component with an object handle, ~comp~, the
  // following code calls <uvm_object::print> for each child:
  //
  //|    string name;
  //|    uvm_component child;
  //|    if (comp.get_first_child(name))
  //|      do begin
  //|        child = comp.get_child(name);
  //|        child.print();
  //|      end while (comp.get_next_child(name));

  extern function int get_first_child (ref string name);


  // Function: get_num_children
  //
  // Returns the number of this component's children. 

  extern function int get_num_children ();


  // Function: has_child
  //
  // Returns 1 if this component has a child with the given ~name~, 0 otherwise.

  extern function int has_child (string name);


  // Function - set_name
  //
  // Renames this component to ~name~ and recalculates all descendants'
  // full names. This is an internal function for now.

  extern virtual function void set_name (string name);

  
  // Function: lookup
  //
  // Looks for a component with the given hierarchical ~name~ relative to this
  // component. If the given ~name~ is preceded with a '.' (dot), then the search
  // begins relative to the top level (absolute lookup). The handle of the
  // matching component is returned, else null. The name must not contain
  // wildcards.

  extern function uvm_component lookup (string name);


  // Function: get_depth
  //
  // Returns the component's depth from the root level. uvm_top has a
  // depth of 0. The test and any other top level components have a depth
  // of 1, and so on.

  extern function int unsigned get_depth();


  //----------------------------------------------------------------------------
  // Group: Phasing Interface
  //----------------------------------------------------------------------------
  //
  // These methods implement an interface which allows all components to step
  // through a standard schedule of phases, or a customized schedule, and
  // also an API to allow independent phase domains which can jump like state
  // machines to reflect behavior e.g. power domains on the DUT in different
  // portions of the testbench. The phase tasks and functions are the phase
  // name with the _phase suffix. For example, the build phase function is
  // <build_phase>.
  //
  // All processes associated with a task-based phase are killed when the phase
  // ends. See <uvm_phase::execute> for more details.
  //----------------------------------------------------------------------------


  // Function: build_phase
  //
  // The <uvm_build_phase> phase implementation method.
  //
  // Any override should call super.build_phase(phase) to execute the automatic
  // configuration of fields registed in the component by calling 
  // <apply_config_settings>.
  // To turn off automatic configuration for a component, 
  // do not call super.build_phase(phase).
  //
  // This method should never be called directly. 

  extern virtual function void build_phase(uvm_phase phase);

  // For backward compatibility the base build_phase method calls build.
  extern virtual function void build();


  // Function: connect_phase
  //
  // The <uvm_connect_phase> phase implementation method.
  //
  // This method should never be called directly. 

  extern virtual function void connect_phase(uvm_phase phase);

  // For backward compatibility the base connect_phase method calls connect.
  extern virtual function void connect();

  // Function: end_of_elaboration_phase
  //
  // The <uvm_end_of_elaboration_phase> phase implementation method.
  //
  // This method should never be called directly.

  extern virtual function void end_of_elaboration_phase(uvm_phase phase);

  // For backward compatibility the base end_of_elaboration_phase method calls end_of_elaboration.
  extern virtual function void end_of_elaboration();

  // Function: start_of_simulation_phase
  //
  // The <uvm_start_of_simulation_phase> phase implementation method.
  //
  // This method should never be called directly.

  extern virtual function void start_of_simulation_phase(uvm_phase phase);

  // For backward compatibility the base start_of_simulation_phase method calls start_of_simulation.
  extern virtual function void start_of_simulation();

  // Task: run_phase
  //
  // The <uvm_run_phase> phase implementation method.
  //
  // This task returning or not does not indicate the end
  // or persistence of this phase.
  // Thn the phase will automatically
  // ends once all objections are dropped using ~phase.drop_objection()~.
  // 
  // Any processes forked by this task continue to run
  // after the task returns,
  // but they will be killed once the phase ends.
  //
  // The run_phase task should never be called directly.

  extern virtual task run_phase(uvm_phase phase);

  // For backward compatibility the base run_phase method calls run.
  extern virtual task run();

  // Task: pre_reset_phase
  //
  // The <uvm_pre_reset_phase> phase implementation method.
  //
  // This task returning or not does not indicate the end
  // or persistence of this phase.
  // It is necessary to raise an objection
  // using ~phase.raise_objection()~ to cause the phase to persist.
  // Once all components have dropped their respective objection
  // using ~phase.drop_objection()~, or if no components raises an
  // objection, the phase is ended.
  // 
  // Any processes forked by this task continue to run
  // after the task returns,
  // but they will be killed once the phase ends.
  //
  // This method should not be called directly.

  extern virtual task pre_reset_phase(uvm_phase phase);

  // Task: reset_phase
  //
  // The <uvm_reset_phase> phase implementation method.
  //
  // This task returning or not does not indicate the end
  // or persistence of this phase.
  // It is necessary to raise an objection
  // using ~phase.raise_objection()~ to cause the phase to persist.
  // Once all components have dropped their respective objection
  // using ~phase.drop_objection()~, or if no components raises an
  // objection, the phase is ended.
  // 
  // Any processes forked by this task continue to run
  // after the task returns,
  // but they will be killed once the phase ends.
  //
  // This method should not be called directly.

  extern virtual task reset_phase(uvm_phase phase);

  // Task: post_reset_phase
  //
  // The <uvm_post_reset_phase> phase implementation method.
  //
  // This task returning or not does not indicate the end
  // or persistence of this phase.
  // It is necessary to raise an objection
  // using ~phase.raise_objection()~ to cause the phase to persist.
  // Once all components have dropped their respective objection
  // using ~phase.drop_objection()~, or if no components raises an
  // objection, the phase is ended.
  // 
  // Any processes forked by this task continue to run
  // after the task returns,
  // but they will be killed once the phase ends.
  //
  // This method should not be called directly.

  extern virtual task post_reset_phase(uvm_phase phase);

  // Task: pre_configure_phase
  //
  // The <uvm_pre_configure_phase> phase implementation method.
  //
  // This task returning or not does not indicate the end
  // or persistence of this phase.
  // It is necessary to raise an objection
  // using ~phase.raise_objection()~ to cause the phase to persist.
  // Once all components have dropped their respective objection
  // using ~phase.drop_objection()~, or if no components raises an
  // objection, the phase is ended.
  // 
  // Any processes forked by this task continue to run
  // after the task returns,
  // but they will be killed once the phase ends.
  //
  // This method should not be called directly.

  extern virtual task pre_configure_phase(uvm_phase phase);

  // Task: configure_phase
  //
  // The <uvm_configure_phase> phase implementation method.
  //
  // This task returning or not does not indicate the end
  // or persistence of this phase.
  // It is necessary to raise an objection
  // using ~phase.raise_objection()~ to cause the phase to persist.
  // Once all components have dropped their respective objection
  // using ~phase.drop_objection()~, or if no components raises an
  // objection, the phase is ended.
  // 
  // Any processes forked by this task continue to run
  // after the task returns,
  // but they will be killed once the phase ends.
  //
  // This method should not be called directly.

  extern virtual task configure_phase(uvm_phase phase);

  // Task: post_configure_phase
  //
  // The <uvm_post_configure_phase> phase implementation method.
  //
  // This task returning or not does not indicate the end
  // or persistence of this phase.
  // It is necessary to raise an objection
  // using ~phase.raise_objection()~ to cause the phase to persist.
  // Once all components have dropped their respective objection
  // using ~phase.drop_objection()~, or if no components raises an
  // objection, the phase is ended.
  // 
  // Any processes forked by this task continue to run
  // after the task returns,
  // but they will be killed once the phase ends.
  //
  // This method should not be called directly.

  extern virtual task post_configure_phase(uvm_phase phase);

  // Task: pre_main_phase
  //
  // The <uvm_pre_main_phase> phase implementation method.
  //
  // This task returning or not does not indicate the end
  // or persistence of this phase.
  // It is necessary to raise an objection
  // using ~phase.raise_objection()~ to cause the phase to persist.
  // Once all components have dropped their respective objection
  // using ~phase.drop_objection()~, or if no components raises an
  // objection, the phase is ended.
  // 
  // Any processes forked by this task continue to run
  // after the task returns,
  // but they will be killed once the phase ends.
  //
  // This method should not be called directly.

  extern virtual task pre_main_phase(uvm_phase phase);

  // Task: main_phase
  //
  // The <uvm_main_phase> phase implementation method.
  //
  // This task returning or not does not indicate the end
  // or persistence of this phase.
  // It is necessary to raise an objection
  // using ~phase.raise_objection()~ to cause the phase to persist.
  // Once all components have dropped their respective objection
  // using ~phase.drop_objection()~, or if no components raises an
  // objection, the phase is ended.
  // 
  // Any processes forked by this task continue to run
  // after the task returns,
  // but they will be killed once the phase ends.
  //
  // This method should not be called directly.

  extern virtual task main_phase(uvm_phase phase);

  // Task: post_main_phase
  //
  // The <uvm_post_main_phase> phase implementation method.
  //
  // This task returning or not does not indicate the end
  // or persistence of this phase.
  // It is necessary to raise an objection
  // using ~phase.raise_objection()~ to cause the phase to persist.
  // Once all components have dropped their respective objection
  // using ~phase.drop_objection()~, or if no components raises an
  // objection, the phase is ended.
  // 
  // Any processes forked by this task continue to run
  // after the task returns,
  // but they will be killed once the phase ends.
  //
  // This method should not be called directly.

  extern virtual task post_main_phase(uvm_phase phase);

  // Task: pre_shutdown_phase
  //
  // The <uvm_pre_shutdown_phase> phase implementation method.
  //
  // This task returning or not does not indicate the end
  // or persistence of this phase.
  // It is necessary to raise an objection
  // using ~phase.raise_objection()~ to cause the phase to persist.
  // Once all components have dropped their respective objection
  // using ~phase.drop_objection()~, or if no components raises an
  // objection, the phase is ended.
  // 
  // Any processes forked by this task continue to run
  // after the task returns,
  // but they will be killed once the phase ends.
  //
  // This method should not be called directly.

  extern virtual task pre_shutdown_phase(uvm_phase phase);

  // Task: shutdown_phase
  //
  // The <uvm_shutdown_phase> phase implementation method.
  //
  // This task returning or not does not indicate the end
  // or persistence of this phase.
  // It is necessary to raise an objection
  // using ~phase.raise_objection()~ to cause the phase to persist.
  // Once all components have dropped their respective objection
  // using ~phase.drop_objection()~, or if no components raises an
  // objection, the phase is ended.
  // 
  // Any processes forked by this task continue to run
  // after the task returns,
  // but they will be killed once the phase ends.
  //
  // This method should not be called directly.

  extern virtual task shutdown_phase(uvm_phase phase);

  // Task: post_shutdown_phase
  //
  // The <uvm_post_shutdown_phase> phase implementation method.
  //
  // This task returning or not does not indicate the end
  // or persistence of this phase.
  // It is necessary to raise an objection
  // using ~phase.raise_objection()~ to cause the phase to persist.
  // Once all components have dropped their respective objection
  // using ~phase.drop_objection()~, or if no components raises an
  // objection, the phase is ended.
  // 
  // Any processes forked by this task continue to run
  // after the task returns,
  // but they will be killed once the phase ends.
  //
  // This method should not be called directly.

  extern virtual task post_shutdown_phase(uvm_phase phase);

  // Function: extract_phase
  //
  // The <uvm_extract_phase> phase implementation method.
  //
  // This method should never be called directly.

  extern virtual function void extract_phase(uvm_phase phase);

  // For backward compatibility the base extract_phase method calls extract.
  extern virtual function void extract();

  // Function: check_phase
  //
  // The <uvm_check_phase> phase implementation method.
  //
  // This method should never be called directly.

  extern virtual function void check_phase(uvm_phase phase);

  // For backward compatibility the base check_phase method calls check.
  extern virtual function void check();

  // Function: report_phase
  //
  // The <uvm_report_phase> phase implementation method.
  //
  // This method should never be called directly.

  extern virtual function void report_phase(uvm_phase phase);

  // For backward compatibility the base report_phase method calls report.
  extern virtual function void report();

  // Function: final_phase
  //
  // The <uvm_final_phase> phase implementation method.
  //
  // This method should never be called directly.
  
  extern virtual function void final_phase(uvm_phase phase);

  // Function: phase_started
  //
  // Invoked at the start of each phase. The ~phase~ argument specifies
  // the phase being started. Any threads spawned in this callback are
  // not affected when the phase ends.

  extern virtual function void phase_started (uvm_phase phase);

  // Function: phase_ready_to_end
  //
  // Invoked when all objections to ending the given ~phase~ and all
  // sibling phases have been dropped, thus indicating that ~phase~ is 
  // ready to begin a clean exit. Sibling phases are any phases that 
  // have a common successor phase in the schedule plus any phases that
  // sync'd to the current phase. Components needing to consume delta
  // cycles or advance time to perform a clean exit from the phase
  // may raise the phase's objection. 
  //
  // |phase.raise_objection(this,"Reason");
  //
  // It is the responsibility of this component to drop the objection 
  // once it is ready for this phase to end (and processes killed).
  // If no objection to the given ~phase~ or sibling phases are raised,
  // then phase_ended() is called after a delta cycle.  If any objection
  // is raised, then when all objections to ending the given ~phase~
  // and siblings are dropped, another iteration of phase_ready_to_end
  // is called.  To prevent endless iterations due to coding error,
  // after 20 iterations, phase_ended() is called regardless of whether
  // previous iteration had any objections raised.
  
  extern virtual function void phase_ready_to_end (uvm_phase phase);


  // Function: phase_ended
  //
  // Invoked at the end of each phase. The ~phase~ argument specifies
  // the phase that is ending.  Any threads spawned in this callback are
  // not affected when the phase ends.
  
  extern virtual function void phase_ended (uvm_phase phase);

  
  //--------------------------------------------------------------------
  // phase / schedule / domain API
  //--------------------------------------------------------------------

  
  // Function: set_domain
  //
  // Apply a phase domain to this component and, if ~hier~ is set, 
  // recursively to all its children. 
  //
  // Calls the virtual <define_domain> method, which derived components can
  // override to augment or replace the domain definition of ita base class.
  //

  extern function void set_domain(uvm_domain domain, int hier=1);


  // Function: get_domain
  //
  // Return handle to the phase domain set on this component
  
  extern function uvm_domain get_domain();


  // Function: define_domain
  //
  // Builds custom phase schedules into the provided ~domain~ handle.
  //
  // This method is called by <set_domain>, which integrators use to specify
  // this component belongs in a domain apart from the default 'uvm' domain.
  //
  // Custom component base classes requiring a custom phasing schedule can
  // augment or replace the domain definition they inherit by overriding
  // <defined_domain>. To augment, overrides would call super.define_domain().
  // To replace, overrides would not call super.define_domain().
  // 
  // The default implementation adds a copy of the ~uvm~ phasing schedule to
  // the given ~domain~, if one doesn't already exist, and only if the domain
  // is currently empty.
  //
  // Calling <set_domain>
  // with the default ~uvm~ domain (see <uvm_domain::get_uvm_domain>) on
  // a component with no ~define_domain~ override effectively reverts the
  // that component to using the default ~uvm~ domain. This may be useful
  // if a branch of the testbench hierarchy defines a custom domain, but
  // some child sub-branch should remain in the default ~uvm~ domain,
  // call <set_domain> with a new domain instance handle with ~hier~ set.
  // Then, in the sub-branch, call <set_domain> with the default ~uvm~ domain handle,
  // obtained via <uvm_domain::get_uvm_domain()>.
  //
  // Alternatively, the integrator may define the graph in a new domain externally,
  // then call <set_domain> to apply it to a component.


  extern virtual protected function void define_domain(uvm_domain domain);


  // Function: set_phase_imp
  //
  // Override the default implementation for a phase on this component (tree) with a
  // custom one, which must be created as a singleton object extending the default
  // one and implementing required behavior in exec and traverse methods
  //
  // The ~hier~ specifies whether to apply the custom functor to the whole tree or
  // just this component.

  extern function void set_phase_imp(uvm_phase phase, uvm_phase imp, int hier=1);

  
  // Task: suspend
  //
  // Suspend this component.
  //
  // This method must be implemented by the user to suspend the
  // component according to the protocol and functionality it implements.
  // A suspended component can be subsequently resumed using <resume()>. 

  extern virtual task suspend ();


  // Task: resume
  //
  // Resume this component.
  //
  // This method must be implemented by the user to resume a component
  // that was previously suspended using <suspend()>.
  // Some component may start in the suspended state and
  // may need to be explicitly resumed.

  extern virtual task resume ();


`ifndef UVM_NO_DEPRECATED
  // Function- status  - DEPRECATED
  //
  // Returns the status of this component.
  //
  // Returns a string that describes the current status of the
  // components. Possible values include, but are not limited to
  //
  // "<unknown>"   - Status is unknown (default)
  // "FINISHED"    - Component has stopped on its own accord. May be resumed.
  // "RUNNING"     - Component is running.
  //                 May be suspended after normal completion
  //                 of operation in progress.
  // "WAITING"     - Component is waiting. May be suspended immediately.
  // "SUSPENDED"   - Component is suspended. May be resumed.
  // "KILLED"      - Component has been killed and is unable to operate
  //                 any further. It cannot be resumed.


  extern function string status ();


  // Function- kill  - DEPRECATED
  //
  // Kills the process tree associated with this component's currently running
  // task-based phase, e.g., run.

  extern virtual function void kill ();


  // Function- do_kill_all  - DEPRECATED
  //
  // Recursively calls <kill> on this component and all its descendants,
  // which abruptly ends the currently running task-based phase, e.g., run.
  // See <run_phase> for better options to ending a task-based phase.

  extern virtual  function void  do_kill_all ();


  // Task- stop_phase  -- DEPRECATED
  //
  // The stop_phase task is called when this component's <enable_stop_interrupt>
  // bit is set and <global_stop_request> is called during a task-based phase,
  // e.g., run.
  //
  // Before a phase is abruptly ended, e.g., when a test deems the simulation
  // complete, some components may need extra time to shut down cleanly. Such
  // components may implement stop_phase to finish the currently executing
  // transaction, flush the queue, or perform other cleanup. Upon return from
  // stop_phase, a component signals it is ready to be stopped. 
  //
  // The ~stop_phase~ method will not be called if <enable_stop_interrupt> is 0.
  //
  // The default implementation is empty, i.e., it will return immediately.
  //
  // This method should never be called directly.

  extern virtual task stop_phase(uvm_phase phase);

  // backward compat
  extern virtual task stop (string ph_name);


  // Variable- enable_stop_interrupt  - DEPRECATED
  //
  // This bit allows a component to raise an objection to the stopping of the
  // current phase. It affects only time consuming phases (such as the run
  // phase).
  //
  // When this bit is set, the <stop> task in the component is called as a result
  // of a call to <global_stop_request>. Components that are sensitive to an
  // immediate killing of its run-time processes should set this bit and
  // implement the stop task to prepare for shutdown.

  int enable_stop_interrupt;
`endif


  // Function: resolve_bindings
  //
  // Processes all port, export, and imp connections. Checks whether each port's
  // min and max connection requirements are met.
  //
  // It is called just before the end_of_elaboration phase.
  //
  // Users should not call directly.

  extern virtual function void resolve_bindings ();


  //----------------------------------------------------------------------------
  // Group: Configuration Interface
  //----------------------------------------------------------------------------
  //
  // Components can be designed to be user-configurable in terms of its
  // topology (the type and number of children it has), mode of operation, and
  // run-time parameters (knobs). The configuration interface accommodates
  // this common need, allowing component composition and state to be modified
  // without having to derive new classes or new class hierarchies for
  // every configuration scenario. 
  //
  //----------------------------------------------------------------------------


  // Used for caching config settings
  static bit m_config_set = 1;

  extern function string massage_scope(string scope);

  // Function: set_config_int

  extern virtual function void set_config_int (string inst_name,  
                                               string field_name,
                                               uvm_bitstream_t value);

  // Function: set_config_string

  extern virtual function void set_config_string (string inst_name,  
                                                  string field_name,
                                                  string value);

  // Function: set_config_object
  //
  // Calling set_config_* causes configuration settings to be created and
  // placed in a table internal to this component. There are similar global
  // methods that store settings in a global table. Each setting stores the
  // supplied ~inst_name~, ~field_name~, and ~value~ for later use by descendent
  // components during their construction. (The global table applies to
  // all components and takes precedence over the component tables.)
  //
  // When a descendant component calls a get_config_* method, the ~inst_name~
  // and ~field_name~ provided in the get call are matched against all the
  // configuration settings stored in the global table and then in each
  // component in the parent hierarchy, top-down. Upon the first match, the
  // value stored in the configuration setting is returned. Thus, precedence is
  // global, following by the top-level component, and so on down to the
  // descendent component's parent.
  //
  // These methods work in conjunction with the get_config_* methods to
  // provide a configuration setting mechanism for integral, string, and
  // uvm_object-based types. Settings of other types, such as virtual interfaces
  // and arrays, can be indirectly supported by defining a class that contains
  // them.
  //
  // Both ~inst_name~ and ~field_name~ may contain wildcards.
  //
  // - For set_config_int, ~value~ is an integral value that can be anything
  //   from 1 bit to 4096 bits.
  //
  // - For set_config_string, ~value~ is a string.
  //
  // - For set_config_object, ~value~ must be an <uvm_object>-based object or
  //   null.  Its clone argument specifies whether the object should be cloned.
  //   If set, the object is cloned both going into the table (during the set)
  //   and coming out of the table (during the get), so that multiple components
  //   matched to the same setting (by way of wildcards) do not end up sharing
  //   the same object.
  //
  //
  // See <get_config_int>, <get_config_string>, and <get_config_object> for
  // information on getting the configurations set by these methods.


  extern virtual function void set_config_object (string inst_name,  
                                                  string field_name,
                                                  uvm_object value,  
                                                  bit clone=1);


  // Function: get_config_int

  extern virtual function bit get_config_int (string field_name,
                                              inout uvm_bitstream_t value);

  // Function: get_config_string

  extern virtual function bit get_config_string (string field_name,
                                                 inout string value);

  // Function: get_config_object
  //
  // These methods retrieve configuration settings made by previous calls to
  // their set_config_* counterparts. As the methods' names suggest, there is
  // direct support for integral types, strings, and objects.  Settings of other
  // types can be indirectly supported by defining an object to contain them.
  //
  // Configuration settings are stored in a global table and in each component
  // instance. With each call to a get_config_* method, a top-down search is
  // made for a setting that matches this component's full name and the given
  // ~field_name~. For example, say this component's full instance name is
  // top.u1.u2. First, the global configuration table is searched. If that
  // fails, then it searches the configuration table in component 'top',
  // followed by top.u1. 
  //
  // The first instance/field that matches causes ~value~ to be written with the
  // value of the configuration setting and 1 is returned. If no match
  // is found, then ~value~ is unchanged and the 0 returned.
  //
  // Calling the get_config_object method requires special handling. Because
  // ~value~ is an output of type <uvm_object>, you must provide an uvm_object
  // handle to assign to (_not_ a derived class handle). After the call, you can
  // then $cast to the actual type.
  //
  // For example, the following code illustrates how a component designer might
  // call upon the configuration mechanism to assign its ~data~ object property,
  // whose type myobj_t derives from uvm_object.
  //
  //|  class mycomponent extends uvm_component;
  //|
  //|    local myobj_t data;
  //|
  //|    function void build_phase(uvm_phase phase);
  //|      uvm_object tmp;
  //|      super.build_phase(phase);
  //|      if(get_config_object("data", tmp))
  //|        if (!$cast(data, tmp))
  //|          $display("error! config setting for 'data' not of type myobj_t");
  //|        endfunction
  //|      ...
  //
  // The above example overrides the <build_phase> method. If you want to retain
  // any base functionality, you must call super.build_phase(uvm_phase phase).
  //
  // The ~clone~ bit clones the data inbound. The get_config_object method can
  // also clone the data outbound.
  //
  // See Members for information on setting the global configuration table.

  extern virtual function bit get_config_object (string field_name,
                                                 inout uvm_object value,  
                                                 input bit clone=1);


  // Function: check_config_usage
  //
  // Check all configuration settings in a components configuration table
  // to determine if the setting has been used, overridden or not used.
  // When ~recurse~ is 1 (default), configuration for this and all child
  // components are recursively checked. This function is automatically
  // called in the check phase, but can be manually called at any time.
  //
  // To get all configuration information prior to the run phase, do something 
  // like this in your top object:
  //|  function void start_of_simulation_phase(uvm_phase phase);
  //|    check_config_usage();
  //|  endfunction

  extern function void check_config_usage (bit recurse=1);


  // Function: apply_config_settings
  //
  // Searches for all config settings matching this component's instance path.
  // For each match, the appropriate set_*_local method is called using the
  // matching config setting's field_name and value. Provided the set_*_local
  // method is implemented, the component property associated with the
  // field_name is assigned the given value. 
  //
  // This function is called by <uvm_component::build_phase>.
  //
  // The apply_config_settings method determines all the configuration
  // settings targeting this component and calls the appropriate set_*_local
  // method to set each one. To work, you must override one or more set_*_local
  // methods to accommodate setting of your component's specific properties.
  // Any properties registered with the optional `uvm_*_field macros do not
  // require special handling by the set_*_local methods; the macros provide
  // the set_*_local functionality for you. 
  //
  // If you do not want apply_config_settings to be called for a component,
  // then the build_phase() method should be overloaded and you should not call
  // super.build_phase(phase). Likewise, apply_config_settings can be overloaded to
  // customize automated configuration.
  //
  // When the ~verbose~ bit is set, all overrides are printed as they are
  // applied. If the component's <print_config_matches> property is set, then
  // apply_config_settings is automatically called with ~verbose~ = 1.

  extern virtual function void apply_config_settings (bit verbose=0);


  // Function: print_config_settings
  //
  // Called without arguments, print_config_settings prints all configuration
  // information for this component, as set by previous calls to set_config_*.
  // The settings are printing in the order of their precedence.
  // 
  // If ~field~ is specified and non-empty, then only configuration settings
  // matching that field, if any, are printed. The field may not contain
  // wildcards. 
  //
  // If ~comp~ is specified and non-null, then the configuration for that
  // component is printed.
  //
  // If ~recurse~ is set, then configuration information for all ~comp~'s
  // children and below are printed as well.
  //
  // This function has been deprecated.  Use print_config instead.

  extern function void print_config_settings (string field="", 
                                              uvm_component comp=null, 
                                              bit recurse=0);

  // Function: print_config
  //
  // Print_config_settings prints all configuration information for this
  // component, as set by previous calls to set_config_* and exports to
  // the resources pool.  The settings are printing in the order of
  // their precedence.
  //
  // If ~recurse~ is set, then configuration information for all
  // children and below are printed as well.
  //
  // if ~audit~ is set then the audit trail for each resource is printed
  // along with the resource name and value

  extern function void print_config(bit recurse = 0, bit audit = 0);

  // Function: print_config_with_audit
  //
  // Operates the same as print_config except that the audit bit is
  // forced to 1.  This interface makes user code a bit more readable as
  // it avoids multiple arbitrary bit settings in the argument list.
  //
  // If ~recurse~ is set, then configuration information for all
  // children and below are printed as well.

  extern function void print_config_with_audit(bit recurse = 0);

  // Variable: print_config_matches
  //
  // Setting this static variable causes get_config_* to print info about
  // matching configuration settings as they are being applied.

  static bit print_config_matches;


  //----------------------------------------------------------------------------
  // Group: Objection Interface
  //----------------------------------------------------------------------------
  //
  // These methods provide object level hooks into the <uvm_objection> 
  // mechanism.
  // 
  //----------------------------------------------------------------------------


  // Function: raised
  //
  // The ~raised~ callback is called when this or a descendant of this component
  // instance raises the specfied ~objection~. The ~source_obj~ is the object
  // that originally raised the objection. 
  // The ~description~ is optionally provided by the ~source_obj~ to give a
  // reason for raising the objection. The ~count~ indicates the number of
  // objections raised by the ~source_obj~.

  virtual function void raised (uvm_objection objection, uvm_object source_obj, 
      string description, int count);
  endfunction


  // Function: dropped
  //
  // The ~dropped~ callback is called when this or a descendant of this component
  // instance drops the specfied ~objection~. The ~source_obj~ is the object
  // that originally dropped the objection. 
  // The ~description~ is optionally provided by the ~source_obj~ to give a
  // reason for dropping the objection. The ~count~ indicates the number of
  // objections dropped by the the ~source_obj~.

  virtual function void dropped (uvm_objection objection, uvm_object source_obj, 
      string description, int count);
  endfunction


  // Task: all_dropped
  //
  // The ~all_droppped~ callback is called when all objections have been 
  // dropped by this component and all its descendants.  The ~source_obj~ is the
  // object that dropped the last objection.
  // The ~description~ is optionally provided by the ~source_obj~ to give a
  // reason for raising the objection. The ~count~ indicates the number of
  // objections dropped by the the ~source_obj~.

  virtual task all_dropped (uvm_objection objection, uvm_object source_obj, 
      string description, int count);
  endtask


  //----------------------------------------------------------------------------
  // Group: Factory Interface
  //----------------------------------------------------------------------------
  //
  // The factory interface provides convenient access to a portion of UVM's
  // <uvm_factory> interface. For creating new objects and components, the
  // preferred method of accessing the factory is via the object or component
  // wrapper (see <uvm_component_registry #(T,Tname)> and
  // <uvm_object_registry #(T,Tname)>). The wrapper also provides functions
  // for setting type and instance overrides.
  //
  //----------------------------------------------------------------------------

  // Function: create_component
  //
  // A convenience function for <uvm_factory::create_component_by_name>,
  // this method calls upon the factory to create a new child component
  // whose type corresponds to the preregistered type name, ~requested_type_name~,
  // and instance name, ~name~. This method is equivalent to:
  //
  //|  factory.create_component_by_name(requested_type_name,
  //|                                   get_full_name(), name, this);
  //
  // If the factory determines that a type or instance override exists, the type
  // of the component created may be different than the requested type. See
  // <set_type_override> and <set_inst_override>. See also <uvm_factory> for
  // details on factory operation.

  extern function uvm_component create_component (string requested_type_name, 
                                                  string name);


  // Function: create_object
  //
  // A convenience function for <uvm_factory::create_object_by_name>,
  // this method calls upon the factory to create a new object
  // whose type corresponds to the preregistered type name,
  // ~requested_type_name~, and instance name, ~name~. This method is
  // equivalent to:
  //
  //|  factory.create_object_by_name(requested_type_name,
  //|                                get_full_name(), name);
  //
  // If the factory determines that a type or instance override exists, the
  // type of the object created may be different than the requested type.  See
  // <uvm_factory> for details on factory operation.

  extern function uvm_object create_object (string requested_type_name,
                                            string name="");


  // Function: set_type_override_by_type
  //
  // A convenience function for <uvm_factory::set_type_override_by_type>, this
  // method registers a factory override for components and objects created at
  // this level of hierarchy or below. This method is equivalent to:
  //
  //|  factory.set_type_override_by_type(original_type, override_type,replace);
  //
  // The ~relative_inst_path~ is relative to this component and may include
  // wildcards. The ~original_type~ represents the type that is being overridden.
  // In subsequent calls to <uvm_factory::create_object_by_type> or
  // <uvm_factory::create_component_by_type>, if the requested_type matches the
  // ~original_type~ and the instance paths match, the factory will produce
  // the ~override_type~. 
  //
  // The original and override type arguments are lightweight proxies to the
  // types they represent. See <set_inst_override_by_type> for information
  // on usage.

  extern static function void set_type_override_by_type
                                             (uvm_object_wrapper original_type, 
                                              uvm_object_wrapper override_type,
                                              bit replace=1);


  // Function: set_inst_override_by_type
  //
  // A convenience function for <uvm_factory::set_inst_override_by_type>, this
  // method registers a factory override for components and objects created at
  // this level of hierarchy or below. In typical usage, this method is
  // equivalent to:
  //
  //|  factory.set_inst_override_by_type({get_full_name(),".",
  //|                                     relative_inst_path},
  //|                                     original_type,
  //|                                     override_type);
  //
  // The ~relative_inst_path~ is relative to this component and may include
  // wildcards. The ~original_type~ represents the type that is being overridden.
  // In subsequent calls to <uvm_factory::create_object_by_type> or
  // <uvm_factory::create_component_by_type>, if the requested_type matches the
  // ~original_type~ and the instance paths match, the factory will produce the
  // ~override_type~. 
  //
  // The original and override types are lightweight proxies to the types they
  // represent. They can be obtained by calling ~type::get_type()~, if
  // implemented by ~type~, or by directly calling ~type::type_id::get()~, where 
  // ~type~ is the user type and ~type_id~ is the name of the typedef to
  // <uvm_object_registry #(T,Tname)> or <uvm_component_registry #(T,Tname)>.
  //
  // If you are employing the `uvm_*_utils macros, the typedef and the get_type
  // method will be implemented for you. For details on the utils macros
  // refer to <Utility and Field Macros for Components and Objects>.
  //
  // The following example shows `uvm_*_utils usage:
  //
  //|  class comp extends uvm_component;
  //|    `uvm_component_utils(comp)
  //|    ...
  //|  endclass
  //|
  //|  class mycomp extends uvm_component;
  //|    `uvm_component_utils(mycomp)
  //|    ...
  //|  endclass
  //|
  //|  class block extends uvm_component;
  //|    `uvm_component_utils(block)
  //|    comp c_inst;
  //|    virtual function void build_phase(uvm_phase phase);
  //|      set_inst_override_by_type("c_inst",comp::get_type(),
  //|                                         mycomp::get_type());
  //|    endfunction
  //|    ...
  //|  endclass

  extern function void set_inst_override_by_type(string relative_inst_path,  
                                                 uvm_object_wrapper original_type,
                                                 uvm_object_wrapper override_type);


  // Function: set_type_override
  //
  // A convenience function for <uvm_factory::set_type_override_by_name>,
  // this method configures the factory to create an object of type
  // ~override_type_name~ whenever the factory is asked to produce a type
  // represented by ~original_type_name~.  This method is equivalent to:
  //
  //|  factory.set_type_override_by_name(original_type_name,
  //|                                    override_type_name, replace);
  //
  // The ~original_type_name~ typically refers to a preregistered type in the
  // factory. It may, however, be any arbitrary string. Subsequent calls to
  // create_component or create_object with the same string and matching
  // instance path will produce the type represented by override_type_name.
  // The ~override_type_name~ must refer to a preregistered type in the factory. 

  extern static function void set_type_override(string original_type_name, 
                                                string override_type_name,
                                                bit    replace=1);


  // Function: set_inst_override
  //
  // A convenience function for <uvm_factory::set_inst_override_by_name>, this
  // method registers a factory override for components created at this level
  // of hierarchy or below. In typical usage, this method is equivalent to:
  //
  //|  factory.set_inst_override_by_name({get_full_name(),".",
  //|                                     relative_inst_path},
  //|                                      original_type_name,
  //|                                     override_type_name);
  //
  // The ~relative_inst_path~ is relative to this component and may include
  // wildcards. The ~original_type_name~ typically refers to a preregistered type
  // in the factory. It may, however, be any arbitrary string. Subsequent calls
  // to create_component or create_object with the same string and matching
  // instance path will produce the type represented by ~override_type_name~.
  // The ~override_type_name~ must refer to a preregistered type in the factory. 

  extern function void set_inst_override(string relative_inst_path,  
                                         string original_type_name,
                                         string override_type_name);


  // Function: print_override_info
  //
  // This factory debug method performs the same lookup process as create_object
  // and create_component, but instead of creating an object, it prints
  // information about what type of object would be created given the
  // provided arguments.

  extern function void print_override_info(string requested_type_name,
                                           string name="");


  //----------------------------------------------------------------------------
  // Group: Hierarchical Reporting Interface
  //----------------------------------------------------------------------------
  //
  // This interface provides versions of the set_report_* methods in the
  // <uvm_report_object> base class that are applied recursively to this
  // component and all its children.
  //
  // When a report is issued and its associated action has the LOG bit set, the
  // report will be sent to its associated FILE descriptor.
  //----------------------------------------------------------------------------

  // Function: set_report_id_verbosity_hier

  extern function void set_report_id_verbosity_hier (string id,
                                                  int verbosity);

  // Function: set_report_severity_id_verbosity_hier
  //
  // These methods recursively associate the specified verbosity with reports of
  // the given ~severity~, ~id~, or ~severity-id~ pair. An verbosity associated
  // with a particular severity-id pair takes precedence over an verbosity
  // associated with id, which takes precedence over an an verbosity associated
  // with a severity.
  //
  // For a list of severities and their default verbosities, refer to
  // <uvm_report_handler>.

  extern function void set_report_severity_id_verbosity_hier(uvm_severity severity,
                                                          string id,
                                                          int verbosity);


  // Function: set_report_severity_action_hier

  extern function void set_report_severity_action_hier (uvm_severity severity,
                                                        uvm_action action);


  // Function: set_report_id_action_hier

  extern function void set_report_id_action_hier (string id,
                                                  uvm_action action);

  // Function: set_report_severity_id_action_hier
  //
  // These methods recursively associate the specified action with reports of
  // the given ~severity~, ~id~, or ~severity-id~ pair. An action associated
  // with a particular severity-id pair takes precedence over an action
  // associated with id, which takes precedence over an an action associated
  // with a severity.
  //
  // For a list of severities and their default actions, refer to
  // <uvm_report_handler>.

  extern function void set_report_severity_id_action_hier(uvm_severity severity,
                                                          string id,
                                                          uvm_action action);



  // Function: set_report_default_file_hier

  extern function void set_report_default_file_hier (UVM_FILE file);

  // Function: set_report_severity_file_hier

  extern function void set_report_severity_file_hier (uvm_severity severity,
                                                      UVM_FILE file);

  // Function: set_report_id_file_hier

  extern function void set_report_id_file_hier (string id,
                                                UVM_FILE file);

  // Function: set_report_severity_id_file_hier
  //
  // These methods recursively associate the specified FILE descriptor with
  // reports of the given ~severity~, ~id~, or ~severity-id~ pair. A FILE
  // associated with a particular severity-id pair takes precedence over a FILE
  // associated with id, which take precedence over an a FILE associated with a
  // severity, which takes precedence over the default FILE descriptor.
  //
  // For a list of severities and other information related to the report
  // mechanism, refer to <uvm_report_handler>.

  extern function void set_report_severity_id_file_hier(uvm_severity severity,
                                                        string id,
                                                        UVM_FILE file);


  // Function: set_report_verbosity_level_hier
  //
  // This method recursively sets the maximum verbosity level for reports for
  // this component and all those below it. Any report from this component
  // subtree whose verbosity exceeds this maximum will be ignored.
  // 
  // See <uvm_report_handler> for a list of predefined message verbosity levels
  // and their meaning.

    extern function void set_report_verbosity_level_hier (int verbosity);
 

  // Function: pre_abort
  //
  // This callback is executed when the message system is executing a
  // <UVM_EXIT> action. The exit action causes an immediate termination of
  // the simulation, but the pre_abort callback hook gives components an 
  // opportunity to provide additional information to the user before
  // the termination happens. For example, a test may want to executed
  // the report function of a particular component even when an error
  // condition has happened to force a premature termination you would
  // write a function like:
  //
  //| function void mycomponent::pre_abort();
  //|   report();
  //| endfunction
  //
  // The pre_abort() callback hooks are called in a bottom-up fashion.

  virtual function void pre_abort;
  endfunction

  //----------------------------------------------------------------------------
  // Group: Recording Interface
  //----------------------------------------------------------------------------
  // These methods comprise the component-based transaction recording
  // interface. The methods can be used to record the transactions that
  // this component "sees", i.e. produces or consumes.
  //
  // The API and implementation are subject to change once a vendor-independent
  // use-model is determined.
  //----------------------------------------------------------------------------

  // Function: accept_tr
  //
  // This function marks the acceptance of a transaction, ~tr~, by this
  // component. Specifically, it performs the following actions:
  //
  // - Calls the ~tr~'s <uvm_transaction::accept_tr> method, passing to it the
  //   ~accept_time~ argument.
  //
  // - Calls this component's <do_accept_tr> method to allow for any post-begin
  //   action in derived classes.
  //
  // - Triggers the component's internal accept_tr event. Any processes waiting
  //   on this event will resume in the next delta cycle. 

  extern function void accept_tr (uvm_transaction tr, time accept_time=0);


  // Function: do_accept_tr
  //
  // The <accept_tr> method calls this function to accommodate any user-defined
  // post-accept action. Implementations should call super.do_accept_tr to
  // ensure correct operation.
    
  extern virtual protected function void do_accept_tr (uvm_transaction tr);

  // Modified by Verdi
`ifndef UVM_VERDI_NO_COMP_TYPE
  extern function bit is_sequencer(uvm_component comp);
  extern function bit is_driver(uvm_component comp);
  extern function string check_component_type(uvm_component comp);
`endif
  // End

  // Function: begin_tr
  //
  // This function marks the start of a transaction, ~tr~, by this component.
  // Specifically, it performs the following actions:
  //
  // - Calls ~tr~'s <uvm_transaction::begin_tr> method, passing to it the
  //   ~begin_time~ argument. The ~begin_time~ should be greater than or equal
  //   to the accept time. By default, when ~begin_time~ = 0, the current
  //   simulation time is used.
  //
  //   If recording is enabled (recording_detail != UVM_OFF), then a new
  //   database-transaction is started on the component's transaction stream
  //   given by the stream argument. No transaction properties are recorded at
  //   this time.
  //
  // - Calls the component's <do_begin_tr> method to allow for any post-begin
  //   action in derived classes.
  //
  // - Triggers the component's internal begin_tr event. Any processes waiting
  //   on this event will resume in the next delta cycle. 
  //
  // A handle to the transaction is returned. The meaning of this handle, as
  // well as the interpretation of the arguments ~stream_name~, ~label~, and
  // ~desc~ are vendor specific.

  extern function integer begin_tr (uvm_transaction tr,
                                    string stream_name="main",
                                    string label="",
                                    string desc="",
                                    time begin_time=0,
                                    integer parent_handle=0);


  // Function: begin_child_tr
  //
  // This function marks the start of a child transaction, ~tr~, by this
  // component. Its operation is identical to that of <begin_tr>, except that
  // an association is made between this transaction and the provided parent
  // transaction. This association is vendor-specific.

  extern function integer begin_child_tr (uvm_transaction tr,
                                          integer parent_handle=0,
                                          string stream_name="main",
                                          string label="",
                                          string desc="",
                                          time begin_time=0);


  // Function: do_begin_tr
  //
  // The <begin_tr> and <begin_child_tr> methods call this function to
  // accommodate any user-defined post-begin action. Implementations should call
  // super.do_begin_tr to ensure correct operation.

  extern virtual protected 
                 function void do_begin_tr (uvm_transaction tr,
                                            string stream_name,
                                            integer tr_handle);


  // Function: end_tr
  //
  // This function marks the end of a transaction, ~tr~, by this component.
  // Specifically, it performs the following actions:
  //
  // - Calls ~tr~'s <uvm_transaction::end_tr> method, passing to it the
  //   ~end_time~ argument. The ~end_time~ must at least be greater than the
  //   begin time. By default, when ~end_time~ = 0, the current simulation time
  //   is used.
  //
  //   The transaction's properties are recorded to the database-transaction on
  //   which it was started, and then the transaction is ended. Only those
  //   properties handled by the transaction's do_record method (and optional
  //   `uvm_*_field macros) are recorded.
  //
  // - Calls the component's <do_end_tr> method to accommodate any post-end
  //   action in derived classes.
  //
  // - Triggers the component's internal end_tr event. Any processes waiting on
  //   this event will resume in the next delta cycle. 
  //
  // The ~free_handle~ bit indicates that this transaction is no longer needed.
  // The implementation of free_handle is vendor-specific.

  extern function void end_tr (uvm_transaction tr,
                               time end_time=0,
                               bit free_handle=1);


  // Function: do_end_tr
  //
  // The <end_tr> method calls this function to accommodate any user-defined
  // post-end action. Implementations should call super.do_end_tr to ensure
  // correct operation.

  extern virtual protected function void do_end_tr (uvm_transaction tr,
                                                    integer tr_handle);


  // Function: record_error_tr
  //
  // This function marks an error transaction by a component. Properties of the
  // given uvm_object, ~info~, as implemented in its <uvm_object::do_record> method,
  // are recorded to the transaction database.
  //
  // An ~error_time~ of 0 indicates to use the current simulation time. The
  // ~keep_active~ bit determines if the handle should remain active. If 0,
  // then a zero-length error transaction is recorded. A handle to the
  // database-transaction is returned. 
  //
  // Interpretation of this handle, as well as the strings ~stream_name~,
  // ~label~, and ~desc~, are vendor-specific.

  extern function integer record_error_tr (string stream_name="main",
                                           uvm_object info=null,
                                           string label="error_tr",
                                           string desc="",
                                           time   error_time=0,
                                           bit    keep_active=0);


  // Function: record_event_tr
  //
  // This function marks an event transaction by a component. 
  //
  // An ~event_time~ of 0 indicates to use the current simulation time. 
  //
  // A handle to the transaction is returned. The ~keep_active~ bit determines
  // if the handle may be used for other vendor-specific purposes. 
  //
  // The strings for ~stream_name~, ~label~, and ~desc~ are vendor-specific
  // identifiers for the transaction.

  extern function integer record_event_tr (string stream_name="main",
                                           uvm_object info=null,
                                           string label="event_tr",
                                           string desc="",
                                           time   event_time=0,
                                           bit    keep_active=0);

  // Modified by Verdi 9001092057 9001330016 120*120*8-1=115199
`ifdef VCS extern function void uvm_set_verbosity(logic [115199:0] options_bv); `endif 
  // End

  // Variable: print_enabled
  //
  // This bit determines if this component should automatically be printed as a
  // child of its parent object. 
  // 
  // By default, all children are printed. However, this bit allows a parent
  // component to disable the printing of specific children.

  bit print_enabled = 1;


  // Variable: recorder
  //
  // Specifies the <uvm_recorder> object to use for <begin_tr> and other
  // methods in the <Recording Interface>. Default is <uvm_default_recorder>.
  //
  uvm_recorder recorder;

  //----------------------------------------------------------------------------
  //                     PRIVATE or PSUEDO-PRIVATE members
  //                      *** Do not call directly ***
  //         Implementation and even existence are subject to change. 
  //----------------------------------------------------------------------------
  // Most local methods are prefixed with m_, indicating they are not
  // user-level methods. SystemVerilog does not support friend classes,
  // which forces some otherwise internal methods to be exposed (i.e. not
  // be protected via 'local' keyword). These methods are also prefixed
  // with m_ to indicate they are not intended for public use.
  //
  // Internal methods will not be documented, although their implementa-
  // tions are freely available via the open-source license.
  //----------------------------------------------------------------------------

  protected uvm_domain m_domain;    // set_domain stores our domain handle

  /*protected*/ uvm_phase  m_phase_imps[uvm_phase];    // functors to override ovm_root defaults

  //TND review protected, provide read-only accessor.
  uvm_phase            m_current_phase;            // the most recently executed phase
  protected process    m_phase_process;

  /*protected*/ bit  m_build_done;
  /*protected*/ int  m_phasing_active;

  extern                   function void set_int_local(string field_name, 
                                                       uvm_bitstream_t value,
                                                       bit recurse=1);

  /*protected*/ uvm_component m_parent;
  protected     uvm_component m_children[string];
  protected     uvm_component m_children_by_handle[uvm_component];
  extern protected virtual function bit  m_add_child(uvm_component child);
  extern local     virtual function void m_set_full_name();

  extern                   function void do_resolve_bindings();
  extern                   function void do_flush();

  extern virtual           function void flush ();

  extern local             function void m_extract_name(string name ,
                                                        output string leaf ,
                                                        output string remainder );

  // overridden to disable
  extern virtual function uvm_object create (string name=""); 
  extern virtual function uvm_object clone  ();

  local integer m_stream_handle[string];
  local integer m_tr_h[uvm_transaction];
  extern protected function integer m_begin_tr (uvm_transaction tr,
              integer parent_handle=0, bit has_parent=0,
              string stream_name="main", string label="",
              string desc="", time begin_time=0);

  string m_name;

  const static string type_name = "uvm_component";
  virtual function string get_type_name();
    return type_name;
  endfunction

  protected uvm_event_pool event_pool;

  int unsigned recording_detail = UVM_NONE;
  extern         function void   do_print(uvm_printer printer);

  // Internal methods for setting up command line messaging stuff
  extern function void m_set_cl_msg_args;
  extern function void m_set_cl_verb;
  extern function void m_set_cl_action;
  extern function void m_set_cl_sev;
  extern function void m_apply_verbosity_settings(uvm_phase phase);

  // The verbosity settings may have a specific phase to start at. 
  // We will do this work in the phase_started callback. 

  typedef struct {
    string comp;
    string phase;
    time   offset;
    uvm_verbosity verbosity;
    string id;
  } m_verbosity_setting;

  m_verbosity_setting m_verbosity_settings[$];
  static m_verbosity_setting m_time_settings[$];

  // does the pre abort callback hierarchically
  extern /*local*/ function void m_do_pre_abort;

endclass : uvm_component

`include "base/uvm_root.svh"

// Modified by Verdi
`ifndef UVM_VERDI_NO_HIER_TRACE
function bit is_verdi_trace_dht_used_by_sep(byte sep);
    string verdi_trace_values[$], split_values[$];
    static uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
    static bit result = 0;

    void'(clp.get_arg_values("+UVM_VERDI_TRACE=",verdi_trace_values));
    foreach (verdi_trace_values[i]) begin
      uvm_split_string(verdi_trace_values[i], sep, split_values);
      foreach (split_values[j]) begin
        case (split_values[j])
          "HIER": result = 1;
          // "UVM_AWARE": result = 1; // 9001175642 turn off HIER tree by default
          "COMPWAVE": result = 1;
        endcase
      end
    end
  
    return result;
endfunction

function bit is_verdi_trace_dht_used();
    static bit is_verdi_trace_dht = 0;
    static bit is_verdi_trace_dht_checked = 0;

    if (is_verdi_trace_dht_checked==0) begin
        is_verdi_trace_dht_checked = 1;
        is_verdi_trace_dht = is_verdi_trace_dht_used_by_sep("|") || is_verdi_trace_dht_used_by_sep("+");
    end

    return is_verdi_trace_dht;
endfunction
`endif

`ifndef UVM_VERDI_NO_IMPLICIT_GET
function bit is_verdi_trace_no_implicit_get_used_by_sep(byte sep);
    string verdi_trace_values[$], split_values[$];
    static uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
    static bit result = 0;

    void'(clp.get_arg_values("+UVM_VERDI_TRACE=",verdi_trace_values));
    foreach (verdi_trace_values[i]) begin
      uvm_split_string(verdi_trace_values[i], sep, split_values);
      foreach (split_values[j]) begin
        case (split_values[j])
          "NO_IMPLICIT_GET": result = 1;
        endcase
      end
    end

    return result;
endfunction

function bit is_verdi_trace_no_implicit_get_used();
    static bit is_verdi_trace_no_implicit_get = 0;
    static bit is_verdi_trace_no_implicit_get_checked = 0;

    if (is_verdi_trace_no_implicit_get_checked==0) begin
        is_verdi_trace_no_implicit_get_checked = 1;
        is_verdi_trace_no_implicit_get = is_verdi_trace_no_implicit_get_used_by_sep("|") || is_verdi_trace_no_implicit_get_used_by_sep("+");
    end

    return is_verdi_trace_no_implicit_get;
endfunction
`endif
// End

//------------------------------------------------------------------------------
// IMPLEMENTATION
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// CLASS- uvm_component
//
//------------------------------------------------------------------------------


// new
// ---

function uvm_component::new (string name, uvm_component parent);
  string error_str;
  uvm_root top;

  super.new(name);

  // If uvm_top, reset name to "" so it doesn't show in full paths then return
  if (parent==null && name == "__top__") begin
    set_name(""); // *** VIRTUAL
    return;
  end

  top = uvm_root::get();

  // Check that we're not in or past end_of_elaboration
  begin
    uvm_phase bld;
    uvm_domain common;
    common = uvm_domain::get_common_domain();
    bld = common.find(uvm_build_phase::get());
    if (bld == null)
      uvm_report_fatal("COMP/INTERNAL",
                       "attempt to find build phase object failed",UVM_NONE);
    if (bld.get_state() == UVM_PHASE_DONE) begin
      uvm_report_fatal("ILLCRT", {"It is illegal to create a component ('",
                name,"' under '",
                (parent == null ? top.get_full_name() : parent.get_full_name()),
               "') after the build phase has ended."},
                       UVM_NONE);
    end
  end

  if (name == "") begin
    name.itoa(m_inst_count);
    name = {"COMP_", name};
  end

  if(parent == this) begin
    `uvm_fatal("THISPARENT", "cannot set the parent of a component to itself")
  end

  if (parent == null)
    parent = top;

  `ifndef UVM_VERDI_NO_HIER_TRACE
  //////////////////////////
  // Modified by Verdi
  begin
    uvm_port_component_base port_component;

    if (is_verdi_trace_dht_used() && !$cast(port_component,this)) begin
      string label, message, full_name, type_name;

      label = {"Creating ", name};
      full_name = {(parent==top?"":{parent.get_full_name(),"."}),name};
      type_name = get_type_name();
      $sformat(message,"label:%s name:%s full_name:%s type_name:%s full_type_name:%s",label,name,full_name,type_name,type_name);
      if (name!="DHIER_COMP")
          `uvm_info("SNPS_COMP_TRACE",message,UVM_LOW)
    end
  end
  // End 
  /////////////////////////
`endif

  if(uvm_report_enabled(UVM_MEDIUM+1, UVM_INFO, "NEWCOMP"))
    `uvm_info("NEWCOMP", {"Creating ",
      (parent==top?"uvm_top":parent.get_full_name()),".",name},UVM_MEDIUM+1)

  if (parent.has_child(name) && this != parent.get_child(name)) begin
    if (parent == top) begin
      error_str = {"Name '",name,"' is not unique to other top-level ",
      "instances. If parent is a module, build a unique name by combining the ",
      "the module name and component name: $sformatf(\"\%m.\%s\",\"",name,"\")."};
      `uvm_fatal("CLDEXT",error_str)
    end
    else
      `uvm_fatal("CLDEXT",
        $sformatf("Cannot set '%s' as a child of '%s', %s",
                  name, parent.get_full_name(),
                  "which already has a child by that name."))
    return;
  end

  m_parent = parent;

  set_name(name); // *** VIRTUAL

  if (!m_parent.m_add_child(this))
    m_parent = null;

  event_pool = new("event_pool");

  m_domain = parent.m_domain;     // by default, inherit domains from parents
  
  // Now that inst name is established, reseed (if use_uvm_seeding is set)
  reseed();

  // Do local configuration settings
  if (!uvm_config_db #(uvm_bitstream_t)::get(this, "", "recording_detail", recording_detail))
        void'(uvm_config_db #(int)::get(this, "", "recording_detail", recording_detail));

  set_report_verbosity_level(parent.get_report_verbosity_level());

  m_set_cl_msg_args();

endfunction


// m_add_child
// -----------

function bit uvm_component::m_add_child(uvm_component child);

  if (m_children.exists(child.get_name()) &&
      m_children[child.get_name()] != child) begin
      `uvm_warning("BDCLD",
        $sformatf("A child with the name '%0s' (type=%0s) already exists.",
           child.get_name(), m_children[child.get_name()].get_type_name()))
      return 0;
  end

  if (m_children_by_handle.exists(child)) begin
      `uvm_warning("BDCHLD",
        $sformatf("A child with the name '%0s' %0s %0s'",
                  child.get_name(),
                  "already exists in parent under name '",
                  m_children_by_handle[child].get_name()))
      return 0;
    end

  m_children[child.get_name()] = child;
  m_children_by_handle[child] = child;
  return 1;
endfunction



//------------------------------------------------------------------------------
//
// Hierarchy Methods
// 
//------------------------------------------------------------------------------


// get_children
// ------------

function void uvm_component::get_children(ref uvm_component children[$]);
  foreach(m_children[i]) 
    children.push_back(m_children[i]);
endfunction


// get_first_child
// ---------------

function int uvm_component::get_first_child(ref string name);
  return m_children.first(name);
endfunction


// get_next_child
// --------------

function int uvm_component::get_next_child(ref string name);
  return m_children.next(name);
endfunction


// get_child
// ---------

function uvm_component uvm_component::get_child(string name);
  if (m_children.exists(name))
    return m_children[name];
  `uvm_warning("NOCHILD",{"Component with name '",name,
       "' is not a child of component '",get_full_name(),"'"})
  return null;
endfunction


// has_child
// ---------

function int uvm_component::has_child(string name);
  return m_children.exists(name);
endfunction


// get_num_children
// ----------------

function int uvm_component::get_num_children();
  return m_children.num();
endfunction


// get_full_name
// -------------

function string uvm_component::get_full_name ();
  // Note- Implementation choice to construct full name once since the
  // full name may be used often for lookups.
  if(m_name == "")
    return get_name();
  else
    return m_name;
endfunction


// get_parent
// ----------

function uvm_component uvm_component::get_parent ();
  return  m_parent;
endfunction


// set_name
// --------

function void uvm_component::set_name (string name);
  if(m_name != "") begin
    `uvm_error("INVSTNM", $sformatf("It is illegal to change the name of a component. The component name will not be changed to \"%s\"", name))
    return;
  end
  super.set_name(name);
  m_set_full_name();

endfunction


// m_set_full_name
// ---------------

function void uvm_component::m_set_full_name();
  uvm_root top;
  top = uvm_top;
  if (m_parent == top || m_parent==null)
    m_name = get_name();
  else 
    m_name = {m_parent.get_full_name(), ".", get_name()};

  foreach (m_children[c]) begin
    uvm_component tmp;
    tmp = m_children[c];
    tmp.m_set_full_name(); 
  end

endfunction


// lookup
// ------

function uvm_component uvm_component::lookup( string name );

  string leaf , remainder;
  uvm_component comp;
  uvm_root top;
  top = uvm_root::get();

  comp = this;
  
  m_extract_name(name, leaf, remainder);

  if (leaf == "") begin
    comp = top; // absolute lookup
    m_extract_name(remainder, leaf, remainder);
  end
  
  if (!comp.has_child(leaf)) begin
    `uvm_warning("Lookup Error", 
       $sformatf("Cannot find child %0s",leaf))
    return null;
  end

  if( remainder != "" )
    return comp.m_children[leaf].lookup(remainder);

  return comp.m_children[leaf];

endfunction


// get_depth
// ---------

function int unsigned uvm_component::get_depth();
  if(m_name == "") return 0;
  get_depth = 1;
  foreach(m_name[i]) 
    if(m_name[i] == ".") ++get_depth;
endfunction


// m_extract_name
// --------------

function void uvm_component::m_extract_name(input string name ,
                                            output string leaf ,
                                            output string remainder );
  int i , len;
  string extract_str;
  len = name.len();
  
  for( i = 0; i < name.len(); i++ ) begin  
    if( name[i] == "." ) begin
      break;
    end
  end

  if( i == len ) begin
    leaf = name;
    remainder = "";
    return;
  end

  leaf = name.substr( 0 , i - 1 );
  remainder = name.substr( i + 1 , len - 1 );

  return;
endfunction
  

// flush
// -----

function void uvm_component::flush();
  return;
endfunction


// do_flush  (flush_hier?)
// --------

function void uvm_component::do_flush();
  foreach( m_children[s] )
    m_children[s].do_flush();
  flush();
endfunction
  


//------------------------------------------------------------------------------
//
// Factory Methods
// 
//------------------------------------------------------------------------------


// create
// ------

function uvm_object  uvm_component::create (string name =""); 
  `uvm_error("ILLCRT",
    "create cannot be called on a uvm_component. Use create_component instead.")
  return null;
endfunction


// clone
// ------

function uvm_object  uvm_component::clone ();
  `uvm_error("ILLCLN", $sformatf("Attempting to clone '%s'.  Clone cannot be called on a uvm_component.  The clone target variable will be set to null.", get_full_name()))
  return null;
endfunction


// print_override_info
// -------------------

function void  uvm_component::print_override_info (string requested_type_name, 
                                                   string name="");
  factory.debug_create_by_name(requested_type_name, get_full_name(), name);
endfunction


// create_component
// ----------------

function uvm_component uvm_component::create_component (string requested_type_name,
                                                        string name);
  return factory.create_component_by_name(requested_type_name, get_full_name(),
                                          name, this);
endfunction


// create_object
// -------------

function uvm_object uvm_component::create_object (string requested_type_name,
                                                  string name="");
  return factory.create_object_by_name(requested_type_name,
                                       get_full_name(), name);
endfunction


// set_type_override (static)
// -----------------

function void uvm_component::set_type_override (string original_type_name,
                                                string override_type_name,
                                                bit    replace=1);
   factory.set_type_override_by_name(original_type_name,
                                     override_type_name, replace);
endfunction 


// set_type_override_by_type (static)
// -------------------------

function void uvm_component::set_type_override_by_type (uvm_object_wrapper original_type,
                                                        uvm_object_wrapper override_type,
                                                        bit    replace=1);
   factory.set_type_override_by_type(original_type, override_type, replace);
endfunction 


// set_inst_override
// -----------------

function void  uvm_component::set_inst_override (string relative_inst_path,  
                                                 string original_type_name,
                                                 string override_type_name);
  string full_inst_path;

  if (relative_inst_path == "")
    full_inst_path = get_full_name();
  else
    full_inst_path = {get_full_name(), ".", relative_inst_path};

  factory.set_inst_override_by_name(
                            original_type_name,
                            override_type_name,
                            full_inst_path);
endfunction 


// set_inst_override_by_type
// -------------------------

function void uvm_component::set_inst_override_by_type (string relative_inst_path,  
                                                        uvm_object_wrapper original_type,
                                                        uvm_object_wrapper override_type);
  string full_inst_path;

  if (relative_inst_path == "")
    full_inst_path = get_full_name();
  else
    full_inst_path = {get_full_name(), ".", relative_inst_path};

  factory.set_inst_override_by_type(original_type, override_type, full_inst_path);

endfunction



//------------------------------------------------------------------------------
//
// Hierarchical report configuration interface
//
//------------------------------------------------------------------------------

// set_report_id_verbosity_hier
// -------------------------

function void uvm_component::set_report_id_verbosity_hier( string id, int verbosity);
  set_report_id_verbosity(id, verbosity);
  foreach( m_children[c] )
    m_children[c].set_report_id_verbosity_hier(id, verbosity);
endfunction


// set_report_severity_id_verbosity_hier
// ----------------------------------

function void uvm_component::set_report_severity_id_verbosity_hier( uvm_severity severity,
                                                                 string id,
                                                                 int verbosity);
  set_report_severity_id_verbosity(severity, id, verbosity);
  foreach( m_children[c] )
    m_children[c].set_report_severity_id_verbosity_hier(severity, id, verbosity);
endfunction


// set_report_severity_action_hier
// -------------------------

function void uvm_component::set_report_severity_action_hier( uvm_severity severity, 
                                                           uvm_action action);
  set_report_severity_action(severity, action);
  foreach( m_children[c] )
    m_children[c].set_report_severity_action_hier(severity, action);
endfunction


// set_report_id_action_hier
// -------------------------

function void uvm_component::set_report_id_action_hier( string id, uvm_action action);
  set_report_id_action(id, action);
  foreach( m_children[c] )
    m_children[c].set_report_id_action_hier(id, action);
endfunction


// set_report_severity_id_action_hier
// ----------------------------------

function void uvm_component::set_report_severity_id_action_hier( uvm_severity severity,
                                                                 string id,
                                                                 uvm_action action);
  set_report_severity_id_action(severity, id, action);
  foreach( m_children[c] )
    m_children[c].set_report_severity_id_action_hier(severity, id, action);
endfunction


// set_report_severity_file_hier
// -----------------------------

function void uvm_component::set_report_severity_file_hier( uvm_severity severity,
                                                            UVM_FILE file);
  set_report_severity_file(severity, file);
  foreach( m_children[c] )
    m_children[c].set_report_severity_file_hier(severity, file);
endfunction


// set_report_default_file_hier
// ----------------------------

function void uvm_component::set_report_default_file_hier( UVM_FILE file);
  set_report_default_file(file);
  foreach( m_children[c] )
    m_children[c].set_report_default_file_hier(file);
endfunction


// set_report_id_file_hier
// -----------------------
  
function void uvm_component::set_report_id_file_hier( string id, UVM_FILE file);
  set_report_id_file(id, file);
  foreach( m_children[c] )
    m_children[c].set_report_id_file_hier(id, file);
endfunction


// set_report_severity_id_file_hier
// --------------------------------

function void uvm_component::set_report_severity_id_file_hier ( uvm_severity severity,
                                                                string id,
                                                                UVM_FILE file);
  set_report_severity_id_file(severity, id, file);
  foreach( m_children[c] )
    m_children[c].set_report_severity_id_file_hier(severity, id, file);
endfunction


// set_report_verbosity_level_hier
// -------------------------------

function void uvm_component::set_report_verbosity_level_hier(int verbosity);
  set_report_verbosity_level(verbosity);
  foreach( m_children[c] )
    m_children[c].set_report_verbosity_level_hier(verbosity);
endfunction  



//------------------------------------------------------------------------------
//
// Phase interface 
//
//------------------------------------------------------------------------------


// phase methods
//--------------
// these are prototypes for the methods to be implemented in user components
// build_phase() has a default implementation, the others have an empty default

function void uvm_component::build_phase(uvm_phase phase);
  m_build_done = 1;
  build();
endfunction

// Backward compatibility build function

function void uvm_component::build();
  uvm_root r_obj;
  m_build_done = 1;
  r_obj = uvm_root::get();
  if (!(r_obj.disable_apply_cfg_settings))
  apply_config_settings(print_config_matches);
//   else `uvm_info("NO_APPLY_CFG","apply_config_settings disabled by +UVM_DISABLE_APPLY_CFG_SETTINGS",UVM_DEBUG)
  if(m_phasing_active == 0) begin
    uvm_report_warning("UVM_DEPRECATED", "build()/build_phase() has been called explicitly, outside of the phasing system. This usage of build is deprecated and may lead to unexpected behavior.");
  end
endfunction

// these phase methods are common to all components in UVM. For backward
// compatibility, they call the old style name (without the _phse)

function void uvm_component::connect_phase(uvm_phase phase);
  connect();
  return; 
endfunction
function void uvm_component::start_of_simulation_phase(uvm_phase phase);
  start_of_simulation();
  return; 
endfunction
function void uvm_component::end_of_elaboration_phase(uvm_phase phase);
  end_of_elaboration();
  return; 
endfunction
task          uvm_component::run_phase(uvm_phase phase);
  run();
  return; 
endtask
function void uvm_component::extract_phase(uvm_phase phase);
  extract();
  return; 
endfunction
function void uvm_component::check_phase(uvm_phase phase);
  check();
  return; 
endfunction
function void uvm_component::report_phase(uvm_phase phase);
  report();
  return; 
endfunction


// These are the old style phase names. In order for runtime phase names
// to not conflict with user names, the _phase postfix was added.

function void uvm_component::connect();             return; endfunction
function void uvm_component::start_of_simulation(); return; endfunction
function void uvm_component::end_of_elaboration();  return; endfunction
task          uvm_component::run();                 return; endtask
function void uvm_component::extract();             return; endfunction
function void uvm_component::check();               return; endfunction
function void uvm_component::report();              return; endfunction
function void uvm_component::final_phase(uvm_phase phase);         return; endfunction

// these runtime phase methods are only called if a set_domain() is done

task uvm_component::pre_reset_phase(uvm_phase phase);      return; endtask
task uvm_component::reset_phase(uvm_phase phase);          return; endtask
task uvm_component::post_reset_phase(uvm_phase phase);     return; endtask
task uvm_component::pre_configure_phase(uvm_phase phase);  return; endtask
task uvm_component::configure_phase(uvm_phase phase);      return; endtask
task uvm_component::post_configure_phase(uvm_phase phase); return; endtask
task uvm_component::pre_main_phase(uvm_phase phase);       return; endtask
task uvm_component::main_phase(uvm_phase phase);           return; endtask
task uvm_component::post_main_phase(uvm_phase phase);      return; endtask
task uvm_component::pre_shutdown_phase(uvm_phase phase);   return; endtask
task uvm_component::shutdown_phase(uvm_phase phase);       return; endtask
task uvm_component::post_shutdown_phase(uvm_phase phase);  return; endtask


//------------------------------
// current phase convenience API
//------------------------------


// phase_started
// -------------
// phase_started() and phase_ended() are extra callbacks called at the
// beginning and end of each phase, respectively.  Since they are
// called for all phases the phase is passed in as an argument so the
// extender can decide what to do, if anything, for each phase.

function void uvm_component::phase_started(uvm_phase phase);
`ifdef UVM_VCS_RECORD
 if (m_phase_record_enabled == -1) begin
    uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
// Register the Phase recording mechanism to dump phasing info into VPD
    if (clp.get_arg_matches("+UVM_PHASE_RECORD", tr_args)) begin
      m_phase_record_enabled = 1;
    end else begin
      m_phase_record_enabled = 0;
    end
  end


  if (m_phase_record_enabled) begin
    string stream, msgname, hdr, msg, typ;
    uvm_port_component_base port_base;
 
    if (this.get_full_name() == "") return;
    if($cast(port_base,this)) begin
     return; 
    end 

    stream = {"PHASE$", phase.get_domain_name()};
    msgname = phase.get_name();
    hdr = phase.get_name();
    msg = {"Started: ", this.get_full_name()};
    typ = this.get_type_name();
   
    if (m_phase_record_ref_count[phase.get_inst_id()] == 0) begin
      $vcdplusmsglog(stream, 'h0080, msgname, 'h0008, hdr,"", 'h0001); 
    end
    $vcdplusmsglog(stream, 'h0080, msgname,'h0008,msg ,typ, 'h0080); 

    m_phase_record_ref_count[phase.get_inst_id()]++;
  end
`endif


endfunction

// phase_ended
// -----------

function void uvm_component::phase_ended(uvm_phase phase);
`ifdef UVM_VCS_RECORD
  if (m_phase_record_enabled) begin
    string stream, msgname, hdr, msg, typ;
    uvm_port_component_base port_base;

    if (get_full_name() == "" || !m_phase_record_ref_count.exists(phase.get_inst_id())) return;
    if($cast(port_base,this)) return;

    stream = {"PHASE$", phase.get_domain_name()};
    msgname = phase.get_name();
    msg = {"Ended: ", this.get_full_name()};
    typ = this.get_type_name();
  
    m_phase_record_ref_count[phase.get_inst_id()]--;

    if (m_phase_record_ref_count[phase.get_inst_id()]  == 0) begin
      $vcdplusmsglog(stream, 'h0080, msgname, 'h0008, hdr,"", 'h0002); 
    end
    else begin
    $vcdplusmsglog(stream, 'h0080, msgname,'h0008,msg ,typ, 'h0080); 
    end
  end
`endif


endfunction


// phase_ready_to_end
// ------------------

function void uvm_component::phase_ready_to_end (uvm_phase phase);
endfunction

//------------------------------
// phase / schedule / domain API
//------------------------------
// methods for VIP creators and integrators to use to set up schedule domains
// - a schedule is a named, organized group of phases for a component base type
// - a domain is a named instance of a schedule in the master phasing schedule


// define_domain
// -------------

function void uvm_component::define_domain(uvm_domain domain);
  uvm_phase schedule;
  //schedule = domain.find(uvm_domain::get_uvm_schedule());
  schedule = domain.find_by_name("uvm_sched");
  if (schedule == null) begin
    uvm_domain common;
    schedule = new("uvm_sched", UVM_PHASE_SCHEDULE);
    uvm_domain::add_uvm_phases(schedule);
    domain.add(schedule);
    common = uvm_domain::get_common_domain();
    if (common.find(domain,0) == null)
      common.add(domain,.with_phase(uvm_run_phase::get()));
  end

endfunction


// set_domain
// ----------
// assigns this component [tree] to a domain. adds required schedules into graph
// If called from build, ~hier~ won't recurse into all chilren (which don't exist yet)
// If we have components inherit their parent's domain by default, then ~hier~
// isn't needed and we need a way to prevent children from inheriting this component's domain

function void uvm_component::set_domain(uvm_domain domain, int hier=1);

  // build and store the custom domain
  m_domain = domain;
  define_domain(domain);
  if (hier)
    foreach (m_children[c])
      m_children[c].set_domain(domain);
endfunction

// get_domain
// ----------
//
function uvm_domain uvm_component::get_domain();
  return m_domain;
endfunction


// set_phase_imp
// -------------

function void uvm_component::set_phase_imp(uvm_phase phase, uvm_phase imp, int hier=1);
  m_phase_imps[phase] = imp;
  if (hier)
    foreach (m_children[c])
      m_children[c].set_phase_imp(phase,imp,hier);
endfunction


//--------------------------
// phase runtime control API
//--------------------------

`ifndef UVM_NO_DEPRECATED
// do_kill_all
// -----------

function void uvm_component::do_kill_all();
  foreach(m_children[c])
    m_children[c].do_kill_all();
  kill();
endfunction


// kill
// ----

function void uvm_component::kill();
    if (m_phase_process != null) begin
      m_phase_process.kill;
      m_phase_process = null;
    end
endfunction
`endif

// suspend
// -------

task uvm_component::suspend();
   `uvm_warning("COMP/SPND/UNIMP", "suspend() not implemented")
endtask


// resume
// ------

task uvm_component::resume();
   `uvm_warning("COMP/RSUM/UNIMP", "resume() not implemented")
endtask


// status
//-------

`ifndef UVM_NO_DEPRECATED
function string uvm_component::status();

  `ifdef UVM_USE_SUSPEND_RESUME
   `ifdef UVM_USE_PROCESS_STATE
    process::state ps;

    if(m_phase_process == null)
      return "<unknown>";

    ps = m_phase_process.status();

    return ps.name();
  `else
    if(m_phase_process == null)
      return "<unknown>";

    case(m_phase_process.status())
      0: return "FINISHED";
      1: return "RUNNING";
      2: return "WAITING";
      3: return "SUSPENDED";
      4: return "KILLED";
      default: return "<unknown>";
    endcase
  `endif
  `endif 

   return "<unknown>";
   
endfunction

// stop
// ----

task uvm_component::stop(string ph_name);
  return;
endtask


// stop_phase
// ----------

task uvm_component::stop_phase(uvm_phase phase);
  stop(phase.get_name());
  return;
endtask
`endif


// resolve_bindings
// ----------------

function void uvm_component::resolve_bindings();
  return;
endfunction


// do_resolve_bindings
// -------------------

function void uvm_component::do_resolve_bindings();
  foreach( m_children[s] )
    m_children[s].do_resolve_bindings();
  resolve_bindings();
endfunction



//------------------------------------------------------------------------------
//
// Recording interface
//
//------------------------------------------------------------------------------

// accept_tr
// ---------

function void uvm_component::accept_tr (uvm_transaction tr,
                                        time accept_time=0);
  uvm_event e;
  tr.accept_tr(accept_time);
  do_accept_tr(tr);
  e = event_pool.get("accept_tr");
  if(e!=null) 
    e.trigger();
endfunction

// begin_tr
// --------

function integer uvm_component::begin_tr (uvm_transaction tr,
                                          string stream_name ="main",
                                          string label="",
                                          string desc="",
                                          time begin_time=0,
                                          integer parent_handle=0);
  return m_begin_tr(tr, parent_handle, (parent_handle!=0), stream_name, label, desc, begin_time);
endfunction

// begin_child_tr
// --------------

function integer uvm_component::begin_child_tr (uvm_transaction tr,
                                          integer parent_handle=0,
                                          string stream_name="main",
                                          string label="",
                                          string desc="",
                                          time begin_time=0);
  return m_begin_tr(tr, parent_handle, 1, stream_name, label, desc, begin_time);
endfunction

// Modified by Verdi
`ifndef UVM_VERDI_NO_COMP_TYPE
function bit is_verdi_trace_tlm_used_by_sep(byte sep);
    string verdi_trace_values[$], split_values[$];
    static uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
    static bit result = 0;

    void'(clp.get_arg_values("+UVM_VERDI_TRACE=",verdi_trace_values));
    foreach (verdi_trace_values[i]) begin
      uvm_split_string(verdi_trace_values[i], sep, split_values);
      foreach (split_values[j]) begin
        case (split_values[j])
          "TLM": result = 1;
        endcase
      end
    end

    return result;
endfunction

function bit is_verdi_trace_tlm_used();
    static bit is_verdi_trace_tlm_checked = 0;
    static bit is_verdi_trace_tlm = 0;

    if (is_verdi_trace_tlm_checked==0) begin
        is_verdi_trace_tlm_checked = 1;
        is_verdi_trace_tlm = is_verdi_trace_tlm_used_by_sep("|")||is_verdi_trace_tlm_used_by_sep("+");
    end

    return is_verdi_trace_tlm;
endfunction

function bit is_verdi_recorder_enabled ();
    static uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
    static bit is_verdi_recorder_option_checked = 0;
    static bit is_verdi_rec_enabled = 0; 
    string trace_args[$];

    if (!is_verdi_recorder_option_checked) begin
        is_verdi_recorder_option_checked = 1;

        if ((clp.get_arg_matches("+UVM_TR_RECORD",trace_args) &&
            clp.get_arg_matches("+UVM_VERDI_TRACE", trace_args))||is_verdi_trace_tlm_used())
            is_verdi_rec_enabled = 1;
    end
    return is_verdi_rec_enabled;
endfunction

function bit uvm_component::is_sequencer(uvm_component comp);
    uvm_sequencer_base sqr_base;

    if ($cast(sqr_base,comp))
        return 1;
    else
        return 0;
endfunction

function bit uvm_component::is_driver(uvm_component comp);
    string child_name;
    uvm_component child;
    uvm_port_component_base port;

    if (comp.get_first_child(child_name))
        do begin
           child = comp.get_child(child_name);
           if ($cast(port,child)) begin
               if (child_name=="seq_item_port"||child_name=="rsp_port")
                   return 1;
           end
        end while (comp.get_next_child(child_name));

    return 0;
endfunction

function string uvm_component::check_component_type(uvm_component comp);
  string ret_str = "TVM";

  if (is_sequencer(comp))
      ret_str = "TVM:sequencer";
  if (is_driver(comp))
      ret_str = "TVM:driver";

  return ret_str;
endfunction
`endif
// End

// m_begin_tr
// ----------

function integer uvm_component::m_begin_tr (uvm_transaction tr,
                                          integer parent_handle=0,
                                          bit    has_parent=0,
                                          string stream_name="main",
                                          string label="",
                                          string desc="",
                                          time begin_time=0);
  uvm_event e;
  integer stream_h=0;
  integer tr_h;
  integer link_tr_h;
  string name;
  string kind;
  uvm_recorder recordr;
`ifdef UVM_VCS_RECORD
  uvm_sequence_base seq_base;
`endif

  if (tr == null)
    return 0;

  recordr = (recorder == null) ? uvm_default_recorder : recorder;

  if (!has_parent) begin
    uvm_sequence_item seq;
    if ($cast(seq,tr)) begin
      uvm_sequence_base parent_seq = seq.get_parent_sequence();
      if (parent_seq != null) begin
        parent_handle = parent_seq.m_tr_handle;
        if (parent_handle!=0)
          has_parent = 1;
      end
    end
  end

  tr_h = 0;
  if(has_parent)
    link_tr_h = tr.begin_child_tr(begin_time, parent_handle);
  else
    link_tr_h = tr.begin_tr(begin_time);

  if (tr.get_name() != "")
    name = tr.get_name();
  else
    name = tr.get_type_name();

  if(stream_name == "") stream_name="main";

  if (uvm_verbosity'(recording_detail) != UVM_NONE) begin

    if(m_stream_handle.exists(stream_name))
        stream_h = m_stream_handle[stream_name];

    if (recordr.check_handle_kind("Fiber", stream_h) != 1) begin  
        // Modified by Verdi
        `ifndef UVM_VERDI_NO_COMP_TYPE
        if (is_verdi_recorder_enabled())
            stream_h = recordr.create_stream(stream_name, check_component_type(this), get_full_name());
        else
        `endif
        // End
        stream_h = recordr.create_stream(stream_name, "TVM", get_full_name());
        m_stream_handle[stream_name] = stream_h;
    end

    kind = (has_parent == 0) ? "Begin_No_Parent, Link" : "Begin_End, Link";

`ifdef UVM_VCS_RECORD
    desc = {desc,
            $sformatf("Object ID: %0s (@%0d)\n", $vcs_get_object_id(tr), tr.get_inst_id()),
            $sformatf("Sequencer ID: %0s (@%0d)\n",  $vcs_get_object_id(this), get_inst_id())};

    if ($cast(seq_base,tr)) begin
      desc = {desc,
              "Phase: ", seq_base.starting_phase ? seq_base.starting_phase.get_name() : "N/A", "\n"};
    end
`endif

// Modified by Verdi
`ifndef UVM_VERDI_NO_COMP_TYPE
  if (is_verdi_recorder_enabled())
    begin
      uvm_sequence_item seq_item;
      uvm_sequence_base parent_seq;
 `ifndef UVM_VCS_RECORD
      uvm_sequence_base seq_base;
    desc = {desc, //9001130255
            $sformatf("Object ID: %0s (@%0d)\n", recordr.get_object_id(tr), tr.get_inst_id()), 
            $sformatf("Sequencer ID: %0s (@%0d)\n", recordr.get_object_id(this), get_inst_id())};
    if ($cast(seq_base,tr)) begin
      desc = {desc,
              "Phase: ", seq_base.starting_phase ? seq_base.starting_phase.get_name() : "N/A", "\n"};
    end
`endif

    if ($cast(seq_base,tr)) begin
      parent_seq = seq_base.get_parent_sequence();
      if(parent_seq!=null) begin
         desc = {desc,
                 $sformatf("Parent Sequence ID: %0d\n", parent_seq.get_inst_id())};
      end
    end else if($cast(seq_item, tr)) begin
      parent_seq = seq_item.get_parent_sequence();
      if(parent_seq!=null) begin
         desc = {desc,
                 $sformatf("Parent Sequence ID: %0d\n",  parent_seq.get_inst_id())};
      end
    end
  end
`endif
// End

    tr_h = recordr.begin_tr(kind, stream_h, name, label, desc, begin_time);

    if (has_parent && parent_handle != 0)
        recordr.link_tr(parent_handle, tr_h, "child");

    m_tr_h[tr] = tr_h;

    if (recordr.check_handle_kind("Transaction", link_tr_h) == 1)
      recordr.link_tr(tr_h,link_tr_h);
        
    do_begin_tr(tr,stream_name,tr_h); 
        
  end
 
  e = event_pool.get("begin_tr");
  if (e!=null) 
    e.trigger(tr);
        
  return tr_h;

endfunction


// end_tr
// ------

function void uvm_component::end_tr (uvm_transaction tr,
                                     time end_time=0,
                                     bit free_handle=1);
  uvm_event e;
  integer tr_h;
  uvm_recorder recordr;

  if (tr == null)
    return;

  recordr = (recorder == null) ? uvm_default_recorder : recorder;
  tr_h = 0;

  tr.end_tr(end_time,free_handle);

  if (uvm_verbosity'(recording_detail) != UVM_NONE) begin

    if (m_tr_h.exists(tr)) begin

      tr_h = m_tr_h[tr];

      do_end_tr(tr, tr_h); // callback

      m_tr_h.delete(tr);

      if (recordr.check_handle_kind("Transaction", tr_h) == 1) begin  

        recordr.tr_handle = tr_h;
        tr.record(recordr);

        recordr.end_tr(tr_h,end_time);

        if (free_handle)
           recordr.free_tr(tr_h);

      end
    end
    else begin
      do_end_tr(tr, tr_h); // callback
    end

  end

  e = event_pool.get("end_tr");
  if(e!=null) 
    e.trigger();

endfunction


// record_error_tr
// ---------------

function integer uvm_component::record_error_tr (string stream_name="main",
                                              uvm_object info=null,
                                              string label="error_tr",
                                              string desc="",
                                              time   error_time=0,
                                              bit    keep_active=0);
  string etype;
  integer stream_h;
  uvm_recorder recordr;
  recordr = (recorder == null) ? uvm_default_recorder : recorder;

  if(keep_active) etype = "Error, Link";
  else etype = "Error";

  if(error_time == 0) error_time = $realtime;

  stream_h = m_stream_handle[stream_name];
  if (recordr.check_handle_kind("Fiber", stream_h) != 1) begin  
    stream_h = recordr.create_stream(stream_name, "TVM", get_full_name());
    m_stream_handle[stream_name] = stream_h;
  end

  record_error_tr = recordr.begin_tr(etype, stream_h, label,
                         label, desc, error_time);
  if(info!=null) begin
    recordr.tr_handle = record_error_tr;
    info.record(recordr);
  end

  recordr.end_tr(record_error_tr,error_time);
endfunction


// record_event_tr
// ---------------

function integer uvm_component::record_event_tr (string stream_name="main",
                                              uvm_object info=null,
                                              string label="event_tr",
                                              string desc="",
                                              time   event_time=0,
                                              bit    keep_active=0);
  string etype;
  integer stream_h;
  uvm_recorder recordr;
  recordr = (recorder == null) ? uvm_default_recorder : recorder;

  if(keep_active) etype = "Event, Link";
  else etype = "Event";

  if(event_time == 0) event_time = $realtime;

  stream_h = m_stream_handle[stream_name];
  if (recordr.check_handle_kind("Fiber", stream_h) != 1) begin  
    stream_h = recordr.create_stream(stream_name, "TVM", get_full_name());
    m_stream_handle[stream_name] = stream_h;
  end

  record_event_tr = recordr.begin_tr(etype, stream_h, label,
                         label, desc, event_time);
  if(info!=null) begin
    recordr.tr_handle = record_event_tr;
    info.record(recordr);
  end

  recordr.end_tr(record_event_tr,event_time);
endfunction

// Modified by Verdi 9001092057 9001330016 120*120*8-1=115199
`ifdef VCS function void uvm_component::uvm_set_verbosity(logic [115199:0] options_bv);
  // _ALL_ can be used for ids
  // +uvm_set_verbosity=<comp>,<id>,<verbosity>,<phase|time>,<offset>
  // +uvm_set_verbosity=uvm_test_top.env0.agent1.*,_ALL_,UVM_FULL,time,800

  static bit first = 1;
  string args[$];
  string options;  
  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
  uvm_root top = uvm_root::get();

  begin
    m_verbosity_setting setting;
    args.delete();
    options = uvm_bits_to_string(options_bv);
    uvm_split_string(options, ",", args);

    begin
      setting.comp = args[0];
      setting.id = args[1];
      void'(clp.m_convert_verb(args[2],setting.verbosity));
      setting.phase = args[3];
      setting.offset = 0;
      if(args.size() == 5) setting.offset = args[4].atoi();
      if((setting.phase == "time") && (this == top)) begin
        m_time_settings.push_back(setting);
      end

      if (uvm_is_match(setting.comp, get_full_name()) ) begin
        if((setting.phase == "" || setting.phase == "build" || setting.phase == "time") &&
           (setting.offset == 0) )
        begin
          if(setting.id == "_ALL_")
            set_report_verbosity_level(setting.verbosity);
          else
            set_report_id_verbosity(setting.id, setting.verbosity);
        end
        else begin
          if(setting.phase != "time") begin
            m_verbosity_settings.push_back(setting);
          end
        end
      end
    end
  end
  // do time based settings
  if(this == top) begin
    fork begin
      time last_time = 0;
      if (m_time_settings.size() > 0)
        m_time_settings.sort() with ( item.offset );
      foreach(m_time_settings[i]) begin
        uvm_component comps[$];
        top.find_all(m_time_settings[i].comp,comps);
        #(m_time_settings[i].offset - last_time);
        last_time = m_time_settings[i].offset;
        if(m_time_settings[i].id == "_ALL_") begin
           foreach(comps[j]) begin
             comps[j].set_report_verbosity_level(m_time_settings[i].verbosity);
           end
        end
        else begin
          foreach(comps[j]) begin
            comps[j].set_report_id_verbosity(m_time_settings[i].id, m_time_settings[i].verbosity);
          end
        end
      end
    end join_none // fork begin
  end

  first = 0;
endfunction `endif
// End

// do_accept_tr
// ------------

function void uvm_component::do_accept_tr (uvm_transaction tr);
  return;
endfunction


// do_begin_tr
// -----------

function void uvm_component::do_begin_tr (uvm_transaction tr,
                                          string stream_name,
                                          integer tr_handle);
  return;
endfunction


// do_end_tr
// ---------

function void uvm_component::do_end_tr (uvm_transaction tr,
                                        integer tr_handle);
  return;
endfunction


//------------------------------------------------------------------------------
//
// Configuration interface
//
//------------------------------------------------------------------------------


function string uvm_component::massage_scope(string scope);

  // uvm_top
  if(scope == "")
    return "^$";

  if(scope == "*")
    return {get_full_name(), ".*"};

  // absolute path to the top-level test
  if(scope == "uvm_test_top")
    return "uvm_test_top";

  // absolute path to uvm_root
  if(scope[0] == ".")
    return {get_full_name(), scope};

  return {get_full_name(), ".", scope};

endfunction

//
// set_config_int
//
typedef uvm_config_db#(uvm_bitstream_t) uvm_config_int;
typedef uvm_config_db#(string) uvm_config_string;
typedef uvm_config_db#(uvm_object) uvm_config_object;

// Undocumented struct for storing clone bit along w/
// object on set_config_object(...) calls
class uvm_config_object_wrapper;
   uvm_object obj;
   bit clone;
endclass : uvm_config_object_wrapper

function void uvm_component::set_config_int(string inst_name,
                                           string field_name,
                                           uvm_bitstream_t value);

  uvm_config_int::set(this, inst_name, field_name, value);
endfunction

//
// set_config_string
//
function void uvm_component::set_config_string(string inst_name,
                                               string field_name,
                                               string value);

  uvm_config_string::set(this, inst_name, field_name, value);
endfunction

//
// set_config_object
//
function void uvm_component::set_config_object(string inst_name,
                                               string field_name,
                                               uvm_object value,
                                               bit clone = 1);
  uvm_object tmp;
  uvm_config_object_wrapper wrapper;

  if(value == null)
    `uvm_warning("NULLCFG", {"A null object was provided as a ",
       $sformatf("configuration object for set_config_object(\"%s\",\"%s\")",
       inst_name, field_name), ". Verify that this is intended."})

  if(clone && (value != null)) begin
    tmp = value.clone();
    if(tmp == null) begin
      uvm_component comp;
      if ($cast(comp,value)) begin
        `uvm_error("INVCLNC", {"Clone failed during set_config_object ",
          "with an object that is an uvm_component. Components cannot be cloned."})
        return;
      end
      else begin
        `uvm_warning("INVCLN", {"Clone failed during set_config_object, ",
          "the original reference will be used for configuration. Check that ",
          "the create method for the object type is defined properly."})
      end
    end
    else
      value = tmp;
  end


  uvm_config_object::set(this, inst_name, field_name, value);

  wrapper = new;
  wrapper.obj = value;
  wrapper.clone = clone;
  uvm_config_db#(uvm_config_object_wrapper)::set(this, inst_name, field_name, wrapper);
endfunction

//
// get_config_int
//
function bit uvm_component::get_config_int (string field_name,
                                            inout uvm_bitstream_t value);

  return uvm_config_int::get(this, "", field_name, value);
endfunction

//
// get_config_string
//
function bit uvm_component::get_config_string(string field_name,
                                              inout string value);

  return uvm_config_string::get(this, "", field_name, value);
endfunction

//
// get_config_object
//
//
// Note that this does not honor the set_config_object clone bit
function bit uvm_component::get_config_object (string field_name,
                                               inout uvm_object value,
                                               input bit clone=1);

  if(!uvm_config_object::get(this, "", field_name, value)) begin
    return 0;
  end

  if(clone && value != null) begin
    value = value.clone();
  end

  return 1;
endfunction

// check_config_usage
// ------------------

function void uvm_component::check_config_usage ( bit recurse=1 );
  uvm_resource_pool rp = uvm_resource_pool::get();
  uvm_queue#(uvm_resource_base) rq;

  rq = rp.find_unused_resources();

  if(rq.size() == 0)
    return;

  uvm_report_info("CFGNRD"," ::: The following resources have at least one write and no reads :::",UVM_INFO);
  rp.print_resources(rq, 1);
endfunction

// apply_config_settings
// ---------------------

function void uvm_component::apply_config_settings (bit verbose=0);

  uvm_resource_pool rp = uvm_resource_pool::get();
  uvm_queue#(uvm_resource_base) rq;
  uvm_resource_base r;
  string name;
  string search_name;
  int unsigned i;
  int unsigned j;

  // populate an internal 'field_array' with list of
  // fields declared with `uvm_field macros (checking
  // that there aren't any duplicates along the way)
  __m_uvm_field_automation (null, UVM_CHECK_FIELDS, "");

  // if no declared fields, nothing to do. 
  if (__m_uvm_status_container.field_array.size() == 0)
    return;

  if(verbose)
    uvm_report_info("CFGAPL","applying configuration settings", UVM_NONE);

  // Note: the following is VERY expensive. Needs refactoring. Should
  // get config only for the specific field names in 'field_array'.
  // That's because the resource pool is organized first by field name.
  // Can further optimize by encoding the value for each 'field_array' 
  // entry to indicate string, uvm_bitstream_t, or object. That way,
  // we call 'get' for specific fields of specific types rather than
  // the search-and-cast approach here.
  rq = rp.lookup_scope(get_full_name());
  rp.sort_by_precedence(rq);

  // rq is in precedence order now, so we have to go through in reverse
  // order to do the settings.
  for(int i=rq.size()-1; i>=0; --i) begin

    r = rq.get(i);
    name = r.get_name();
   


    // does name have brackets [] in it?
    for(j = 0; j < name.len(); j++)
      if(name[j] == "[" || name[j] == ".")
        break;

    // If it does have brackets then we'll use the name
    // up to the brackets to search __m_uvm_status_container.field_array
    if(j < name.len())
      search_name = name.substr(0, j-1);
    else
      search_name = name;

    if(!uvm_resource_pool::m_has_wildcard_names && 
       !__m_uvm_status_container.field_array.exists(search_name) && 
       search_name != "recording_detail")
      continue;

// Modified by Verdi
`ifndef UVM_VERDI_NO_IMPLICIT_GET
    begin
    string cfgapl_str = "", apl_val = "";
    uvm_resource#(uvm_bitstream_t) rbs;
    uvm_cmdline_processor clp;
    string trace_args[$];

    if(verbose)
      uvm_report_info("CFGAPL",$sformatf("applying configuration to field %s", name),UVM_NONE);
    clp = uvm_cmdline_processor::get_inst();
    $sformat(cfgapl_str,"applying configuration to field %s", name);
    if($cast(rbs, r)) begin
      set_int_local(name, rbs.read(this));
      $sformat(apl_val," type=uvm_bitstream_t value=%0b",rbs.read(this));
    end
    else begin
      uvm_resource#(int) ri;
      if($cast(ri, r)) begin
        set_int_local(name, ri.read(this));
        $sformat(apl_val," type=int value=%0d",ri.read(this));
      end
      else begin
        uvm_resource#(int unsigned) riu;
        if($cast(riu, r)) begin
          set_int_local(name, riu.read(this));
          $sformat(apl_val," type=int unsigned value=%0d",riu.read(this)); 
        end
        else begin
          uvm_resource#(string) rs;
          if($cast(rs, r)) begin
            set_string_local(name, rs.read(this));
            $sformat(apl_val," type=string value=%s",rs.read(this)); 
          end
          else begin
             uvm_resource#(uvm_active_passive_enum) re;
             if($cast(re, r)) begin
               set_int_local(name, re.read(this));
               $sformat(apl_val," type=uvm_active_passive_enum value=%0d",re.read(this));
             end
             else begin
                uvm_resource#(uvm_config_object_wrapper) rcow;
                if ($cast(rcow, r)) begin
                   uvm_config_object_wrapper wrapper_obj = rcow.read();
                   set_object_local(name, wrapper_obj.obj, wrapper_obj.clone);
                   $sformat(apl_val," type=uvm_config_object_wrapper value=%s","?");
                end else begin
                   uvm_resource#(uvm_object) ro;
                   if($cast(ro, r)) begin
                     set_object_local(name, ro.read(this), 0);
                     $sformat(apl_val," type=uvm_object value=%s","?");
                   end
                   else if (verbose) begin
                      uvm_report_info("CFGAPL", $sformatf("field %s has an unsupported type", name), UVM_NONE);
                   end
                end   
             end
          end
        end
      end
    end
    if (is_verdi_trace_aware_used()||clp.get_arg_matches("+UVM_CONFIG_DB_TRACE", trace_args)) begin
        if (!is_verdi_trace_no_implicit_get_used()&&(name!="recording_detail")&&(apl_val!="")) begin
            $sformat(cfgapl_str,"%s%s",cfgapl_str,apl_val);
            uvm_report_info("CFGAPL",cfgapl_str,UVM_NONE);
        end
    end
    end
 
  end
`else
    if(verbose)
      uvm_report_info("CFGAPL",$sformatf("applying configuration to field %s", name),UVM_NONE);

    begin
    uvm_resource#(uvm_bitstream_t) rbs;
    if($cast(rbs, r))
      set_int_local(name, rbs.read(this));
    else begin
      uvm_resource#(int) ri;
      if($cast(ri, r))
        set_int_local(name, ri.read(this));
      else begin
        uvm_resource#(int unsigned) riu;
        if($cast(riu, r))
          set_int_local(name, riu.read(this));
        else begin
          uvm_resource#(string) rs;
          if($cast(rs, r))
            set_string_local(name, rs.read(this));
          else begin
             uvm_resource#(uvm_active_passive_enum) re;
             if($cast(re, r))
               set_int_local(name, re.read(this));
             else begin
                uvm_resource#(uvm_config_object_wrapper) rcow;
                if ($cast(rcow, r)) begin
                   uvm_config_object_wrapper wrapper_obj = rcow.read();
                   set_object_local(name, wrapper_obj.obj, wrapper_obj.clone);
                end else begin
                   uvm_resource#(uvm_object) ro;
                   if($cast(ro, r))
                     set_object_local(name, ro.read(this), 0);
                   else if (verbose)
                      uvm_report_info("CFGAPL", $sformatf("field %s has an unsupported type", name), UVM_NONE);    
                end    
             end
          end
        end
      end
    end
    end

  end
`endif
// End

  __m_uvm_status_container.field_array.delete();
  
endfunction


// print_config
// ------------

function void uvm_component::print_config(bit recurse = 0, audit = 0);

  uvm_resource_pool rp = uvm_resource_pool::get();

  uvm_report_info("CFGPRT","visible resources:",UVM_INFO);
  rp.print_resources(rp.lookup_scope(get_full_name()), audit);

  if(recurse) begin
    uvm_component c;
    foreach(m_children[name]) begin
      c = m_children[name];
      c.print_config(recurse, audit);
    end
  end

endfunction


// print_config_settings
// ---------------------

function void uvm_component::print_config_settings (string field="",
                                                    uvm_component comp=null,
                                                    bit recurse=0);
  static bit have_been_warned;
  if(!have_been_warned) begin
    uvm_report_warning("deprecated", "uvm_component::print_config_settings has been deprecated.  Use print_config() instead");
    have_been_warned = 1;
  end

  print_config(recurse, 1);
endfunction


// print_config_with_audit
// -----------------------

function void uvm_component::print_config_with_audit(bit recurse = 0);
  print_config(recurse, 1);
endfunction


// do_print (override)
// --------

function void uvm_component::do_print(uvm_printer printer);
  string v;
  super.do_print(printer);

  // It is printed only if its value is other than the default (UVM_NONE)
  if(uvm_verbosity'(recording_detail) != UVM_NONE)
    case (recording_detail)
      UVM_LOW : printer.print_generic("recording_detail", "uvm_verbosity", 
        $bits(recording_detail), "UVM_LOW");
      UVM_MEDIUM : printer.print_generic("recording_detail", "uvm_verbosity", 
        $bits(recording_detail), "UVM_MEDIUM");
      UVM_HIGH : printer.print_generic("recording_detail", "uvm_verbosity", 
        $bits(recording_detail), "UVM_HIGH");
      UVM_FULL : printer.print_generic("recording_detail", "uvm_verbosity", 
        $bits(recording_detail), "UVM_FULL");
      default : printer.print_int("recording_detail", recording_detail, 
        $bits(recording_detail), UVM_DEC, , "integral");
    endcase

`ifndef UVM_NO_DEPRECATED
  if (enable_stop_interrupt != 0) begin
    printer.print_int("enable_stop_interrupt", enable_stop_interrupt,
                        $bits(enable_stop_interrupt), UVM_BIN, ".", "bit");
  end
 `endif
endfunction


// set_int_local (override)
// -------------

function void uvm_component::set_int_local (string field_name,
                             uvm_bitstream_t value,
                             bit recurse=1);

  //call the super function to get child recursion and any registered fields
  super.set_int_local(field_name, value, recurse);

  //set the local properties
  if(uvm_is_match(field_name, "recording_detail"))
    recording_detail = value;

endfunction


// Internal methods for setting messagin parameters from command line switches

typedef class uvm_cmdline_processor;


// m_set_cl_msg_args
// -----------------

function void uvm_component::m_set_cl_msg_args;
  m_set_cl_verb();
  m_set_cl_action();
  m_set_cl_sev();
endfunction


// m_set_cl_verb
// -------------
function void uvm_component::m_set_cl_verb;
  // _ALL_ can be used for ids
  // +uvm_set_verbosity=<comp>,<id>,<verbosity>,<phase|time>,<offset>
  // +uvm_set_verbosity=uvm_test_top.env0.agent1.*,_ALL_,UVM_FULL,time,800
 
  static string values[$];
  static bit first = 1;
  string args[$];
  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
  uvm_root top = uvm_root::get();

  if(!values.size())
    void'(uvm_cmdline_proc.get_arg_values("+uvm_set_verbosity=",values));

  foreach(values[i]) begin
    m_verbosity_setting setting;
    args.delete();
    uvm_split_string(values[i], ",", args);

    // Warning is already issued in uvm_root, so just don't keep it
    if(first && ( ((args.size() != 4) && (args.size() != 5)) || 
                  (clp.m_convert_verb(args[2], setting.verbosity) == 0))  )
    begin
      values.delete(i);
    end
    else begin
      setting.comp = args[0];
      setting.id = args[1];
      void'(clp.m_convert_verb(args[2],setting.verbosity));
      setting.phase = args[3];
      setting.offset = 0;
      if(args.size() == 5) setting.offset = args[4].atoi();
      if((setting.phase == "time") && (this == top)) begin
        m_time_settings.push_back(setting);
      end
  
      if (uvm_is_match(setting.comp, get_full_name()) ) begin
        if((setting.phase == "" || setting.phase == "build" || setting.phase == "time") && 
           (setting.offset == 0) ) 
        begin
          if(setting.id == "_ALL_") 
            set_report_verbosity_level(setting.verbosity);
          else
            set_report_id_verbosity(setting.id, setting.verbosity);
        end
        else begin
          if(setting.phase != "time") begin
            m_verbosity_settings.push_back(setting);
          end
        end
      end
    end
  end
  // do time based settings
  if(this == top) begin
    fork begin
      time last_time = 0;
      if (m_time_settings.size() > 0)
        m_time_settings.sort() with ( item.offset );
      foreach(m_time_settings[i]) begin
        uvm_component comps[$];
        top.find_all(m_time_settings[i].comp,comps);
        #(m_time_settings[i].offset - last_time);
        last_time = m_time_settings[i].offset;
        if(m_time_settings[i].id == "_ALL_") begin
           foreach(comps[j]) begin
             comps[j].set_report_verbosity_level(m_time_settings[i].verbosity);
           end
        end
        else begin
          foreach(comps[j]) begin
            comps[j].set_report_id_verbosity(m_time_settings[i].id, m_time_settings[i].verbosity);
          end
        end
      end
    end join_none // fork begin
  end

  first = 0;
endfunction


// m_set_cl_action
// ---------------

function void uvm_component::m_set_cl_action;
  // _ALL_ can be used for ids or severities
  // +uvm_set_action=<comp>,<id>,<severity>,<action[|action]>
  // +uvm_set_action=uvm_test_top.env0.*,_ALL_,UVM_ERROR,UVM_NO_ACTION

  static string values[$];
  string args[$];
  uvm_severity sev;
  uvm_action action;

  if(!values.size())
    void'(uvm_cmdline_proc.get_arg_values("+uvm_set_action=",values));

  foreach(values[i]) begin
    uvm_split_string(values[i], ",", args);
    if(args.size() != 4) begin
      `uvm_warning("INVLCMDARGS", $sformatf("+uvm_set_action requires 4 arguments, only %0d given for command +uvm_set_action=%s, Usage: +uvm_set_action=<comp>,<id>,<severity>,<action[|action]>", args.size(), values[i]))
      values.delete(i);
      break;
    end
    if (!uvm_is_match(args[0], get_full_name()) ) break; 
    if((args[2] != "_ALL_") && !uvm_string_to_severity(args[2], sev)) begin
      `uvm_warning("INVLCMDARGS", $sformatf("Bad severity argument \"%s\" given to command +uvm_set_action=%s, Usage: +uvm_set_action=<comp>,<id>,<severity>,<action[|action]>", args[2], values[i]))
      values.delete(i);
      break;
    end
    if(!uvm_string_to_action(args[3], action)) begin
      `uvm_warning("INVLCMDARGS", $sformatf("Bad action argument \"%s\" given to command +uvm_set_action=%s, Usage: +uvm_set_action=<comp>,<id>,<severity>,<action[|action]>", args[3], values[i]))
      values.delete(i);
      break;
    end
    if(args[1] == "_ALL_") begin
      if(args[2] == "_ALL_") begin
        set_report_severity_action(UVM_INFO, action);
        set_report_severity_action(UVM_WARNING, action);
        set_report_severity_action(UVM_ERROR, action);
        set_report_severity_action(UVM_FATAL, action);
      end
      else begin
        set_report_severity_action(sev, action);
      end
    end
    else begin
      if(args[2] == "_ALL_") begin
        set_report_id_action(args[1], action);
      end
      else begin
        set_report_severity_id_action(sev, args[1], action);
      end
    end
  end

endfunction


// m_set_cl_sev
// ------------

function void uvm_component::m_set_cl_sev;
  // _ALL_ can be used for ids or severities
  //  +uvm_set_severity=<comp>,<id>,<orig_severity>,<new_severity>
  //  +uvm_set_severity=uvm_test_top.env0.*,BAD_CRC,UVM_ERROR,UVM_WARNING

  static string values[$];
  static bit first = 1;
  string args[$];
  uvm_severity orig_sev, sev;

  if(!values.size())
    void'(uvm_cmdline_proc.get_arg_values("+uvm_set_severity=",values));

  foreach(values[i]) begin
    uvm_split_string(values[i], ",", args);
    if(args.size() != 4) begin
      `uvm_warning("INVLCMDARGS", $sformatf("+uvm_set_severity requires 4 arguments, only %0d given for command +uvm_set_severity=%s, Usage: +uvm_set_severity=<comp>,<id>,<orig_severity>,<new_severity>", args.size(), values[i]))
      values.delete(i);
      break;
    end
    if (!uvm_is_match(args[0], get_full_name()) ) break; 
    if(args[2] != "_ALL_" && !uvm_string_to_severity(args[2], orig_sev)) begin
      `uvm_warning("INVLCMDARGS", $sformatf("Bad severity argument \"%s\" given to command +uvm_set_severity=%s, Usage: +uvm_set_severity=<comp>,<id>,<orig_severity>,<new_severity>", args[2], values[i]))
      values.delete(i);
      break;
    end
    if(!uvm_string_to_severity(args[3], sev)) begin
      `uvm_warning("INVLCMDARGS", $sformatf("Bad severity argument \"%s\" given to command +uvm_set_severity=%s, Usage: +uvm_set_severity=<comp>,<id>,<orig_severity>,<new_severity>", args[3], values[i]))
      values.delete(i);
      break;
    end
    if(args[1] == "_ALL_" && args[2] == "_ALL_") begin
      set_report_severity_override(UVM_INFO,sev);
      set_report_severity_override(UVM_WARNING,sev);
      set_report_severity_override(UVM_ERROR,sev);
      set_report_severity_override(UVM_FATAL,sev);
    end
    else if(args[1] == "_ALL_") begin
      set_report_severity_override(orig_sev,sev);
    end
    else if(args[2] == "_ALL_") begin
      set_report_severity_id_override(UVM_INFO,args[1],sev);
      set_report_severity_id_override(UVM_WARNING,args[1],sev);
      set_report_severity_id_override(UVM_ERROR,args[1],sev);
      set_report_severity_id_override(UVM_FATAL,args[1],sev);
    end
    else begin
      set_report_severity_id_override(orig_sev,args[1],sev);
    end
  end
endfunction


// m_apply_verbosity_settings
// --------------------------

function void uvm_component::m_apply_verbosity_settings(uvm_phase phase);
  foreach(m_verbosity_settings[i]) begin
    if(phase.get_name() == m_verbosity_settings[i].phase) begin
      if( m_verbosity_settings[i].offset == 0 ) begin
          if(m_verbosity_settings[i].id == "_ALL_") 
            set_report_verbosity_level(m_verbosity_settings[i].verbosity);
          else 
            set_report_id_verbosity(m_verbosity_settings[i].id, m_verbosity_settings[i].verbosity);
      end
      else begin
        process p = process::self();
        string p_rand = p.get_randstate();
        fork begin
          m_verbosity_setting setting = m_verbosity_settings[i];
          #setting.offset;
          if(setting.id == "_ALL_") 
            set_report_verbosity_level(setting.verbosity);
          else 
            set_report_id_verbosity(setting.id, setting.verbosity);
        end join_none;
        p.set_randstate(p_rand);
      end
      // Remove after use
      m_verbosity_settings.delete(i);
    end
  end
endfunction


// m_do_pre_abort
// --------------

function void uvm_component::m_do_pre_abort;
  foreach(m_children[i])
    m_children[i].m_do_pre_abort(); 
  pre_abort(); 
endfunction
