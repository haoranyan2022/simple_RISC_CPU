module clk_gen (
    input       clk                  ,
    input       reset                ,
    output reg  fetch                ,
    output reg  alu_ena              //输出算数计算器使能信号
);
    reg [7:0] state                  ;

    parameter S1 = 8'b00000001      ,
              S2 = 8'b00000010      ,
              S3 = 8'b00000100      ,
              S4 = 8'b00001000      ,
              S5 = 8'b00010000      ,
              S6 = 8'b00100000      ,
              S7 = 8'b01000000      ,
              S8 = 8'b10000000      ,
              IDLE = 8'b00000000    ;

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE           ;
            fetch <= 1'b0           ;
            alu_ena <= 1'b0         ;
        end else begin
            case (state)
                IDLE:
                    begin
                        state <= S1     ;
                    end
                S1:
                    begin
                        alu_ena <= 1'b1 ;
                        state   <= S2   ;
                    end 
                S2:
                    begin
                        alu_ena <= 1'b0 ;
                        state   <= S3   ;
                    end
                S3:
                    begin
                        fetch   <= 1'b1 ;
                        state   <= S4   ;
                    end
                S4:
                    begin
                        state   <= S5   ;
                    end
                S5:
                    begin
                        state   <= S6   ;
                    end
                S6:
                    begin
                        state   <= S7   ;
                    end
                S7:
                    begin
                        fetch   <= 1'b0 ;
                        state   <= S8   ;
                    end
                S8:
                    begin
                        state   <= S1   ;
                    end    
                default: state  <= IDLE ;
            endcase
        end
    end

endmodule