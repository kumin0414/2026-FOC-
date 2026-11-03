`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/12 21:55:05
// Design Name: 
// Module Name: motor_top
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
module motor_top(   
    input                   sys_clk_i                   ,
    input                   sys_rst_n_i                 ,
    input                   pwm_clk_200M_i              ,
    //三相电流输入
    output                  adc_convert_req_o           ,
    input                   adc_convert_ack_i           ,
    input                   adc_offset_finish_i         ,
    input signed[15:0]      Ia_i                        ,
    input signed[15:0]      Ib_i                        ,
    input signed[15:0]      Ic_i                        ,
    //as5047p spi 接口
    output                  as5047p_spi_ss_pin_o        ,     
    output                  as5047p_spi_sck_pin_o       ,    
    output                  as5047p_spi_mosi_pin_o      ,   
    input                   as5047p_spi_miso_pin_i      ,
    //as5047p ABZ 接口
    input                   as5047p_A_pin_i             ,
    input                   as5047p_B_pin_i             ,
    input                   as5047p_I_pin_i             ,
    //电机UVW引脚输出
    output                  svpwm_u_pin_o               ,
    output                  svpwm_v_pin_o               ,
    output                  svpwm_w_pin_o               ,
    output                  svpwm_un_pin_o              ,
    output                  svpwm_vn_pin_o              ,
    output                  svpwm_wn_pin_o              ,

    //AXI4_FULL SLAVE
    //WRTIE ADDR CHANNEL
    input[0:0]          s_axi_awid                      ,
    input[31:0]         s_axi_awaddr                    ,
    input[7:0]          s_axi_awlen                     ,
    input[2:0]          s_axi_awsize                    ,
    input[1:0]          s_axi_awburst                   ,
    input               s_axi_awlock                    ,
    input[3:0]          s_axi_awcache                   ,
    input[2:0]          s_axi_awprot                    ,
    input[3:0]          s_axi_awqos                     ,
    input[3:0]          s_axi_awregion                  ,
    input               s_axi_awuser                    ,
    input               s_axi_awvalid                   ,
    output              s_axi_awready                   ,
    //WRITE DATA CHANNEL
    input[0:0]          s_axi_wid                       ,
    input[31:0]         s_axi_wdata                     ,
    input[3:0]          s_axi_wstrb                     ,
    input               s_axi_wlast                     ,
    input               s_axi_wuser                     ,
    input               s_axi_wvalid                    ,
    output              s_axi_wready                    ,
    //WRITE RESPONCE CHANNEL
    output[0:0]         s_axi_bid                       ,
    output[1:0]         s_axi_bresp                     ,
    output              s_axi_buser                     ,
    output              s_axi_bvalid                    ,
    input               s_axi_bready                    ,
    //READ ADDR CHANNEL
    input[0:0]          s_axi_arid                      ,
    input[31:0]         s_axi_araddr                    ,
    input[7:0]          s_axi_arlen                     ,
    input[2:0]          s_axi_arsize                    ,
    input[1:0]          s_axi_arburst                   ,
    input               s_axi_arlock                    ,
    input[3:0]          s_axi_arcache                   ,
    input[2:0]          s_axi_arprot                    ,
    input[3:0]          s_axi_arqos                     ,
    input[3:0]          s_axi_arregion                  ,
    input               s_axi_aruser                    ,
    input               s_axi_arvalid                   ,
    output              s_axi_arready                   ,
    //READ DATA CHANNEL 
    output[0:0]         s_axi_rid                       ,
    output [31:0]       s_axi_rdata                     ,
    output[1:0]         s_axi_rresp                     ,
    output              s_axi_rlast                     ,
    output              s_axi_ruser                     ,
    output              s_axi_rvalid                    ,
    input               s_axi_rready                    
);




localparam  S_POWER_DELAY                    =   'd0;
localparam  S_ADC_CALIBRATION                =   'd1;
localparam  S_STOP                           =   'd2;        //暂停
localparam  S_CALIBRATION                    =   'd3;        //校准电机 零偏和极对数
localparam  S_WORK                           =   'd4;        //运行
localparam  S_SELFTEST                       =   'd5;        //自测模式

reg[5:0]            state , next_state              ;


wire                pwr_delay_ack                   ;
reg[31:0]           pwr_delay_cnt                   ;

wire                sleftest_en                     ;
wire[7:0]           sleftest_foc_mode               ;
wire[24:0]          selftest_angle                  ;
wire signed[24:0]   selftest_Uq                     ;     //自测模式下Uq参数
wire signed[24:0]   selftest_Ud                     ;     //自测模式下Ud参数



wire [24:0]         motor_electrical_angle          ;     //经过零偏校准后的角度

wire                calibration_en                  ;
wire                calibration_ack                 ;
wire                calibration_encoder_dir         ;
wire [24:0]         calibration_angle_offset        ;
wire [7:0]          calibration_motor_pole_pair     ;
wire [7:0]          calibration_foc_mode            ;
wire [24:0]         calibration_Open_angle          ;
wire signed[24:0]   calibration_Open_Uq             ;
wire signed[24:0]   calibration_Open_Ud             ;



reg[7:0]                foc_mode                    ;
reg[24:0]               foc_angle                   ;
reg signed[24:0]        Open_Uq                     ;
reg signed[24:0]        Open_Ud                     ;

wire                    motor_position_en           ; //电机位置检测使能
wire                    motor_position_set          ; //设置电机当前位置为初始位置        
wire [24:0]             motor_angle                 ; //电机当前角度
wire signed[31:0]       motor_speed                 ; //电机当前速度
wire signed[31:0]       motor_position              ; //电机当前位置
wire                    motor_one_circle            ; //电机运行一圈标志输出
wire [15:0]             abz_one_circle_plus         ; //电机 ABZ接口一圈的脉冲数


wire signed[31:0]       foc_Ialpha_o                ;
wire signed[31:0]       foc_Ibeta_o                 ;
wire signed[31:0]       foc_Iq_o                    ;
wire signed[31:0]       foc_Id_o                    ;


//axi参数配置
wire[7:0]               foc_mode_axi                        ;  
wire signed[24:0]       foc_open_uq                         ;
wire signed[24:0]       foc_open_ud                         ;
wire signed[15:0]       foc_Iq_pid_p                        ;
wire signed[15:0]       foc_Iq_pid_i                        ;
wire signed[15:0]       foc_Id_pid_p                        ;
wire signed[15:0]       foc_Id_pid_i                        ;
wire signed[15:0]       foc_speed_pid_p                     ;
wire signed[15:0]       foc_speed_pid_i                     ;
wire signed[15:0]       foc_position_pid_p                  ;
wire signed[15:0]       foc_position_pid_i                  ;
wire signed[24:0]       foc_Iq_aim                          ;
wire signed[24:0]       foc_Id_aim                          ;
wire signed[24:0]       foc_speed_aim                       ;
wire signed[24:0]       foc_position_aim                    ;
wire signed[31:0]       foc_position_fb_max_speed           ;
wire[7:0]               motor_calibration_type              ;
wire                    axi_motor_encoder_dir               ;      
wire [24:0]             axi_motor_angle_offset              ;      
wire [7:0]              axi_motor_pole_pair                 ;      
wire                    axi_motor_calibration_data_valid    ;      

reg                     calibration_encoder_dir_sel         ;
reg [24:0]              calibration_angle_offset_sel        ;
reg [7:0]               calibration_motor_pole_pair_sel     ;



assign motor_position_en = (  foc_mode_axi[5:0] == `FOC_MODE_POSTION ) ? 1'b1 : 1'b0;

assign pwr_delay_ack = ( pwr_delay_cnt == 'd2_000_000 ) ? 1'b1 : 1'b0;

assign calibration_en = ( state == S_CALIBRATION ) ? 1'b1 : 1'b0;
assign sleftest_en    = ( state == S_SELFTEST ) ? 1'b1 : 1'b0;


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        state <= S_POWER_DELAY;
    else
        state <= next_state;
end


always@(*) begin
    case( state )
    S_POWER_DELAY:
        if( pwr_delay_ack == 1'b1 )
            next_state <= S_STOP;
        else
            next_state <= S_POWER_DELAY;
    S_STOP:
        if( adc_offset_finish_i == 1'b0 )
            next_state <= S_STOP;
        else if(foc_mode_axi == `FOC_MODE_CALIBRATION )
            next_state <= S_CALIBRATION;
        else if( foc_mode_axi == `FOC_MODE_SELFTEST )
            next_state <= S_SELFTEST;
        else if( foc_mode_axi == `FOC_MODE_STOP )
            next_state <= S_STOP;
        else
            next_state <= S_WORK;
    S_CALIBRATION:
        if( calibration_ack == 1'b1 )
            next_state <= S_STOP;
        else
            next_state <= S_CALIBRATION; 
    S_SELFTEST:
        if( foc_mode_axi == `FOC_MODE_STOP )
            next_state <= S_STOP;
        else
            next_state <= S_SELFTEST;
    S_WORK:
        if( foc_mode_axi == `FOC_MODE_STOP )
            next_state <= S_STOP;
        else
            next_state <= S_WORK;
    default: next_state <= S_ADC_CALIBRATION;
    endcase
end


always@(posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        pwr_delay_cnt <= 'd0;
    else if( state == S_POWER_DELAY )
        pwr_delay_cnt <=  pwr_delay_cnt + 1'b1;
    else
        pwr_delay_cnt <= pwr_delay_cnt;

end

always@( posedge sys_clk_i  ) begin
    if( state == S_CALIBRATION ) begin
        foc_mode <= calibration_foc_mode;
        Open_Uq  <= calibration_Open_Uq;
        Open_Ud  <= calibration_Open_Ud;
    end
    else if( state == S_SELFTEST ) begin
        foc_mode <= sleftest_foc_mode;
        Open_Uq  <= selftest_Uq;
        Open_Ud  <= selftest_Ud;
    end
    else if( state == S_WORK ) begin
        foc_mode <= foc_mode_axi;
        Open_Uq  <= foc_open_uq[24:0];
        Open_Ud  <= foc_open_ud[24:0];
    end 
    else begin
        foc_mode <= `FOC_MODE_STOP;
        Open_Uq  <= foc_open_uq[24:0];
        Open_Ud  <= foc_open_ud[24:0];
    end
end

always@( posedge sys_clk_i ) begin
    if( state == S_CALIBRATION )
        foc_angle <= calibration_Open_angle;
    else if( state == S_SELFTEST )
        foc_angle <= selftest_angle;
    else
        foc_angle <= motor_electrical_angle;
end

       
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        calibration_encoder_dir_sel     <= 'd0;
        calibration_angle_offset_sel    <= 'd0;
        calibration_motor_pole_pair_sel <= 'd1;
    end
    else if( calibration_ack == 1'b1 ) begin
        calibration_encoder_dir_sel     <= calibration_encoder_dir    ;
        calibration_angle_offset_sel    <= calibration_angle_offset   ;
        calibration_motor_pole_pair_sel <= calibration_motor_pole_pair;
    end
    else if( axi_motor_calibration_data_valid == 1'b1 ) begin
        calibration_encoder_dir_sel     <= axi_motor_encoder_dir        ;         
        calibration_angle_offset_sel    <= axi_motor_angle_offset       ;         
        calibration_motor_pole_pair_sel <= axi_motor_pole_pair          ;
    end
    else;
end
//自测模块--用于检测电机硬件是否OK
motor_selftest motor_selftest_hp(
    .sys_clk_i                  (   sys_clk_i                   ),
    .sys_rst_n_i                (   sys_rst_n_i                 ),

    .sleftest_en_i              (   sleftest_en                 ),

    .foc_mode_o                 (   sleftest_foc_mode           ),
    .selftest_angle_o           (   selftest_angle              ),
    .selftest_Uq_o              (   selftest_Uq                 ),     //自测模式下Uq参数
    .selftest_Ud_o              (   selftest_Ud                 )      //自测模式下Ud参数
);

//将机械角度转为电角度 并归一化
mechanical2electrical_angle mechanical2electrical_angle_hp(
    .sys_clk_i                  (   sys_clk_i                   ),
    .sys_rst_n_i                (   sys_rst_n_i                 ),
    .encoder_dir_i              (   calibration_encoder_dir_sel ),
    .encoder_angle_i            (   motor_angle                 ),
    .encoder_angle_offset_i     (   calibration_angle_offset_sel    ),
    .motor_pole_pair_i          (   calibration_motor_pole_pair_sel ),

    .motor_angle_o              (   motor_electrical_angle      )     
);

//校准模块
motor_calibration motor_calibration_hp(
    .sys_clk_i                  (   sys_clk_i                   ),
    .sys_rst_n_i                (   sys_rst_n_i                 ),

    .calibration_en_i           (   calibration_en              ),
    .calibration_ack_o          (   calibration_ack             ),

    .encoder_one_circle_i       (   motor_one_circle            ),
    .encoder_angle_i            (   motor_angle                 ),

    .encoder_dir_o              (   calibration_encoder_dir     ),
    .encoder_angle_offset_o     (   calibration_angle_offset    ),
    .motor_pole_pair_o          (   calibration_motor_pole_pair ),

    .foc_mode_o                 (   calibration_foc_mode        ),
    .Open_angle_o               (   calibration_Open_angle      ),
    .Open_Uq_o                  (   calibration_Open_Uq         ),     //开环模式下Uq参数
    .Open_Ud_o                  (   calibration_Open_Ud         )      //开环模式下Ud参数
);

//FOC算法模块
FOC FOC_hp(
    .sys_clk_i                  (   sys_clk_i           ),
    .sys_rst_n_i                (   sys_rst_n_i         ),

    .pwm_clk_200M_i             (   pwm_clk_200M_i      ),

    .foc_mode_i                 (   foc_mode            ),       //FOC运行模式
    .Open_Uq_i                  (   Open_Uq             ),       //开环模式下Uq参数输入
    .Open_Ud_i                  (   Open_Ud             ),       //开环模式下Ud参数输入

    .desired_position_i         (   foc_position_aim    ),
    .desired_speed_i            (   foc_speed_aim       ),
    .desired_Iq_i               (   foc_Iq_aim          ),
    .desired_Id_i               (   foc_Id_aim          ),
    //三环控制参数
    .Torque_Iq_PID_P_i          (   foc_Iq_pid_p        ),
    .Torque_Iq_PID_I_i          (   foc_Iq_pid_i        ),
    .Torque_Id_PID_P_i          (   foc_Id_pid_p        ),
    .Torque_Id_PID_I_i          (   foc_Id_pid_i        ),
    .Speed_PID_P_i              (   foc_speed_pid_p     ),
    .Speed_PID_I_i              (   foc_speed_pid_i     ),
    .Position_PID_P_i           (   foc_position_pid_p  ),
    .Position_PID_I_i           (   foc_position_pid_i  ),
    //电机参数输出
    .foc_Ialpha_o               (   foc_Ialpha_o        ),
    .foc_Ibeta_o                (   foc_Ibeta_o         ),
    .foc_Iq_o                   (   foc_Iq_o            ),
    .foc_Id_o                   (   foc_Id_o            ),
    .foc_time_u_o               (   foc_time_u_o        ),
    .foc_time_v_o               (   foc_time_v_o        ),
    .foc_time_w_o               (   foc_time_w_o        ),
    //外部传感器数据输入
    .foc_angle_i                (   foc_angle           ),
    .foc_speed_i                (   motor_speed         ),
    .foc_position_i             (   motor_position      ),
    .Ia_i                       (   Ia_i                ),
    .Ib_i                       (   Ib_i                ),
    .Ic_i                       (   Ic_i                ),
    .senser_tirgger_o           (   adc_convert_req_o   ),   //传感器触发信号
    .senser_ack_i               (   adc_convert_ack_i   ),   //传感器转换完成
    //无刷电机控制管脚
    .svpwm_u_pin_o              (   svpwm_u_pin_o       ),
    .svpwm_v_pin_o              (   svpwm_v_pin_o       ),
    .svpwm_w_pin_o              (   svpwm_w_pin_o       ),
    .svpwm_un_pin_o             (   svpwm_un_pin_o      ),
    .svpwm_vn_pin_o             (   svpwm_vn_pin_o      ),
    .svpwm_wn_pin_o             (   svpwm_wn_pin_o      )
);

//as5047磁编码器
AS5047P_Top AS5047P_Top_hp(
    .sys_clk_i                   (      sys_clk_i                   ),
    .sys_rst_n_i                 (      sys_rst_n_i                 ),

    //角度 位置 速度 信息输出
    .motor_position_en_i         (      motor_position_en           ), //电机位置检测使能
    .motor_position_set_i        (      motor_position_set          ), //设置电机当前位置为初始位置        
    .motor_angle_o               (      motor_angle                 ), //电机当前角度
    .motor_speed_o               (      motor_speed                 ), //电机当前速度
    .motor_position_o            (      motor_position              ), //电机当前位置
    .motor_one_circle_o          (      motor_one_circle            ), //电机运行一圈标志输出
    .abz_one_circle_plus_o       (      abz_one_circle_plus         ), //电机 ABZ接口一圈的脉冲数
    //spi 接口
    .as5047p_spi_csn_p_o         (      as5047p_spi_ss_pin_o        ),
    .as5047p_spi_sclk_p_o        (      as5047p_spi_sck_pin_o       ),   // max 10Mhz
    .as5047p_spi_miso_p_i        (      as5047p_spi_miso_pin_i      ),
    .as5047p_spi_mosi_p_o        (      as5047p_spi_mosi_pin_o      ),
    //ABZ 接口
    .as5047p_A_p_i               (      as5047p_A_pin_i             ),  
    .as5047p_B_p_i               (      as5047p_B_pin_i             ),
    .as5047p_I_p_i               (      as5047p_I_pin_i             )
);

axi_motor_foc_cfg axi_motor_foc_cfg_hp(
    .sys_clk_i                   (      sys_clk_i                   ),
    .sys_rst_n_i                 (      sys_rst_n_i                 ),
    //input
    .Ia_i                        (      Ia_i                        ),
    .Ib_i                        (      Ib_i                        ),
    .Ic_i                        (      Ic_i                        ),
    .Ialpha_i                    (      foc_Ialpha_o                ),
    .Ibeta_i                     (      foc_Ibeta_o                 ),
    .Iq_i                        (      foc_Iq_o                    ),
    .Id_i                        (      foc_Id_o                    ),
    .motor_angle_i               (      motor_angle                 ),
    .motor_speed_i               (      motor_speed                 ),
    .motor_position_i            (      motor_position              ),
    .motor_encoder_dir_i         (      calibration_encoder_dir_sel     ),
    .motor_angle_offset_i        (      calibration_angle_offset_sel    ),
    .motor_pole_pair_i          (      calibration_motor_pole_pair_sel ),
    //output
    .foc_mode_o                  (      foc_mode_axi                ),
    .foc_open_uq_o               (      foc_open_uq                 ),
    .foc_open_ud_o               (      foc_open_ud                 ),
    .foc_Iq_pid_p_o              (      foc_Iq_pid_p                ),
    .foc_Iq_pid_i_o              (      foc_Iq_pid_i                ),
    .foc_Id_pid_p_o              (      foc_Id_pid_p                ),
    .foc_Id_pid_i_o              (      foc_Id_pid_i                ),
    .foc_speed_pid_p_o           (      foc_speed_pid_p             ),
    .foc_speed_pid_i_o           (      foc_speed_pid_i             ),
    .foc_position_pid_p_o        (      foc_position_pid_p          ),
    .foc_position_pid_i_o        (      foc_position_pid_i          ),
    .foc_Iq_aim_o                (      foc_Iq_aim                  ),
    .foc_Id_aim_o                (      foc_Id_aim                  ),
    .foc_speed_aim_o             (      foc_speed_aim               ),
    .foc_position_aim_o          (      foc_position_aim            ),
    .foc_position_fb_max_speed_o (      foc_position_fb_max_speed   ),
    .motor_calibration_type_o    (      motor_calibration_type      ),
    .motor_position_set_o        (      motor_position_set          ),
       
    .motor_encoder_dir_o            (   axi_motor_encoder_dir               ),
    .motor_angle_offset_o           (   axi_motor_angle_offset              ),
    .motor_pole_pair_o              (   axi_motor_pole_pair                 ),
    .motor_calibration_data_valid_o (   axi_motor_calibration_data_valid    ),
    //AXI4_FULL SLAVE
    //WRTIE ADDR CHANNEL
    .s_axi_awid                     (       s_axi_awid                      ),
    .s_axi_awaddr                   (       s_axi_awaddr                    ),
    .s_axi_awlen                    (       s_axi_awlen                     ),
    .s_axi_awsize                   (       s_axi_awsize                    ),
    .s_axi_awburst                  (       s_axi_awburst                   ),
    .s_axi_awlock                   (       s_axi_awlock                    ),
    .s_axi_awcache                  (       s_axi_awcache                   ),
    .s_axi_awprot                   (       s_axi_awprot                    ),
    .s_axi_awqos                    (       s_axi_awqos                     ),
    .s_axi_awregion                 (       s_axi_awregion                  ),
    .s_axi_awuser                   (       s_axi_awuser                    ),
    .s_axi_awvalid                  (       s_axi_awvalid                   ),
    .s_axi_awready                  (       s_axi_awready                   ),
    //WRITE DATA CHANNEL
    .s_axi_wid                      (       s_axi_wid                       ),
    .s_axi_wdata                    (       s_axi_wdata                     ),
    .s_axi_wstrb                    (       s_axi_wstrb                     ),
    .s_axi_wlast                    (       s_axi_wlast                     ),
    .s_axi_wuser                    (       s_axi_wuser                     ),
    .s_axi_wvalid                   (       s_axi_wvalid                    ),
    .s_axi_wready                   (       s_axi_wready                    ),
    //WRITE RESPONCE CHANNEL
    .s_axi_bid                      (       s_axi_bid                       ),
    .s_axi_bresp                    (       s_axi_bresp                     ),
    .s_axi_buser                    (       s_axi_buser                     ),
    .s_axi_bvalid                   (       s_axi_bvalid                    ),
    .s_axi_bready                   (       s_axi_bready                    ),
    //READ ADDR CHANNEL
    .s_axi_arid                     (       s_axi_arid                      ),
    .s_axi_araddr                   (       s_axi_araddr                    ),
    .s_axi_arlen                    (       s_axi_arlen                     ),
    .s_axi_arsize                   (       s_axi_arsize                    ),
    .s_axi_arburst                  (       s_axi_arburst                   ),
    .s_axi_arlock                   (       s_axi_arlock                    ),
    .s_axi_arcache                  (       s_axi_arcache                   ),
    .s_axi_arprot                   (       s_axi_arprot                    ),
    .s_axi_arqos                    (       s_axi_arqos                     ),
    .s_axi_arregion                 (       s_axi_arregion                  ),
    .s_axi_aruser                   (       s_axi_aruser                    ),
    .s_axi_arvalid                  (       s_axi_arvalid                   ),
    .s_axi_arready                  (       s_axi_arready                   ),
    //READ DATA CHANNEL 
    .s_axi_rid                      (       s_axi_rid                       ),
    .s_axi_rdata                    (       s_axi_rdata                     ),
    .s_axi_rresp                    (       s_axi_rresp                     ),
    .s_axi_rlast                    (       s_axi_rlast                     ),
    .s_axi_ruser                    (       s_axi_ruser                     ),
    .s_axi_rvalid                   (       s_axi_rvalid                    ),
    .s_axi_rready                   (       s_axi_rready                    )
);

endmodule
