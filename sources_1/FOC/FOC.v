`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/24 21:20:54
// Design Name: 
// Module Name: FOC
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

module FOC(
    input                   sys_clk_i           ,
    input                   sys_rst_n_i         ,

    input                   pwm_clk_200M_i      ,

    input [7:0]             foc_mode_i          ,       //FOC运行模式
    input signed[24:0]      Open_Uq_i           ,       //开环模式下Uq参数输入
    input signed[24:0]      Open_Ud_i           ,       //开环模式下Ud参数输入

    input signed[31:0]      desired_position_i  ,
    input signed[31:0]      desired_speed_i     ,
    input signed[31:0]      desired_Iq_i        ,
    input signed[31:0]      desired_Id_i        ,
    //三环控制参数
    input signed[15:0]      Torque_Iq_PID_P_i   ,
    input signed[15:0]      Torque_Iq_PID_I_i   ,
    input signed[15:0]      Torque_Id_PID_P_i   ,
    input signed[15:0]      Torque_Id_PID_I_i   ,
    input signed[15:0]      Speed_PID_P_i       ,
    input signed[15:0]      Speed_PID_I_i       ,
    input signed[15:0]      Position_PID_P_i    ,
    input signed[15:0]      Position_PID_I_i    ,
    //电机参数输出
    output signed[31:0]     foc_Ialpha_o        ,
    output signed[31:0]     foc_Ibeta_o         ,
    output signed[31:0]     foc_Iq_o            ,
    output signed[31:0]     foc_Id_o            ,
    output[31:0]            foc_time_u_o        ,
    output[31:0]            foc_time_v_o        ,
    output[31:0]            foc_time_w_o        ,
    //外部传感器数据输入
    input[24:0]             foc_angle_i         ,
    input signed[31:0]      foc_speed_i         ,
    input signed[31:0]      foc_position_i      ,
    input signed[15:0]      Ia_i                ,
    input signed[15:0]      Ib_i                ,
    input signed[15:0]      Ic_i                ,
    output                  senser_tirgger_o    ,   //传感器触发信号
    input                   senser_ack_i        ,   //传感器转换完成
    //无刷电机控制管脚
    output                  svpwm_u_pin_o       ,
    output                  svpwm_v_pin_o       ,
    output                  svpwm_w_pin_o       ,
    output                  svpwm_un_pin_o      ,
    output                  svpwm_vn_pin_o      ,
    output                  svpwm_wn_pin_o      
);



localparam  S_IDLE          =   'd0     ;            //空闲状态
localparam  S_CORDIC        =   'd1     ;            //计数sin/cos角度值
localparam  S_WIAT_IaIbIc   =   'd2     ;            //等待电流计算完成
localparam  S_TRANSFER1     =   'd3     ;            //计算clark -  park  变换
localparam  S_LOOP_ADJUST   =   'd4     ;            //环路调节输出 Uq 和 Ud 值 
localparam  S_TRANSFER2     =   'd5     ;            //计算iclark - ipark 变换
localparam  S_GEN_SVPWM     =   'd6     ;            //生成svpwm波
localparam  S_UPDATE_PWM    =   'd7     ;            //更新至PWM IO

reg[5:0] state;
reg[5:0] next_state;


wire signed[24:0]   Uq                  ;
wire signed[24:0]   Ud                  ;
wire signed[24:0]   Ualpha              ;
wire signed[24:0]   Ubeta               ;
wire signed[24:0]   Ialpha              ;
wire signed[24:0]   Ibeta               ;
wire signed[24:0]   Ua                  ;
wire signed[24:0]   Ub                  ;
wire signed[24:0]   Uc                  ;
wire signed[24:0]   Iq                  ;
wire signed[24:0]   Id                  ;


reg                 timer_wr_type       ;
reg                 timer_write_en      ;
reg[15:0]           timer_write_data_U  ;
reg[15:0]           timer_write_data_V  ;
reg[15:0]           timer_write_data_W  ;
wire                timer_trig          ;


reg[24:0]           foc_angle_lock      ;
wire                cordic_req          ;
wire                cordic_ack          ;

wire signed[17:0]   cordic_sin          ;
wire signed[17:0]   cordic_cos          ;

wire                clark_park_en       ;
wire                clark_park_ack      ;

wire                loop_adjust_en       ;
wire                loop_adjust_ack      ;          

wire                iclark_ipark_en     ;
wire                iclark_ipark_ack    ;

wire                svpwm_en            ;
wire                svpwm_ack           ;


wire[15:0]           pwm_ta             ;
wire[15:0]           pwm_tb             ;
wire[15:0]           pwm_tc             ;

assign senser_tirgger_o = timer_trig;


assign foc_Ialpha_o     = Ialpha        ;
assign foc_Ibeta_o      = Ibeta         ;
assign foc_Iq_o         = Iq            ;
assign foc_Id_o         = Id            ;
assign foc_time_u_o     = {16'd0,pwm_ta};
assign foc_time_v_o     = {16'd0,pwm_tb};
assign foc_time_w_o     = {16'd0,pwm_tc};


assign cordic_req       = ( state == S_CORDIC    ) ? 1'b1 : 1'b0;
assign clark_park_en    = ( state == S_TRANSFER1 ) ? 1'b1 : 1'b0;
assign loop_adjust_en   = ( state == S_LOOP_ADJUST) ? 1'b1 : 1'b0;
assign iclark_ipark_en  = ( state == S_TRANSFER2 ) ? 1'b1 : 1'b0;
assign svpwm_en         = ( state == S_GEN_SVPWM ) ? 1'b1 : 1'b0; 

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        state <= S_IDLE;
    else
        state <= next_state;
end
 
always@(*) begin
    case (state)
        S_IDLE:
            if( foc_mode_i == `FOC_MODE_STOP )
                next_state <= S_IDLE;
            else if( timer_trig == 1'b1 ) 
                next_state <= S_CORDIC;
            else
                next_state <= S_IDLE;
        S_CORDIC:
            if( cordic_ack == 1'b1 )
                next_state <= S_WIAT_IaIbIc;
            else
                next_state <= S_CORDIC;
        S_WIAT_IaIbIc:
            if( senser_ack_i == 1'b1 )
                next_state <= S_TRANSFER1;
            else
                next_state <= S_WIAT_IaIbIc;
        S_TRANSFER1:
            if( clark_park_ack == 1'b1 )
                next_state <= S_LOOP_ADJUST;
            else
                next_state <= S_TRANSFER1;
        S_LOOP_ADJUST:
            if( loop_adjust_ack == 1'b1 )
                next_state <= S_TRANSFER2;
            else
                next_state <= S_LOOP_ADJUST;
        S_TRANSFER2:
            if( iclark_ipark_ack == 1'b1 )
                next_state <= S_GEN_SVPWM;
            else
                next_state <= S_TRANSFER2;
        S_GEN_SVPWM:
            if( svpwm_ack == 1'b1 )
                next_state <= S_UPDATE_PWM;
            else
                next_state <= S_GEN_SVPWM;
        S_UPDATE_PWM:
            next_state <= S_IDLE;
        default:next_state <= S_IDLE; 
    endcase
end

always@(posedge sys_clk_i) begin
    if( state == S_IDLE && timer_trig == 1'b1 )
        foc_angle_lock <= foc_angle_i;
    else
        foc_angle_lock <= foc_angle_lock;
end

always@( posedge sys_clk_i ) begin
    if( state == S_UPDATE_PWM ) begin
        timer_wr_type <= 1'b1;
        timer_write_en <= 1'b1;
        timer_write_data_U <= pwm_ta;
        timer_write_data_V <= pwm_tb;
        timer_write_data_W <= pwm_tc;
    end
    else if( foc_mode_i == `FOC_MODE_STOP ) begin
        timer_wr_type <= 1'b1;
        timer_write_en <= 1'b1;
        timer_write_data_U <= 16'd0;
        timer_write_data_V <= 16'd0;
        timer_write_data_W <= 16'd0;
    end
    else begin
        timer_wr_type <= 1'b1;
        timer_write_en <= 1'b0;
        timer_write_data_U <=timer_write_data_U ;
        timer_write_data_V <=timer_write_data_V ;
        timer_write_data_W <=timer_write_data_W ;
    end
end

loop_adjust loop_adjust_hp(
    .sys_clk_i              (   sys_clk_i           ),  
    .sys_rst_n_i            (   sys_rst_n_i         ),


    .loop_adjust_en_i       (   loop_adjust_en      ),
    .loop_adjust_ack_o      (   loop_adjust_ack     ),

    .foc_mode_i             (   foc_mode_i          ),       //FOC运行模式
    .Open_Uq_i              (   Open_Uq_i           ),       //开环模式下Uq参数输入
    .Open_Ud_i              (   Open_Ud_i           ),       //开环模式下Ud参数输入
    //三环控制参数
    .Torque_Iq_PID_P_i      (   Torque_Iq_PID_P_i   ),
    .Torque_Iq_PID_I_i      (   Torque_Iq_PID_I_i   ),
    .Torque_Id_PID_P_i      (   Torque_Id_PID_P_i   ),
    .Torque_Id_PID_I_i      (   Torque_Id_PID_I_i   ),
    .Speed_PID_P_i          (   Speed_PID_P_i       ),
    .Speed_PID_I_i          (   Speed_PID_I_i       ),
    .Position_PID_P_i       (   Position_PID_P_i    ),
    .Position_PID_I_i       (   Position_PID_I_i    ),


    .desired_Iq_i           (   desired_Iq_i        ),
    .desired_Id_i           (   desired_Id_i        ),
    .desired_speed_i        (   desired_speed_i     ),
    .desired_position_i     (   desired_position_i  ),
    .actual_Iq_i            (   Iq                  ),
    .actual_Id_i            (   Id                  ),
    .actual_speed_i         (   foc_speed_i         ),
    .actual_position_i      (   foc_position_i      ),

    .uq_o                   (    Uq                 ),
    .ud_o                   (    Ud                 )
);



SVPWM #(    
    .Ts             (  `TIME_ARR                    ),
    .K              (  (3251*`TIME_ARR ) / `Udc     )    
)SVPWM_hp(
    .sys_clk_i              (   sys_clk_i           ),  
    .sys_rst_n_i            (   sys_rst_n_i         ),

    .svpwm_en_i             (   svpwm_en            ),
    .svpwm_ack_o            (   svpwm_ack           ),


    .Ualpha_i               (   Ualpha              ),
    .Ubeta_i                (   Ubeta               ),


    .pwm_ta                 (   pwm_ta              ),
    .pwm_tb                 (   pwm_tb              ),
    .pwm_tc                 (   pwm_tc              )
);


clark_park clark_park_hp(
    .sys_clk_i              (   sys_clk_i           ),  
    .sys_rst_n_i            (   sys_rst_n_i         ),

    .clark_park_en_i        (   clark_park_en       ),
    .clark_park_ack_o       (   clark_park_ack      ),

    .cordic_sin_i           (   cordic_sin          ),   
    .cordic_cos_i           (   cordic_cos          ),
    .Ia_i                   (   Ia_i                ),
    .Ib_i                   (   Ib_i                ),
    .Ic_i                   (   Ic_i                ),

    .Ialpha_o               (   Ialpha              ),
    .Ibeta_o                (   Ibeta               ),
    .Iq_o                   (   Iq                  ),
    .Id_o                   (   Id                  )
);

iclark_ipark iclark_ipark_hp(
    .sys_clk_i              (   sys_clk_i           ),  
    .sys_rst_n_i            (   sys_rst_n_i         ),

    .iclark_ipark_en_i      (   iclark_ipark_en     ),
    .iclark_ipark_ack_o     (   iclark_ipark_ack    ),

    .cordic_sin_i           (   cordic_sin          ),   
    .cordic_cos_i           (   cordic_cos          ),
    .Uq_i                   (   Uq                  ),
    .Ud_i                   (   Ud                  ),

    .Ua_o                   (   Ua                  ),
    .Ub_o                   (   Ub                  ),
    .Uc_o                   (   Uc                  ),
    .Ualpha_o               (   Ualpha              ),
    .Ubeta_o                (   Ubeta               )
);


Cordic_Top #(
    .CORDIC_MODE            (   "ROTATE"            )       // ROTATE    VECTOR
)Cordic_Top_inst(
    .sys_clk_i              (   sys_clk_i           ),  
    .sys_rst_n_i            (   sys_rst_n_i         ),

    .cordic_req_i           (   cordic_req          ),
    .cordic_ack_o           (   cordic_ack          ),

    //ROTATE
    .cordic_angle_i         (   foc_angle_lock      ),   // * 2^16
    .cordic_sin_o           (   cordic_sin          ),   // * 2^16
    .cordic_cos_o           (   cordic_cos          ),   // * 2^16

    //VECTOR
    .cordic_x_i             (   32'd0               ),
    .cordic_y_i             (   32'd0               ),
    .cordic_arctan_o        (                       ),    // * 2^16
    .cordic_mod_o           (                       )    
);


timer_top #(
    .DEFAULT_ARR            (  `TIME_ARR            ),
    .DEFAULT_CCR            (  'd0                  ),
    .COUNT_MODE             (  "CENTRE"             ),  // UP  DOWN  CENTRE
    .TRIG_ENABLE            (  "DISABLE"            ),  // ENABLE DISABLE
    .PWM_OUT                (  "PN"                 ),  // NONE P PN
    .PWM_OUT_MODE           (  "MODE1"              ),  // MODE1 MODE2
    .PWM_DEATH_TIME         (  `PWM_DEATH_TIME_SET  ) // 0 ~ 10 sys_clk
)timer_top_U(
    .sys_clk_i              (   sys_clk_i           ),  
    .sys_rst_n_i            (   sys_rst_n_i         ),

    .pwm_clk_200M_i         (   pwm_clk_200M_i      ),

    .timer_wr_type_i        (   timer_wr_type       ),
    .timer_write_en_i       (   timer_write_en      ),
    .timer_write_data_i     (   timer_write_data_U  ),
    .timer_read_en_i        (   1'b0                ),
    .timer_read_data_o      (                       ),

    .timer_trig_o           (                       ),
    .timer_pwm_o            (   svpwm_u_pin_o       ),
    .timer_pwm_n_o          (   svpwm_un_pin_o      )  
);
timer_top #(
    .DEFAULT_ARR            (  `TIME_ARR            ),
    .DEFAULT_CCR            (  'd0                  ),
    .COUNT_MODE             (  "CENTRE"             ),  // UP  DOWN  CENTRE
    .TRIG_ENABLE            (  "DISABLE"            ),  // ENABLE DISABLE
    .PWM_OUT                (  "PN"                 ),  // NONE P PN
    .PWM_OUT_MODE           (  "MODE1"              ),  // MODE1 MODE2
    .PWM_DEATH_TIME         (  `PWM_DEATH_TIME_SET  ) // 0 ~ 10 sys_clk
)timer_top_V(
    .sys_clk_i              (   sys_clk_i           ),  
    .sys_rst_n_i            (   sys_rst_n_i         ),

    .pwm_clk_200M_i         (   pwm_clk_200M_i      ),

    .timer_wr_type_i        (   timer_wr_type       ),
    .timer_write_en_i       (   timer_write_en      ),
    .timer_write_data_i     (   timer_write_data_V  ),
    .timer_read_en_i        (   1'b0                ),
    .timer_read_data_o      (                       ),

    .timer_trig_o           (                       ),
    .timer_pwm_o            (   svpwm_v_pin_o       ),
    .timer_pwm_n_o          (   svpwm_vn_pin_o      )  
);
timer_top #(
    .DEFAULT_ARR            (  `TIME_ARR            ),
    .DEFAULT_CCR            (  'd0                  ),
    .COUNT_MODE             (  "CENTRE"             ),  // UP  DOWN  CENTRE
    .TRIG_ENABLE            (  "DISABLE"            ),  // ENABLE DISABLE
    .PWM_OUT                (  "PN"                 ),  // NONE P PN
    .PWM_OUT_MODE           (  "MODE1"              ),  // MODE1 MODE2
    .PWM_DEATH_TIME         (  `PWM_DEATH_TIME_SET  ) // 0 ~ 10 sys_clk
)timer_top_W(
    .sys_clk_i              (   sys_clk_i           ),  
    .sys_rst_n_i            (   sys_rst_n_i         ),

    .pwm_clk_200M_i         (   pwm_clk_200M_i      ),

    .timer_wr_type_i        (   timer_wr_type       ),
    .timer_write_en_i       (   timer_write_en      ),
    .timer_write_data_i     (   timer_write_data_W  ),
    .timer_read_en_i        (   1'b0                ),
    .timer_read_data_o      (                       ),

    .timer_trig_o           (                       ),
    .timer_pwm_o            (   svpwm_w_pin_o       ),
    .timer_pwm_n_o          (   svpwm_wn_pin_o      )  
);



timer_top #(
    .DEFAULT_ARR            (  `TIME_ARR_MUL2       ),
    .DEFAULT_CCR            (  `TIME_ARR            ),
    .COUNT_MODE             (  "UP"                 ),  // UP  DOWN  CENTRE
    .TRIG_ENABLE            (  "ENABLE"             ),  // ENABLE DISABLE
    .PWM_OUT                (  "NONE"               ),  // NONE P PN
    .PWM_OUT_MODE           (  "MODE1"              ),  // MODE1 MODE2
    .PWM_DEATH_TIME         (  3'd0                 ) // 0 ~ 10 sys_clk
)timer_top_trig(
    .sys_clk_i              (   sys_clk_i           ),  
    .sys_rst_n_i            (   sys_rst_n_i         ),

    .pwm_clk_200M_i         (   pwm_clk_200M_i      ),

    .timer_wr_type_i        (   1'b0                ),
    .timer_write_en_i       (   1'b0                ),
    .timer_write_data_i     (   'd0                 ),
    .timer_read_en_i        (   1'b0                ),
    .timer_read_data_o      (                       ),

    .timer_trig_o           (  timer_trig           ),
    .timer_pwm_o            (                       ),
    .timer_pwm_n_o          (                       )  
);
endmodule
