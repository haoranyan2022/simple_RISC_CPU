//状态控制器接收复位信号rst，rst有效，控制输出ena为0，fetch有效控制ena为1。
module machine_ctrl (
    input           clk     ,
    input           rst     ,
    input           fetch   ,//fetch有效，读取rom中的指令pc——addr
    output  reg     ena
);
    
    always @(posedge clk) begin
        if (rst) begin
            ena <= 1'b0 ; 
        end else if (fetch) begin
            ena <= 1'b1 ;//contr_ena,用于使能machine模块
        end
    end

endmodule