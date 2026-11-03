`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/07 21:59:13
// Design Name: FPGA之旅
// Module Name: ABZ_encoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:  
//   采用M测速法进行测量 周期为10ms  速度扩大10倍输出
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module ABZ_encoder(
    input                       sys_clk_i               ,
    input                       sys_rst_n_i             ,

    input                       motor_position_en_i     , //电机位置检测使能
    input                       motor_position_set_i    , //设置电机当前位置为初始位置  
    output reg [24:0]           motor_angle_o           , //电机当前角度
    output reg signed[31:0]     motor_speed_o           , //电机当前速度
    output reg signed[31:0]     motor_position_o        , //电机当前位置
    output                      motor_one_circle_o      , //电机运行一圈标志输出
    output reg[15:0]            ABZ_one_circle_plus_o   , //电机运行一圈，输出的脉冲总数
    //ABZ编码器输入 
    input                       ABZ_A_i                 ,   
    input                       ABZ_B_i                 ,   
    input                       ABZ_Z_i                     
);

localparam                  ENCODER_ABZ_MIN_RESOLUTION = 25'd11520;        //ABZ脉冲最小角度分辨率
localparam                  ENCODER_ABZ_ONE_CIRCLE     = 25'd23592960;     //最大角度数
localparam                  SPEED_DETECT_CYCLE         = 24'd1_000_00;     //速度检测时钟周期数   1ms

reg[23:0]          cnt;
reg signed[31:0]   plus;
reg signed[31:0]   speed_plus_cnt;
reg signed[31:0]   speed;
reg signed[31:0]   speed_d0;
reg signed[31:0]   speed_d1;
reg signed[31:0]   speed_d2;
reg signed[31:0]   speed_d3;
reg signed[31:0]   speed_d4;
reg signed[31:0]   speed_d5;
reg signed[31:0]   speed_d6;
reg signed[31:0]   speed_d7;
reg signed[31:0]  speed_sum_d0;
reg signed[31:0]  speed_sum_d1;

reg     ABZ_A_d0        ;
reg     ABZ_A_d1        ;
reg     ABZ_A_d2        ;
wire    ABZ_A_posedge   ;
wire    ABZ_A_negedge   ;

reg     ABZ_B_d0        ;
reg     ABZ_B_d1        ;
reg     ABZ_B_d2        ;
wire    ABZ_B_posedge   ;
wire    ABZ_B_negedge   ;

reg     ABZ_Z_d0        ;
reg     ABZ_Z_d1        ;
reg     ABZ_Z_d2        ;
wire    ABZ_Z_posedge   ;

reg     ABZ_valid       ;
reg     ABZ_dir         ;

assign ABZ_A_posedge = (!ABZ_A_d2) & ABZ_A_d1;
assign ABZ_A_negedge = (!ABZ_A_d1) & ABZ_A_d2;
assign ABZ_B_posedge = (!ABZ_B_d2) & ABZ_B_d1;
assign ABZ_B_negedge = (!ABZ_B_d1) & ABZ_B_d2;

assign ABZ_Z_posedge = (!ABZ_Z_d2) & ABZ_Z_d1;

assign motor_one_circle_o = ABZ_Z_posedge       ;


ila_0 ila_0_hp(
.clk            (sys_clk_i),


.probe0         ( ABZ_Z_posedge  ),
.probe1         ( ABZ_one_circle_plus_o  )
);

always@( posedge sys_clk_i ) begin
    ABZ_A_d0 <= ABZ_A_i;
    ABZ_A_d1 <= ABZ_A_d0;
    ABZ_A_d2 <= ABZ_A_d1;
    ABZ_B_d0 <= ABZ_B_i;
    ABZ_B_d1 <= ABZ_B_d0;
    ABZ_B_d2 <= ABZ_B_d1;
    ABZ_Z_d0 <= ABZ_Z_i;
    ABZ_Z_d1 <= ABZ_Z_d0;
    ABZ_Z_d2 <= ABZ_Z_d1;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        ABZ_valid <= 1'b0;
        ABZ_dir   <= 1'b0;
    end
    else if( ABZ_A_posedge == 1'b1 ) begin
        ABZ_valid <= 1'b1;
        ABZ_dir   <= ABZ_B_d0;
    end
    else if( ABZ_A_negedge == 1'b1 ) begin
        ABZ_valid <= 1'b1;
        ABZ_dir   <= !ABZ_B_d0;
    end
    else if( ABZ_B_posedge == 1'b1 ) begin
        ABZ_valid <= 1'b1;
        ABZ_dir   <= !ABZ_A_d0;
    end
    else if( ABZ_B_negedge == 1'b1 ) begin
        ABZ_valid <= 1'b1;
        ABZ_dir   <= ABZ_A_d0;
    end
    else begin
        ABZ_valid <= 1'b0;
        ABZ_dir   <= ABZ_dir;
    end
end

//统计脉冲总数
always@( posedge sys_clk_i ) begin
    if( ABZ_valid == 1'b1  )
        plus <= plus + 1'b1;
    else if( ABZ_Z_posedge == 1'b1 )
        plus <= 'd0;
    else
        plus <= plus;
end

always@(posedge sys_clk_i ) begin
    if( ABZ_Z_posedge == 1'b1 )
        ABZ_one_circle_plus_o <= plus;
    else 
        ABZ_one_circle_plus_o <= ABZ_one_circle_plus_o;
end


//输出当前角度
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        motor_angle_o <= 'd0;
    else if( ABZ_Z_posedge == 1'b1 )
        motor_angle_o <= 'd0;
    else if( ABZ_valid == 1'b1 && ABZ_dir == 1'b0)
        if(  motor_angle_o == ENCODER_ABZ_ONE_CIRCLE )
            motor_angle_o <= 'd0;
        else        
            motor_angle_o <= motor_angle_o + $signed(ENCODER_ABZ_MIN_RESOLUTION);
    else if( ABZ_valid == 1'b1 && ABZ_dir == 1'b1 )
        if( motor_angle_o == 'd0 )
            motor_angle_o <= ENCODER_ABZ_ONE_CIRCLE;
        else
            motor_angle_o <= motor_angle_o - $signed(ENCODER_ABZ_MIN_RESOLUTION);
    else
        motor_angle_o <= motor_angle_o;
end


//输出当前位置
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        motor_position_o <= 'd0;
    else if( motor_position_set_i == 1'b1 )
        motor_position_o <= 'd0;
    else if( motor_position_en_i == 1'b1 )
        if( ABZ_valid == 1'b1 && ABZ_dir == 1'b0 )
            motor_position_o <= motor_position_o + $signed(ENCODER_ABZ_MIN_RESOLUTION);
        else if( ABZ_valid == 1'b1 && ABZ_dir == 1'b1 )
            motor_position_o <= motor_position_o - $signed(ENCODER_ABZ_MIN_RESOLUTION);
        else
            motor_position_o <= motor_position_o;
    else
        motor_position_o <= 'd0;
end





//输出当前的速度 10ms计算一次
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        cnt <= 'd0;
    else if( cnt == SPEED_DETECT_CYCLE - 24'b1)
        cnt <= 'd0;
    else
        cnt <= cnt + 1'b1;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        speed_plus_cnt <= 32'd0;
    else if( cnt == SPEED_DETECT_CYCLE - 24'b1 )
        speed_plus_cnt <= 32'd0;
    else
        if( ABZ_valid == 1'b1 && ABZ_dir == 1'b1 )
            speed_plus_cnt <= speed_plus_cnt + 1'b1;
        else if(  ABZ_valid == 1'b1 && ABZ_dir == 1'b0 )
            speed_plus_cnt <= speed_plus_cnt - $signed(32'd1);
        else;
end
//2.93 * 100 = 293 = 256 + 32 + 4 + 1
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        speed <= 32'd0;
    else if( cnt == SPEED_DETECT_CYCLE - 1'b1  )
        speed <= ( speed_plus_cnt <<< 8 ) + (speed_plus_cnt <<< 5) +  (speed_plus_cnt <<< 2 )  + (speed_plus_cnt);
    else
        speed <= speed;
end

//滤波
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        speed_d0 <= 32'd0;
        speed_d1 <= 32'd0;
        speed_d2 <= 32'd0;
        speed_d3 <= 32'd0;
        speed_d4 <= 32'd0;
        speed_d5 <= 32'd0;
        speed_d6 <= 32'd0;
        speed_d7 <= 32'd0;
    end
    else if( cnt == 'd0 ) begin
        speed_d0 <= speed;
        speed_d1 <= speed_d0;
        speed_d2 <= speed_d1;
        speed_d3 <= speed_d2;
        speed_d4 <= speed_d3;
        speed_d5 <= speed_d4;
        speed_d6 <= speed_d5;
        speed_d7 <= speed_d6;
    end
    else;
end
always@( posedge sys_clk_i ) begin
    if( cnt == 'd1 ) begin
        speed_sum_d0 <= speed_d0 + speed_d1 + speed_d2 + speed_d3;
        speed_sum_d1 <= speed_d4 + speed_d5 + speed_d6 + speed_d7;
    end
    else;
end

always@( posedge sys_clk_i ) begin
    if( cnt == 'd2  )
        motor_speed_o <= (( ( speed_sum_d0 + speed_sum_d1 ) >>> 3 ));
    else;
end

endmodule
