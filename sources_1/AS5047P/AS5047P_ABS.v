`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/06 09:43:58
// Design Name: FPGA之旅
// Module Name: AS5047P_ABS
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 周期为10ms  速度扩大100倍输出
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: AS5047P通过绝对值获取电机位置信息 
// 1440    1°/s = 0.1667 RPM
//////////////////////////////////////////////////////////////////////////////////




module AS5047P_ABS(
    input                       sys_clk_i               ,
    input                       sys_rst_n_i             ,

    input                       abs_req_i               ,

    
    input                       motor_position_en_i     , //电机位置检测使能
    input                       motor_position_set_i    , //设置电机当前位置为初始位置 
    output reg [24:0]           motor_angle_o           , //电机当前角度
    output reg signed[31:0]     motor_speed_o           , //电机当前速度
    output reg signed[31:0]     motor_position_o        , //电机当前位置
    output                      abs_motor_one_circle_o  , //电机输出一圈标志
    //SPI接口
    output                      spi_start_en_o          ,
    output[15:0]                spi_tx_data_o           ,
    input[15:0]                 spi_rx_data_i           ,
    input                       spi_end_ack_i           
);
localparam SPEED_DETECT_CYCLE     = 24'd10_000                   ;   //速度检测时钟周期数       100us = 0.0001s
localparam ANGLE_GAP_DETECT_CYCLE = 24'd5000                     ;   //角度间隔检测时钟周期数    50us


localparam S_IDLE           = 'd0;
localparam S_GET_ANGLE      = 'd1;
localparam S_DELAY          = 'd2;
localparam S_GET_ANGLE2     = 'd3;
localparam S_PARITY_CHECK   = 'd4;
localparam S_ANGLE_CAL      = 'd5;
localparam S_ERROR          = 'd6;
localparam S_ACK            = 'd7;


reg[4:0]  state , next_state;
reg[15:0] cnt;   
reg[15:0] gap_cnt;
reg[15:0] raw_angle;

reg[15:0] last_angle;
reg[15:0] curr_angle;

reg signed[15:0] raw_angle_gap_dd;

reg signed[15:0] raw_angle_gap_d;
reg signed[15:0] raw_angle_gap;   
reg signed[24:0] angle_gap_sum;

reg signed[31:0] speed_temp1;
reg signed[31:0] speed_temp2;
reg signed[31:0] speed;
reg signed[31:0] speed_d0;
reg signed[31:0] speed_d1;
reg signed[31:0] speed_d2;
reg signed[31:0] speed_d3;
reg signed[31:0] speed_d4;
reg signed[31:0] speed_d5;
reg signed[31:0] speed_d6;
reg signed[31:0] speed_d7;
reg signed[31:0] speed_d8;
reg signed[31:0] speed_d9;
reg signed[31:0] speed_d10;
reg signed[31:0] speed_d11;
reg signed[31:0] speed_d12;
reg signed[31:0] speed_d13;
reg signed[31:0] speed_d14;
reg signed[31:0] speed_d15;
reg signed[31:0] speed_sum_d0;
reg signed[31:0] speed_sum_d1;
reg signed[31:0] speed_sum_d2;
reg signed[31:0] speed_sum_d3;



reg[24:0] motor_angle_part1;
reg[24:0] motor_angle_part2;



reg signed[24:0]  motor_speed_d0;
reg signed[24:0]  motor_speed_d1;
reg signed[24:0]  motor_speed_d2;
reg signed[24:0]  motor_speed_d3;




reg[24:0] speed_cnt;
reg[15:0] one_circle_delay;
reg       one_circle_delay_flag;   

reg       error;

reg      abs_motor_one_circle_d0,abs_motor_one_circle_d1;
wire     abs_motor_one_circle_negedge;



assign abs_motor_one_circle_negedge = (~abs_motor_one_circle_d0) & abs_motor_one_circle_d1;

assign abs_motor_one_circle_o       = ( abs_motor_one_circle_negedge == 1'b1 &&  one_circle_delay == 'd0 ) ? 1'b1 : 1'b0;



assign spi_start_en_o = ( state == S_GET_ANGLE || state == S_GET_ANGLE2 ) ? 1'b1 : 1'b0;
assign spi_tx_data_o  = ( state == S_GET_ANGLE )  ? 16'hFFFF :
                        ( state == S_GET_ANGLE2)  ? 16'hFFFF : 'd0;






always@(posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        state <= S_IDLE;
    else
        state <= next_state;
end

always@(*) begin
    case (state)
        S_IDLE:
            if( abs_req_i == 1'b1 )
                next_state <= S_GET_ANGLE;
            else
                next_state <= S_IDLE;
        S_GET_ANGLE:
            if( spi_end_ack_i == 1'b1 )
                next_state <= S_DELAY;
            else
                next_state <= S_GET_ANGLE;
        S_DELAY:    
            if( cnt == 'd200 )
                next_state <= S_GET_ANGLE2;
            else
                next_state <= S_DELAY;
        S_GET_ANGLE2:
            if( spi_end_ack_i == 1'b1 )
                next_state <= S_PARITY_CHECK;
            else
                next_state <= S_GET_ANGLE2;
        S_PARITY_CHECK:
            if( error == 1'b1 )
                next_state <= S_ERROR;
            else if( cnt == 'd3)
                next_state <= S_ANGLE_CAL;
            else
                next_state <= S_PARITY_CHECK;
        S_ANGLE_CAL:
            if( cnt == 'd1 )
                next_state <= S_ACK;
            else
                next_state <= S_ANGLE_CAL;
        S_ERROR:
            if( cnt == 'd200)
                next_state <= S_GET_ANGLE;
            else
                next_state <= S_ERROR;
        S_ACK:
            if( cnt == 'd1000)
                next_state <= S_IDLE;
            else
                next_state <= S_ACK;
        default:next_state <= S_IDLE;
    endcase
end


always@( posedge sys_clk_i ) begin
    if( state != next_state )
        cnt <= 'd0;
    else if( state == S_DELAY )
        cnt <= cnt + 1'b1;
    else if( state == S_PARITY_CHECK )
        cnt <= cnt + 1'b1;
    else if( state == S_ANGLE_CAL )
        cnt <= cnt + 1'b1;
    else if( state == S_ERROR )
        cnt <= cnt + 1'b1;
    else if( state == S_ACK )
        cnt <= cnt + 1'b1;
    else
        cnt <= 'd0;
end

always@( posedge sys_clk_i ) begin
    if( state == S_GET_ANGLE2 && spi_end_ack_i == 1'b1 )
        raw_angle <= spi_rx_data_i[15:0];
    else
        raw_angle <= raw_angle;
end

always@( posedge sys_clk_i ) begin
    if( state == S_GET_ANGLE2 && spi_end_ack_i == 1'b1 )
        raw_angle_gap_dd <= $signed({2'b0,raw_angle[13:0]}) - $signed({2'b0,spi_rx_data_i[13:0]});
    else
        raw_angle_gap_dd <= raw_angle_gap_dd;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        abs_motor_one_circle_d0 <= 1'b1;
        abs_motor_one_circle_d1 <= 1'b1;
    end
    else if( state == S_ANGLE_CAL && cnt == 'd0 )
        if(  raw_angle_gap_dd < $signed(-10000)  ||  raw_angle_gap_dd > $signed(10000)) begin
            abs_motor_one_circle_d0 <= 1'b0;
            abs_motor_one_circle_d1 <= abs_motor_one_circle_d0;
        end
        else begin
            abs_motor_one_circle_d0 <= abs_motor_one_circle_d0;
            abs_motor_one_circle_d1 <= abs_motor_one_circle_d0;
        end
    else begin
            abs_motor_one_circle_d0 <= 1'b1;
            abs_motor_one_circle_d1 <= abs_motor_one_circle_d0;
    end
end
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        one_circle_delay_flag <= 1'b0;
    else if( one_circle_delay == 'd400 ) 
        one_circle_delay_flag <= 1'b0;
    else if( abs_motor_one_circle_negedge == 1'b1 )
        one_circle_delay_flag <= 1'b1;
    else
        one_circle_delay_flag <= one_circle_delay_flag;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        one_circle_delay <= 16'd0;
    else if( one_circle_delay == 'd400 )
        one_circle_delay <= 'd0;
    else if( state == S_ANGLE_CAL && cnt == 'd1 && one_circle_delay_flag == 1'b1 )
        one_circle_delay <= one_circle_delay + 1'b1;
    else
        one_circle_delay <= one_circle_delay;
end




always@( posedge sys_clk_i ) begin
    if( state == S_PARITY_CHECK && cnt == 'd0 )
        if( raw_angle[14] == 1'b1 )
            error <= 1'b1;
        else
            error <= 1'b0;
    else if( state == S_PARITY_CHECK && cnt == 'd1)
        if((^raw_angle) == 1'b1 )
            error <= 1'b1;
        else
            error <= 1'b0;
    else
        error <= 1'b0;
end




//1440 = 1024(2^10) + 256(2^8) + 128(2^7) + 32(2^5)
always@( posedge sys_clk_i ) begin
    if( state == S_ANGLE_CAL && cnt == 'd0 )
        motor_angle_part1 <= ({2'b00,raw_angle[13:0]} << 10) + ({2'b00,raw_angle[13:0]} << 8);
    else
        motor_angle_part1 <= motor_angle_part1;
end
always@( posedge sys_clk_i ) begin
    if( state == S_ANGLE_CAL && cnt == 'd0 )
        motor_angle_part2 <= ({2'b00,raw_angle[13:0]} << 7) + ({2'b00,raw_angle[13:0]} << 5);
    else
        motor_angle_part2 <= motor_angle_part2;
end
always@( posedge sys_clk_i ) begin
    if( state == S_ANGLE_CAL && cnt == 'd1 )
        motor_angle_o <= motor_angle_part1 + motor_angle_part2;
    else
        motor_angle_o <= motor_angle_o;
end




always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )   
        speed_cnt <= 'd0;
    else if( speed_cnt == SPEED_DETECT_CYCLE - 1'b1 )
        speed_cnt <= 'd0;
    else
        speed_cnt <= speed_cnt + 1'b1;

end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        gap_cnt <= 'd0;
    else if( gap_cnt == ANGLE_GAP_DETECT_CYCLE - 1'b1 )
        gap_cnt <= 'd0;    
    else
        gap_cnt <= gap_cnt + 1'b1;
end

always@( posedge sys_clk_i ) begin
    if( gap_cnt == ANGLE_GAP_DETECT_CYCLE - 1'b1 )
        last_angle <= curr_angle;
    else
        last_angle <= last_angle;
end

always@( posedge sys_clk_i ) begin
    if( state == S_ANGLE_CAL && cnt == 'd0 )
        curr_angle <= raw_angle[13:0];
    else
        curr_angle <= curr_angle;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        raw_angle_gap_d <= 'd0;
    else if( gap_cnt == ANGLE_GAP_DETECT_CYCLE - 1'b1 )
        raw_angle_gap_d <= curr_angle - last_angle;
    else
        raw_angle_gap_d <= raw_angle_gap_d;
end


always@( posedge sys_clk_i ) begin
    if( gap_cnt == 'd0  )
        if( raw_angle_gap_d < $signed(-10000) )
            raw_angle_gap <=  $signed(16'd16384) + raw_angle_gap_d;
        else if( raw_angle_gap_d > $signed(10000))
            raw_angle_gap <= raw_angle_gap_d - $signed(16'd16384);
        else
            raw_angle_gap <= raw_angle_gap_d;
    else
        raw_angle_gap <= raw_angle_gap;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        angle_gap_sum <= 'd0;
    else if( speed_cnt == SPEED_DETECT_CYCLE - 1'b1)
        angle_gap_sum <= 'd0;
    else if( gap_cnt == 'd1 )
        angle_gap_sum <= angle_gap_sum + raw_angle_gap;
    else
        angle_gap_sum <= angle_gap_sum;
end
// x * 219.73  = M ° / s
// M * 0.1667  = N rpm
// N = x * 36.628
// N * 100 = x * 3662.8
// 3662.8 ≈ 2048 + 1024 + 512 + 64  + 16 - 2 + 0.5 + 0.25
always@( posedge sys_clk_i ) begin
    if( speed_cnt == SPEED_DETECT_CYCLE - 2'd2 )
        speed_temp1 <= (angle_gap_sum <<< 11) + (angle_gap_sum <<< 10) + (angle_gap_sum <<< 9) + (angle_gap_sum <<< 6);
    else
        speed_temp1 <= speed_temp1;
end
always@( posedge sys_clk_i ) begin
    if( speed_cnt == SPEED_DETECT_CYCLE - 2'd2 )
        speed_temp2 <= (angle_gap_sum <<< 4)  - (angle_gap_sum <<< 1) + (angle_gap_sum >>> 1) + (angle_gap_sum >>> 2);
    else
        speed_temp2 <= speed_temp2;
end
always@( posedge sys_clk_i ) begin
    if( speed_cnt == SPEED_DETECT_CYCLE - 2'd1 )
        speed <= speed_temp1 + speed_temp2;
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
        speed_d8 <= 32'd0;
        speed_d9 <= 32'd0;
        speed_d10 <= 32'd0;
        speed_d11 <= 32'd0;
        speed_d12 <= 32'd0;
        speed_d13 <= 32'd0;
        speed_d14 <= 32'd0;
        speed_d15 <= 32'd0;
    end
    else if( speed_cnt == 'd0 ) begin
        speed_d0 <= speed;
        speed_d1 <= speed_d0;
        speed_d2 <= speed_d1;
        speed_d3 <= speed_d2;
        speed_d4 <= speed_d3;
        speed_d5 <= speed_d4;
        speed_d6 <= speed_d5;
        speed_d7 <=  speed_d6;
        speed_d8  <= speed_d7 ;
        speed_d9  <= speed_d8 ;
        speed_d10 <= speed_d9 ;
        speed_d11 <= speed_d10;
        speed_d12 <= speed_d11;
        speed_d13 <= speed_d12;
        speed_d14 <= speed_d13;
        speed_d15 <= speed_d14;
    end
    else;
end
always@( posedge sys_clk_i ) begin
    if( speed_cnt == 'd1 ) begin
        speed_sum_d0 <= (speed_d0 + speed_d1 + speed_d2 + speed_d3) >>> 2;
        speed_sum_d1 <= (speed_d4 + speed_d5 + speed_d6 + speed_d7) >>> 2;
        speed_sum_d2 <= (speed_d8 + speed_d9 + speed_d10 + speed_d11) >>> 2;
        speed_sum_d3 <= (speed_d12 + speed_d13 + speed_d14 + speed_d15) >>> 2;
    end
    else;
end

always@( posedge sys_clk_i ) begin
    if( speed_cnt == 'd2  )
        motor_speed_o <= (( ( speed_sum_d0 + speed_sum_d1 + speed_sum_d2 + speed_sum_d3 ) >>> 2 ));
    else;
end

always@( posedge sys_clk_i) begin
    if( motor_position_set_i == 1'b1 )
        motor_position_o <= 'd0;
    else if( gap_cnt == 'd1 && motor_position_en_i == 1'b1)
        motor_position_o <= motor_position_o + ( raw_angle_gap );
    else
        motor_position_o <= motor_position_o; 
end

endmodule
