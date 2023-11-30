module counter (
    input [12:0]        ir_addr     ,//目标地址
    input               load        ,//load_pc
    input               clk         ,//inc_pc
    input               rst         ,
    output  reg [12:0]  pc_addr     //程序计数器地址
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_addr <= 13'b0_0000_0000_0000     ;
        end else begin
            if (load) begin
                pc_addr <= ir_addr              ;
            end else begin
                pc_addr <= pc_addr + 1'b1       ;
            end
        end
    end

endmodule