module rom (
    input       [12:0]          addr        ,
    input                       read        ,
    input                       ena         ,
    output  wire    [7:0]       data        
);
    reg [7:0] mem[13'h1ff : 0]          ;

    assign  data = (read && ena)?mem[addr]:8'bzzzz_zzzz     ;
endmodule