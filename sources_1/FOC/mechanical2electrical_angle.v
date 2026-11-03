`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/19 21:42:06
// Design Name: 
// Module Name: mechanical2electrical_angle
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//  1. 将电机的机械角度 转换为 电机的极对数
//////////////////////////////////////////////////////////////////////////////////

`include "foc_header.vh"
module mechanical2electrical_angle(
    input                   sys_clk_i                       ,
    input                   sys_rst_n_i                     ,

    input                   encoder_dir_i                   ,
    input [24:0]            encoder_angle_i                 ,
    input [24:0]            encoder_angle_offset_i          ,
    input [7:0]             motor_pole_pair_i               ,

    output reg[24:0]        motor_angle_o                      
);

localparam  S_OFFSET     =  'd1;
localparam  S_ENCODER_DIR=  'd2;
localparam  S_POLE_ANGLE =  'd3;
localparam  S_NORMAL     =  'd4;
localparam  S_ACK        =  'd5;


reg[4:0] state;
reg[32:0] angle_d;  

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        state <= S_OFFSET;
    else if( state == S_OFFSET ) begin
        state <= S_ENCODER_DIR;
        if( encoder_angle_i < encoder_angle_offset_i )
            angle_d <= encoder_angle_offset_i - encoder_angle_i ;
        else 
            angle_d <= encoder_angle_offset_i + ( 25'd23592960 - encoder_angle_i );
    end 
    else if( state == S_ENCODER_DIR ) begin
        state <= S_POLE_ANGLE;
        if( encoder_dir_i == 1'b0 )
            angle_d <=  25'd23592960 - angle_d;
        else
            angle_d <= angle_d;
    end
    else if( state == S_POLE_ANGLE ) begin
        state <= S_NORMAL;
        angle_d <= angle_d * motor_pole_pair_i;
    end
    else if( state == S_NORMAL ) begin
        if(  angle_d > 25'd23592960 ) begin
            state <= S_NORMAL;
            angle_d <= angle_d - 25'd23592960;
        end
        else begin
            state <= S_ACK;
            angle_d <= angle_d;
        end
    end
    else
        state <= S_OFFSET;
end

always@( posedge sys_clk_i ) begin
    if( state == S_ACK )
        motor_angle_o <= angle_d;
    else
        motor_angle_o <= motor_angle_o;
end

endmodule
