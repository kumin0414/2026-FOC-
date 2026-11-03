`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/09 13:33:36
// Design Name: 
// Module Name: iclark_ipark
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


module iclark_ipark(
    input                   sys_clk_i           ,
    input                   sys_rst_n_i         ,

    input                   iclark_ipark_en_i   ,
    output                  iclark_ipark_ack_o  ,

    input signed[17:0]      cordic_sin_i        ,   
    input signed[17:0]      cordic_cos_i        ,
    input signed[24:0]      Uq_i                ,
    input signed[24:0]      Ud_i                ,


    output signed[31:0]     Ua_o                ,   //没有用到,暂不实现
    output signed[31:0]     Ub_o                ,   //没有用到,暂不实现
    output signed[31:0]     Uc_o                ,   //没有用到,暂不实现
    output reg signed[24:0] Ualpha_o            ,
    output reg signed[24:0] Ubeta_o             
);





reg[5:0]    cnt;
reg         dealing;

reg signed[42:0]   a;
reg signed[42:0]   b;
reg signed[42:0]   c;
reg signed[42:0]   d;

assign iclark_ipark_ack_o = ( cnt == 'd7 ) ? 1'b1 : 1'b0;

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        dealing <= 1'b0;
    else if( iclark_ipark_ack_o == 1'b1 )
        dealing <= 1'b0;
    else if( iclark_ipark_en_i == 1'b1 )
        dealing <= 1'b1;
    else
        dealing <= 1'b0;
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
    if( sys_rst_n_i == 1'b0 ) begin
        a <= 'd0;
        b <= 'd0;   
        c <= 'd0;
        d <= 'd0;      
    end
    else if( cnt == 'd1 ) begin
        a <= Uq_i * cordic_sin_i;
        b <= Ud_i * cordic_cos_i;   
        c <= Uq_i * cordic_cos_i;
        d <= Ud_i * cordic_sin_i;
    end
    else if( cnt == 'd3) begin
        a <= a >>> 16;
        b <= b >>> 16;
        c <= c >>> 16;
        d <= d >>> 16;
    end
    else begin
        a <= a;
        b <= b;
        c <= c;
        d <= d;
    end
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        Ualpha_o <= 'd0;
        Ubeta_o <= 'd0;      
    end
    else if( cnt == 'd5 ) begin
        Ualpha_o <= b - a;
        Ubeta_o <= c + d;     
    end
    else begin
        Ualpha_o <= Ualpha_o;
        Ubeta_o <= Ubeta_o;
    end
end


endmodule
