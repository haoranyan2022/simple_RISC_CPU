//用于选择输出地址是PC（程序计数）地址还是数据/端口地址。
//每个指令周期的前4个时钟周期用于从ROM种读取指令，输出的是PC地址；
//后四个时钟周期用于对RAM或端口读写。

module adr (
    input           fetch   ,//后四个周期为高电平
    input [12:0]    ir_addr ,//ram或者端口地址
    input [12:0]    pc_addr ,//指令地址rom地址
    output  [12:0]  addr    
);
    assign addr = fetch?pc_addr:ir_addr ;
endmodule