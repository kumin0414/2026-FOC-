`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/28 23:10:54
// Design Name:  FPGA之旅
// Module Name: AS5047P_Top
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


module AS5047P_Top #(
    parameter                   encoder_mode               = "SPI"     //   SPI    ABZ 两种模式
)(
    input                       sys_clk_i                   ,
    input                       sys_rst_n_i                 ,

    //角度 位置 速度 信息输出
    input                       motor_position_en_i         , //电机位置检测使能
    input                       motor_position_set_i        , //设置电机当前位置为初始位置        
    output  [24:0]              motor_angle_o               , //电机当前角度
    output signed[31:0]         motor_speed_o               , //电机当前速度
    output signed[31:0]         motor_position_o            , //电机当前位置
    output                      motor_one_circle_o          , //电机运行一圈标志输出
    output [15:0]               abz_one_circle_plus_o       , //电机 ABZ接口一圈的脉冲数
    //spi 接口
    output                      as5047p_spi_csn_p_o         ,
    output                      as5047p_spi_sclk_p_o        ,   // max 10Mhz
    input                       as5047p_spi_miso_p_i        ,
    output                      as5047p_spi_mosi_p_o        ,
    //ABZ 接口
    input                       as5047p_A_p_i               ,  
    input                       as5047p_B_p_i               ,
    input                       as5047p_I_p_i               
);

localparam            POWER_ON_DELAY_TIME   =   'd100000;
  

wire                  abs_req                       ; 
wire                  abs_spi_start_en              ;
wire[15:0]            abs_spi_tx_data               ;    

wire                  spi_start_en                  ;
wire [15:0]           spi_tx_data                   ;
wire[15:0]            spi_rx_data                   ;
wire                  spi_end_ack                   ;
reg[20:0]             cnt                           ;

assign spi_start_en          = abs_spi_start_en;
assign spi_tx_data           = abs_spi_tx_data;

assign abs_req               = ( (cnt == POWER_ON_DELAY_TIME) && ( encoder_mode == "SPI" )) ? 1'b1 : 1'b0;

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        cnt <= 'd0;
    else if( cnt < POWER_ON_DELAY_TIME )
        cnt <= cnt + 1'b1;
    else
        cnt <= cnt;
end




generate
    if( encoder_mode == "SPI" ) begin: abslolute_encoder_mode
        AS5047P_ABS AS5047P_ABS_hp(
            .sys_clk_i                      (  sys_clk_i                ),
            .sys_rst_n_i                    (  sys_rst_n_i              ),

            .abs_req_i                      (  abs_req                  ),

            .motor_position_en_i            (  motor_position_en_i      ), //电机位置检测使能
            .motor_position_set_i           (  motor_position_set_i     ), //设置电机当前位置为初始位置  
            .motor_angle_o                  (  motor_angle_o            ), //电机当前角度
            .motor_speed_o                  (  motor_speed_o            ), //电机当前速度
            .motor_position_o               (  motor_position_o         ), //电机当前位置
            .abs_motor_one_circle_o         (  motor_one_circle_o       ), //电机运行一圈标志输出
            //SPI接口
            .spi_start_en_o                 (  abs_spi_start_en         ),
            .spi_tx_data_o                  (  abs_spi_tx_data          ),
            .spi_rx_data_i                  (  spi_rx_data              ),
            .spi_end_ack_i                  (  spi_end_ack              )
        );
        AS5047P_SPI #(
            .CPOL                           (   1'b0                    ),
            .CPHA                           (   1'b1                    ),
            .SCLK_DIV                       (   8'd16                   ), //4 8 16 32 64分频系数
            .DATA_WIDTH                     (   16'd16                  )
        )AS5047P_SPI_hp(
            .sys_clk_i                      (  sys_clk_i                ),
            .sys_rst_n_i                    (  sys_rst_n_i              ),

            .spi_start_en_i                 (   spi_start_en            ),
            .spi_tx_data_i                  (   spi_tx_data             ),
            .spi_rx_data_o                  (   spi_rx_data             ),
            .spi_end_ack_o                  (   spi_end_ack             ),

            //spi 接口
            .spi_csn_p_o                    (   as5047p_spi_csn_p_o     ),
            .spi_sclk_p_o                   (   as5047p_spi_sclk_p_o    ),  
            .spi_miso_p_i                   (   as5047p_spi_miso_p_i    ),
            .spi_mosi_p_o                   (   as5047p_spi_mosi_p_o    )
        );
    end
    else begin: ABZ_encoder_mode
        ABZ_encoder ABZ_encoder_hp(
            .sys_clk_i                      (   sys_clk_i               ),
            .sys_rst_n_i                    (   sys_rst_n_i             ),

            .motor_position_en_i            (   motor_position_en_i     ), //电机位置检测使能
            .motor_position_set_i           (   motor_position_set_i    ), //设置电机当前位置为初始位置 
            .motor_angle_o                  (   motor_angle_o           ), //电机当前角度
            .motor_speed_o                  (   motor_speed_o           ), //电机当前速度
            .motor_position_o               (   motor_position_o        ), //电机当前位置
            .motor_one_circle_o             (   motor_one_circle_o      ), //电机运行一圈标志输出
            .ABZ_one_circle_plus_o          (   abz_one_circle_plus_o   ), //电机运行一圈，输出的脉冲总数
            //ABZ编码器输入 
            .ABZ_A_i                        (   as5047p_A_p_i           ),   
            .ABZ_B_i                        (   as5047p_B_p_i           ),   
            .ABZ_Z_i                        (   as5047p_I_p_i           )    
        );
    end
endgenerate

endmodule
