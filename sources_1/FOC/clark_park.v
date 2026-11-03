`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/09 13:30:05
// Design Name: 
// Module Name: clark_park
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


module clark_park(
    input                   sys_clk_i           ,
    input                   sys_rst_n_i         ,
    
    input                   clark_park_en_i     ,
    output                  clark_park_ack_o    ,

    
    input signed[17:0]      cordic_sin_i        ,   
    input signed[17:0]      cordic_cos_i        ,
    input signed[15:0]      Ia_i                ,
    input signed[15:0]      Ib_i                ,
    input signed[15:0]      Ic_i                ,
    
    output reg signed[24:0] Ialpha_o            ,
    output reg signed[24:0] Ibeta_o             ,
    output reg signed[24:0] Iq_o                ,
    output reg signed[24:0] Id_o                 
);

localparam SQRT3        =       $signed(18'd37937);   // (1 / sqrt(3))^16 = d37937
localparam SQRT3_mul_2  =       $signed(18'd75674);   //（(1 / sqrt(3))*2)^16 = d75674

reg[5:0]           cnt;
reg                dealing;

reg signed[42:0]   temp1;
reg signed[42:0]   temp2;
reg signed[43:0]   temp12_sum;

reg signed[42:0]   a;
reg signed[42:0]   b;
reg signed[42:0]   c;
reg signed[42:0]   d;

reg signed[24:0]   aa;
reg signed[24:0]   bb;
reg signed[24:0]   cc;
reg signed[24:0]   dd;

assign clark_park_ack_o = ( cnt == 'd13 ) ? 1'b1 : 1'b0;

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        dealing <= 1'b0;
    else if( clark_park_ack_o == 1'b1 )
        dealing <= 1'b0;
    else if( clark_park_en_i == 1'b1 )
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
    if( sys_rst_n_i == 1'b0 ) begin
        temp1 <= 'd0;
        temp2 <= 'd0;      
    end
    else if( cnt == 'd1 ) begin
        temp1   <= SQRT3 * Ia_i;
        temp2   <= SQRT3_mul_2 * Ib_i;    
    end
    else begin
        temp1 <= temp1;
        temp2 <= temp2;
    end
end
always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        temp12_sum <= 'd0;
    else if( cnt ==  'd3)
        temp12_sum <= temp1 + temp2;
    else
        temp12_sum <= temp12_sum;
end



always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        Ialpha_o    <= 'd0;
        Ibeta_o     <= 'd0;      
    end
    else if( cnt == 'd5 ) begin
        Ialpha_o    <= Ia_i;              
        Ibeta_o     <= temp12_sum >>> 16; 
    end
    else begin
        Ialpha_o <= Ialpha_o;
        Ibeta_o  <= Ibeta_o;
    end
end



always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        a <= 'd0;
        b <= 'd0;   
        c <= 'd0;
        d <= 'd0;      
    end
    else if( cnt == 'd7 ) begin
        a <= Ialpha_o * cordic_sin_i;
        b <= Ibeta_o  * cordic_cos_i;
        c <= Ialpha_o * cordic_cos_i;
        d <= Ibeta_o  * cordic_sin_i;
    end
    else begin
        a <= a;
        b <= b;
        c <= c;
        d <= d;
    end
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        aa <= 'd0;
        bb <= 'd0;   
        cc <= 'd0;
        dd <= 'd0;      
    end
    else if( cnt == 'd9 ) begin
        aa <= a >>> 16;
        bb <= b >>> 16;
        cc <= c >>> 16;
        dd <= d >>> 16;
    end
    else ;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 ) begin
        Iq_o <= 'd0;
        Id_o <= 'd0;      
    end
    else if( cnt == 'd11 ) begin
        Iq_o <= bb - aa;
        Id_o <= cc + dd;     
    end
    else begin
        Iq_o <= Iq_o;
        Id_o <= Id_o;
    end
end

endmodule
