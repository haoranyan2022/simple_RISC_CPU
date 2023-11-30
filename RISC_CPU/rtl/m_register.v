module register (
    input clk       ,
    input ena       ,//load_ir
    input rst       ,
    input [7 : 0]   data    ,
    output reg [15:0] opc_iraddr
);
    reg state       ;
    // If load_ir from machine actived, load instruction data from rom in 2 clock periods.
    // Load high 8 bits first, and then low 8 bits.

    always @(posedge clk ) begin
        if (rst) begin
            opc_iraddr <= 16'h0000      ;
            state <= 1'b0               ;
        end else if (ena) begin
            casex (state)
                1'b0:
                    begin
                        opc_iraddr[15 : 8] <= data      ;
                        state <= 1'b1                   ;
                    end 
                1'b1:
                    begin
                        opc_iraddr[7 : 0] <= data       ;
                        state <= 1'b0                   ;
                    end
                default: 
                    begin
                        opc_iraddr[15 : 0] <= 16'bxxxx_xxxx_xxxx_xxxx   ;
                        state <= 1'bx                                   ;
                    end
            endcase
        end else begin
            state <= 1'b0               ; 
        end 
    end
endmodule