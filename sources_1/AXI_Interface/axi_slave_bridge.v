`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/30 08:40:42
// Design Name: 
// Module Name: axi_slave_brigde
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

module axi_slave_brigde(
    input               sys_clk_i                                       ,
    input               sys_rst_n_i                                     ,

    //register  input 
    input[31:0]         data0_reg_in_i                                  ,
    input[31:0]         data1_reg_in_i                                  ,
    input[31:0]         data2_reg_in_i                                  ,
    input[31:0]         data3_reg_in_i                                  ,
    input[31:0]         data4_reg_in_i                                  ,
    input[31:0]         data5_reg_in_i                                  ,
    input[31:0]         data6_reg_in_i                                  ,
    input[31:0]         data7_reg_in_i                                  ,
    input[31:0]         data8_reg_in_i                                  ,
    input[31:0]         data9_reg_in_i                                  ,
    input[31:0]         data10_reg_in_i                                 ,
    input[31:0]         data11_reg_in_i                                 ,
    input[31:0]         data12_reg_in_i                                 ,
    input[31:0]         data13_reg_in_i                                 ,
    input[31:0]         data14_reg_in_i                                 ,
    input[31:0]         data15_reg_in_i                                 ,
    input[31:0]         data16_reg_in_i                                 ,
    input[31:0]         data17_reg_in_i                                 ,
    input[31:0]         data18_reg_in_i                                 ,
    input[31:0]         data19_reg_in_i                                 ,
    input[31:0]         data20_reg_in_i                                 ,
    input[31:0]         data21_reg_in_i                                 ,
    input[31:0]         data22_reg_in_i                                 ,
    input[31:0]         data23_reg_in_i                                 ,
    input[31:0]         data24_reg_in_i                                 ,
    input[31:0]         data25_reg_in_i                                 ,
    input[31:0]         data26_reg_in_i                                 ,
    input[31:0]         data27_reg_in_i                                 ,
    input[31:0]         data28_reg_in_i                                 ,
    input[31:0]         data29_reg_in_i                                 ,
    input[31:0]         data30_reg_in_i                                 ,
    input[31:0]         data31_reg_in_i                                 ,
    input[31:0]         data32_reg_in_i                                 ,

    //register  output 
    output              datax_reg_update_o                              ,
    output    [9:0]     datax_reg_update_addr_o                         ,
    output reg[31:0]    data0_reg_out_o                                 ,
    output reg[31:0]    data1_reg_out_o                                 ,
    output reg[31:0]    data2_reg_out_o                                 ,
    output reg[31:0]    data3_reg_out_o                                 ,
    output reg[31:0]    data4_reg_out_o                                 ,
    output reg[31:0]    data5_reg_out_o                                 ,
    output reg[31:0]    data6_reg_out_o                                 ,
    output reg[31:0]    data7_reg_out_o                                 ,
    output reg[31:0]    data8_reg_out_o                                 ,
    output reg[31:0]    data9_reg_out_o                                 ,
    output reg[31:0]    data10_reg_out_o                                ,
    output reg[31:0]    data11_reg_out_o                                ,
    output reg[31:0]    data12_reg_out_o                                ,
    output reg[31:0]    data13_reg_out_o                                ,
    output reg[31:0]    data14_reg_out_o                                ,
    output reg[31:0]    data15_reg_out_o                                ,
    output reg[31:0]    data16_reg_out_o                                ,
    output reg[31:0]    data17_reg_out_o                                ,
    output reg[31:0]    data18_reg_out_o                                ,
    output reg[31:0]    data19_reg_out_o                                ,
    output reg[31:0]    data20_reg_out_o                                ,
    output reg[31:0]    data21_reg_out_o                                ,
    output reg[31:0]    data22_reg_out_o                                ,
    output reg[31:0]    data23_reg_out_o                                ,
    output reg[31:0]    data24_reg_out_o                                ,
    output reg[31:0]    data25_reg_out_o                                ,
    output reg[31:0]    data26_reg_out_o                                ,
    output reg[31:0]    data27_reg_out_o                                ,
    output reg[31:0]    data28_reg_out_o                                ,
    output reg[31:0]    data29_reg_out_o                                ,
    output reg[31:0]    data30_reg_out_o                                ,
    output reg[31:0]    data31_reg_out_o                                ,
    output reg[31:0]    data32_reg_out_o                                ,
    //AXI4_FULL SLAVE
    //WRTIE ADDR CHANNEL
    input[0:0]          s_axi_awid                                      ,
    input[31:0]         s_axi_awaddr                                    ,
    input[7:0]          s_axi_awlen                                     ,
    input[2:0]          s_axi_awsize                                    ,
    input[1:0]          s_axi_awburst                                   ,
    input               s_axi_awlock                                    ,
    input[3:0]          s_axi_awcache                                   ,
    input[2:0]          s_axi_awprot                                    ,
    input[3:0]          s_axi_awqos                                     ,
    input[3:0]          s_axi_awregion                                  ,
    input               s_axi_awuser                                    ,
    input               s_axi_awvalid                                   ,
    output              s_axi_awready                                   ,
    //WRITE DATA CHANNEL
    input[0:0]          s_axi_wid                                       ,
    input[31:0]         s_axi_wdata                                     ,
    input[3:0]          s_axi_wstrb                                     ,
    input               s_axi_wlast                                     ,
    input               s_axi_wuser                                     ,
    input               s_axi_wvalid                                    ,
    output              s_axi_wready                                    ,
    //WRITE RESPONCE CHANNEL
    output[0:0]         s_axi_bid                                       ,
    output[1:0]         s_axi_bresp                                     ,
    output              s_axi_buser                                     ,
    output              s_axi_bvalid                                    ,
    input               s_axi_bready                                    ,
    //READ ADDR CHANNEL
    input[0:0]          s_axi_arid                                      ,
    input[31:0]         s_axi_araddr                                    ,
    input[7:0]          s_axi_arlen                                     ,
    input[2:0]          s_axi_arsize                                    ,
    input[1:0]          s_axi_arburst                                   ,
    input               s_axi_arlock                                    ,
    input[3:0]          s_axi_arcache                                   ,
    input[2:0]          s_axi_arprot                                    ,
    input[3:0]          s_axi_arqos                                     ,
    input[3:0]          s_axi_arregion                                  ,
    input               s_axi_aruser                                    ,
    input               s_axi_arvalid                                   ,
    output              s_axi_arready                                   ,
    //READ DATA CHANNEL
    output[0:0]         s_axi_rid                                       ,
    output reg[31:0]    s_axi_rdata                                     ,
    output[1:0]         s_axi_rresp                                     ,
    output              s_axi_rlast                                     ,
    output              s_axi_ruser                                     ,
    output              s_axi_rvalid                                    ,
    input               s_axi_rready                                    
);
localparam  S_IDLE          =   'd0;
localparam  S_WRITE_ADDR    =   'd1;
localparam  S_WRITE_DATA    =   'd2;
localparam  S_WRITE_RESPONSE=   'd3;
localparam  S_READ_ADDR     =   'd4;
localparam  S_READ_DATA     =   'd5;
localparam  S_ACK           =   'd7;

reg[5:0]    state , next_state;


reg[11:0] s_axi_awaddr_r;
reg[7:0]  s_axi_awlen_r;

reg[11:0] s_axi_araddr_r;
reg[7:0]  s_axi_arlen_r;
reg[7:0]  s_axi_arlen_cnt;


assign s_axi_awready = ( state == S_WRITE_ADDR && s_axi_awvalid == 1'b1 ) ? 1'b1 : 1'b0;
assign s_axi_wready  = ( state == S_WRITE_DATA ) ? 1'b1 : 1'b0; 


assign s_axi_bid    = 1'b0;
assign s_axi_bresp  = 2'b00;
assign s_axi_buser  = 1'b0;
assign s_axi_bvalid = ( state == S_WRITE_RESPONSE ) ? 1'b1 : 1'b0;
assign s_axi_arready = ( state == S_READ_ADDR && s_axi_arvalid == 1'b1 ) ? 1'b1 : 1'b0;


assign s_axi_rid = 1'b0;
assign s_axi_rresp = 2'b00;
assign s_axi_ruser = 1'b0;
assign s_axi_rvalid = ( state == S_READ_DATA ) ? 1'b1 : 1'b0;
assign s_axi_rlast  = ( s_axi_rready == 1'b1 && s_axi_arlen_cnt == s_axi_arlen_r ) ? 1'b1 : 1'b0;

assign datax_reg_update_o = ( s_axi_bvalid & s_axi_bready ) ? 1'b1 : 1'b0;
assign datax_reg_update_addr_o = s_axi_awaddr_r[11:2];

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        state <= S_IDLE;
    else
        state <= next_state;
end


always@(*) begin
    case( state )
    S_IDLE:
        if( s_axi_awvalid == 1'b1 )
            next_state <= S_WRITE_ADDR;
        else if( s_axi_arvalid == 1'b1 )
            next_state <= S_READ_ADDR;
        else
            next_state <= S_IDLE;
    S_WRITE_ADDR:
        if( s_axi_awready == 1'b1 )
            next_state <= S_WRITE_DATA;
        else
            next_state <= S_WRITE_ADDR;
    S_WRITE_DATA:
        if( s_axi_wlast == 1'b1 && s_axi_wvalid == 1'b1 )
            next_state <= S_WRITE_RESPONSE;
        else
            next_state <= S_WRITE_DATA;
    S_WRITE_RESPONSE:
        if( s_axi_bvalid & s_axi_bready )
            next_state <= S_ACK;
        else
            next_state <= S_WRITE_RESPONSE;

    S_READ_ADDR:
        if( s_axi_arready == 1'b1 )
            next_state <= S_READ_DATA;
        else
            next_state <= S_READ_ADDR;
    S_READ_DATA:
        if( s_axi_rready == 1'b1 && s_axi_arlen_cnt == s_axi_arlen_r )
            next_state <= S_ACK;
        else
            next_state <= S_READ_DATA;
    S_ACK:
        next_state <= S_IDLE;
    endcase
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        s_axi_awaddr_r <= 'd0;
    else if( state == S_ACK )
        s_axi_awaddr_r <= 'd0;
    else if( state == S_WRITE_ADDR )
        s_axi_awaddr_r <= s_axi_awaddr[11:0];
    else if( state == S_WRITE_DATA )
        if( s_axi_wready && s_axi_wvalid )
            s_axi_awaddr_r <= s_axi_awaddr_r;
        else
            s_axi_awaddr_r <= s_axi_awaddr_r;
    else
        s_axi_awaddr_r <= s_axi_awaddr_r;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        s_axi_awlen_r <= 'd0;
    else if( state == S_WRITE_ADDR )
        s_axi_awlen_r <= s_axi_awlen;
    else
        s_axi_awlen_r <= s_axi_awlen_r;
end


always@(posedge sys_clk_i ) begin
    if( state == S_WRITE_DATA && s_axi_wready == 1'b1 ) begin
        case( s_axi_awaddr_r[11:2])
        'd0:    data0_reg_out_o      = s_axi_wdata;
        'd1:    data1_reg_out_o      = s_axi_wdata;
        'd2:    data2_reg_out_o      = s_axi_wdata;
        'd3:    data3_reg_out_o      = s_axi_wdata;
        'd4:    data4_reg_out_o      = s_axi_wdata;
        'd5:    data5_reg_out_o      = s_axi_wdata;
        'd6:    data6_reg_out_o      = s_axi_wdata;
        'd7:    data7_reg_out_o      = s_axi_wdata;
        'd8:    data8_reg_out_o      = s_axi_wdata;
        'd9:    data9_reg_out_o      = s_axi_wdata;
        'd10:   data10_reg_out_o     = s_axi_wdata;
        'd11:   data11_reg_out_o     = s_axi_wdata;
        'd12:   data12_reg_out_o     = s_axi_wdata;
        'd13:   data13_reg_out_o     = s_axi_wdata;
        'd14:   data14_reg_out_o     = s_axi_wdata;
        'd15:   data15_reg_out_o     = s_axi_wdata;
        'd16:   data16_reg_out_o     = s_axi_wdata;
        'd17:   data17_reg_out_o     = s_axi_wdata;
        'd18:   data18_reg_out_o     = s_axi_wdata;
        'd19:   data19_reg_out_o     = s_axi_wdata;
        'd20:   data20_reg_out_o     = s_axi_wdata;
        'd21:   data21_reg_out_o     = s_axi_wdata;
        'd22:   data22_reg_out_o     = s_axi_wdata;
        'd23:   data23_reg_out_o     = s_axi_wdata;
        'd24:   data24_reg_out_o     = s_axi_wdata;
        'd25:   data25_reg_out_o     = s_axi_wdata;
        'd26:   data26_reg_out_o     = s_axi_wdata;
        'd27:   data27_reg_out_o     = s_axi_wdata;
        'd28:   data28_reg_out_o     = s_axi_wdata;
        'd29:   data29_reg_out_o     = s_axi_wdata;
        'd30:   data30_reg_out_o     = s_axi_wdata;
        'd31:   data31_reg_out_o     = s_axi_wdata;
        'd32:   data32_reg_out_o     = s_axi_wdata;
        endcase
    end
end




always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        s_axi_araddr_r <= 'd0;
    else if( state == S_READ_ADDR )
        s_axi_araddr_r <= s_axi_araddr[11:0];
    else if( state == S_READ_DATA )
        if( s_axi_rready && s_axi_rvalid )
            s_axi_araddr_r <= s_axi_araddr_r;
        else
            s_axi_araddr_r <= s_axi_araddr_r;
    else
        s_axi_araddr_r <= s_axi_araddr_r;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        s_axi_arlen_r <= 'd0;
    else if( state == S_READ_ADDR )
        s_axi_arlen_r <= s_axi_arlen;
    else
        s_axi_arlen_r <= s_axi_arlen_r;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        s_axi_arlen_cnt <= 'd0;
    else if( state == S_READ_DATA )
        if(  s_axi_rready == 1'b1 )
            s_axi_arlen_cnt <= s_axi_arlen_cnt + 1'b1;
        else
            s_axi_arlen_cnt <= s_axi_arlen_cnt;
    else
        s_axi_arlen_cnt <= 'd0;
end

always@(*) begin
    case( s_axi_araddr_r[11:0] )
    'd0:    s_axi_rdata = data0_reg_in_i;
    'd4:    s_axi_rdata = data1_reg_in_i;
    'd8:    s_axi_rdata = data2_reg_in_i;
    'd12:   s_axi_rdata = data3_reg_in_i;
    'd16:   s_axi_rdata = data4_reg_in_i;
    'd20:   s_axi_rdata = data5_reg_in_i;
    'd24:   s_axi_rdata = data6_reg_in_i;
    'd28:   s_axi_rdata = data7_reg_in_i;
    'd32:   s_axi_rdata = data8_reg_in_i;
    'd36:   s_axi_rdata = data9_reg_in_i;
    'd40:   s_axi_rdata = data10_reg_in_i;
    'd44:   s_axi_rdata = data11_reg_in_i;
    'd48:   s_axi_rdata = data12_reg_in_i;
    'd52:   s_axi_rdata = data13_reg_in_i;
    'd56:   s_axi_rdata = data14_reg_in_i;
    'd60:   s_axi_rdata = data15_reg_in_i;
    'd64:   s_axi_rdata = data16_reg_in_i;
    'd68:   s_axi_rdata = data17_reg_in_i;
    'd72:   s_axi_rdata = data18_reg_in_i;
    'd76:   s_axi_rdata = data19_reg_in_i;
    'd80:   s_axi_rdata = data20_reg_in_i;
    'd84:   s_axi_rdata = data21_reg_in_i;
    'd88:   s_axi_rdata = data22_reg_in_i;
    'd92:   s_axi_rdata = data23_reg_in_i;
    'd96:   s_axi_rdata = data24_reg_in_i;
    'd100:  s_axi_rdata = data25_reg_in_i;
    'd104:  s_axi_rdata = data26_reg_in_i;
    'd108:  s_axi_rdata = data27_reg_in_i;
    'd112:  s_axi_rdata = data28_reg_in_i;
    'd116:  s_axi_rdata = data29_reg_in_i;
    'd120:  s_axi_rdata = data30_reg_in_i;
    'd124:  s_axi_rdata = data31_reg_in_i;
    'd128:  s_axi_rdata = data32_reg_in_i;
    default:s_axi_rdata = 'd0;
    endcase 
end
endmodule