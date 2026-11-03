`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/17 12:05:22
// Design Name: FPGA之旅
// Module Name: AS5047P_SPI
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


module AS5047P_SPI #(
    parameter               CPOL            =   1'b1    ,
    parameter               CPHA            =   1'b0    ,
    parameter               SCLK_DIV        =   8'd4    , //4 8 16 32 64分频系数
    parameter               DATA_WIDTH      =   16'd16  
)(
    input                   sys_clk_i                   ,
    input                   sys_rst_n_i                 ,

    input                   spi_start_en_i              ,
    input [DATA_WIDTH-1:0]  spi_tx_data_i               ,
    output[DATA_WIDTH-1:0]  spi_rx_data_o               ,
    output                  spi_end_ack_o               ,

    //spi 接口
    output reg              spi_csn_p_o                 ,
    output reg              spi_sclk_p_o                ,  
    input                   spi_miso_p_i                ,
    output reg              spi_mosi_p_o                
);

reg[18:0] cnt; 
reg[5:0]  sclk_div_cnt;
reg       spi_dealing;

reg[DATA_WIDTH-1:0] spi_tx_data_r;
reg[DATA_WIDTH-1:0] spi_rx_data_r;

assign spi_rx_data_o = spi_rx_data_r;
assign spi_end_ack_o = ( cnt == ((DATA_WIDTH * SCLK_DIV ) + 'd5)) ? 1'b1 : 1'b0;

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        spi_dealing <= 1'b0;
    else if( cnt > (DATA_WIDTH * SCLK_DIV ) - 1'b1 )
        spi_dealing <= 1'b0;
    else if( spi_start_en_i == 1'b1 )
        spi_dealing <= 1'b1;
    else
        spi_dealing <= spi_dealing;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )   
        cnt <= 'd0;
    else if( spi_end_ack_o == 1'b1 )
        cnt <= 'd0;
    else if( spi_dealing == 1'b1 )
        cnt <= cnt + 1'b1;
    else if( cnt != 'd0 )
        cnt <= cnt + 1'b1;
    else
        cnt <= 'd0;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        sclk_div_cnt <= 'd0;
    else if( spi_dealing == 1'b1 )
        if( sclk_div_cnt == SCLK_DIV[7:1] - 1'b1 )
            sclk_div_cnt <= 'd0;
        else
            sclk_div_cnt <= sclk_div_cnt + 1'b1;
    else
        sclk_div_cnt <= 'd0;
end



always@( posedge sys_clk_i ) begin
    if( spi_dealing == 1'b0 )
        spi_sclk_p_o <= CPOL;
    else
        if( sclk_div_cnt == SCLK_DIV[7:1] - 1'b1)
            spi_sclk_p_o <= !spi_sclk_p_o;
        else
            spi_sclk_p_o <= spi_sclk_p_o;
end


always@(posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        spi_tx_data_r <= 'd0;
    else if( spi_dealing == 1'b0 && spi_start_en_i == 1'b1 )
        spi_tx_data_r <= spi_tx_data_i;
    else if( CPHA == 1'b1 && spi_dealing == 1'b1 )
        if( spi_sclk_p_o == CPOL && sclk_div_cnt == SCLK_DIV[7:1] - 1'b1)
            spi_tx_data_r <= {spi_tx_data_r[DATA_WIDTH-2:0],1'b0};
        else
            spi_tx_data_r <= spi_tx_data_r;
    else if( CPHA == 1'b0 && spi_dealing == 1'b1 )
        if( spi_sclk_p_o == CPOL && sclk_div_cnt == 'd0 )
            spi_tx_data_r <= {spi_tx_data_r[DATA_WIDTH-2:0],1'b0};
        else
            spi_tx_data_r <= spi_tx_data_r;
    else;
end



always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        spi_csn_p_o <= 1'b1;
    else if( spi_dealing == 1'b1 )
        spi_csn_p_o <= 1'b0;
    else
        spi_csn_p_o <= 1'b1;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        spi_mosi_p_o <= 1'b1;
    else if( CPHA == 1'b1 && spi_dealing == 1'b1 )
        if( spi_sclk_p_o == CPOL && sclk_div_cnt == SCLK_DIV[7:1] - 1'b1 )
            spi_mosi_p_o <= spi_tx_data_r[DATA_WIDTH-1];
        else
            spi_mosi_p_o <= spi_mosi_p_o;
    else if( CPHA == 1'b0 && spi_dealing == 1'b1 )
        if( spi_sclk_p_o == CPOL && sclk_div_cnt == 'd0 )
            spi_mosi_p_o <= spi_tx_data_r[DATA_WIDTH-1];
        else
            spi_mosi_p_o <= spi_mosi_p_o;
    else
        spi_mosi_p_o <= spi_mosi_p_o;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        spi_rx_data_r <= 'd0;
    else if( CPHA == 1'b1 && spi_dealing == 1'b1 )
        if( spi_sclk_p_o == !CPOL && sclk_div_cnt == SCLK_DIV[7:1] - 1'b1 )
            spi_rx_data_r <= {spi_rx_data_r[DATA_WIDTH-2:0],spi_miso_p_i};
        else
            spi_rx_data_r <= spi_rx_data_r;
    else if( CPHA == 1'b0 && spi_dealing == 1'b1 )
        if( spi_sclk_p_o ==  CPOL && sclk_div_cnt == SCLK_DIV[7:1] - 1'b1 )
            spi_rx_data_r <= {spi_rx_data_r[DATA_WIDTH-2:0],spi_miso_p_i};
        else
            spi_rx_data_r <= spi_rx_data_r;
    else
        spi_rx_data_r <= spi_rx_data_r;
end


endmodule
