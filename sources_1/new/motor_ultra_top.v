`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/14 10:59:23
// Design Name: 
// Module Name: motor_ultra_top
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


module motor_ultra_top(
    input                   sys_clk_i                   ,
    input                   sys_rst_n_i                 ,
    input                   pwm_clk_200M_i              ,

    //adc
    output                  adc_convert_req_o           ,
    input                   adc_convert_ack_i           ,
    input                   adc_offset_finish_i         ,
    input signed[15:0]      m0_ia_i                     ,
    input signed[15:0]      m0_ib_i                     ,
    input signed[15:0]      m0_ic_i                     ,
    input signed[15:0]      m1_ia_i                     ,
    input signed[15:0]      m1_ib_i                     ,
    input signed[15:0]      m1_ic_i                     ,
    input signed[15:0]      m2_ia_i                     ,
    input signed[15:0]      m2_ib_i                     ,
    input signed[15:0]      m2_ic_i                     ,
    input signed[15:0]      m3_ia_i                     ,
    input signed[15:0]      m3_ib_i                     ,
    input signed[15:0]      m3_ic_i                     ,


    //M0
    //as5047p spi 接口
    output                  m0_as5047p_spi_ss_pin_o     ,     
    output                  m0_as5047p_spi_sck_pin_o    ,    
    output                  m0_as5047p_spi_mosi_pin_o   ,   
    input                   m0_as5047p_spi_miso_pin_i   ,
    //电机UVW引脚输出
    output                  m0_svpwm_u_pin_o            ,
    output                  m0_svpwm_v_pin_o            ,
    output                  m0_svpwm_w_pin_o            ,
    output                  m0_svpwm_un_pin_o           ,
    output                  m0_svpwm_vn_pin_o           ,
    output                  m0_svpwm_wn_pin_o           ,
    //AXI4_FULL SLAVE
    //WRTIE ADDR CHANNEL
    input[0:0]              S00_axi_awid                ,
    input[31:0]             S00_axi_awaddr              ,
    input[7:0]              S00_axi_awlen               ,
    input[2:0]              S00_axi_awsize              ,
    input[1:0]              S00_axi_awburst             ,
    input                   S00_axi_awlock              ,
    input[3:0]              S00_axi_awcache             ,
    input[2:0]              S00_axi_awprot              ,
    input[3:0]              S00_axi_awqos               ,
    input[3:0]              S00_axi_awregion            ,
    input                   S00_axi_awuser              ,
    input                   S00_axi_awvalid             ,
    output                  S00_axi_awready             ,
    //WRITE DATA CHANNEL
    input[0:0]              S00_axi_wid                 ,
    input[31:0]             S00_axi_wdata               ,
    input[3:0]              S00_axi_wstrb               ,
    input                   S00_axi_wlast               ,
    input                   S00_axi_wuser               ,
    input                   S00_axi_wvalid              ,
    output                  S00_axi_wready              ,
    //WRITE RESPONCE CHANNEL
    output[0:0]             S00_axi_bid                 ,
    output[1:0]             S00_axi_bresp               ,
    output                  S00_axi_buser               ,
    output                  S00_axi_bvalid              ,
    input                   S00_axi_bready              ,
    //READ ADDR CHANNEL
    input[0:0]              S00_axi_arid                ,
    input[31:0]             S00_axi_araddr              ,
    input[7:0]              S00_axi_arlen               ,
    input[2:0]              S00_axi_arsize              ,
    input[1:0]              S00_axi_arburst             ,
    input                   S00_axi_arlock              ,
    input[3:0]              S00_axi_arcache             ,
    input[2:0]              S00_axi_arprot              ,
    input[3:0]              S00_axi_arqos               ,
    input[3:0]              S00_axi_arregion            ,
    input                   S00_axi_aruser              ,
    input                   S00_axi_arvalid             ,
    output                  S00_axi_arready             ,
    //READ DATA CHANNEL 
    output[0:0]             S00_axi_rid                 ,
    output[31:0]            S00_axi_rdata               ,
    output[1:0]             S00_axi_rresp               ,
    output                  S00_axi_rlast               ,
    output                  S00_axi_ruser               ,
    output                  S00_axi_rvalid              ,
    input                   S00_axi_rready              ,

    //M1
    //as5047p spi 接口
    output                  m1_as5047p_spi_ss_pin_o     ,     
    output                  m1_as5047p_spi_sck_pin_o    ,    
    output                  m1_as5047p_spi_mosi_pin_o   ,   
    input                   m1_as5047p_spi_miso_pin_i   ,
    //电机UVW引脚输出
    output                  m1_svpwm_u_pin_o            ,
    output                  m1_svpwm_v_pin_o            ,
    output                  m1_svpwm_w_pin_o            ,
    output                  m1_svpwm_un_pin_o           ,
    output                  m1_svpwm_vn_pin_o           ,
    output                  m1_svpwm_wn_pin_o           ,
    //AXI4_FULL SLAVE
    //WRTIE ADDR CHANNEL
    input[0:0]              S01_axi_awid                ,
    input[31:0]             S01_axi_awaddr              ,
    input[7:0]              S01_axi_awlen               ,
    input[2:0]              S01_axi_awsize              ,
    input[1:0]              S01_axi_awburst             ,
    input                   S01_axi_awlock              ,
    input[3:0]              S01_axi_awcache             ,
    input[2:0]              S01_axi_awprot              ,
    input[3:0]              S01_axi_awqos               ,
    input[3:0]              S01_axi_awregion            ,
    input                   S01_axi_awuser              ,
    input                   S01_axi_awvalid             ,
    output                  S01_axi_awready             ,
    //WRITE DATA CHANNEL
    input[0:0]              S01_axi_wid                 ,
    input[31:0]             S01_axi_wdata               ,
    input[3:0]              S01_axi_wstrb               ,
    input                   S01_axi_wlast               ,
    input                   S01_axi_wuser               ,
    input                   S01_axi_wvalid              ,
    output                  S01_axi_wready              ,
    //WRITE RESPONCE CHANNEL
    output[0:0]             S01_axi_bid                 ,
    output[1:0]             S01_axi_bresp               ,
    output                  S01_axi_buser               ,
    output                  S01_axi_bvalid              ,
    input                   S01_axi_bready              ,
    //READ ADDR CHANNEL
    input[0:0]              S01_axi_arid                ,
    input[31:0]             S01_axi_araddr              ,
    input[7:0]              S01_axi_arlen               ,
    input[2:0]              S01_axi_arsize              ,
    input[1:0]              S01_axi_arburst             ,
    input                   S01_axi_arlock              ,
    input[3:0]              S01_axi_arcache             ,
    input[2:0]              S01_axi_arprot              ,
    input[3:0]              S01_axi_arqos               ,
    input[3:0]              S01_axi_arregion            ,
    input                   S01_axi_aruser              ,
    input                   S01_axi_arvalid             ,
    output                  S01_axi_arready             ,
    //READ DATA CHANNEL 
    output[0:0]             S01_axi_rid                 ,
    output[31:0]            S01_axi_rdata               ,
    output[1:0]             S01_axi_rresp               ,
    output                  S01_axi_rlast               ,
    output                  S01_axi_ruser               ,
    output                  S01_axi_rvalid              ,
    input                   S01_axi_rready              ,

    //M2
    //as5047p spi 接口
    output                  m2_as5047p_spi_ss_pin_o     ,     
    output                  m2_as5047p_spi_sck_pin_o    ,    
    output                  m2_as5047p_spi_mosi_pin_o   ,   
    input                   m2_as5047p_spi_miso_pin_i   ,
    //电机UVW引脚输出
    output                  m2_svpwm_u_pin_o            ,
    output                  m2_svpwm_v_pin_o            ,
    output                  m2_svpwm_w_pin_o            ,
    output                  m2_svpwm_un_pin_o           ,
    output                  m2_svpwm_vn_pin_o           ,
    output                  m2_svpwm_wn_pin_o           ,
    //AXI4_FULL SLAVE
    //WRTIE ADDR CHANNEL
    input[0:0]              S02_axi_awid                ,
    input[31:0]             S02_axi_awaddr              ,
    input[7:0]              S02_axi_awlen               ,
    input[2:0]              S02_axi_awsize              ,
    input[1:0]              S02_axi_awburst             ,
    input                   S02_axi_awlock              ,
    input[3:0]              S02_axi_awcache             ,
    input[2:0]              S02_axi_awprot              ,
    input[3:0]              S02_axi_awqos               ,
    input[3:0]              S02_axi_awregion            ,
    input                   S02_axi_awuser              ,
    input                   S02_axi_awvalid             ,
    output                  S02_axi_awready             ,
    //WRITE DATA CHANNEL
    input[0:0]              S02_axi_wid                 ,
    input[31:0]             S02_axi_wdata               ,
    input[3:0]              S02_axi_wstrb               ,
    input                   S02_axi_wlast               ,
    input                   S02_axi_wuser               ,
    input                   S02_axi_wvalid              ,
    output                  S02_axi_wready              ,
    //WRITE RESPONCE CHANNEL
    output[0:0]             S02_axi_bid                 ,
    output[1:0]             S02_axi_bresp               ,
    output                  S02_axi_buser               ,
    output                  S02_axi_bvalid              ,
    input                   S02_axi_bready              ,
    //READ ADDR CHANNEL
    input[0:0]              S02_axi_arid                ,
    input[31:0]             S02_axi_araddr              ,
    input[7:0]              S02_axi_arlen               ,
    input[2:0]              S02_axi_arsize              ,
    input[1:0]              S02_axi_arburst             ,
    input                   S02_axi_arlock              ,
    input[3:0]              S02_axi_arcache             ,
    input[2:0]              S02_axi_arprot              ,
    input[3:0]              S02_axi_arqos               ,
    input[3:0]              S02_axi_arregion            ,
    input                   S02_axi_aruser              ,
    input                   S02_axi_arvalid             ,
    output                  S02_axi_arready             ,
    //READ DATA CHANNEL 
    output[0:0]             S02_axi_rid                 ,
    output[31:0]            S02_axi_rdata               ,
    output[1:0]             S02_axi_rresp               ,
    output                  S02_axi_rlast               ,
    output                  S02_axi_ruser               ,
    output                  S02_axi_rvalid              ,
    input                   S02_axi_rready              ,

    //M3
    //as5047p spi 接口
    output                  m3_as5047p_spi_ss_pin_o     ,     
    output                  m3_as5047p_spi_sck_pin_o    ,    
    output                  m3_as5047p_spi_mosi_pin_o   ,   
    input                   m3_as5047p_spi_miso_pin_i   ,
    //电机UVW引脚输出
    output                  m3_svpwm_u_pin_o            ,
    output                  m3_svpwm_v_pin_o            ,
    output                  m3_svpwm_w_pin_o            ,
    output                  m3_svpwm_un_pin_o           ,
    output                  m3_svpwm_vn_pin_o           ,
    output                  m3_svpwm_wn_pin_o           ,
    //AXI4_FULL SLAVE
    //WRTIE ADDR CHANNEL
    input[0:0]              S03_axi_awid                ,
    input[31:0]             S03_axi_awaddr              ,
    input[7:0]              S03_axi_awlen               ,
    input[2:0]              S03_axi_awsize              ,
    input[1:0]              S03_axi_awburst             ,
    input                   S03_axi_awlock              ,
    input[3:0]              S03_axi_awcache             ,
    input[2:0]              S03_axi_awprot              ,
    input[3:0]              S03_axi_awqos               ,
    input[3:0]              S03_axi_awregion            ,
    input                   S03_axi_awuser              ,
    input                   S03_axi_awvalid             ,
    output                  S03_axi_awready             ,
    //WRITE DATA CHANNEL
    input[0:0]              S03_axi_wid                 ,
    input[31:0]             S03_axi_wdata               ,
    input[3:0]              S03_axi_wstrb               ,
    input                   S03_axi_wlast               ,
    input                   S03_axi_wuser               ,
    input                   S03_axi_wvalid              ,
    output                  S03_axi_wready              ,
    //WRITE RESPONCE CHANNEL
    output[0:0]             S03_axi_bid                 ,
    output[1:0]             S03_axi_bresp               ,
    output                  S03_axi_buser               ,
    output                  S03_axi_bvalid              ,
    input                   S03_axi_bready              ,
    //READ ADDR CHANNEL
    input[0:0]              S03_axi_arid                ,
    input[31:0]             S03_axi_araddr              ,
    input[7:0]              S03_axi_arlen               ,
    input[2:0]              S03_axi_arsize              ,
    input[1:0]              S03_axi_arburst             ,
    input                   S03_axi_arlock              ,
    input[3:0]              S03_axi_arcache             ,
    input[2:0]              S03_axi_arprot              ,
    input[3:0]              S03_axi_arqos               ,
    input[3:0]              S03_axi_arregion            ,
    input                   S03_axi_aruser              ,
    input                   S03_axi_arvalid             ,
    output                  S03_axi_arready             ,
    //READ DATA CHANNEL 
    output[0:0]             S03_axi_rid                 ,
    output[31:0]            S03_axi_rdata               ,
    output[1:0]             S03_axi_rresp               ,
    output                  S03_axi_rlast               ,
    output                  S03_axi_ruser               ,
    output                  S03_axi_rvalid              ,
    input                   S03_axi_rready              
);

wire m0_adc_convert_req;
wire m1_adc_convert_req;
wire m2_adc_convert_req;
wire m3_adc_convert_req;



assign adc_convert_req_o = m0_adc_convert_req || m1_adc_convert_req || m2_adc_convert_req || m3_adc_convert_req;






motor_top motor_top_hp_m0(   
    .sys_clk_i                      (       sys_clk_i                       ), 
    .sys_rst_n_i                    (       sys_rst_n_i                     ), 
    .pwm_clk_200M_i                 (       pwm_clk_200M_i                  ),
    //三相电流输入
    .adc_convert_req_o              (       m0_adc_convert_req              ),
    .adc_convert_ack_i              (       adc_convert_ack_i               ),
    .adc_offset_finish_i            (       adc_offset_finish_i             ),
    .Ia_i                           (       m0_ib_i                         ),
    .Ib_i                           (       m0_ia_i                         ),
    .Ic_i                           (       m0_ic_i                         ),
    //as5047p spi 接口
    .as5047p_spi_ss_pin_o           (       m0_as5047p_spi_ss_pin_o         ),     
    .as5047p_spi_sck_pin_o          (       m0_as5047p_spi_sck_pin_o        ),    
    .as5047p_spi_mosi_pin_o         (       m0_as5047p_spi_mosi_pin_o       ),   
    .as5047p_spi_miso_pin_i         (       m0_as5047p_spi_miso_pin_i       ),
    //as5047p ABZ 接口
    .as5047p_A_pin_i                (                                       ),
    .as5047p_B_pin_i                (                                       ),
    .as5047p_I_pin_i                (                                       ),
    //电机UVW引脚输出
    .svpwm_u_pin_o                  (       m0_svpwm_u_pin_o                ),
    .svpwm_v_pin_o                  (       m0_svpwm_v_pin_o                ),
    .svpwm_w_pin_o                  (       m0_svpwm_w_pin_o                ),
    .svpwm_un_pin_o                 (       m0_svpwm_un_pin_o               ),
    .svpwm_vn_pin_o                 (       m0_svpwm_vn_pin_o               ),
    .svpwm_wn_pin_o                 (       m0_svpwm_wn_pin_o               ),

    //AXI4_FULL SLAVE
    //WRTIE ADDR CHANNEL
    .s_axi_awid                     (       S00_axi_awid                    ),
    .s_axi_awaddr                   (       S00_axi_awaddr                  ),
    .s_axi_awlen                    (       S00_axi_awlen                   ),
    .s_axi_awsize                   (       S00_axi_awsize                  ),
    .s_axi_awburst                  (       S00_axi_awburst                 ),
    .s_axi_awlock                   (       S00_axi_awlock                  ),
    .s_axi_awcache                  (       S00_axi_awcache                 ),
    .s_axi_awprot                   (       S00_axi_awprot                  ),
    .s_axi_awqos                    (       S00_axi_awqos                   ),
    .s_axi_awregion                 (       S00_axi_awregion                ),
    .s_axi_awuser                   (       S00_axi_awuser                  ),
    .s_axi_awvalid                  (       S00_axi_awvalid                 ),
    .s_axi_awready                  (       S00_axi_awready                 ),
    //WRITE DATA CHANNEL
    .s_axi_wid                      (       S00_axi_wid                     ),
    .s_axi_wdata                    (       S00_axi_wdata                   ),
    .s_axi_wstrb                    (       S00_axi_wstrb                   ),
    .s_axi_wlast                    (       S00_axi_wlast                   ),
    .s_axi_wuser                    (       S00_axi_wuser                   ),
    .s_axi_wvalid                   (       S00_axi_wvalid                  ),
    .s_axi_wready                   (       S00_axi_wready                  ),
    //WRITE RESPONCE CHANNEL
    .s_axi_bid                      (       S00_axi_bid                     ),
    .s_axi_bresp                    (       S00_axi_bresp                   ),
    .s_axi_buser                    (       S00_axi_buser                   ),
    .s_axi_bvalid                   (       S00_axi_bvalid                  ),
    .s_axi_bready                   (       S00_axi_bready                  ),
    //READ ADDR CHANNEL
    .s_axi_arid                     (       S00_axi_arid                    ),
    .s_axi_araddr                   (       S00_axi_araddr                  ),
    .s_axi_arlen                    (       S00_axi_arlen                   ),
    .s_axi_arsize                   (       S00_axi_arsize                  ),
    .s_axi_arburst                  (       S00_axi_arburst                 ),
    .s_axi_arlock                   (       S00_axi_arlock                  ),
    .s_axi_arcache                  (       S00_axi_arcache                 ),
    .s_axi_arprot                   (       S00_axi_arprot                  ),
    .s_axi_arqos                    (       S00_axi_arqos                   ),
    .s_axi_arregion                 (       S00_axi_arregion                ),
    .s_axi_aruser                   (       S00_axi_aruser                  ),
    .s_axi_arvalid                  (       S00_axi_arvalid                 ),
    .s_axi_arready                  (       S00_axi_arready                 ),
    //READ DATA CHANNEL 
    .s_axi_rid                      (       S00_axi_rid                     ),
    .s_axi_rdata                    (       S00_axi_rdata                   ),
    .s_axi_rresp                    (       S00_axi_rresp                   ),
    .s_axi_rlast                    (       S00_axi_rlast                   ),
    .s_axi_ruser                    (       S00_axi_ruser                   ),
    .s_axi_rvalid                   (       S00_axi_rvalid                  ),
    .s_axi_rready                   (       S00_axi_rready                  )
);

motor_top motor_top_hp_m1(   
    .sys_clk_i                      (       sys_clk_i                       ), 
    .sys_rst_n_i                    (       sys_rst_n_i                     ), 
    .pwm_clk_200M_i                 (       pwm_clk_200M_i                  ),
    //三相电流输入
    .adc_convert_req_o              (       m1_adc_convert_req              ),
    .adc_convert_ack_i              (       adc_convert_ack_i               ),
    .adc_offset_finish_i            (       adc_offset_finish_i             ),
    .Ia_i                           (       m1_ib_i                         ),
    .Ib_i                           (       m1_ia_i                         ),
    .Ic_i                           (       m1_ic_i                         ),
    //as5047p spi 接口
    .as5047p_spi_ss_pin_o           (       m1_as5047p_spi_ss_pin_o         ),     
    .as5047p_spi_sck_pin_o          (       m1_as5047p_spi_sck_pin_o        ),    
    .as5047p_spi_mosi_pin_o         (       m1_as5047p_spi_mosi_pin_o       ),   
    .as5047p_spi_miso_pin_i         (       m1_as5047p_spi_miso_pin_i       ),
    //as5047p ABZ 接口
    .as5047p_A_pin_i                (                                       ),
    .as5047p_B_pin_i                (                                       ),
    .as5047p_I_pin_i                (                                       ),
    //电机UVW引脚输出
    .svpwm_u_pin_o                  (       m1_svpwm_u_pin_o                ),
    .svpwm_v_pin_o                  (       m1_svpwm_v_pin_o                ),
    .svpwm_w_pin_o                  (       m1_svpwm_w_pin_o                ),
    .svpwm_un_pin_o                 (       m1_svpwm_un_pin_o               ),
    .svpwm_vn_pin_o                 (       m1_svpwm_vn_pin_o               ),
    .svpwm_wn_pin_o                 (       m1_svpwm_wn_pin_o               ),

     //AXI4_FULL SLAVE
    //WRTIE ADDR CHANNEL
    .s_axi_awid                     (       S01_axi_awid                    ),
    .s_axi_awaddr                   (       S01_axi_awaddr                  ),
    .s_axi_awlen                    (       S01_axi_awlen                   ),
    .s_axi_awsize                   (       S01_axi_awsize                  ),
    .s_axi_awburst                  (       S01_axi_awburst                 ),
    .s_axi_awlock                   (       S01_axi_awlock                  ),
    .s_axi_awcache                  (       S01_axi_awcache                 ),
    .s_axi_awprot                   (       S01_axi_awprot                  ),
    .s_axi_awqos                    (       S01_axi_awqos                   ),
    .s_axi_awregion                 (       S01_axi_awregion                ),
    .s_axi_awuser                   (       S01_axi_awuser                  ),
    .s_axi_awvalid                  (       S01_axi_awvalid                 ),
    .s_axi_awready                  (       S01_axi_awready                 ),
    //WRITE DATA CHANNEL
    .s_axi_wid                      (       S01_axi_wid                     ),
    .s_axi_wdata                    (       S01_axi_wdata                   ),
    .s_axi_wstrb                    (       S01_axi_wstrb                   ),
    .s_axi_wlast                    (       S01_axi_wlast                   ),
    .s_axi_wuser                    (       S01_axi_wuser                   ),
    .s_axi_wvalid                   (       S01_axi_wvalid                  ),
    .s_axi_wready                   (       S01_axi_wready                  ),
    //WRITE RESPONCE CHANNEL
    .s_axi_bid                      (       S01_axi_bid                     ),
    .s_axi_bresp                    (       S01_axi_bresp                   ),
    .s_axi_buser                    (       S01_axi_buser                   ),
    .s_axi_bvalid                   (       S01_axi_bvalid                  ),
    .s_axi_bready                   (       S01_axi_bready                  ),
    //READ ADDR CHANNEL
    .s_axi_arid                     (       S01_axi_arid                    ),
    .s_axi_araddr                   (       S01_axi_araddr                  ),
    .s_axi_arlen                    (       S01_axi_arlen                   ),
    .s_axi_arsize                   (       S01_axi_arsize                  ),
    .s_axi_arburst                  (       S01_axi_arburst                 ),
    .s_axi_arlock                   (       S01_axi_arlock                  ),
    .s_axi_arcache                  (       S01_axi_arcache                 ),
    .s_axi_arprot                   (       S01_axi_arprot                  ),
    .s_axi_arqos                    (       S01_axi_arqos                   ),
    .s_axi_arregion                 (       S01_axi_arregion                ),
    .s_axi_aruser                   (       S01_axi_aruser                  ),
    .s_axi_arvalid                  (       S01_axi_arvalid                 ),
    .s_axi_arready                  (       S01_axi_arready                 ),
    //READ DATA CHANNEL 
    .s_axi_rid                      (       S01_axi_rid                     ),
    .s_axi_rdata                    (       S01_axi_rdata                   ),
    .s_axi_rresp                    (       S01_axi_rresp                   ),
    .s_axi_rlast                    (       S01_axi_rlast                   ),
    .s_axi_ruser                    (       S01_axi_ruser                   ),
    .s_axi_rvalid                   (       S01_axi_rvalid                  ),
    .s_axi_rready                   (       S01_axi_rready                  )
);

motor_top motor_top_hp_m2(   
    .sys_clk_i                      (       sys_clk_i                       ), 
    .sys_rst_n_i                    (       sys_rst_n_i                     ), 
    .pwm_clk_200M_i                 (       pwm_clk_200M_i                  ), 
    //三相电流输入
    .adc_convert_req_o              (       m2_adc_convert_req              ),
    .adc_convert_ack_i              (       adc_convert_ack_i               ),
    .adc_offset_finish_i            (       adc_offset_finish_i             ),
    .Ia_i                           (       m2_ib_i                         ),
    .Ib_i                           (       m2_ia_i                         ),
    .Ic_i                           (       m2_ic_i                         ),
    //as5047p spi 接口
    .as5047p_spi_ss_pin_o           (       m2_as5047p_spi_ss_pin_o         ),     
    .as5047p_spi_sck_pin_o          (       m2_as5047p_spi_sck_pin_o        ),    
    .as5047p_spi_mosi_pin_o         (       m2_as5047p_spi_mosi_pin_o       ),   
    .as5047p_spi_miso_pin_i         (       m2_as5047p_spi_miso_pin_i       ),
    //as5047p ABZ 接口
    .as5047p_A_pin_i                (                                       ),
    .as5047p_B_pin_i                (                                       ),
    .as5047p_I_pin_i                (                                       ),
    //电机UVW引脚输出
    .svpwm_u_pin_o                  (       m2_svpwm_u_pin_o                ),
    .svpwm_v_pin_o                  (       m2_svpwm_v_pin_o                ),
    .svpwm_w_pin_o                  (       m2_svpwm_w_pin_o                ),
    .svpwm_un_pin_o                 (       m2_svpwm_un_pin_o               ),
    .svpwm_vn_pin_o                 (       m2_svpwm_vn_pin_o               ),
    .svpwm_wn_pin_o                 (       m2_svpwm_wn_pin_o               ),

     //AXI4_FULL SLAVE
    //WRTIE ADDR CHANNEL
    .s_axi_awid                     (       S02_axi_awid                    ),
    .s_axi_awaddr                   (       S02_axi_awaddr                  ),
    .s_axi_awlen                    (       S02_axi_awlen                   ),
    .s_axi_awsize                   (       S02_axi_awsize                  ),
    .s_axi_awburst                  (       S02_axi_awburst                 ),
    .s_axi_awlock                   (       S02_axi_awlock                  ),
    .s_axi_awcache                  (       S02_axi_awcache                 ),
    .s_axi_awprot                   (       S02_axi_awprot                  ),
    .s_axi_awqos                    (       S02_axi_awqos                   ),
    .s_axi_awregion                 (       S02_axi_awregion                ),
    .s_axi_awuser                   (       S02_axi_awuser                  ),
    .s_axi_awvalid                  (       S02_axi_awvalid                 ),
    .s_axi_awready                  (       S02_axi_awready                 ),
    //WRITE DATA CHANNEL
    .s_axi_wid                      (       S02_axi_wid                     ),
    .s_axi_wdata                    (       S02_axi_wdata                   ),
    .s_axi_wstrb                    (       S02_axi_wstrb                   ),
    .s_axi_wlast                    (       S02_axi_wlast                   ),
    .s_axi_wuser                    (       S02_axi_wuser                   ),
    .s_axi_wvalid                   (       S02_axi_wvalid                  ),
    .s_axi_wready                   (       S02_axi_wready                  ),
    //WRITE RESPONCE CHANNEL
    .s_axi_bid                      (       S02_axi_bid                     ),
    .s_axi_bresp                    (       S02_axi_bresp                   ),
    .s_axi_buser                    (       S02_axi_buser                   ),
    .s_axi_bvalid                   (       S02_axi_bvalid                  ),
    .s_axi_bready                   (       S02_axi_bready                  ),
    //READ ADDR CHANNEL
    .s_axi_arid                     (       S02_axi_arid                    ),
    .s_axi_araddr                   (       S02_axi_araddr                  ),
    .s_axi_arlen                    (       S02_axi_arlen                   ),
    .s_axi_arsize                   (       S02_axi_arsize                  ),
    .s_axi_arburst                  (       S02_axi_arburst                 ),
    .s_axi_arlock                   (       S02_axi_arlock                  ),
    .s_axi_arcache                  (       S02_axi_arcache                 ),
    .s_axi_arprot                   (       S02_axi_arprot                  ),
    .s_axi_arqos                    (       S02_axi_arqos                   ),
    .s_axi_arregion                 (       S02_axi_arregion                ),
    .s_axi_aruser                   (       S02_axi_aruser                  ),
    .s_axi_arvalid                  (       S02_axi_arvalid                 ),
    .s_axi_arready                  (       S02_axi_arready                 ),
    //READ DATA CHANNEL 
    .s_axi_rid                      (       S02_axi_rid                     ),
    .s_axi_rdata                    (       S02_axi_rdata                   ),
    .s_axi_rresp                    (       S02_axi_rresp                   ),
    .s_axi_rlast                    (       S02_axi_rlast                   ),
    .s_axi_ruser                    (       S02_axi_ruser                   ),
    .s_axi_rvalid                   (       S02_axi_rvalid                  ),
    .s_axi_rready                   (       S02_axi_rready                  )
);

motor_top motor_top_hp_m3(   
    .sys_clk_i                      (       sys_clk_i                       ), 
    .sys_rst_n_i                    (       sys_rst_n_i                     ), 
    .pwm_clk_200M_i                 (       pwm_clk_200M_i                  ), 
    //三相电流输入
    .adc_convert_req_o              (       m3_adc_convert_req              ),
    .adc_convert_ack_i              (       adc_convert_ack_i               ),
    .adc_offset_finish_i            (       adc_offset_finish_i             ),
    .Ia_i                           (       m3_ib_i                         ),
    .Ib_i                           (       m3_ia_i                         ),
    .Ic_i                           (       m3_ic_i                         ),
    //as5047p spi 接口
    .as5047p_spi_ss_pin_o           (       m3_as5047p_spi_ss_pin_o         ),     
    .as5047p_spi_sck_pin_o          (       m3_as5047p_spi_sck_pin_o        ),    
    .as5047p_spi_mosi_pin_o         (       m3_as5047p_spi_mosi_pin_o       ),   
    .as5047p_spi_miso_pin_i         (       m3_as5047p_spi_miso_pin_i       ),
    //as5047p ABZ 接口
    .as5047p_A_pin_i                (                                       ),
    .as5047p_B_pin_i                (                                       ),
    .as5047p_I_pin_i                (                                       ),
    //电机UVW引脚输出
    .svpwm_u_pin_o                  (       m3_svpwm_u_pin_o                ),
    .svpwm_v_pin_o                  (       m3_svpwm_v_pin_o                ),
    .svpwm_w_pin_o                  (       m3_svpwm_w_pin_o                ),
    .svpwm_un_pin_o                 (       m3_svpwm_un_pin_o               ),
    .svpwm_vn_pin_o                 (       m3_svpwm_vn_pin_o               ),
    .svpwm_wn_pin_o                 (       m3_svpwm_wn_pin_o               ),

     //AXI4_FULL SLAVE
    //WRTIE ADDR CHANNEL
    .s_axi_awid                     (       S03_axi_awid                    ),
    .s_axi_awaddr                   (       S03_axi_awaddr                  ),
    .s_axi_awlen                    (       S03_axi_awlen                   ),
    .s_axi_awsize                   (       S03_axi_awsize                  ),
    .s_axi_awburst                  (       S03_axi_awburst                 ),
    .s_axi_awlock                   (       S03_axi_awlock                  ),
    .s_axi_awcache                  (       S03_axi_awcache                 ),
    .s_axi_awprot                   (       S03_axi_awprot                  ),
    .s_axi_awqos                    (       S03_axi_awqos                   ),
    .s_axi_awregion                 (       S03_axi_awregion                ),
    .s_axi_awuser                   (       S03_axi_awuser                  ),
    .s_axi_awvalid                  (       S03_axi_awvalid                 ),
    .s_axi_awready                  (       S03_axi_awready                 ),
    //WRITE DATA CHANNEL
    .s_axi_wid                      (       S03_axi_wid                     ),
    .s_axi_wdata                    (       S03_axi_wdata                   ),
    .s_axi_wstrb                    (       S03_axi_wstrb                   ),
    .s_axi_wlast                    (       S03_axi_wlast                   ),
    .s_axi_wuser                    (       S03_axi_wuser                   ),
    .s_axi_wvalid                   (       S03_axi_wvalid                  ),
    .s_axi_wready                   (       S03_axi_wready                  ),
    //WRITE RESPONCE CHANNEL
    .s_axi_bid                      (       S03_axi_bid                     ),
    .s_axi_bresp                    (       S03_axi_bresp                   ),
    .s_axi_buser                    (       S03_axi_buser                   ),
    .s_axi_bvalid                   (       S03_axi_bvalid                  ),
    .s_axi_bready                   (       S03_axi_bready                  ),
    //READ ADDR CHANNEL
    .s_axi_arid                     (       S03_axi_arid                    ),
    .s_axi_araddr                   (       S03_axi_araddr                  ),
    .s_axi_arlen                    (       S03_axi_arlen                   ),
    .s_axi_arsize                   (       S03_axi_arsize                  ),
    .s_axi_arburst                  (       S03_axi_arburst                 ),
    .s_axi_arlock                   (       S03_axi_arlock                  ),
    .s_axi_arcache                  (       S03_axi_arcache                 ),
    .s_axi_arprot                   (       S03_axi_arprot                  ),
    .s_axi_arqos                    (       S03_axi_arqos                   ),
    .s_axi_arregion                 (       S03_axi_arregion                ),
    .s_axi_aruser                   (       S03_axi_aruser                  ),
    .s_axi_arvalid                  (       S03_axi_arvalid                 ),
    .s_axi_arready                  (       S03_axi_arready                 ),
    //READ DATA CHANNEL 
    .s_axi_rid                      (       S03_axi_rid                     ),
    .s_axi_rdata                    (       S03_axi_rdata                   ),
    .s_axi_rresp                    (       S03_axi_rresp                   ),
    .s_axi_rlast                    (       S03_axi_rlast                   ),
    .s_axi_ruser                    (       S03_axi_ruser                   ),
    .s_axi_rvalid                   (       S03_axi_rvalid                  ),
    .s_axi_rready                   (       S03_axi_rready                  )
);




endmodule
