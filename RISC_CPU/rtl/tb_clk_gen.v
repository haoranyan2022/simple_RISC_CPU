`timescale 1ns / 1ps
module tb_clk_gen(
    );
    reg clk                 ;
    reg reset               ;
    wire fetch              ;
    wire alu_ena            ;

    clk_gen tb_clk_gen(
        .clk(clk)           ,
        .reset(reset)       ,
        .fetch(fetch)       ,
        .alu_ena(alu_ena)   
    );

    initial
        begin
            clk = 1'b0              ;
            forever begin
                # 25 clk = ~clk     ;
            end
        end
        
    initial
        begin
            reset = 1'b1            ;
            # 120 reset = 1'b0      ;
        end       
endmodule