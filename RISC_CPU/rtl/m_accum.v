//用来存放当前的结果，累加器
//双目运算时，与data进行运算
module accum (
    input   clk     ,
    input   ena     ,//load_acc
    input   rst     ,
    input        [7:0]   data    ,//输入为alu_out，由算数运算器产生
    output  reg  [7:0]   accum
);
    
    always @(posedge clk ) begin
        if (rst) begin
            accum <= 8'h00      ;
        end else if (ena) begin
            accum <= data   ;//cpu发出信号，这边获取总线数据
        end 
    end 
endmodule