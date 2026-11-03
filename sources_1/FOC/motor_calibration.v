`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/18 23:05:49
// Design Name: 
// Module Name: motor_calibration
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
// 
//////////////////////////////////////////////////////////////////////////////////
`include "foc_header.vh"
module motor_calibration(
    input                   sys_clk_i                   ,
    input                   sys_rst_n_i                 ,

    input                   calibration_en_i            ,
    output                  calibration_ack_o           ,

    input                   encoder_one_circle_i        ,       //编码器一圈标志输入
    input [24:0]            encoder_angle_i             ,       //编码器角度输入

    output reg              encoder_dir_o               ,       //编码器安装方向
    output reg[24:0]        encoder_angle_offset_o      ,       //编码器安装零偏
    output reg[7:0]         motor_pole_pair_o           ,       //电机极对数
                
    output[7:0]             foc_mode_o                  ,
    output reg[24:0]        Open_angle_o                ,
    output signed[24:0]     Open_Uq_o                   ,     //开环模式下Uq参数
    output signed[24:0]     Open_Ud_o                         //开环模式下Ud参数
);

localparam  EX_CYCLE        =   'd6000;

localparam  S_IDLE          =   'd0;
localparam  S_TOZERO        =   'd1;
localparam  S_ONECIRCLE     =   'd2;
localparam  S_EANGLE_ZERO   =   'd3;
localparam  S_ACK           =   'd4;






reg[5:0]  state , next_state;
reg[31:0] cnt;
reg[7:0]  dir_cnt;
reg[15:0]  encoder_dir_num_p;
reg[15:0]  encoder_dir_num_n;
reg[24:0] encoder_angle_d0;    

assign calibration_ack_o = ( state == S_ACK ) ? 1'b1 : 1'b0;
assign foc_mode_o = `FOC_MODE_OPEN;

assign Open_Uq_o = 25'd0;
assign Open_Ud_o = `CALIBRATION_UD;


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        state <= S_IDLE;
    else
        state <= next_state;
end

always@(*) begin
    case(state)
    S_IDLE:
        if( calibration_en_i == 1'b1 )
            next_state <= S_TOZERO;
        else
            next_state <= S_IDLE;
    S_TOZERO:
        if( encoder_one_circle_i == 1'b1 )
            next_state <= S_ONECIRCLE;
        else
            next_state <= S_TOZERO;
    S_ONECIRCLE:
        if( encoder_one_circle_i == 1'b1 )
            next_state <= S_EANGLE_ZERO;
        else
            next_state <= S_ONECIRCLE;
    S_EANGLE_ZERO:
        if( cnt == 'd35000000 )
            next_state <= S_ACK;
        else
            next_state <= S_EANGLE_ZERO;
    S_ACK:
        next_state <= S_IDLE;
    default: next_state <= S_IDLE;
    endcase
end



always @(posedge sys_clk_i ) begin
    if( state == S_IDLE )
        cnt <= 'd0;
    else if(state == S_EANGLE_ZERO )
        cnt <= cnt + 1'b1;
    else if( cnt == EX_CYCLE )
        cnt <= 'd0;
    else
        cnt <= cnt + 1'b1;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i) begin
    if( sys_rst_n_i == 1'b0 )
        Open_angle_o <= 25'd0;
    else if( state == S_TOZERO || state == S_ONECIRCLE )
        if( cnt == EX_CYCLE && Open_angle_o >= 25'd23592960 )
            Open_angle_o <= 'd0;
        else if( cnt == EX_CYCLE )
            Open_angle_o <= Open_angle_o + ( 25'd1440 );
        else
            Open_angle_o <= Open_angle_o; 
    else if( state == S_EANGLE_ZERO )
        Open_angle_o <= 'd0;
    else
        Open_angle_o <= Open_angle_o;
end



always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        encoder_angle_offset_o <= 'd0;
    else if( state == S_EANGLE_ZERO &&  cnt == ( 'd35000000 - 'd1))
        encoder_angle_offset_o <= encoder_angle_i;//Open_angle_o;
    else
        encoder_angle_offset_o <= encoder_angle_offset_o;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        motor_pole_pair_o <= 'd0;
    else if( state == S_TOZERO )
        motor_pole_pair_o <= 'd0;
    else if( state == S_ONECIRCLE &&  cnt == EX_CYCLE )
        if( Open_angle_o == 'd0 )
            motor_pole_pair_o <= motor_pole_pair_o + 1'b1;
        else
            motor_pole_pair_o <= motor_pole_pair_o;
    else
        motor_pole_pair_o <= motor_pole_pair_o;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        dir_cnt <= 'd0;
    else if( state == S_ONECIRCLE && cnt == EX_CYCLE )
        if( dir_cnt == 'd100)
            dir_cnt <= 'd0;
        else
            dir_cnt <= dir_cnt + 1'b1;
    else
        dir_cnt <= 'd0;
end

always@( posedge sys_clk_i ) begin
    if( dir_cnt == 'd100 )
        encoder_angle_d0 <= encoder_angle_i;
    else
        encoder_angle_d0 <= encoder_angle_d0;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        encoder_dir_num_p <= 'd0;
    else if( state == S_IDLE )
        encoder_dir_num_p  <= 'd0;
    else if( dir_cnt == 'd100 )
        if( encoder_angle_i > encoder_angle_d0 ) 
            encoder_dir_num_p <= encoder_dir_num_p + 1'b1;
        else
            encoder_dir_num_p <= encoder_dir_num_p;
    else
        encoder_dir_num_p <= encoder_dir_num_p;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        encoder_dir_num_n <= 'd0;
    else if( state == S_IDLE )
        encoder_dir_num_n <= 'd0;
    else if( dir_cnt == 'd100 )
        if( encoder_angle_i < encoder_angle_d0 ) 
            encoder_dir_num_n <= encoder_dir_num_n + 1'b1;
        else
            encoder_dir_num_n <= encoder_dir_num_n;
    else
        encoder_dir_num_n <= encoder_dir_num_n;
end



always@( posedge sys_clk_i ) begin
    if( state == S_ACK )
        if( encoder_dir_num_p > encoder_dir_num_n )
            encoder_dir_o <= 1'b1;
        else
            encoder_dir_o <= 1'b0;
    else    
        encoder_dir_o <= encoder_dir_o;
end

endmodule
