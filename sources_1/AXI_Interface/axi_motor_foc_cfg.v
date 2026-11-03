`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/30 08:40:42
// Design Name: 
// Module Name: axi_motor_foc_cfg
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




module axi_motor_foc_cfg(
    input                   sys_clk_i                                       ,
    input                   sys_rst_n_i                                     ,
    //input
    input signed[15:0]      Ia_i                                            ,
    input signed[15:0]      Ib_i                                            ,
    input signed[15:0]      Ic_i                                            ,
    input signed[24:0]      Ialpha_i                                        ,
    input signed[24:0]      Ibeta_i                                         ,
    input signed[24:0]      Iq_i                                            ,
    input signed[24:0]      Id_i                                            ,
    input [24:0]            motor_angle_i                                   ,
    input signed[31:0]      motor_speed_i                                   ,
    input signed[31:0]      motor_position_i                                ,
    input                   motor_encoder_dir_i                             ,
    input [24:0]            motor_angle_offset_i                            ,
    input [7:0]             motor_pole_pair_i                               ,
    //output
    output[7:0]             foc_mode_o                                      ,
    output signed[24:0]     foc_open_uq_o                                   ,
    output signed[24:0]     foc_open_ud_o                                   ,
    output signed[15:0]     foc_Iq_pid_p_o                                  ,
    output signed[15:0]     foc_Iq_pid_i_o                                  ,
    output signed[15:0]     foc_Id_pid_p_o                                  ,
    output signed[15:0]     foc_Id_pid_i_o                                  ,
    output signed[15:0]     foc_speed_pid_p_o                               ,
    output signed[15:0]     foc_speed_pid_i_o                               ,
    output signed[15:0]     foc_position_pid_p_o                            ,
    output signed[15:0]     foc_position_pid_i_o                            ,
    output signed[24:0]     foc_Iq_aim_o                                    ,
    output signed[24:0]     foc_Id_aim_o                                    ,
    output signed[24:0]     foc_speed_aim_o                                 ,
    output signed[24:0]     foc_position_aim_o                              ,
    output signed[31:0]     foc_position_fb_max_speed_o                     ,
    output[7:0]             motor_calibration_type_o                        ,
    output                  motor_position_set_o                            ,
    output                  motor_encoder_dir_o                             ,
    output [24:0]           motor_angle_offset_o                            ,
    output [7:0]            motor_pole_pair_o                               ,
    output reg              motor_calibration_data_valid_o                  ,
       
    //AXI4_FULL SLAVE
    //WRTIE ADDR CHANNEL
    input[0:0]          s_axi_awid                                          ,
    input[31:0]         s_axi_awaddr                                        ,
    input[7:0]          s_axi_awlen                                         ,
    input[2:0]          s_axi_awsize                                        ,
    input[1:0]          s_axi_awburst                                       ,
    input               s_axi_awlock                                        ,
    input[3:0]          s_axi_awcache                                       ,
    input[2:0]          s_axi_awprot                                        ,
    input[3:0]          s_axi_awqos                                         ,
    input[3:0]          s_axi_awregion                                      ,
    input               s_axi_awuser                                        ,
    input               s_axi_awvalid                                       ,
    output              s_axi_awready                                       ,
    //WRITE DATA CHANNEL
    input[0:0]          s_axi_wid                                           ,
    input[31:0]         s_axi_wdata                                         ,
    input[3:0]          s_axi_wstrb                                         ,
    input               s_axi_wlast                                         ,
    input               s_axi_wuser                                         ,
    input               s_axi_wvalid                                        ,
    output              s_axi_wready                                        ,
    //WRITE RESPONCE CHANNEL
    output[0:0]         s_axi_bid                                           ,
    output[1:0]         s_axi_bresp                                         ,
    output              s_axi_buser                                         ,
    output              s_axi_bvalid                                        ,
    input               s_axi_bready                                        ,
    //READ ADDR CHANNEL
    input[0:0]          s_axi_arid                                          ,
    input[31:0]         s_axi_araddr                                        ,
    input[7:0]          s_axi_arlen                                         ,
    input[2:0]          s_axi_arsize                                        ,
    input[1:0]          s_axi_arburst                                       ,
    input               s_axi_arlock                                        ,
    input[3:0]          s_axi_arcache                                       ,
    input[2:0]          s_axi_arprot                                        ,
    input[3:0]          s_axi_arqos                                         ,
    input[3:0]          s_axi_arregion                                      ,
    input               s_axi_aruser                                        ,
    input               s_axi_arvalid                                       ,
    output              s_axi_arready                                       ,
    //READ DATA CHANNEL 
    output[0:0]         s_axi_rid                                           ,
    output[31:0]        s_axi_rdata                                         ,
    output[1:0]         s_axi_rresp                                         ,
    output              s_axi_rlast                                         ,
    output              s_axi_ruser                                         ,
    output              s_axi_rvalid                                        ,
    input               s_axi_rready                                    
);



wire[31:0]              data0_reg_in                                        ;
wire[31:0]              data1_reg_in                                        ;
wire[31:0]              data2_reg_in                                        ;
wire[31:0]              data3_reg_in                                        ;
wire[31:0]              data4_reg_in                                        ;
wire[31:0]              data5_reg_in                                        ;
wire[31:0]              data6_reg_in                                        ;
wire[31:0]              data7_reg_in                                        ;
wire[31:0]              data8_reg_in                                        ;
wire[31:0]              data9_reg_in                                        ;
wire[31:0]              data10_reg_in                                       ;
wire[31:0]              data11_reg_in                                       ;
wire[31:0]              data12_reg_in                                       ;
wire[31:0]              data13_reg_in                                       ;
wire[31:0]              data14_reg_in                                       ;
wire[31:0]              data15_reg_in                                       ;
wire[31:0]              data16_reg_in                                       ;
wire[31:0]              data17_reg_in                                       ;
wire[31:0]              data18_reg_in                                       ;
wire[31:0]              data19_reg_in                                       ;
wire[31:0]              data20_reg_in                                       ;
wire[31:0]              data21_reg_in                                       ;
wire[31:0]              data22_reg_in                                       ;
wire[31:0]              data23_reg_in                                       ;
wire[31:0]              data24_reg_in                                       ;
wire[31:0]              data25_reg_in                                       ;
wire[31:0]              data26_reg_in                                       ;
wire[31:0]              data27_reg_in                                       ;
wire[31:0]              data28_reg_in                                       ;
wire[31:0]              data29_reg_in                                       ;
wire[31:0]              data30_reg_in                                       ;
wire[31:0]              data31_reg_in                                       ;
wire[31:0]              data32_reg_in                                       ;

wire                    datax_reg_update                                    ;
wire[9:0]               datax_reg_update_addr                               ;
wire[31:0]              data0_reg_out                                       ;
wire[31:0]              data1_reg_out                                       ;
wire[31:0]              data2_reg_out                                       ;
wire[31:0]              data3_reg_out                                       ;
wire[31:0]              data4_reg_out                                       ;
wire[31:0]              data5_reg_out                                       ;
wire[31:0]              data6_reg_out                                       ;
wire[31:0]              data7_reg_out                                       ;
wire[31:0]              data8_reg_out                                       ;
wire[31:0]              data9_reg_out                                       ;
wire[31:0]              data10_reg_out                                      ;
wire[31:0]              data11_reg_out                                      ;
wire[31:0]              data12_reg_out                                      ;
wire[31:0]              data13_reg_out                                      ;
wire[31:0]              data14_reg_out                                      ;
wire[31:0]              data15_reg_out                                      ;
wire[31:0]              data16_reg_out                                      ;
wire[31:0]              data17_reg_out                                      ;
wire[31:0]              data18_reg_out                                      ;
wire[31:0]              data19_reg_out                                      ;
wire[31:0]              data20_reg_out                                      ;
wire[31:0]              data21_reg_out                                      ;
wire[31:0]              data22_reg_out                                      ;
wire[31:0]              data23_reg_out                                      ;
wire[31:0]              data24_reg_out                                      ;
wire[31:0]              data25_reg_out                                      ;
wire[31:0]              data26_reg_out                                      ;
wire[31:0]              data27_reg_out                                      ;
wire[31:0]              data28_reg_out                                      ;
wire[31:0]              data29_reg_out                                      ;
wire[31:0]              data30_reg_out                                      ;
wire[31:0]              data31_reg_out                                      ;
wire[31:0]              data32_reg_out                                      ;

assign foc_mode_o                   =   data0_reg_out                       ;
assign foc_open_uq_o                =   data1_reg_out                       ;
assign foc_open_ud_o                =   data2_reg_out                       ;
assign foc_Iq_pid_p_o               =   data3_reg_out                       ;
assign foc_Iq_pid_i_o               =   data4_reg_out                       ;
assign foc_Id_pid_p_o               =   data5_reg_out                       ;
assign foc_Id_pid_i_o               =   data6_reg_out                       ;
assign foc_speed_pid_p_o            =   data7_reg_out                       ;
assign foc_speed_pid_i_o            =   data8_reg_out                       ;
assign foc_position_pid_p_o         =   data9_reg_out                       ;
assign foc_position_pid_i_o         =   data10_reg_out                      ;
assign foc_Iq_aim_o                 =   data11_reg_out                      ;
assign foc_Id_aim_o                 =   data12_reg_out                      ;
assign foc_speed_aim_o              =   data13_reg_out                      ;
assign foc_position_aim_o           =   data14_reg_out                      ;
assign foc_position_fb_max_speed_o  =   data15_reg_out                      ;
assign motor_calibration_type_o     =   data16_reg_out                      ;
assign motor_position_set_o         =   data17_reg_out[0]                   ;
assign motor_encoder_dir_o          =   data18_reg_out[0]                   ;
assign motor_angle_offset_o         =   data19_reg_out                      ;
assign motor_pole_pair_o            =   data20_reg_out                      ;




assign data0_reg_in                 =   'd0                                 ;
assign data1_reg_in                 =   'd0                                 ;
assign data2_reg_in                 =   'd0                                 ;
assign data3_reg_in                 =   'd0                                 ;
assign data4_reg_in                 =   'd0                                 ;
assign data5_reg_in                 =   'd0                                 ;
assign data6_reg_in                 =   'd0                                 ;
assign data7_reg_in                 =   'd0                                 ;
assign data8_reg_in                 =   'd0                                 ;
assign data9_reg_in                 =   'd0                                 ;
assign data10_reg_in                =   'd0                                 ;
assign data11_reg_in                =   'd0                                 ;
assign data12_reg_in                =   'd0                                 ;
assign data13_reg_in                =   'd0                                 ;
assign data14_reg_in                =   'd0                                 ;
assign data15_reg_in                =   'd0                                 ;
assign data16_reg_in                =   'd0                                 ;
assign data17_reg_in                =   'd0                                 ;
assign data18_reg_in                =   motor_encoder_dir_i                 ;
assign data19_reg_in                =   motor_angle_offset_i                ;
assign data20_reg_in                =   motor_pole_pair_i                   ;
assign data21_reg_in                =   Ia_i                                ;
assign data22_reg_in                =   Ib_i                                ;
assign data23_reg_in                =   Ic_i                                ;
assign data24_reg_in                =   Ialpha_i                            ;             
assign data25_reg_in                =   Ibeta_i                             ;
assign data26_reg_in                =   Iq_i                                ;                   
assign data27_reg_in                =   Id_i                                ;
assign data28_reg_in                =   motor_angle_i                       ;
assign data29_reg_in                =   motor_speed_i                       ;
assign data30_reg_in                =   motor_position_i                    ;                           
assign data31_reg_in                =   'd0                                 ;
assign data32_reg_in                =   'd0                                 ;


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        motor_calibration_data_valid_o <= 1'b0;
    else if( datax_reg_update == 1'b1 && datax_reg_update_addr == 'd20)
        motor_calibration_data_valid_o <= 1'b1;
    else
        motor_calibration_data_valid_o <= 1'b0;
end

axi_slave_brigde axi_slave_brigde_hp(
    .sys_clk_i                                       (      sys_clk_i                   ),
    .sys_rst_n_i                                     (      sys_rst_n_i                 ),

    //register  input 
    .data0_reg_in_i                                  (      data0_reg_in                ),
    .data1_reg_in_i                                  (      data1_reg_in                ),
    .data2_reg_in_i                                  (      data2_reg_in                ),
    .data3_reg_in_i                                  (      data3_reg_in                ),
    .data4_reg_in_i                                  (      data4_reg_in                ),
    .data5_reg_in_i                                  (      data5_reg_in                ),
    .data6_reg_in_i                                  (      data6_reg_in                ),
    .data7_reg_in_i                                  (      data7_reg_in                ),
    .data8_reg_in_i                                  (      data8_reg_in                ),
    .data9_reg_in_i                                  (      data9_reg_in                ),
    .data10_reg_in_i                                 (      data10_reg_in               ),
    .data11_reg_in_i                                 (      data11_reg_in               ),
    .data12_reg_in_i                                 (      data12_reg_in               ),
    .data13_reg_in_i                                 (      data13_reg_in               ),
    .data14_reg_in_i                                 (      data14_reg_in               ),
    .data15_reg_in_i                                 (      data15_reg_in               ),
    .data16_reg_in_i                                 (      data16_reg_in               ),
    .data17_reg_in_i                                 (      data17_reg_in               ),
    .data18_reg_in_i                                 (      data18_reg_in               ),
    .data19_reg_in_i                                 (      data19_reg_in               ),
    .data20_reg_in_i                                 (      data20_reg_in               ),
    .data21_reg_in_i                                 (      data21_reg_in               ),
    .data22_reg_in_i                                 (      data22_reg_in               ),
    .data23_reg_in_i                                 (      data23_reg_in               ),
    .data24_reg_in_i                                 (      data24_reg_in               ),
    .data25_reg_in_i                                 (      data25_reg_in               ),
    .data26_reg_in_i                                 (      data26_reg_in               ),
    .data27_reg_in_i                                 (      data27_reg_in               ),
    .data28_reg_in_i                                 (      data28_reg_in               ),
    .data29_reg_in_i                                 (      data29_reg_in               ),
    .data30_reg_in_i                                 (      data30_reg_in               ),
    .data31_reg_in_i                                 (      data31_reg_in               ),
    .data32_reg_in_i                                 (      data32_reg_in               ),

    //register  output 
    .datax_reg_update_o                              (      datax_reg_update            ),
    .datax_reg_update_addr_o                         (      datax_reg_update_addr       ),
    .data0_reg_out_o                                 (      data0_reg_out               ),
    .data1_reg_out_o                                 (      data1_reg_out               ),
    .data2_reg_out_o                                 (      data2_reg_out               ),
    .data3_reg_out_o                                 (      data3_reg_out               ),
    .data4_reg_out_o                                 (      data4_reg_out               ),
    .data5_reg_out_o                                 (      data5_reg_out               ),
    .data6_reg_out_o                                 (      data6_reg_out               ),
    .data7_reg_out_o                                 (      data7_reg_out               ),
    .data8_reg_out_o                                 (      data8_reg_out               ),
    .data9_reg_out_o                                 (      data9_reg_out               ),
    .data10_reg_out_o                                (      data10_reg_out              ),
    .data11_reg_out_o                                (      data11_reg_out              ),
    .data12_reg_out_o                                (      data12_reg_out              ),
    .data13_reg_out_o                                (      data13_reg_out              ),
    .data14_reg_out_o                                (      data14_reg_out              ),
    .data15_reg_out_o                                (      data15_reg_out              ),
    .data16_reg_out_o                                (      data16_reg_out              ),
    .data17_reg_out_o                                (      data17_reg_out              ),
    .data18_reg_out_o                                (      data18_reg_out              ),
    .data19_reg_out_o                                (      data19_reg_out              ),
    .data20_reg_out_o                                (      data20_reg_out              ),
    .data21_reg_out_o                                (      data21_reg_out              ),
    .data22_reg_out_o                                (      data22_reg_out              ),
    .data23_reg_out_o                                (      data23_reg_out              ),
    .data24_reg_out_o                                (      data24_reg_out              ),
    .data25_reg_out_o                                (      data25_reg_out              ),
    .data26_reg_out_o                                (      data26_reg_out              ),
    .data27_reg_out_o                                (      data27_reg_out              ),
    .data28_reg_out_o                                (      data28_reg_out              ),
    .data29_reg_out_o                                (      data29_reg_out              ),
    .data30_reg_out_o                                (      data30_reg_out              ),
    .data31_reg_out_o                                (      data31_reg_out              ),
    .data32_reg_out_o                                (      data32_reg_out              ),
    //AXI4_FULL SLAVE
    //WRTIE ADDR CHANNEL
    .s_axi_awid                                      (       s_axi_awid                     ),
    .s_axi_awaddr                                    (       s_axi_awaddr                   ),
    .s_axi_awlen                                     (       s_axi_awlen                    ),
    .s_axi_awsize                                    (       s_axi_awsize                   ),
    .s_axi_awburst                                   (       s_axi_awburst                  ),
    .s_axi_awlock                                    (       s_axi_awlock                   ),
    .s_axi_awcache                                   (       s_axi_awcache                  ),
    .s_axi_awprot                                    (       s_axi_awprot                   ),
    .s_axi_awqos                                     (       s_axi_awqos                    ),
    .s_axi_awregion                                  (       s_axi_awregion                 ),
    .s_axi_awuser                                    (       s_axi_awuser                   ),
    .s_axi_awvalid                                   (       s_axi_awvalid                  ),
    .s_axi_awready                                   (       s_axi_awready                  ),
    //WRITE DATA CHANNEL
    .s_axi_wid                                       (      s_axi_wid                       ),
    .s_axi_wdata                                     (      s_axi_wdata                     ),
    .s_axi_wstrb                                     (      s_axi_wstrb                     ),
    .s_axi_wlast                                     (      s_axi_wlast                     ),
    .s_axi_wuser                                     (      s_axi_wuser                     ),
    .s_axi_wvalid                                    (      s_axi_wvalid                    ),
    .s_axi_wready                                    (      s_axi_wready                    ),
    //WRITE RESPONCE CHANNEL
    .s_axi_bid                                       (      s_axi_bid                       ),
    .s_axi_bresp                                     (      s_axi_bresp                     ),
    .s_axi_buser                                     (      s_axi_buser                     ),
    .s_axi_bvalid                                    (      s_axi_bvalid                    ),
    .s_axi_bready                                    (      s_axi_bready                    ),
    //READ ADDR CHANNEL
    .s_axi_arid                                      (      s_axi_arid                      ),
    .s_axi_araddr                                    (      s_axi_araddr                    ),
    .s_axi_arlen                                     (      s_axi_arlen                     ),
    .s_axi_arsize                                    (      s_axi_arsize                    ),
    .s_axi_arburst                                   (      s_axi_arburst                   ),
    .s_axi_arlock                                    (      s_axi_arlock                    ),
    .s_axi_arcache                                   (      s_axi_arcache                   ),
    .s_axi_arprot                                    (      s_axi_arprot                    ),
    .s_axi_arqos                                     (      s_axi_arqos                     ),
    .s_axi_arregion                                  (      s_axi_arregion                  ),
    .s_axi_aruser                                    (      s_axi_aruser                    ),
    .s_axi_arvalid                                   (      s_axi_arvalid                   ),
    .s_axi_arready                                   (      s_axi_arready                   ),
    //READ DATA CHANNEL
    .s_axi_rid                                       (      s_axi_rid                       ),
    .s_axi_rdata                                     (      s_axi_rdata                     ),
    .s_axi_rresp                                     (      s_axi_rresp                     ),
    .s_axi_rlast                                     (      s_axi_rlast                     ),
    .s_axi_ruser                                     (      s_axi_ruser                     ),
    .s_axi_rvalid                                    (      s_axi_rvalid                    ),
    .s_axi_rready                                    (      s_axi_rready                    )
);

endmodule