`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/28 11:25:43
// Design Name: 
// Module Name: SVPWM
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


module SVPWM #(
    parameter       Ts     = 25'd1500  , 
    parameter       K      = 25'd750     
)(
    input                   sys_clk_i           ,
    input                   sys_rst_n_i         ,

    input                   svpwm_en_i          ,
    output                  svpwm_ack_o         ,


    input signed[24:0]      Ualpha_i            ,
    input signed[24:0]      Ubeta_i             ,


    output reg[15:0]        pwm_ta              ,
    output reg[15:0]        pwm_tb              ,
    output reg[15:0]        pwm_tc              
);

`define SQRT3_div_2 $signed(18'd56755)      

reg[6:0]    cnt;
reg         dealing;

reg signed[24:0]    U1;
reg signed[24:0]    U2;
reg signed[24:0]    U3;
reg signed[24:0]    Ubeta_div2;
reg signed[42:0]    sqrt3_div2_mul_ualpha;

reg signed[42:0]    K_mul_U1;
reg signed[42:0]    K_mul_U2;
reg signed[42:0]    K_mul_U3;

reg signed[24:0]    TIME1;
reg signed[24:0]    TIME2;
reg signed[24:0]    TIME3;

reg signed[15:0]    Ta_temp;
reg signed[15:0]    Tb_temp;
reg signed[15:0]    Tc_temp;



reg A,B,C;
reg[3:0] N;
reg[5:0] sector;


assign svpwm_ack_o = ( cnt == 'd19 ) ? 1'b1 : 1'b0;

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        dealing <= 1'b0;
    else if( svpwm_ack_o == 1'b1 )
        dealing <= 1'b0;
    else if( svpwm_en_i == 1'b1 )
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
    if( sys_rst_n_i == 1'b0 )
        U1 <= 'd0;
    else if( cnt == 'd1 ) 
        U1 <= Ubeta_i;
    else
        U1 <= U1;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        Ubeta_div2 <= 'd0;
    else if( cnt == 'd1 ) 
        Ubeta_div2 <= Ubeta_i >>> 1;
    else
        Ubeta_div2 <= Ubeta_div2;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        sqrt3_div2_mul_ualpha <= 'd0;
    else if( cnt == 'd1 ) 
        sqrt3_div2_mul_ualpha <= (`SQRT3_div_2 * Ualpha_i );
    else if( cnt == 'd3 )
        sqrt3_div2_mul_ualpha <= sqrt3_div2_mul_ualpha >>> 16;
    else
        sqrt3_div2_mul_ualpha <= sqrt3_div2_mul_ualpha;
end



always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        U2 <= 'd0;
    else if( cnt == 'd5 ) 
        U2 <= -( sqrt3_div2_mul_ualpha + Ubeta_div2);
    else
        U2 <= U2;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        U3 <= 'd0;
    else if( cnt == 'd5 ) 
        U3 <= sqrt3_div2_mul_ualpha - Ubeta_div2;
    else
        U3 <= U3;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        K_mul_U1 <= 'd0;       
        K_mul_U2 <= 'd0;
        K_mul_U3 <= 'd0;
    end
    else if( cnt == 'd7 )  begin
        K_mul_U1 <=  $signed(K) * U1;       
        K_mul_U2 <=  $signed(K) * U2;
        K_mul_U3 <=  $signed(K) * U3;
    end
   else if( cnt == 'd9 )  begin
       K_mul_U1 <= K_mul_U1 >>> 16;       
       K_mul_U2 <= K_mul_U2 >>> 16;
       K_mul_U3 <= K_mul_U3 >>> 16;
   end
    else;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        A <= 'd0;
    else if( cnt == 'd7 ) 
        if( U1[24] == 1'b0)
            A <= 1'b1;
        else
            A <= 1'b0;
    else
        A <= A;
end
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        B <= 'd0;
    else if( cnt == 'd7 ) 
        if( U2[24] == 1'b0)
            B <= 1'b1;
        else
            B <= 1'b0;
    else
        B <= B;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        C <= 'd0;
    else if( cnt == 'd7 ) 
        if( U3[24] == 1'b0)
            C <= 1'b1;
        else
            C <= 1'b0;
    else
        C <= C;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        N <= 'd0;
    else if( cnt == 'd8 ) 
        N <= (A << 2) + (B << 1) + C;
    else
        N <= N;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )  
        sector <= 'd0;
    else if( cnt == 'd9 )
        case(N)
            5: sector <= 'd1;
            4: sector <= 'd2;
            6: sector <= 'd3;
            2: sector <= 'd4;
            3: sector <= 'd5;
        default: sector <= 'd6;
        endcase
    else
        sector <= sector;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )  
        TIME1 <= 'd0;
    else if( cnt == 'd11 )
        case(sector)
            1: TIME1 <= K_mul_U3;
            2: TIME1 <= -K_mul_U3;
            3: TIME1 <= K_mul_U1;
            4: TIME1 <= -K_mul_U1;
            5: TIME1 <= K_mul_U2;
            6: TIME1 <= -K_mul_U2;
        default: TIME1 <= -K_mul_U2;
        endcase
    else if( cnt == 'd12 )
        TIME1 <= TIME1 >>> 6;
    else
        TIME1 <= TIME1;
end
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )  
        TIME2 <= 'd0;
    else if( cnt == 'd11 )
        case(sector)
            1: TIME2 <= K_mul_U1;
            2: TIME2 <= -K_mul_U2;
            3: TIME2 <= K_mul_U2;
            4: TIME2 <= -K_mul_U3;
            5: TIME2 <= K_mul_U3;
            6: TIME2 <= -K_mul_U1;
        default: TIME2 <= -K_mul_U1;
        endcase
    else if( cnt == 'd12 )
        TIME2 <= TIME2 >>> 6;
    else
        TIME2 <= TIME2;
end
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )  
        TIME3 <= 'd0;
    else if( cnt == 'd13 )
        TIME3 <= Ts - TIME1 - TIME2;
    else if( cnt == 'd14 )
        TIME3 <= TIME3 >>> 1;
    else
        TIME3 <= TIME3;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )  
        Ta_temp <= 'd0;
    else if( cnt == 'd15 )
        case(sector)
            1: Ta_temp <= TIME1 + TIME2 + TIME3;
            2: Ta_temp <= TIME2 + TIME3;
            3: Ta_temp <= TIME3;
            4: Ta_temp <= TIME3;
            5: Ta_temp <= TIME2 + TIME3;
            6: Ta_temp <= TIME1 + TIME2 + TIME3;
        default: Ta_temp <= -K_mul_U1;
        endcase
    else
        Ta_temp <= Ta_temp;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )  
        Tb_temp <= 'd0;
    else if( cnt == 'd15 )
        case(sector)
            1: Tb_temp <= TIME2 + TIME3;
            2: Tb_temp <= TIME1 + TIME2 + TIME3;
            3: Tb_temp <= TIME1 + TIME2 + TIME3;
            4: Tb_temp <= TIME2 + TIME3;
            5: Tb_temp <= TIME3;
            6: Tb_temp <= TIME3;
        default: Tb_temp <= -K_mul_U1;
        endcase
    else
        Tb_temp <= Tb_temp;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )  
        Tc_temp <= 'd0;
    else if( cnt == 'd15 )
        case(sector)
            1: Tc_temp <= TIME3;
            2: Tc_temp <= TIME3;
            3: Tc_temp <= TIME2 + TIME3;
            4: Tc_temp <= TIME1 + TIME2 + TIME3;
            5: Tc_temp <= TIME1 + TIME2 + TIME3;
            6: Tc_temp <= TIME2 + TIME3;
        default: Tc_temp <= -K_mul_U1;
        endcase
    else
        Tc_temp <= Tc_temp;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        pwm_ta <= 'd0;
        pwm_tb <= 'd0;
        pwm_tc <= 'd0;
    end
    else if( cnt == 'd17 ) begin
        pwm_ta <= Ta_temp;
        pwm_tb <= Tb_temp;
        pwm_tc <= Tc_temp;
    end
    else if( ( pwm_ta[15] == 1'b1 ) || ( pwm_tb[15] == 1'b1 ) || ( pwm_tc[15] == 1'b1 ) ) begin  //溢出措施
        pwm_ta <= 16'd0;
        pwm_tb <= 16'd0;
        pwm_tc <= 16'd0;
    end
    else;
end


endmodule
