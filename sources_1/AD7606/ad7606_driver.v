`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/21 19:44:03
// Design Name: 
// Module Name: ad7606_driver
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


module ad7606_driver(
    input                   sys_clk_i                   ,
    input                   sys_rst_n_i                 ,

    input                   ad7606_req_i                ,    //ad7606采样请求
    output                  ad7606_ack_o                ,    //ad7606采样结束
    output reg[15:0]        ad7606_data_ch1_o           ,    
    output reg[15:0]        ad7606_data_ch2_o           ,
    output reg[15:0]        ad7606_data_ch3_o           ,
    output reg[15:0]        ad7606_data_ch4_o           ,
    output reg[15:0]        ad7606_data_ch5_o           ,
    output reg[15:0]        ad7606_data_ch6_o           ,
    output reg[15:0]        ad7606_data_ch7_o           ,
    output reg[15:0]        ad7606_data_ch8_o           ,



    output[2:0]             ad7606_osx_pin_o            ,    //过采样设置
    output                  ad7606_rst_pin_o            ,    //复位
    output                  ad7606_convst_a_pin_o       ,    //A通道开始转换
    output                  ad7606_convst_b_pin_o       ,    //B通道开始转换
    output reg              ad7606_rd_n_pin_o           ,
    output reg              ad7606_cs_n_pin_o           ,
    input                   ad7606_busy_pin_i           ,
    input                   ad7606_frstdata_pin_i       ,
    input[15:0]             ad7606_data_pin_i                //AD7606并口数据
);


assign ad7606_osx_pin_o = 3'b000;

localparam S_PWR_DELAY  =   15'd0;
localparam S_RESET      =   15'd2;
localparam S_IDLE       =   15'd4;
localparam S_CONVST     =   15'd8;
localparam S_WAIT_BUSY  =   15'd16;
localparam S_LOCK       =   15'd32;
localparam S_READ_CH1   =   15'd64;
localparam S_READ_CH2   =   15'd128;
localparam S_READ_CH3   =   15'd256;
localparam S_READ_CH4   =   15'd512;
localparam S_READ_CH5   =   15'd1024;
localparam S_READ_CH6   =   15'd2048;
localparam S_READ_CH7   =   15'd4096;
localparam S_READ_CH8   =   15'd8192;
localparam S_END        =   15'd16384;


localparam  PWR_TIME_CNT    =   'd5000;
localparam  RESET_TIME_CNT  =   'd8;
localparam  CONVST_TIME_CNT =   'd3;
localparam  RD_LOW_TIME_CNT =   'd4;
localparam  RD_HIGH_TIME_CNT=   'd2;
reg[14:0]    state , next_state;

reg[24:0]   cnt;


assign ad7606_rst_pin_o = ( state == S_RESET ) ? 1'b1 : 1'b0;
assign ad7606_convst_a_pin_o = ( state == S_CONVST ) ? 1'b0 : 1'b1;
assign ad7606_convst_b_pin_o = ( state == S_CONVST ) ? 1'b0 : 1'b1;
assign ad7606_ack_o          = ( state == S_END && cnt == 'd6) ? 1'b1 : 1'b0;

always @( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        state <= S_PWR_DELAY;
    else
        state <= next_state;    
end


always@(*) begin
    case (state)
        S_PWR_DELAY:  
            if( cnt == PWR_TIME_CNT )
                next_state <= S_RESET;
            else
                next_state <= S_PWR_DELAY;
        S_RESET:
            if( cnt ==  RESET_TIME_CNT )
                next_state <= S_IDLE;
            else
                next_state <= S_RESET;
        S_IDLE:
            if( ad7606_req_i == 1'b1 )
                next_state <= S_CONVST;
            else
                next_state <= S_IDLE;
        S_CONVST:
            if( cnt == CONVST_TIME_CNT )
                next_state <= S_WAIT_BUSY;
            else
                next_state <= S_CONVST;
        S_WAIT_BUSY:
            if( cnt > 'd8 && ad7606_busy_pin_i == 1'b0 )
                next_state <= S_LOCK;
            else
                next_state <= S_WAIT_BUSY;
        S_LOCK:
            next_state <= S_READ_CH1;
        S_READ_CH1:
            if( cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
                next_state <= S_READ_CH2;
            else
                next_state <= S_READ_CH1;
        S_READ_CH2:
            if( cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
                next_state <= S_READ_CH3;
            else
                next_state <= S_READ_CH2;
        S_READ_CH3:
            if( cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
                next_state <= S_READ_CH4;
            else
                next_state <= S_READ_CH3;
        S_READ_CH4:
            if( cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
                next_state <= S_READ_CH5;
            else
                next_state <= S_READ_CH4;
        S_READ_CH5:
            if( cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
                next_state <= S_READ_CH6;
            else
                next_state <= S_READ_CH5;
        S_READ_CH6:
            if( cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
                next_state <= S_READ_CH7;
            else
                next_state <= S_READ_CH6;
        S_READ_CH7:
            if( cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
                next_state <= S_READ_CH8;
            else
                next_state <= S_READ_CH7;
        S_READ_CH8:
            if( cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
                next_state <= S_END;
            else
                next_state <= S_READ_CH8;
        S_END:
            if( cnt >= 'd8 )
                next_state <= S_IDLE;
            else
                next_state <= S_END;
        default: 
            next_state <= S_PWR_DELAY;
    endcase
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        cnt <= 'd0;
    else if ( state == S_IDLE )
        cnt <= 'd0;
    else if( state == S_PWR_DELAY && cnt == PWR_TIME_CNT )
        cnt <= 'd0;
    else if( state == S_RESET && cnt == RESET_TIME_CNT )
        cnt <= 'd0;
    else if( state == S_CONVST && cnt == CONVST_TIME_CNT )
        cnt <= 'd0;
    else if( state == S_WAIT_BUSY && cnt > 'd8 && ad7606_busy_pin_i == 1'b0  )
        cnt <= 'd0;
    else if( state == S_LOCK )
        cnt <= 'd0;
    else if( state == S_READ_CH1 && cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
        cnt <= 'd0; 
    else if( state == S_READ_CH2 && cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
        cnt <= 'd0; 
    else if( state == S_READ_CH3 && cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
        cnt <= 'd0; 
    else if( state == S_READ_CH4 && cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
        cnt <= 'd0; 
    else if( state == S_READ_CH5 && cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
        cnt <= 'd0; 
    else if( state == S_READ_CH6 && cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
        cnt <= 'd0;
    else if( state == S_READ_CH7 && cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
        cnt <= 'd0; 
    else if( state == S_READ_CH8 && cnt >= ( RD_LOW_TIME_CNT + RD_HIGH_TIME_CNT))
        cnt <= 'd0; 
    else if( state == S_END && cnt >= 'd8 )
        cnt <= 'd0; 
    else
        cnt <= cnt + 1'b1;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        ad7606_cs_n_pin_o <= 1'b1;
    else if( state == S_END && cnt == 'd4 )
        ad7606_cs_n_pin_o <= 1'b1;
    else if( state == S_LOCK )
        ad7606_cs_n_pin_o <= 1'b0;
    else
        ad7606_cs_n_pin_o <= ad7606_cs_n_pin_o;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        ad7606_rd_n_pin_o <= 1'b1;
    else if( state == S_READ_CH1 || state == S_READ_CH2 || state == S_READ_CH3 || state == S_READ_CH4 || state == S_READ_CH5 || state == S_READ_CH6 ||
             state == S_READ_CH7 || state == S_READ_CH8)
        if( cnt <= RD_LOW_TIME_CNT )
            ad7606_rd_n_pin_o <= 1'b0;
        else
            ad7606_rd_n_pin_o <= 1'b1;
    else
        ad7606_rd_n_pin_o <= ad7606_rd_n_pin_o;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        ad7606_data_ch1_o <= 'd0;
    else if( state == S_READ_CH1 && cnt == RD_LOW_TIME_CNT )
        ad7606_data_ch1_o <= ad7606_data_pin_i;
    else
        ad7606_data_ch1_o <= ad7606_data_ch1_o;
end
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        ad7606_data_ch2_o <= 'd0;
    else if( state == S_READ_CH2 && cnt == RD_LOW_TIME_CNT )
        ad7606_data_ch2_o <= ad7606_data_pin_i;
    else
        ad7606_data_ch2_o <= ad7606_data_ch2_o;
end
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        ad7606_data_ch3_o <= 'd0;
    else if( state == S_READ_CH3 && cnt == RD_LOW_TIME_CNT )
        ad7606_data_ch3_o <= ad7606_data_pin_i;
    else
        ad7606_data_ch3_o <= ad7606_data_ch3_o;
end
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        ad7606_data_ch4_o <= 'd0;
    else if( state == S_READ_CH4 && cnt == RD_LOW_TIME_CNT )
        ad7606_data_ch4_o <= ad7606_data_pin_i;
    else
        ad7606_data_ch4_o <= ad7606_data_ch4_o;
end
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        ad7606_data_ch5_o <= 'd0;
    else if( state == S_READ_CH5 && cnt == RD_LOW_TIME_CNT )
        ad7606_data_ch5_o <= ad7606_data_pin_i;
    else
        ad7606_data_ch5_o <= ad7606_data_ch5_o;
end
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        ad7606_data_ch6_o <= 'd0;
    else if( state == S_READ_CH6 && cnt == RD_LOW_TIME_CNT )
        ad7606_data_ch6_o <= ad7606_data_pin_i;
    else
        ad7606_data_ch6_o <= ad7606_data_ch6_o;
end
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        ad7606_data_ch7_o <= 'd0;
    else if( state == S_READ_CH7 && cnt == RD_LOW_TIME_CNT )
        ad7606_data_ch7_o <= ad7606_data_pin_i;
    else
        ad7606_data_ch7_o <= ad7606_data_ch7_o;
end
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        ad7606_data_ch8_o <= 'd0;
    else if( state == S_READ_CH8 && cnt == RD_LOW_TIME_CNT )
        ad7606_data_ch8_o <= ad7606_data_pin_i;
    else
        ad7606_data_ch8_o <= ad7606_data_ch8_o;
end
endmodule
