`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/10 23:28:01
// Design Name: 
// Module Name: position_pid
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
//      .WIDTH_A(18),       // Multiplier A-input bus width, 1-25
//      .WIDTH_B(18)        // Multiplier B-input bus width, 1-18
//////////////////////////////////////////////////////////////////////////////////


module position_pid(
    input                   sys_clk_i           ,
    input                   sys_rst_n_i         ,
    
    input                   position_pid_en_i   ,
    output                  position_pid_ack_o  ,

    input signed[24:0]      error_sum_max_i     ,  
    input signed[24:0]      error_sum_min_i     ,
    input signed[24:0]      fb_value_max_i      ,
    input signed[24:0]      fb_value_min_i      ,


    input signed[24:0]     error_sum_i          ,
    output signed[24:0]    error_sum_o          ,

    input signed[15:0]      P_i                 ,
    input signed[15:0]      I_i                 ,
    input signed[15:0]      D_i                 ,

    input signed[24:0]      desired_value_i     ,
    input signed[24:0]      actual_value_i      ,

    output reg signed[31:0] feedback_value_o    
);



reg[4:0]    cnt;
reg         dealing;


reg signed[24:0]    error;
reg signed[24:0]    error_sum_temp;

reg signed[31:0]    P_fb;
reg signed[31:0]    I_fb;

reg signed[32:0]    feedback_value_d0;


assign error_sum_o = error_sum_temp;

assign position_pid_ack_o = ( cnt == 'd15 ) ? 1'b1 : 1'b0;

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        dealing <= 1'b0;
    else if( position_pid_ack_o == 1'b1 )
        dealing <= 1'b0;
    else if( position_pid_en_i == 1'b1 )
        dealing <= 1'b1;
    else
        dealing <= dealing;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        cnt <= 'd0;
    else if( dealing == 1'b1 )
        cnt <= cnt + 1'b1;
    else
        cnt <= 'd0;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        error <= 'd0;
    else if( cnt == 'd1 )
        error <= ( desired_value_i - actual_value_i ) ;
    else
        error <= error;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        P_fb <= 'd0;
    else if( cnt == 'd3 )
        P_fb <= error * P_i;
    else if( cnt == 'd5)
        P_fb <= P_fb >>> 8;
    else
        P_fb <= P_fb;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        error_sum_temp <= 'd0;
    else if( cnt == 'd1 )
        error_sum_temp <= error_sum_i;
    else if( cnt == 'd3 )
            error_sum_temp <= error_sum_temp + error;
    else if( cnt == 'd5 ) begin
        if( error_sum_temp >= error_sum_max_i ) 
            error_sum_temp <=  error_sum_max_i;
        else if( error_sum_temp <= error_sum_min_i)
            error_sum_temp <= error_sum_min_i;
        else
            error_sum_temp <= error_sum_temp;
    end
    else
        error_sum_temp <= error_sum_temp;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        I_fb <= 'd0;
    else if( cnt == 'd7 )
        I_fb <= error_sum_temp * I_i;
    else if( cnt == 'd9 )
        I_fb <= I_fb >>> 8;
    else
        I_fb <= I_fb;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        feedback_value_d0 <= 'd0;
    else if( cnt == 'd11 )
        feedback_value_d0 <= P_fb + I_fb;
    else
        feedback_value_d0 <= feedback_value_d0;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        feedback_value_o <= 'd0;
    else if( cnt == 'd13 )
        if( feedback_value_d0 > fb_value_max_i )
            feedback_value_o <= fb_value_max_i;
        else if( feedback_value_d0 < fb_value_min_i )
            feedback_value_o <= fb_value_min_i;
        else
            feedback_value_o <= feedback_value_d0;
    else
        feedback_value_o <= feedback_value_o;
end


endmodule


