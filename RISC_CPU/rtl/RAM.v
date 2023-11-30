module ram (
    input                       ena         ,
    input                       read        ,
    input                       write       ,
    inout   wire    [7:0]       data        ,
    input           [9:0]       addr        
);
    reg [7:0] ram[10'h3ff : 0];

    assign data = (read && ena )? ram[addr]:8'hzz;//读信号+使能信号
		
	always@(posedge write) begin
		ram[addr] <= data;//write信号直接写
	end
endmodule