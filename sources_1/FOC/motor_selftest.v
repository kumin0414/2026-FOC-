`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/09 21:29:31
// Design Name: 
// Module Name: motor_selftest
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:  自测模块
// 
//////////////////////////////////////////////////////////////////////////////////

`include "foc_header.vh"
module motor_selftest(
    input                   sys_clk_i           ,
    input                   sys_rst_n_i         ,

    input                   sleftest_en_i       ,

    output[7:0]             foc_mode_o          ,
    output reg[24:0]        selftest_angle_o    ,
    output signed[24:0]     selftest_Uq_o       ,     //自测模式下Uq参数
    output signed[24:0]     selftest_Ud_o             //自测模式下Ud参数
);


localparam  FOC_SELFTEST_STEP = 'd20000;

reg[20:0] cnt;

assign foc_mode_o = `FOC_MODE_SELFTEST;
assign selftest_Uq_o = `SELFTEST_UQ;
assign selftest_Ud_o =-`SELFTEST_UQ;


always@( posedge sys_clk_i ) begin
    if( sleftest_en_i == 1'b1)
        if( cnt == 'd20000 )
            cnt <= 'd0;
        else
            cnt <= cnt + 1'b1;
    else
        cnt <= 'd0;
end



always@(posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        selftest_angle_o <= 32'd0;
    else if( cnt == 'd20000)
        selftest_angle_o <= selftest_angle_o + FOC_SELFTEST_STEP;
    else if( selftest_angle_o <= $signed(0))
        selftest_angle_o <= 25'd23592960;
    else if( selftest_angle_o >= 25'd23592960)
        selftest_angle_o <= 25'd536; 
    else
        selftest_angle_o <= selftest_angle_o;
end

endmodule
