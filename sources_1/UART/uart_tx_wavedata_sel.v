`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 11:16:12
// Design Name: 
// Module Name: uart_tx_wavedata_sel
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


module uart_tx_wavedata_sel(
    input                   sys_clk_i           ,
    input                   sys_rst_n_i         ,

    input[7:0]              wavedata_sel_i      ,

    input signed[31:0]      Ia_i                ,
    input signed[31:0]      Ib_i                ,
    input signed[31:0]      Ic_i                ,

    input signed[31:0]      foc_Iq_i            ,
    input signed[31:0]      foc_Id_i            ,
    input signed[31:0]      desired_Iq_i        ,
    input signed[31:0]      desired_Id_i        ,


    input signed[31:0]      motor_speed_i       ,
    input signed[31:0]      desired_speed_i     ,
    input [31:0]            foc_angle           ,


    input signed[31:0]      motor_position_i    ,
    input signed[31:0]      desired_position_i  ,



    output[7:0]             func2_o             ,
    output signed[31:0]     data1_o             ,
    output signed[31:0]     data2_o             ,
    output signed[31:0]     data3_o             ,
    output signed[31:0]     data4_o             
);


assign func2_o = ( wavedata_sel_i == 'd0) ? 8'h30 :
                 ( wavedata_sel_i == 'd1) ? 8'h31 : 
                 ( wavedata_sel_i == 'd2) ? 8'h32 : 
                 ( wavedata_sel_i == 'd3) ? 8'h33 : 8'h30;


assign data1_o = ( wavedata_sel_i == 'd0) ? Ia_i :
                 ( wavedata_sel_i == 'd1) ? foc_Iq_i : 
                 ( wavedata_sel_i == 'd2) ? motor_speed_i : 
                 ( wavedata_sel_i == 'd3) ? motor_position_i : 0;

assign data2_o = ( wavedata_sel_i == 'd0) ? Ib_i :
                 ( wavedata_sel_i == 'd1) ? foc_Id_i : 
                 ( wavedata_sel_i == 'd2) ? desired_speed_i : 
                 ( wavedata_sel_i == 'd3) ? desired_position_i : 0;

assign data3_o = ( wavedata_sel_i == 'd0) ? Ic_i :
                 ( wavedata_sel_i == 'd1) ? desired_Iq_i : 
                 ( wavedata_sel_i == 'd2) ? foc_angle : 
                 ( wavedata_sel_i == 'd3) ? 0 : 0;

assign data4_o = ( wavedata_sel_i == 'd0) ? 0 :
                 ( wavedata_sel_i == 'd1) ? desired_Id_i : 
                 ( wavedata_sel_i == 'd2) ? 0 : 
                 ( wavedata_sel_i == 'd3) ? 0 : 0;










endmodule
