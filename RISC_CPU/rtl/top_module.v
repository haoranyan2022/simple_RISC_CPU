module RISC_CPU (
		input 				clk 	,
		input 				reset 	,
		output 	wire 		rd 		,
		output 	wire 		wr 		,
		output 	wire 		halt 	,
		output 	wire 	 	fetch 	,
		//addr
		output 	wire [12:0]	addr 	,
		output 	wire [12:0]	ir_addr ,
		output 	wire [12:0]	pc_addr ,
		inout 	wire [7:0]	data 	,
		//op
		output 	wire [2:0]	opcode 	
);

		wire [7:0] alu_out 	; 
		wire [7:0] accum	;

		wire 	 	zero 		;
		wire 		inc_pc		;
		wire		load_acc	;
		wire 		load_pc		;
		wire		load_ir		;
		wire		data_ena	;
		wire 		contr_ena	;
		wire 		alu_ena		;

    clk_gen inst_clk_gen(
        .clk(clk)           ,
        .reset(reset)       ,
        .fetch(fetch)       ,
        .alu_ena(alu_ena)   
    );

    register inst_register(
        .clk(clk)           ,
        .rst(reset)         ,
        .data(data)         ,
        .ena(load_ir)       ,
        .opc_iraddr({opcode , ir_addr})
    );

    accum m_accum(
		.data  	(alu_out		),
		.ena 	(load_acc 		),
		.clk 	(clk 			),
		.rst 	(reset   		),
		.accum 	(accum 			)
		);

	alu m_alu(
		.data 		(data 		),
		.accum 		(accum 		),
		.clk 		(clk 		),
		.alu_ena 	(alu_ena 	),
		.opcode 	(opcode 	),
		.alu_out 	(alu_out 	),
		.zero 		(zero 		)
		);

	machine_ctrl m_machinectl(
		.clk 		(clk 		),
		.rst 		(reset 		),
		.fetch 		(fetch 		),
		.ena 		(contr_ena 	)
		);

	machine m_machine(
		.inc_pc 	(inc_pc 		),
		.load_acc 	(load_acc 		),
		.load_pc 	(load_pc 		),
		.rd 		(rd 			),
		.wr 		(wr 			),
		.load_ir 	(load_ir 		),
		.clk 		(clk 			),
		.data_ctrl_ena  (data_ena 		),
		.halt 		(halt 			),
		.zero 		(zero 			),
		.ena 		(contr_ena 		),
		.opcode	 	(opcode 		)
		);

	data_ctrl m_datactl(
		.data_in 		(alu_out 		),
		.data_ena 	    (data_ena 		),
		.data_out 		(data 			)
		);

	adr m_adr(
		.fetch  	(fetch 		),
		.ir_addr 	(ir_addr 	),
		.pc_addr 	(pc_addr 	),
		.addr 		(addr 		)
		);

	counter m_counter(
		.clk 		(inc_pc 	),
		.rst 		(reset 		),
		.ir_addr 	(ir_addr 	),
		.load 		(load_pc 	),
		.pc_addr 	(pc_addr 	)
		);	
endmodule