`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/23 11:44:26
// Design Name: 
// Module Name: top
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


module top(
    input                   sys_clk_i                   ,

    //uart
    output                  uart_tx_pin_o               ,

    //M0
    output                  m0_svpwm_u_pin_o            ,
    output                  m0_svpwm_v_pin_o            ,
    output                  m0_svpwm_w_pin_o            ,
    output                  m0_svpwm_un_pin_o           ,
    output                  m0_svpwm_vn_pin_o           ,
    output                  m0_svpwm_wn_pin_o           ,
    
    output                  m0_as5047p_spi_ss_pin_o     ,     
    output                  m0_as5047p_spi_sck_pin_o    ,    
    output                  m0_as5047p_spi_mosi_pin_o   ,   
    input                   m0_as5047p_spi_miso_pin_i   ,

    //M01
    output                  m1_svpwm_u_pin_o            ,
    output                  m1_svpwm_v_pin_o            ,
    output                  m1_svpwm_w_pin_o            ,
    output                  m1_svpwm_un_pin_o           ,
    output                  m1_svpwm_vn_pin_o           ,
    output                  m1_svpwm_wn_pin_o           ,

    output                  m1_as5047p_spi_ss_pin_o     ,     
    output                  m1_as5047p_spi_sck_pin_o    ,    
    output                  m1_as5047p_spi_mosi_pin_o   ,   
    input                   m1_as5047p_spi_miso_pin_i   ,


    //M2
    output                  m2_svpwm_u_pin_o            ,
    output                  m2_svpwm_v_pin_o            ,
    output                  m2_svpwm_w_pin_o            ,
    output                  m2_svpwm_un_pin_o           ,
    output                  m2_svpwm_vn_pin_o           ,
    output                  m2_svpwm_wn_pin_o           ,

    
    output                  m2_as5047p_spi_ss_pin_o     ,     
    output                  m2_as5047p_spi_sck_pin_o    ,    
    output                  m2_as5047p_spi_mosi_pin_o   ,   
    input                   m2_as5047p_spi_miso_pin_i   ,

    //M3
    output                  m3_svpwm_u_pin_o            ,
    output                  m3_svpwm_v_pin_o            ,
    output                  m3_svpwm_w_pin_o            ,
    output                  m3_svpwm_un_pin_o           ,
    output                  m3_svpwm_vn_pin_o           ,
    output                  m3_svpwm_wn_pin_o           ,

    
    output                  m3_as5047p_spi_ss_pin_o     ,     
    output                  m3_as5047p_spi_sck_pin_o    ,    
    output                  m3_as5047p_spi_mosi_pin_o   ,   
    input                   m3_as5047p_spi_miso_pin_i   ,

    //adc
    output[2:0]             ad7606_osx_pin_o            ,    //过采样设置
    output                  ad7606_rst_pin_o            ,    //复位
    output                  ad7606_convst_a_pin_o       ,    //A通道开始转换
    output                  ad7606_convst_b_pin_o       ,    //B通道开始转换
    output                  ad7606_rd_n_pin_o           ,
    output                  ad7606_cs_n_pin_o           ,
    input                   ad7606_busy_pin_i           ,
    input[15:0]             ad7606_data_pin_i                //AD7606并口数据
);
wire                        sys_clk_100M                ;
wire                        sys_clk_200M                ;
wire                        sys_rst_n_i                 ;

wire                        ad7606_req_i                ;
wire                        ad7606_ack_o                ;
wire                        adc_offset_finish           ;



assign m0_svpwm_u_pin_o   = m3_svpwm_u_pin_o ;
assign m0_svpwm_v_pin_o   = m3_svpwm_v_pin_o ;
assign m0_svpwm_w_pin_o   = m3_svpwm_w_pin_o ;
assign m0_svpwm_un_pin_o  = m3_svpwm_un_pin_o;
assign m0_svpwm_vn_pin_o  = m3_svpwm_vn_pin_o;
assign m0_svpwm_wn_pin_o  = m3_svpwm_wn_pin_o;
assign m1_svpwm_u_pin_o   = m3_svpwm_u_pin_o ;
assign m1_svpwm_v_pin_o   = m3_svpwm_v_pin_o ;
assign m1_svpwm_w_pin_o   = m3_svpwm_w_pin_o ;
assign m1_svpwm_un_pin_o  = m3_svpwm_un_pin_o;
assign m1_svpwm_vn_pin_o  = m3_svpwm_vn_pin_o;
assign m1_svpwm_wn_pin_o  = m3_svpwm_wn_pin_o;
assign m2_svpwm_u_pin_o   = m3_svpwm_u_pin_o ;
assign m2_svpwm_v_pin_o   = m3_svpwm_v_pin_o ;
assign m2_svpwm_w_pin_o   = m3_svpwm_w_pin_o ;
assign m2_svpwm_un_pin_o  = m3_svpwm_un_pin_o;
assign m2_svpwm_vn_pin_o  = m3_svpwm_vn_pin_o;
assign m2_svpwm_wn_pin_o  = m3_svpwm_wn_pin_o;


// assign m0_svpwm_u_pin_o   =1'b0 ;
// assign m0_svpwm_v_pin_o   =1'b0 ;
// assign m0_svpwm_w_pin_o   =1'b0 ;
// assign m0_svpwm_un_pin_o  =1'b0 ;
// assign m0_svpwm_vn_pin_o  =1'b0 ;
// assign m0_svpwm_wn_pin_o  =1'b0 ;
// assign m1_svpwm_u_pin_o   =1'b0 ;
// assign m1_svpwm_v_pin_o   =1'b0 ;
// assign m1_svpwm_w_pin_o   =1'b0 ;
// assign m1_svpwm_un_pin_o  =1'b0 ;
// assign m1_svpwm_vn_pin_o  =1'b0 ;
// assign m1_svpwm_wn_pin_o  =1'b0 ;
// assign m2_svpwm_u_pin_o   =1'b0 ;
// assign m2_svpwm_v_pin_o   =1'b0 ;
// assign m2_svpwm_w_pin_o   =1'b0 ;
// assign m2_svpwm_un_pin_o  =1'b0 ;
// assign m2_svpwm_vn_pin_o  =1'b0 ;
// assign m2_svpwm_wn_pin_o  =1'b0 ;
// assign m3_svpwm_u_pin_o   =1'b0 ;
// assign m3_svpwm_v_pin_o   =1'b0 ;
// assign m3_svpwm_w_pin_o   =1'b0 ;
// assign m3_svpwm_un_pin_o  =1'b0 ;
// assign m3_svpwm_vn_pin_o  =1'b0 ;
// assign m3_svpwm_wn_pin_o  =1'b0 ;




wire signed[15:0]     m0_ia;
wire signed[15:0]     m0_ib;
wire signed[15:0]     m0_ic;
wire signed[15:0]     m1_ia;
wire signed[15:0]     m1_ib;
wire signed[15:0]     m1_ic;
wire signed[15:0]     m2_ia;
wire signed[15:0]     m2_ib;
wire signed[15:0]     m2_ic;
wire signed[15:0]     m3_ia;
wire signed[15:0]     m3_ib;
wire signed[15:0]     m3_ic;


wire signed[15:0]     mx_ia;
wire signed[15:0]     mx_ib;
wire signed[15:0]     mx_ic;


wire[7:0]           monitor_data_sel_i;
wire[7:0]           monitor_func2     ;
wire signed[31:0]   monitor_data1_o   ;
wire signed[31:0]   monitor_data2_o   ;
wire signed[31:0]   monitor_data3_o   ;
wire signed[31:0]   monitor_data4_o   ;


assign monitor_func2 = ( monitor_data_sel_i == 'd0) ? 8'h30 :
                       ( monitor_data_sel_i == 'd1) ? 8'h31 : 
                       ( monitor_data_sel_i == 'd2) ? 8'h32 : 
                       ( monitor_data_sel_i == 'd3) ? 8'h33 : 8'h30;
           




wire[7:0]              foc_mode_i                  ;
wire signed[24:0]      foc_open_uq_i               ;
wire signed[24:0]      foc_open_ud_i               ;
wire signed[15:0]      foc_Iq_pid_p_i              ;
wire signed[15:0]      foc_Iq_pid_i_i              ;
wire signed[15:0]      foc_Id_pid_p_i              ;
wire signed[15:0]      foc_Id_pid_i_i              ;
wire signed[15:0]      foc_speed_pid_p_i           ;
wire signed[15:0]      foc_speed_pid_i_i           ;
wire signed[15:0]      foc_position_pid_p_i        ;
wire signed[15:0]      foc_position_pid_i_i        ;
wire signed[24:0]      foc_Iq_aim_i                ;
wire signed[24:0]      foc_Id_aim_i                ;
wire signed[24:0]      foc_speed_aim_i             ;
wire signed[24:0]      foc_position_aim_i          ;

vio_0 vio_0_hp(

    .clk                 (sys_clk_100M            ),
    .probe_out0          (sys_rst_n_i             ),
    .probe_out1          (foc_mode_i              ),
    .probe_out2          (monitor_data_sel_i      ),

    .probe_out3          (foc_open_uq_i           ),
    .probe_out4          (foc_open_ud_i           ),
    .probe_out5          (foc_Iq_pid_p_i          ),
    .probe_out6          (foc_Iq_pid_i_i          ),
    .probe_out7          (foc_Id_pid_p_i          ),
    .probe_out8          (foc_Id_pid_i_i          ),
    .probe_out9          (foc_speed_pid_p_i       ),
    .probe_out10         (foc_speed_pid_i_i       ),
    .probe_out11         (foc_position_pid_p_i    ),
    .probe_out12         (foc_position_pid_i_i    ),
    .probe_out13         (foc_Iq_aim_i            ),
    .probe_out14         (foc_Id_aim_i            ),
    .probe_out15         (foc_speed_aim_i         ),
    .probe_out16         (foc_position_aim_i      )
);

clk_wiz_0 clk_wiz_0_HP 
 (
  // Clock out ports
  .clk_out1 (sys_clk_100M),
  .clk_out2 (sys_clk_200M),
 // Clock in ports
  .clk_in1  (sys_clk_i)
 );


adc_top adc_top_hp(
    .sys_clk_i                      (       sys_clk_100M                            ),
    .sys_rst_n_i                    (       sys_rst_n_i                             ),

    .adc_req_i                      (       ad7606_req_i                            ),    //ad7606采样请求
    .adc_ack_o                      (       ad7606_ack_o                            ),    //ad7606采样结束
    .adc_offset_finish_o            (       adc_offset_finish                       ),
    .m0_ia_o                        (       m0_ia                                   ),
    .m0_ib_o                        (       m0_ib                                   ),
    .m0_ic_o                        (       m0_ic                                   ),
    .m1_ia_o                        (       m1_ia                                   ),
    .m1_ib_o                        (       m1_ib                                   ),
    .m1_ic_o                        (       m1_ic                                   ),
    .m2_ia_o                        (       m2_ia                                   ),
    .m2_ib_o                        (       m2_ib                                   ),
    .m2_ic_o                        (       m2_ic                                   ),
    .m3_ia_o                        (       m3_ia                                   ),
    .m3_ib_o                        (       m3_ib                                   ),
    .m3_ic_o                        (       m3_ic                                   ),


    .ad7606_osx_pin_o               (       ad7606_osx_pin_o                        ),    //过采样设置
    .ad7606_rst_pin_o               (       ad7606_rst_pin_o                        ),    //复位
    .ad7606_convst_a_pin_o          (       ad7606_convst_a_pin_o                   ),    //A通道开始转换
    .ad7606_convst_b_pin_o          (       ad7606_convst_b_pin_o                   ),    //B通道开始转换
    .ad7606_rd_n_pin_o              (       ad7606_rd_n_pin_o                       ),
    .ad7606_cs_n_pin_o              (       ad7606_cs_n_pin_o                       ),
    .ad7606_busy_pin_i              (       ad7606_busy_pin_i                       ),
    .ad7606_data_pin_i              (       ad7606_data_pin_i                       )     //AD7606并口数据
);


motor_top motor_top_hp3(   
    .sys_clk_i                      (       sys_clk_100M                            ),
    .sys_rst_n_i                    (       sys_rst_n_i                             ),

    .pwm_clk_200M_i                 (       sys_clk_200M                            ),
    //外部配置参数输入
    .foc_mode_i                     (       foc_mode_i                              ),
    .foc_open_uq_i                  (       foc_open_uq_i                           ),
    .foc_open_ud_i                  (       foc_open_ud_i                           ),
    .foc_Iq_pid_p_i                 (       foc_Iq_pid_p_i                          ),
    .foc_Iq_pid_i_i                 (       foc_Iq_pid_i_i                          ),
    .foc_Id_pid_p_i                 (       foc_Id_pid_p_i                          ),
    .foc_Id_pid_i_i                 (       foc_Id_pid_i_i                          ),
    .foc_speed_pid_p_i              (       foc_speed_pid_p_i                       ),
    .foc_speed_pid_i_i              (       foc_speed_pid_i_i                       ),
    .foc_position_pid_p_i           (       foc_position_pid_p_i                    ),
    .foc_position_pid_i_i           (       foc_position_pid_i_i                    ),
    .foc_Iq_aim_i                   (       foc_Iq_aim_i                            ),
    .foc_Id_aim_i                   (       foc_Id_aim_i                            ),
    .foc_speed_aim_i                (       foc_speed_aim_i                         ),
    .foc_position_aim_i             (       foc_position_aim_i                      ),
    //三相电流输入
    .adc_convert_req_o              (        ad7606_req_i                           ),
    .adc_convert_ack_i              (        ad7606_ack_o                           ),
    .adc_offset_finish_i            (        adc_offset_finish                      ),
    .Ia_i                           (        m3_ib                                  ),
    .Ib_i                           (        m3_ia                                  ),
    .Ic_i                           (        m3_ic                                  ),
    //波形选择
    .monitor_data_sel_i             (       monitor_data_sel_i                      ),
    .monitor_data1_o                (       monitor_data1_o                         ),
    .monitor_data2_o                (       monitor_data2_o                         ),
    .monitor_data3_o                (       monitor_data3_o                         ),
    .monitor_data4_o                (       monitor_data4_o                         ),
    //as5047p spi 接口
    .as5047p_spi_ss_pin_o           (       m3_as5047p_spi_ss_pin_o                 ),
    .as5047p_spi_sck_pin_o          (       m3_as5047p_spi_sck_pin_o                ),
    .as5047p_spi_mosi_pin_o         (       m3_as5047p_spi_mosi_pin_o               ),
    .as5047p_spi_miso_pin_i         (       m3_as5047p_spi_miso_pin_i               ),
    //as5047p ABZ 接口
    .as5047p_A_pin_i                (                                               ),
    .as5047p_B_pin_i                (                                               ),
    .as5047p_I_pin_i                (                                               ),
    //电机UVW引脚输出
    .svpwm_u_pin_o                  (       m3_svpwm_u_pin_o                        ),
    .svpwm_v_pin_o                  (       m3_svpwm_v_pin_o                        ),
    .svpwm_w_pin_o                  (       m3_svpwm_w_pin_o                        ),
    .svpwm_un_pin_o                 (       m3_svpwm_un_pin_o                       ),
    .svpwm_vn_pin_o                 (       m3_svpwm_vn_pin_o                       ),
    .svpwm_wn_pin_o                 (       m3_svpwm_wn_pin_o                       )
);


uart_tx_package uart_tx_package_hp(
    .sys_clk_i                      (       sys_clk_100M                            ),
    .sys_rst_n_i                    (       sys_rst_n_i                             ),

    .package_tx_req                 (       ad7606_ack_o                            ),
    .package_tx_ack                 (                                               ),

    .package_head                   (       8'hDE                                   ),
    .package_func1                  (       8'h1A                                   ),
    .package_func2                  (       monitor_func2                           ),
    .package_func3                  (       8'h00                                   ),
    .package_data1                  (       monitor_data1_o                         ),
    .package_data2                  (       monitor_data2_o                         ),
    .package_data3                  (       monitor_data3_o                         ),
    .package_data4                  (       monitor_data4_o                         ),
    .package_motor_id               (       16'h0001                                ),
    .package_id                     (       8'h02                                   ),
    .package_tail                   (       8'hED                                   ),

    .uart_tx_pin_o                  (       uart_tx_pin_o                           )
);








endmodule
