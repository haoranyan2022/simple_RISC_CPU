// 主状态机是CPU的控制核心，用于产生一系列控制信号。
// 指令周期由8个时钟周期组成，每个时钟周期都要完成固定的操作。
// （1）第0个时钟，CPU状态控制器的输出rd和load_ir 为高电平，其余为低电平。指令寄存器寄存由ROM送来的高8位指令代码。
// （2）第1个时钟，与上一个时钟相比只是inc_pc从0变为1，故PC增1，ROM送来低8位指令代码，指令寄存器寄存该8位指令代码。
// （3）第2个时钟，空操作。
// （4）第3个时钟，PC增1，指向下一条指令。
// 操作符为HLT，输出信号HLT为高。
// 操作符不为HLT，除PC增1外，其余控制线输出为0.
// （5）第4个时钟，操作。
// 操作符为AND，ADD，XOR或LDA，读取相应地址的数据；
// 操作符为JMP，将目的地址送给程序计数器；
// 操作符为STO，输出累加器数据。
// （6）第5个时钟，若操作符为ANDD，ADD或者XORR，算术运算器完成相应的计算；
// 操作符为LDA，就把数据通过算术运算器送给累加器；
// 操作符为SKZ，先判断累加器的值是否为0，若为0，PC加1，否则保持原值；
// 操作符为JMP，锁存目的地址；
// 操作符为STO，将数据写入地址处。
// (7)第6个时钟，空操作。
// (8)第7个时钟，若操作符为SKZ且累加器为0，则PC值再加1，跳过一条指令，否则PC无变化。


module machine (
    input               clk         ,
    input               ena         ,//contr_ena由machine_ctrl使能
    input               zero        ,
    input   [2:0]       opcode      ,
    output  reg         inc_pc      ,//counter的时钟信号，loadpc为0时，pcaddr+1
    output  reg         load_acc    ,//输出给accum，存储数据
    output  reg         load_pc     ,//输出给counter，地址计数,
    output  reg         rd          ,
    output  reg         wr          ,
    output  reg         load_ir     ,//register ena信号
    output  reg         data_ctrl_ena   ,
    output  reg         halt         //暂停         
);

    reg [2:0] state         ;

    parameter 
            HLT = 3'b000  ,//暂停指令，将操作数accum传输到输出。空一个指令周期，8个时钟周期
            SKZ = 3'b001  ,//跳过指令，也是将操作数传输到输出
            ADD = 3'b010  ,//
            ANDD = 3'b011 ,//
            XORR = 3'b100 ,//
            LDA = 3'b101  ,//传输指令，将data传输到输出，读数据
            STO = 3'b110  ,//存储指令，将accum传输到输出，写数据
            JMP = 3'b111  ;//跳转指令，将accum传输到输出

    always @(posedge clk ) begin
        if (!ena) begin
            state <= 3'b000     ;
            {inc_pc,load_acc,load_pc,rd} <= 4'b0000     ;
            {wr,load_ir,data_ctrl_ena,halt} <= 4'b0000  ;
        end else begin
            clt_cycle   ;
        end
    end
    
    task clt_cycle;
        begin
            casex (state)
                //rd,load_ir为高电平，register工作，从rom读取数据
                3'b000: //load high 8bits in struction
                        begin
                            {inc_pc,load_acc,load_pc,rd} <= 4'b0001     ;
                            {wr,load_ir,data_ctrl_ena,halt} <= 4'b0100  ;
                            state <= 3'b001     ;
                        end
                //继续上一轮，inc_pc为高电平,counter触发，pc_addr + 1
                3'b001: //pc increased by one then load low 8bits instruction
                        begin
                            {inc_pc,load_acc,load_pc,rd} <= 4'b1001     ;
                            {wr,load_ir,data_ctrl_ena,halt} <= 4'b0100  ;
                            state <= 3'b010     ;
                        end
                //空操作，归0
                3'b010: //idle
                        begin
                            {inc_pc,load_acc,load_pc,rd} <= 4'b0000     ;
                            {wr,load_ir,data_ctrl_ena,halt} <= 4'b0000  ;
                            state <= 3'b011     ;
                        end
                //HLT状态：inc_pc为高电平,counter触发，pc_addr + 1，输出halt暂停信号；
                //非HLT：inc_pc为高电平,counter触发，pc_addr + 1；
                3'b011: 
                        begin
                            if (opcode == HLT) begin
                                {inc_pc,load_acc,load_pc,rd} <= 4'b1000     ;
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b0001  ;
                            end else begin
                                {inc_pc,load_acc,load_pc,rd} <= 4'b1000     ;
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b0000  ;
                            end
                            state <= 3'b100     ;
                        end
                // 操作符为AND，ADD，XOR或LDA，读取相应地址的数据；
                // 操作符为JMP，将目的地址送给程序计数器；
                // 操作符为STO，输出累加器数据。
                3'b100: //取出操作数
                        begin
                            if (opcode == JMP) begin
                                {inc_pc,load_acc,load_pc,rd} <= 4'b0010     ;//load_pc为1但inc——pc不为1，时钟不上升没有用
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b0000  ;
                            end else if (opcode == ADD || opcode == ANDD ||opcode ==XORR ||opcode == LDA) begin
                                {inc_pc,load_acc,load_pc,rd} <= 4'b0001     ;//读取当前地址数据
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b0000  ;
                            end else if (opcode == STO) begin
                                {inc_pc,load_acc,load_pc,rd} <= 4'b0000     ;//使能data——ctrl模块，data=alu——out
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b0010  ;
                            end else begin
                                {inc_pc,load_acc,load_pc,rd} <= 4'b0000     ;
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b0000  ;
                            end    
                            state <= 3'b101    ;      
                        end
                3'b101: //operation
                        begin
                            if (opcode == ADD || opcode == ANDD ||opcode ==XORR ||opcode == LDA) begin
                                {inc_pc,load_acc,load_pc,rd} <= 4'b0101     ;
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b0000  ;
                            end else if (opcode == SKZ && zero == 1) begin
                                {inc_pc,load_acc,load_pc,rd} <= 4'b1000     ;//pc——addr+1
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b0000  ;
                            end else if (opcode == JMP) begin
                                {inc_pc,load_acc,load_pc,rd} <= 4'b1010     ;//jump，load为1，pc_addr = ir_addr
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b0000  ;
                            end else if (opcode == STO) begin
                                {inc_pc,load_acc,load_pc,rd} <= 4'b0000     ;//wr = 1；使能ram，写数据data,写入ram中
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b1010  ;//使能data——ctrl模块，data=alu——out
                            end else begin                                    
                                {inc_pc,load_acc,load_pc,rd} <= 4'b0000     ;
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b0000  ;
                            end   
                            state <= 3'b110    ;       
                        end
                3'b110: //operation
                        begin
                            if (opcode == STO) begin//如果是STO，那么需要使数据控制模块enable，data=alu——out
                                {inc_pc,load_acc,load_pc,rd} <= 4'b0000     ;
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b0010  ;
                            end else if (opcode == ADD || opcode == ANDD ||opcode ==XORR ||opcode == LDA) begin
                                {inc_pc,load_acc,load_pc,rd} <= 4'b0001     ;
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b0000  ;
                            end else begin
                                {inc_pc,load_acc,load_pc,rd} <= 4'b0000     ;
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b0000  ;
                            end
                            state <= 3'b111    ;       
                        end
                3'b111: //operation
                        begin
                            if (opcode == SKZ && zero == 1) begin
                                {inc_pc,load_acc,load_pc,rd} <= 4'b1000     ;
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b0000  ;
                            end else begin
                                {inc_pc,load_acc,load_pc,rd} <= 4'b0000     ;
                                {wr,load_ir,data_ctrl_ena,halt} <= 4'b0000  ;
                            end 
                            state <= 3'b000    ;      
                        end
                default:
                        begin
                            {inc_pc,load_acc,load_pc,rd} <= 4'b0000     ;
                            {wr,load_ir,data_ctrl_ena,halt} <= 4'b0000  ;
                            state <= 3'b000     ;
                        end 
            endcase
        end
    endtask
endmodule