//数据控制器，控制累加器accum的数据输出
module data_ctrl (
    input   [7:0]   data_in     ,//输入为alu_out，由算数运算器产生
    input           data_ena    ,
    output  [7:0]   data_out    
);
    assign  data_out = (data_ena)?data_in:8'bzzzz_zzzz  ;
endmodule