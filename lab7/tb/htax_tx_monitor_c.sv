///////////////////////////////////////////////////////////////////////////
// Texas A&M University
// CSCE 616 Hardware Design Verification
// Created by  : Prof. Quinn and Saumil Gogri
///////////////////////////////////////////////////////////////////////////

class htax_tx_monitor_c extends uvm_monitor;
	
	parameter PORTS = `PORTS;	

	//Factory Registration
	`uvm_component_utils(htax_tx_monitor_c)

	//uvm_analysis_port #(htax_tx_mon_packet_c)	tx_collect_port;
	
	virtual interface htax_tx_interface htax_tx_intf;
	htax_tx_mon_packet_c tx_mon_packet;
	int pkt_len;
		
	//constructor
	function new (string name, uvm_component parent);
		super.new(name,parent);
		//tx_collect_port = new("tx_collect_port",this);
		tx_mon_packet 	= new();
	endfunction : new

  //UVM build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
		if(!uvm_config_db#(virtual htax_tx_interface)::get(this,"","tx_vif",htax_tx_intf))
			`uvm_fatal("NO_TX_VIF",{"Virtual Interface needs to be set for ", get_full_name(),".tx_vif"})
	endfunction : build_phase

	//TO DO : Complete the run_phase tasks with Hints below
	task run_phase(uvm_phase phase);
		forever begin
			pkt_len=0;
			
			@(posedge |htax_tx_intf.tx_vc_gnt) begin
				//TO DO : Assign tx_mon_packet.dest_port from htax_tx_intf.tx_outport_req
				//Encoding the tx_outport_req and then assigning it to tx_mon_packet.dest_port
				tx_mon_packet.dest_port <= htax_tx_intf.tx_outport_req;
				case(htax_tx_intf.tx_outport_req) 
					'b0001: tx_mon_packet.dest_port <= 'b00;	
					'b0010: tx_mon_packet.dest_port <= 'b01;	
					'b0100: tx_mon_packet.dest_port <= 'b10;	
					'b1000: tx_mon_packet.dest_port <= 'b11;
					default: tx_mon_packet.dest_port = 'b00;
				endcase
			end		
					
			@(posedge htax_tx_intf.clk);
			//TO DO : On consequtive cycles append htax_tx_intf.tx_data to tx_mon_packet.data[] till htax_tx_intf.tx_eot pulse
			// sending the values to tx_mon_packet till the time tx_eot is 0
			while(~ htax_tx_intf.tx_eot) begin // TO DO : Replace XXX with appropriate condition

			@(posedge htax_tx_intf.clk);
			tx_mon_packet.data = new[++pkt_len](tx_mon_packet.data); // Dynamically increasing the size of array
			tx_mon_packet.data[pkt_len-1] =  htax_tx_intf.tx_data;
			end
			tx_mon_packet.print();
		end
	endtask : run_phase

endclass : htax_tx_monitor_c
