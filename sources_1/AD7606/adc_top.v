`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/24 22:19:29
// Design Name: 
// Module Name: adc_top
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


module adc_top(
    input                       sys_clk_i                   ,
    input                       sys_rst_n_i                 ,

    input                       adc_req_i                   ,    //ad7606采样请求
    output                      adc_ack_o                   ,    //ad7606采样结束
    output                      adc_offset_finish_o         ,    //ad7606校准完成

    output reg signed[15:0]     m0_ia_o                     ,
    output reg signed[15:0]     m0_ib_o                     ,
    output reg signed[15:0]     m0_ic_o                     ,

    output reg signed[15:0]     m1_ia_o                     ,
    output reg signed[15:0]     m1_ib_o                     ,
    output reg signed[15:0]     m1_ic_o                     ,

    output reg signed[15:0]     m2_ia_o                     ,
    output reg signed[15:0]     m2_ib_o                     ,
    output reg signed[15:0]     m2_ic_o                     ,

    output reg signed[15:0]     m3_ia_o                     ,
    output reg signed[15:0]     m3_ib_o                     ,
    output reg signed[15:0]     m3_ic_o                     ,


    output[2:0]                 ad7606_osx_pin_o            ,    //过采样设置
    output                      ad7606_rst_pin_o            ,    //复位
    output                      ad7606_convst_a_pin_o       ,    //A通道开始转换
    output                      ad7606_convst_b_pin_o       ,    //B通道开始转换
    output                      ad7606_rd_n_pin_o           ,
    output                      ad7606_cs_n_pin_o           ,
    input                       ad7606_busy_pin_i           ,
    input[15:0]                 ad7606_data_pin_i                //AD7606并口数据
);

localparam  PWR_DELAY_CNT_TIME      =   'd4_000_000;

localparam  S_PWR_DELAY             =   5'b0000_1;
localparam  S_OFFSET_CNT            =   5'b0001_0;
localparam  S_OFFSET_WAIT           =   5'b0010_0;
localparam  S_OFFSET_CMP            =   5'b0100_0;
localparam  S_WORK                  =   5'b1000_0;




wire            ad7606_req                          ;                                     
wire            ad7606_ack                          ;                                     
//adc采样原始数据
wire[15:0]      ad7606_data_ch1                     ;
wire[15:0]      ad7606_data_ch2                     ;
wire[15:0]      ad7606_data_ch3                     ;
wire[15:0]      ad7606_data_ch4                     ;
wire[15:0]      ad7606_data_ch5                     ;
wire[15:0]      ad7606_data_ch6                     ;
wire[15:0]      ad7606_data_ch7                     ;
wire[15:0]      ad7606_data_ch8                     ;


//adc零偏 step1
reg[35:0]       ad7606_data_ch1_offset_sum          ;
reg[35:0]       ad7606_data_ch2_offset_sum          ;
reg[35:0]       ad7606_data_ch3_offset_sum          ;
reg[35:0]       ad7606_data_ch4_offset_sum          ;
reg[35:0]       ad7606_data_ch5_offset_sum          ;
reg[35:0]       ad7606_data_ch6_offset_sum          ;
reg[35:0]       ad7606_data_ch7_offset_sum          ;
reg[35:0]       ad7606_data_ch8_offset_sum          ;

//adc零偏 step1
reg[15:0]       ad7606_data_ch1_offset              ;
reg[15:0]       ad7606_data_ch2_offset              ;
reg[15:0]       ad7606_data_ch3_offset              ;
reg[15:0]       ad7606_data_ch4_offset              ;
reg[15:0]       ad7606_data_ch5_offset              ;
reg[15:0]       ad7606_data_ch6_offset              ;
reg[15:0]       ad7606_data_ch7_offset              ;
reg[15:0]       ad7606_data_ch8_offset              ;



reg[4:0]        state , next_state;

reg[31:0]       cnt;
reg[15:0]       wait_cnt;
reg[3:0]        cnt_cmp;


assign ad7606_req = ( state == S_OFFSET_CNT ) ? 1'b1 : 
                    ( state == S_WORK ) ? adc_req_i : 1'b0;

assign adc_ack_o  = ( state == S_WORK && cnt_cmp == 4'b0100 ) ? 1'b1 : 1'b0;

assign adc_offset_finish_o =  ( state == S_WORK ) ? 1'b1 : 1'b0;
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        state <= S_PWR_DELAY;
    else
        state <= next_state;
end


always@(*) begin
    case(state) 
    S_PWR_DELAY:
        if( cnt == PWR_DELAY_CNT_TIME )
            next_state <= S_OFFSET_CNT;
        else
            next_state <= S_PWR_DELAY;
    S_OFFSET_CNT:
        if( ad7606_ack == 1'b1 )
            if( cnt == 'd65535 )
                next_state <= S_OFFSET_CMP;
            else
                next_state <= S_OFFSET_WAIT;
        else
            next_state <= S_OFFSET_CNT;
    S_OFFSET_WAIT:
        if( wait_cnt == 'd2000 )
            next_state <= S_OFFSET_CNT;
        else
            next_state <= S_OFFSET_WAIT;
    S_OFFSET_CMP:
        next_state <= S_WORK;
    S_WORK:
        next_state <= S_WORK;
    default: next_state <= S_PWR_DELAY;
    endcase

end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i ==  1'b0 )
        cnt <= 'd0;
    else if( state == S_PWR_DELAY )
        if( cnt == PWR_DELAY_CNT_TIME )
            cnt <= 'd0;
        else 
            cnt <= cnt + 1'b1;
    else if( state == S_OFFSET_CNT || state == S_OFFSET_WAIT)
        if( ad7606_ack == 1'b1 )
            cnt <= cnt + 1'b1;
        else
            cnt <= cnt;
    else
        cnt <= 'd0;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) 
        wait_cnt <= 'd0;
    else if( state == S_OFFSET_WAIT )
        wait_cnt <= wait_cnt + 1'b1;
    else
        wait_cnt <= 'd0;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        ad7606_data_ch1_offset_sum <= 36'd0;
        ad7606_data_ch2_offset_sum <= 36'd0;
        ad7606_data_ch3_offset_sum <= 36'd0;
        ad7606_data_ch4_offset_sum <= 36'd0;
        ad7606_data_ch5_offset_sum <= 36'd0;
        ad7606_data_ch6_offset_sum <= 36'd0;
        ad7606_data_ch7_offset_sum <= 36'd0;
        ad7606_data_ch8_offset_sum <= 36'd0;
    end
    else if( state == S_OFFSET_CNT && ad7606_ack == 1'b1 ) begin
        ad7606_data_ch1_offset_sum <= ad7606_data_ch1_offset_sum + ad7606_data_ch1;
        ad7606_data_ch2_offset_sum <= ad7606_data_ch2_offset_sum + ad7606_data_ch2;
        ad7606_data_ch3_offset_sum <= ad7606_data_ch3_offset_sum + ad7606_data_ch3;
        ad7606_data_ch4_offset_sum <= ad7606_data_ch4_offset_sum + ad7606_data_ch4;
        ad7606_data_ch5_offset_sum <= ad7606_data_ch5_offset_sum + ad7606_data_ch5;
        ad7606_data_ch6_offset_sum <= ad7606_data_ch6_offset_sum + ad7606_data_ch6;
        ad7606_data_ch7_offset_sum <= ad7606_data_ch7_offset_sum + ad7606_data_ch7;
        ad7606_data_ch8_offset_sum <= ad7606_data_ch8_offset_sum + ad7606_data_ch8;
    end
    else begin
        ad7606_data_ch1_offset_sum <= ad7606_data_ch1_offset_sum;
        ad7606_data_ch2_offset_sum <= ad7606_data_ch2_offset_sum;
        ad7606_data_ch3_offset_sum <= ad7606_data_ch3_offset_sum;
        ad7606_data_ch4_offset_sum <= ad7606_data_ch4_offset_sum;
        ad7606_data_ch5_offset_sum <= ad7606_data_ch5_offset_sum;
        ad7606_data_ch6_offset_sum <= ad7606_data_ch6_offset_sum;
        ad7606_data_ch7_offset_sum <= ad7606_data_ch7_offset_sum;
        ad7606_data_ch8_offset_sum <= ad7606_data_ch8_offset_sum;
    end
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        ad7606_data_ch1_offset <= 'd0;
        ad7606_data_ch2_offset <= 'd0;
        ad7606_data_ch3_offset <= 'd0;
        ad7606_data_ch4_offset <= 'd0;
        ad7606_data_ch5_offset <= 'd0;
        ad7606_data_ch6_offset <= 'd0;
        ad7606_data_ch7_offset <= 'd0;
        ad7606_data_ch8_offset <= 'd0;
    end
    else if( state == S_OFFSET_CMP ) begin
        ad7606_data_ch1_offset <=  ad7606_data_ch1_offset_sum >> 16;
        ad7606_data_ch2_offset <=  ad7606_data_ch2_offset_sum >> 16;
        ad7606_data_ch3_offset <=  ad7606_data_ch3_offset_sum >> 16;
        ad7606_data_ch4_offset <=  ad7606_data_ch4_offset_sum >> 16;
        ad7606_data_ch5_offset <=  ad7606_data_ch5_offset_sum >> 16;
        ad7606_data_ch6_offset <=  ad7606_data_ch6_offset_sum >> 16;
        ad7606_data_ch7_offset <=  ad7606_data_ch7_offset_sum >> 16;
        ad7606_data_ch8_offset <=  ad7606_data_ch8_offset_sum >> 16;

    end
    else;
end





always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        cnt_cmp <= 'd0;
    else if( ad7606_ack == 1'b1 )
        cnt_cmp <= 4'b0001;
    else
        cnt_cmp <= cnt_cmp << 1;    
end



always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        m0_ia_o <= 16'd0;
        m0_ib_o <= 16'd0;
        m0_ic_o <= 16'd0;
    end
    else if( ad7606_ack == 1'b1 ) begin
        m0_ia_o <= ( ad7606_data_ch1 - ad7606_data_ch1_offset - 'd20);
        m0_ib_o <= ( ad7606_data_ch2 - ad7606_data_ch2_offset - 'd22);
        m0_ic_o <= m0_ic_o;
    end
    else if( cnt_cmp == 4'b0001 ) begin
        m0_ia_o <= m0_ia_o;
        m0_ib_o <= m0_ib_o;
        m0_ic_o <= ( m0_ia_o + m0_ib_o );
    end
    else if( cnt_cmp == 4'b0010 ) begin
        m0_ia_o <= m0_ia_o;
        m0_ib_o <= m0_ib_o;
        m0_ic_o <= -m0_ic_o;
    end
    else;
end
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        m1_ia_o <= 16'd0;
        m1_ib_o <= 16'd0;
        m1_ic_o <= 16'd0;
    end
    else if( ad7606_ack == 1'b1 ) begin
        m1_ia_o <= ( ad7606_data_ch3 - ad7606_data_ch3_offset - 'd18);
        m1_ib_o <= ( ad7606_data_ch4 - ad7606_data_ch4_offset - 'd20);
        m1_ic_o <= m1_ic_o;
    end
    else if( cnt_cmp == 4'b0001 ) begin
        m1_ia_o <= m1_ia_o;
        m1_ib_o <= m1_ib_o;
        m1_ic_o <= ( m1_ia_o + m1_ib_o );
    end
    else if( cnt_cmp == 4'b0010 ) begin
        m1_ia_o <= m1_ia_o;
        m1_ib_o <= m1_ib_o;
        m1_ic_o <= -m1_ic_o;
    end
    else;
end
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        m2_ia_o <= 16'd0;
        m2_ib_o <= 16'd0;
        m2_ic_o <= 16'd0;
    end
    else if( ad7606_ack == 1'b1 ) begin
        m2_ia_o <= ( ad7606_data_ch5 - ad7606_data_ch5_offset );
        m2_ib_o <= ( ad7606_data_ch6 - ad7606_data_ch6_offset );
        m2_ic_o <= m2_ic_o;
    end
    else if( cnt_cmp == 4'b0001 ) begin
        m2_ia_o <= m2_ia_o;
        m2_ib_o <= m2_ib_o;
        m2_ic_o <= ( m2_ia_o + m2_ib_o );
    end
    else if( cnt_cmp == 4'b0010 ) begin
        m2_ia_o <= m2_ia_o;
        m2_ib_o <= m2_ib_o;
        m2_ic_o <= -m2_ic_o;
    end
    else;
end
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        m3_ia_o <= 16'd0;
        m3_ib_o <= 16'd0;
        m3_ic_o <= 16'd0;
    end
    else if( ad7606_ack == 1'b1 ) begin
        m3_ia_o <= ( ad7606_data_ch7 - ad7606_data_ch7_offset );
        m3_ib_o <= ( ad7606_data_ch8 - ad7606_data_ch8_offset );
        m3_ic_o <= m3_ic_o;
    end
    else if( cnt_cmp == 4'b0001 ) begin
        m3_ia_o <= m3_ia_o;
        m3_ib_o <= m3_ib_o;
        m3_ic_o <= ( m3_ia_o + m3_ib_o );
    end
    else if( cnt_cmp == 4'b0010 ) begin
        m3_ia_o <= m3_ia_o;
        m3_ib_o <= m3_ib_o;
        m3_ic_o <= -m3_ic_o;
    end
    else;
end



ad7606_driver ad7606_driver_hp(
    .sys_clk_i                              (       sys_clk_i                           ),
    .sys_rst_n_i                            (       sys_rst_n_i                         ),

    .ad7606_req_i                           (       ad7606_req                          ),    //ad7606采样请求
    .ad7606_ack_o                           (       ad7606_ack                          ),    //ad7606采样结束
    .ad7606_data_ch1_o                      (       ad7606_data_ch1                     ),    
    .ad7606_data_ch2_o                      (       ad7606_data_ch2                     ),
    .ad7606_data_ch3_o                      (       ad7606_data_ch3                     ),
    .ad7606_data_ch4_o                      (       ad7606_data_ch4                     ),
    .ad7606_data_ch5_o                      (       ad7606_data_ch5                     ),
    .ad7606_data_ch6_o                      (       ad7606_data_ch6                     ),
    .ad7606_data_ch7_o                      (       ad7606_data_ch7                     ),
    .ad7606_data_ch8_o                      (       ad7606_data_ch8                     ),



    .ad7606_osx_pin_o                       (       ad7606_osx_pin_o                    ),    //过采样设置
    .ad7606_rst_pin_o                       (       ad7606_rst_pin_o                    ),    //复位
    .ad7606_convst_a_pin_o                  (       ad7606_convst_a_pin_o               ),    //A通道开始转换
    .ad7606_convst_b_pin_o                  (       ad7606_convst_b_pin_o               ),    //B通道开始转换
    .ad7606_rd_n_pin_o                      (       ad7606_rd_n_pin_o                   ),
    .ad7606_cs_n_pin_o                      (       ad7606_cs_n_pin_o                   ),
    .ad7606_busy_pin_i                      (       ad7606_busy_pin_i                   ),
    .ad7606_frstdata_pin_i                  (       1'b0                                ),
    .ad7606_data_pin_i                      (       ad7606_data_pin_i                   )     //AD7606并口数据
);


// ila_5 ila_5_hp(
// .clk ( sys_clk_i ),
// .probe0 ( ad7606_req                   ),
// .probe1 ( ad7606_ack                   ),
// .probe2 ( ad7606_data_ch1              ),
// .probe3 ( ad7606_data_ch2              ),
// .probe4 ( ad7606_data_ch3              ),
// .probe5 ( ad7606_data_ch4              ),
// .probe6 ( ad7606_data_ch5              ),
// .probe7 ( ad7606_data_ch6              ),
// .probe8 ( ad7606_data_ch7              ),
// .probe9 ( ad7606_data_ch8              ),

// .probe10 (ad7606_osx_pin_o                     ),
// .probe11 (ad7606_rst_pin_o                     ),
// .probe12 (ad7606_convst_a_pin_o                ),
// .probe13 (ad7606_convst_b_pin_o                ),
// .probe14 (ad7606_rd_n_pin_o                    ),
// .probe15 (ad7606_cs_n_pin_o                    ),
// .probe16 (ad7606_busy_pin_i                    ),
// .probe17 (ad7606_data_pin_i                    )
// );
endmodule
