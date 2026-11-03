`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/09 13:46:37
// Design Name: 
// Module Name: loop_adjust
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
//////////////////////////////////////////////////////////////////////////////////
`include "foc_header.vh"

module loop_adjust(
    input                   sys_clk_i           ,
    input                   sys_rst_n_i         ,

    input                   loop_adjust_en_i    ,
    output                  loop_adjust_ack_o   ,

    input [7:0]             foc_mode_i          ,       //FOC运行模式
    input signed[24:0]      Open_Uq_i           ,       //开环模式下Uq参数输入
    input signed[24:0]      Open_Ud_i           ,       //开环模式下Ud参数输入
    //三环控制参数
    input signed[15:0]      Torque_Iq_PID_P_i   ,
    input signed[15:0]      Torque_Iq_PID_I_i   ,
    input signed[15:0]      Torque_Id_PID_P_i   ,
    input signed[15:0]      Torque_Id_PID_I_i   ,
    input signed[15:0]      Speed_PID_P_i       ,
    input signed[15:0]      Speed_PID_I_i       ,
    input signed[15:0]      Position_PID_P_i    ,
    input signed[15:0]      Position_PID_I_i    ,


    input signed[24:0]      desired_Iq_i        ,
    input signed[24:0]      desired_Id_i        ,
    input signed[24:0]      desired_speed_i     ,
    input signed[24:0]      desired_position_i  ,

    input signed[24:0]      actual_Iq_i         ,
    input signed[24:0]      actual_Id_i         ,
    input signed[24:0]      actual_speed_i      ,
    input signed[24:0]      actual_position_i   ,

    output reg signed[24:0] uq_o                ,
    output reg signed[24:0] ud_o
);

localparam  S_IDLE              = 'd0;
localparam  S_OPEN_LOOP         = 'd1;
localparam  S_TORQUE_IQ_LOOP    = 'd2;
localparam  S_TORQUE_ID_LOOP    = 'd3;
localparam  S_SPEED_LOOP        = 'd4;
localparam  S_POSITION_LOOP     = 'd5;
localparam  S_LIMIT             = 'd6;
localparam  S_ACK               = 'd7;


reg[3:0] state , next_state;


wire                    pid_en_module;
wire                    pid_ack_module;

//积分的最大最小值
wire signed[31:0]       error_sum_max_module;  
wire signed[31:0]       error_sum_min_module;

//PID反馈的最大最小值
wire signed[31:0]       fb_value_max_module;
wire signed[31:0]       fb_value_min_module;

//PID积分输入输出
wire signed[31:0]       error_sum_i_module;  
wire signed[31:0]       error_sum_o_module;


reg signed[31:0]        torque_Iq_error_sum;
reg signed[31:0]        torque_Id_error_sum;
reg signed[31:0]        torque_speed_error_sum;
reg signed[31:0]        torque_position_error_sum;

wire signed[31:0]       P_module;
wire signed[31:0]       I_module;

wire signed[31:0]       desired_module;
wire signed[31:0]       actual_module;

wire signed[31:0]       fb_value_module;



reg  signed[31:0]   desired_torque_Iq_sel;
reg  signed[31:0]   desired_torque_Id_sel;
reg  signed[31:0]   desired_speed_sel;
reg[2:0]            position_speed_cnt;


reg signed[31:0]    uq_d0;
reg signed[31:0]    ud_d0;


assign loop_adjust_ack_o = ( state == S_ACK ) ? 1'b1 : 1'b0;


assign pid_en_module          = ( state == S_TORQUE_IQ_LOOP ) ? 1'b1 :
                                ( state == S_TORQUE_ID_LOOP ) ? 1'b1 :
                                ( state == S_SPEED_LOOP && position_speed_cnt == `FOC_SPEED_POSTION_CYC)  ? 1'b1 :
                                ( state == S_POSITION_LOOP && position_speed_cnt == `FOC_SPEED_POSTION_CYC) ? 1'b1 : 1'b0;


assign error_sum_max_module   = ( state == S_TORQUE_IQ_LOOP ) ?  ($signed(32'd110000)        ):  
                                ( state == S_TORQUE_ID_LOOP ) ?  ($signed(32'd140000)        ):  
                                ( state == S_SPEED_LOOP     ) ?  ($signed(32'd110000)        ): 
                                ( state == S_POSITION_LOOP  ) ?  ($signed(32'd5000)  )      : 'd0;
                
assign error_sum_min_module   = ( state == S_TORQUE_IQ_LOOP ) ?  ($signed(-32'd110000))       :  
                                ( state == S_TORQUE_ID_LOOP ) ?  ($signed(-32'd140000))       :  
                                ( state == S_SPEED_LOOP     ) ?  ($signed(-32'd110000))       :
                                ( state == S_POSITION_LOOP  ) ?  ($signed(-32'd5000))        : 'd0;                
                
assign fb_value_max_module    = ( state == S_TORQUE_IQ_LOOP ) ?  ($signed(32'd10000))        :  
                                ( state == S_TORQUE_ID_LOOP ) ?  ($signed(32'd10000))        :  
                                ( state == S_SPEED_LOOP     ) ?  ($signed(32'd5500) )        :          //反馈最大电流5500个adc值
                                ( state == S_POSITION_LOOP  ) ?  ($signed(32'd150000)    )   : 'd0;     //反馈最大速度1500RPM

assign fb_value_min_module    = ( state == S_TORQUE_IQ_LOOP ) ?  ($signed(-32'd10000))       : 
                                ( state == S_TORQUE_ID_LOOP ) ?  ($signed(-32'd10000))       :  
                                ( state == S_SPEED_LOOP     ) ?  ($signed(-32'd5500) )       :          //反馈最小电流-5500个adc值
                                ( state == S_POSITION_LOOP  ) ?  ($signed(-32'd150000)    )  : 'd0;     //反馈最小速度-1500RPM





assign error_sum_i_module     = ( state == S_TORQUE_IQ_LOOP ) ?  torque_Iq_error_sum        :  
                                ( state == S_TORQUE_ID_LOOP ) ?  torque_Id_error_sum        :  
                                ( state == S_SPEED_LOOP     ) ?  torque_speed_error_sum     :
                                ( state == S_POSITION_LOOP  ) ?  torque_position_error_sum  : 'd0; 


assign P_module               = ( state == S_TORQUE_IQ_LOOP ) ?  Torque_Iq_PID_P_i          :   
                                ( state == S_TORQUE_ID_LOOP ) ?  Torque_Id_PID_P_i          :   
                                ( state == S_SPEED_LOOP     ) ?  Speed_PID_P_i              :
                                ( state == S_POSITION_LOOP  ) ?  Position_PID_P_i           : 'd0;                    

assign I_module               = ( state == S_TORQUE_IQ_LOOP ) ?  Torque_Iq_PID_I_i          :   
                                ( state == S_TORQUE_ID_LOOP ) ?  Torque_Id_PID_I_i          :   
                                ( state == S_SPEED_LOOP     ) ?  Speed_PID_I_i              :
                                ( state == S_POSITION_LOOP  ) ?  Position_PID_I_i           : 'd0;                              

assign desired_module         = ( state == S_TORQUE_IQ_LOOP ) ?  desired_torque_Iq_sel      :   
                                ( state == S_TORQUE_ID_LOOP ) ?  desired_torque_Id_sel      :   
                                ( state == S_SPEED_LOOP     ) ?  desired_speed_sel          :
                                ( state == S_POSITION_LOOP  ) ?  desired_position_i         : 'd0; 

assign actual_module          = ( state == S_TORQUE_IQ_LOOP ) ?  {{7{actual_Iq_i[24]}} ,actual_Iq_i }               :   
                                ( state == S_TORQUE_ID_LOOP ) ?  {{7{actual_Id_i[24]}} ,actual_Id_i }               :   
                                ( state == S_SPEED_LOOP     ) ?  {actual_speed_i >>> 3}     :
                                ( state == S_POSITION_LOOP  ) ?  actual_position_i          : 'd0; 

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        state <= S_IDLE;
    else
        state <= next_state;
end

always@(*) begin
    case(state)
    S_IDLE:
        if( loop_adjust_en_i == 1'b1 && foc_mode_i == `FOC_MODE_OPEN )
            next_state <= S_OPEN_LOOP;
        else if( loop_adjust_en_i == 1'b1 && foc_mode_i == `FOC_MODE_SELFTEST )
            next_state <= S_OPEN_LOOP;
        else if( loop_adjust_en_i == 1'b1 && foc_mode_i == `FOC_MODE_TORQUE )
            next_state <= S_TORQUE_IQ_LOOP;
        else if( loop_adjust_en_i == 1'b1 && foc_mode_i == `FOC_MODE_SPEED )
            next_state <= S_SPEED_LOOP;
        else if( loop_adjust_en_i == 1'b1 && foc_mode_i == `FOC_MODE_POSTION )
            next_state <= S_POSITION_LOOP;
        else
            next_state <= S_IDLE;
    S_OPEN_LOOP:
        next_state <= S_LIMIT;
    S_TORQUE_ID_LOOP:
        if( pid_ack_module == 1'b1 )
            next_state <= S_LIMIT;
        else
            next_state <= S_TORQUE_ID_LOOP;
    S_TORQUE_IQ_LOOP:
        if( pid_ack_module == 1'b1 )
            next_state <= S_TORQUE_ID_LOOP;
        else
            next_state <= S_TORQUE_IQ_LOOP;
    S_SPEED_LOOP:
        if( position_speed_cnt == `FOC_SPEED_POSTION_CYC && pid_ack_module == 1'b1 )
            next_state <= S_TORQUE_IQ_LOOP;
        else if( position_speed_cnt == `FOC_SPEED_POSTION_CYC )
            next_state <= S_SPEED_LOOP;
        else
            next_state <= S_TORQUE_IQ_LOOP;
    S_POSITION_LOOP:
        if( position_speed_cnt == `FOC_SPEED_POSTION_CYC && pid_ack_module == 1'b1 )
            next_state <= S_SPEED_LOOP;
        else if( position_speed_cnt == `FOC_SPEED_POSTION_CYC )
            next_state <= S_POSITION_LOOP;
        else
            next_state <= S_TORQUE_IQ_LOOP;
    S_LIMIT:
        next_state <= S_ACK;
    S_ACK:  
        next_state <= S_IDLE;
    default: next_state <= S_IDLE;
    endcase
end


//选择电流环的期望值
always @( posedge sys_clk_i or negedge sys_rst_n_i) begin
    if( sys_rst_n_i == 1'b0 ) begin
        desired_torque_Iq_sel <= 'd0;
        desired_torque_Id_sel <= 'd0;
    end
    else if( foc_mode_i == `FOC_MODE_TORQUE ) begin
        desired_torque_Iq_sel <= desired_Iq_i;
        desired_torque_Id_sel <= desired_Id_i;
    end
    else if( state == S_SPEED_LOOP && pid_en_module == 1'b1 && pid_ack_module == 1'b1 ) begin
        desired_torque_Iq_sel <= fb_value_module;
        desired_torque_Id_sel <= desired_Id_i;
    end
    else begin
        desired_torque_Iq_sel <= desired_torque_Iq_sel;
        desired_torque_Id_sel <= desired_Id_i;
    end
end

//选择速度环的期望值
always@( posedge sys_clk_i ) begin
    if( foc_mode_i == `FOC_MODE_SPEED )
        desired_speed_sel <= {desired_speed_i >>> 3 };
    else if( state == S_POSITION_LOOP && pid_ack_module == 1'b1 )
        desired_speed_sel <= ( fb_value_module >>> 3 );
    else
        desired_speed_sel <= desired_speed_sel;
end

always@( posedge sys_clk_i  or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        position_speed_cnt <= 'd0;
    else if( state == S_IDLE &&  loop_adjust_en_i == 1'b1 && (foc_mode_i == `FOC_MODE_SPEED || foc_mode_i == `FOC_MODE_POSTION))
        if( position_speed_cnt == `FOC_SPEED_POSTION_CYC )
            position_speed_cnt <= position_speed_cnt;
        else
            position_speed_cnt <= position_speed_cnt + 1'b1;
    else if( state == S_ACK && position_speed_cnt == `FOC_SPEED_POSTION_CYC )
        position_speed_cnt <= 'd0;
    else
        position_speed_cnt <= position_speed_cnt;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        uq_d0 <= 'd0;
        ud_d0 <= 'd0;
    end
    else if( state == S_OPEN_LOOP ) begin
        uq_d0 <= Open_Uq_i;
        ud_d0 <= Open_Ud_i;
    end
    else if( state == S_TORQUE_IQ_LOOP && pid_ack_module == 1'b1 ) begin
        uq_d0 <= fb_value_module;
        ud_d0 <= ud_d0;
    end
    else if( state == S_TORQUE_ID_LOOP && pid_ack_module == 1'b1 ) begin
        uq_d0 <= uq_d0;
        ud_d0 <= fb_value_module;
    end
    else begin
        uq_d0 <= uq_d0;
        ud_d0 <= ud_d0;
    end
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        uq_o <= 'd0;
    else if( state == S_LIMIT )
        if( uq_d0 >  `UQ_MAX )
            uq_o <= `UQ_MAX;
        else if( uq_d0 < `UQ_MIN )
            uq_o <= `UQ_MIN ;
        else
            uq_o <= uq_d0;
    else
        uq_o <= uq_o;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        ud_o <= 'd0;
    else if( state == S_LIMIT )
        if( ud_d0 > `UD_MAX )
            ud_o <= `UD_MAX;
        else if( ud_d0 < `UD_MIN  )
            ud_o <= `UD_MIN ;
        else
            ud_o <= ud_d0;
    else
        ud_o <= ud_o;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i ==  1'b0 )
        torque_Iq_error_sum <= 'd0;
    else if( state == S_TORQUE_IQ_LOOP && pid_ack_module == 1'b1 )
        torque_Iq_error_sum <= error_sum_o_module;
    else
        torque_Iq_error_sum <= torque_Iq_error_sum;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i ==  1'b0 )
        torque_Id_error_sum <= 'd0;
    else if( state == S_TORQUE_ID_LOOP && pid_ack_module == 1'b1 )
        torque_Id_error_sum <= error_sum_o_module;
    else
        torque_Id_error_sum <= torque_Id_error_sum;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i ==  1'b0 )
        torque_speed_error_sum <= 'd0;
    else if( state == S_SPEED_LOOP && pid_ack_module == 1'b1 )
        torque_speed_error_sum <= error_sum_o_module;
    else
        torque_speed_error_sum <= torque_speed_error_sum;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i ==  1'b0 )
        torque_position_error_sum <= 'd0;
    else if( state == S_POSITION_LOOP && pid_ack_module == 1'b1 )
        torque_position_error_sum <= error_sum_o_module;
    else
        torque_position_error_sum <= torque_position_error_sum;
end

position_pid position_pid_hp(
    .sys_clk_i              (   sys_clk_i                   ),
    .sys_rst_n_i            (   sys_rst_n_i                 ),
    
    .position_pid_en_i      (   pid_en_module               ),
    .position_pid_ack_o     (   pid_ack_module              ),

    .error_sum_max_i        (   error_sum_max_module        ),  
    .error_sum_min_i        (   error_sum_min_module        ),
    .fb_value_max_i         (   fb_value_max_module         ),
    .fb_value_min_i         (   fb_value_min_module         ),


    .error_sum_i            (   error_sum_i_module          ),
    .error_sum_o            (   error_sum_o_module          ),

    .P_i                    (   P_module                    ),
    .I_i                    (   I_module                    ),
    .D_i                    (   'd0                         ),

    .desired_value_i        (   desired_module              ),
    .actual_value_i         (   actual_module               ),

    .feedback_value_o       (   fb_value_module             )
);


endmodule
