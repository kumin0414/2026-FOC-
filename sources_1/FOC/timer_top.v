`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/17 10:44:07
// Design Name: 
// Module Name: timer_top
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


module timer_top #(
    parameter       DEFAULT_ARR     = 16'd1500  ,  //5000
    parameter       DEFAULT_CCR     = 16'd750   ,  //2500
    parameter       COUNT_MODE      = "UP"      ,  // UP  DOWN  CENTRE
    parameter       TRIG_ENABLE     = "ENABLE"  ,  // ENABLE DISABLE
    parameter       PWM_OUT         = "NONE"    ,  // NONE P PN
    parameter       PWM_OUT_MODE    = "MODE1"   ,  // MODE1 MODE2
    parameter       PWM_DEATH_TIME  = 3'd0         // 0 ~ 10 sys_clk
)(
    input           sys_clk_i           ,  
    input           sys_rst_n_i         ,

    input           pwm_clk_200M_i      ,

    input           timer_wr_type_i     ,
    input           timer_write_en_i    ,
    input[15:0]     timer_write_data_i  ,
    input           timer_read_en_i     ,
    output[15:0]    timer_read_data_o   ,

    output          timer_trig_o        ,
    output          timer_pwm_o         ,
    output reg      timer_pwm_n_o       
);


reg[15:0]   CNT                 ;
reg[15:0]   ARR                 ;
reg[15:0]   CCR                 ; 
reg[15:0]   CCR_SHADOW          ;
reg         center_direct       ;

reg         timer_trig_pluse    ;
reg         timer_trig_pluse_d0 ;
reg         timer_trig_pluse_d1 ;
wire        timer_trig_pluse_p  ;
wire        timer_trig_pluse_n  ;

assign timer_trig_pluse_p = ( ~timer_trig_pluse_d1 ) & timer_trig_pluse_d0;
assign timer_trig_pluse_n = ( ~timer_trig_pluse_d0 ) & timer_trig_pluse_d1;


assign timer_trig_o = timer_trig_pluse_p | timer_trig_pluse_n;

assign timer_pwm_o =  ( PWM_OUT_MODE == "MODE1" && CNT < CCR_SHADOW) ? 1'b1 :
                      ( PWM_OUT_MODE == "MODE1"                    ) ? 1'b0 :
                      ( PWM_OUT_MODE == "MODE2" && CNT < CCR_SHADOW) ? 1'b0 :
                      ( PWM_OUT_MODE == "MODE2"                    ) ? 1'b1 : 1'b0;




always@( posedge pwm_clk_200M_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        timer_trig_pluse <= 1'b0;
    else if( TRIG_ENABLE == "ENABLE" && CNT == CCR_SHADOW )
        timer_trig_pluse <= ~timer_trig_pluse;
    else
        timer_trig_pluse <= timer_trig_pluse;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        timer_trig_pluse_d0 <= 1'b0;
        timer_trig_pluse_d1 <= 1'b0;
    end
    else begin
        timer_trig_pluse_d0 <= timer_trig_pluse;
        timer_trig_pluse_d1 <= timer_trig_pluse_d0;
    end
end





always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        ARR <= DEFAULT_ARR;
    else if( timer_wr_type_i == 1'b0 && timer_write_en_i == 1'b1 )
        ARR <= timer_write_data_i;
    else
        ARR <= ARR;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        CCR <= DEFAULT_CCR;
    else if( timer_wr_type_i == 1'b1 && timer_write_en_i == 1'b1 )
        CCR <= timer_write_data_i;
    else
        CCR <= CCR;
end










always@( posedge pwm_clk_200M_i ) begin
    if( COUNT_MODE == "UP" )
        if( CNT == ARR - 1'b1)
            CCR_SHADOW <= CCR;
        else
            CCR_SHADOW <= CCR_SHADOW;
    else if( COUNT_MODE == "DOWN" )
        if( CNT == 16'd0)
            CCR_SHADOW <= CCR;
        else
            CCR_SHADOW <= CCR_SHADOW;
    else if(  COUNT_MODE == "CENTRE" )
        if( CNT == 16'd1 && center_direct == 1'b1 )
            CCR_SHADOW <= CCR;
        else
            CCR_SHADOW <= CCR_SHADOW;
    else
        CCR_SHADOW <= CCR_SHADOW;
end

always@( posedge pwm_clk_200M_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        center_direct <= 1'b0;
    else if( COUNT_MODE == "CENTRE" ) begin
        if( CNT == ARR - 1'b1 && center_direct == 1'b0)
            center_direct <= 1'b1;
        else if( CNT == 1'b1 && center_direct == 1'b1)
            center_direct <= 1'b0;
        else
            center_direct <= center_direct;
    end
    else;
end

always @( posedge pwm_clk_200M_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        CNT <= 16'd0;
    else if( COUNT_MODE == "UP" ) begin
        if( CNT == ARR - 1'b1)
            CNT <= 16'd0;
        else
            CNT <= CNT + 1'b1;
    end
    else if( COUNT_MODE == "DOWN" ) begin
        if( CNT == 16'd0 )
            CNT <= ARR -1'b1;
        else
            CNT <= CNT - 1'b1;
    end
    else if( COUNT_MODE == "CENTRE" ) begin
        if( center_direct == 1'b0 )
            CNT <= CNT + 1'b1;
        else
            CNT <= CNT - 1'b1;
    end
end


always@( posedge pwm_clk_200M_i ) begin
    if( PWM_OUT == "PN" ) begin
        if( COUNT_MODE == "UP" && PWM_OUT_MODE == "MODE1" )
            if( CNT == CCR_SHADOW + PWM_DEATH_TIME )
                timer_pwm_n_o <= 1'b1;
            else if( CNT == ARR - PWM_DEATH_TIME - 1'b1 )
                timer_pwm_n_o <= 1'b0;
            else
                 timer_pwm_n_o <= timer_pwm_n_o;
        else if( COUNT_MODE == "DOWN" && PWM_OUT_MODE == "MODE2" )
            if( CNT == CCR_SHADOW - PWM_DEATH_TIME )
                timer_pwm_n_o <= 1'b1;
            else if( CNT ==  PWM_DEATH_TIME )
                timer_pwm_n_o <= 1'b0;
            else
                 timer_pwm_n_o <= timer_pwm_n_o;
        else if( COUNT_MODE == "UP" && PWM_OUT_MODE == "MODE2" )
            if( CNT == CCR_SHADOW - PWM_DEATH_TIME - 1'b1)
                timer_pwm_n_o <= 1'b0;
            else if( CNT == PWM_DEATH_TIME )    
                timer_pwm_n_o <= 1'b1;
            else
                timer_pwm_n_o <= timer_pwm_n_o;
        else if( COUNT_MODE == "DOWN" && PWM_OUT_MODE == "MODE1" )
            if( CNT == CCR_SHADOW + PWM_DEATH_TIME )
                timer_pwm_n_o <= 1'b0;
            else if( CNT ==  ARR - PWM_DEATH_TIME - 1'b1 )
                timer_pwm_n_o <= 1'b1;
            else
                 timer_pwm_n_o <= timer_pwm_n_o;
        else if( ( COUNT_MODE == "CENTRE" && PWM_OUT_MODE == "MODE1" && center_direct == 1'b0))
            if( CNT ==  CCR_SHADOW + PWM_DEATH_TIME )
                timer_pwm_n_o <= 1'b1;
            else 
                timer_pwm_n_o <= timer_pwm_n_o;
        else if( ( COUNT_MODE == "CENTRE" && PWM_OUT_MODE == "MODE1" && center_direct == 1'b1))
            if( CNT == CCR_SHADOW + PWM_DEATH_TIME )
                timer_pwm_n_o <= 1'b0;
            else
                timer_pwm_n_o <= timer_pwm_n_o;
        
        else if( ( COUNT_MODE == "CENTRE" && PWM_OUT_MODE == "MODE2" && center_direct == 1'b0))
            if( CNT ==  CCR_SHADOW - PWM_DEATH_TIME )
                timer_pwm_n_o <= 1'b0;
            else 
                timer_pwm_n_o <= timer_pwm_n_o;
        else if( ( COUNT_MODE == "CENTRE" && PWM_OUT_MODE == "MODE2" && center_direct == 1'b1))
            if( CNT ==  CCR_SHADOW - PWM_DEATH_TIME )
                timer_pwm_n_o <= 1'b1;
            else 
                timer_pwm_n_o <= timer_pwm_n_o;
        else
            ;
    end
    else
        timer_pwm_n_o <= 1'b0;
end


endmodule
