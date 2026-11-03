`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/18 21:48:53
// Design Name: 
// Module Name: Cordic_Top
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


module Cordic_Top #(
    parameter CORDIC_MODE = "ROTATE"         // ROTATE    VECTOR
)(
    input               sys_clk_i       ,
    input               sys_rst_n_i     ,

    input               cordic_req_i    ,
    output              cordic_ack_o    ,

    //ROTATE
    input[24:0]         cordic_angle_i         ,   // * 2^16
    output reg signed[17:0]    cordic_sin_o    ,   // * 2^16
    output reg signed[17:0]    cordic_cos_o    ,   // * 2^16

    //VECTOR
    input signed[31:0]  cordic_x_i      ,
    input signed[31:0]  cordic_y_i      ,
    output reg[31:0]    cordic_arctan_o ,    // * 2^16
    output reg[31:0]    cordic_mod_o        
);


localparam  angle90 = 25'd5898240   ; //90度*2^16


localparam  rot0    = 25'd2949120   ; //45度*2^16
localparam  rot1    = 25'd1740992   ; //26.5651度*2^16
localparam  rot2    = 25'd919872    ; //14.0362度*2^16
localparam  rot3    = 25'd466944    ; //7.1250度*2^16
localparam  rot4    = 25'd234368    ; //3.5763度*2^16
localparam  rot5    = 25'd117312    ; //1.7899度*2^16
localparam  rot6    = 25'd58688     ; //0.8952度*2^16
localparam  rot7    = 25'd29312     ; //0.4476度*2^16
localparam  rot8    = 25'd14656     ; //0.2238度*2^16
localparam  rot9    = 25'd7360      ; //0.1119度*2^16
localparam  rot10   = 25'd3648      ; //0.0560度*2^16
localparam  rot11   = 25'd1856      ; //0.0280度*2^16
localparam  rot12   = 25'd896       ; //0.0140度*2^16
localparam  rot13   = 25'd448       ; //0.0070度*2^16
localparam  rot14   = 25'd256       ; //0.0035度*2^16
localparam  rot15   = 25'd128       ; //0.0018度*2^16
localparam  K       = $signed(32'h09b75)     ; // 0.6072253* 2^16 = 1/2 + 1/16 + 1/32 + 1/128 + 1/256 + 1/1024 + 1/2048 + 1/4096



localparam  S_IDLE      =   'd0;
localparam  S_NORAML    =   'd1;
localparam  S_ROTATE    =   'd2;
localparam  S_ACK       =   'd3;

reg signed [31:0] xp[16:0];
reg signed [31:0] yp[16:0];
reg signed [31:0] zn[16:0];
reg[23:0]         rot[15:0];



reg signed[31:0] xp_temp;
reg signed[31:0] yp_temp;

reg[2:0]  normal_num;
reg[5:0]  rotate_num;
reg signed[31:0] angle;
reg signed[31:0] vector_x;
reg signed[31:0] vector_y;

reg signed[16:0] cordic_sin_temp;
reg signed[16:0] cordic_cos_temp;
reg signed[63:0] cordic_mod_temp;

reg[3:0]    state;
reg[3:0]    next_state;

assign cordic_ack_o = ( state == S_ACK ) ? 1'b1 : 1'b0;

always @( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        state <= S_IDLE;
    else
        state <= next_state;
end

always@(*) begin
    case (state)
        S_IDLE: 
            if( cordic_req_i == 1'b1 )
                next_state <= S_NORAML;
            else
                next_state <= S_IDLE;
        S_NORAML:
            if( CORDIC_MODE == "VECTOR")
                next_state <= S_ROTATE;
            else if( angle <= angle90 )
                next_state <= S_ROTATE;
            else
                next_state <= S_NORAML;
        S_ROTATE:
            if( rotate_num == 'd25 )
                next_state <= S_ACK;
            else
                next_state <= S_ROTATE;
        S_ACK:
            next_state <= S_IDLE;
        default:  next_state <= S_IDLE;
    endcase

end


always@(posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        angle <= 32'd0;
    else if( state == S_NORAML && CORDIC_MODE == "VECTOR" )
        angle <= 32'd0;
    else if( state == S_IDLE && cordic_req_i == 1'b1 )
        angle <= cordic_angle_i;
    else if( state == S_NORAML && angle > angle90 )
        angle <= angle - angle90;
    else if( state == S_NORAML && (normal_num == 'd1 || normal_num == 'd3))
        angle <= angle90 - angle;
    else
        angle <= angle;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        normal_num <= 3'd0;
    else if( state == S_IDLE && CORDIC_MODE == "VECTOR" && cordic_req_i == 1'b1 ) begin
        if( cordic_x_i > $signed(0) && cordic_y_i > $signed(0))
            normal_num <= 'd0;
        else  if( cordic_x_i < $signed(0) && cordic_y_i > $signed(0))
             normal_num <= 'd1;
        else  if( cordic_x_i < $signed(0) && cordic_y_i < $signed(0))
             normal_num <= 'd2;     
        else
            normal_num <= 'd3;
    end
    else if( state == S_IDLE )
        normal_num <= 'd0;
    else if( state ==S_NORAML && CORDIC_MODE == "ROTATE" && angle > angle90 )
        if( normal_num == 'd3)
            normal_num <= 'd0;
        else
            normal_num <= normal_num + 1'b1;
    else
        normal_num <= normal_num;
end


always@( posedge sys_clk_i ) begin
    if( state == S_IDLE && CORDIC_MODE == "VECTOR" && cordic_req_i == 1'b1 ) begin
        if( cordic_x_i  < $signed(0) )
            vector_x <= -cordic_x_i;
        else
            vector_x <= cordic_x_i;
    end 
    else;
end
always@( posedge sys_clk_i ) begin
    if( state == S_IDLE && CORDIC_MODE == "VECTOR" && cordic_req_i == 1'b1 ) begin
        if( cordic_y_i  < $signed(0) )
            vector_y <= -cordic_y_i;
        else
            vector_y <= cordic_y_i;
    end 
    else;
end


always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        rotate_num <= 'd0;
    else if( state == S_ROTATE )
        rotate_num <= rotate_num + 1'b1;
    else
        rotate_num <= 'd0;
end



always@(posedge sys_clk_i ) begin
    if( state == S_ROTATE && rotate_num == 'd0) begin
        if( CORDIC_MODE == "ROTATE" ) begin 
            xp[0] <= 'd1 <<< 16;
            yp[0] <= 'd0;
            zn[0] <= 'd0;
        end
        else begin
            xp[0] <= vector_x <<< 16;
            yp[0] <= vector_y <<< 16;
            zn[0] <= 'd0;
        end
    end
    else begin
        xp[0] <= xp[0];
        yp[0] <= yp[0];
        zn[0] <= zn[0];
    end

end

genvar i;
generate
    for( i = 1 ;i < 17 ;i = i+1)
    begin: loop2
    always@( posedge sys_clk_i ) begin
        if( state == S_ROTATE && CORDIC_MODE == "VECTOR" &&rotate_num == i) begin
            if( yp[i-1][31] == 1'b0) begin
                xp[i] <= xp[i-1] + (yp[i-1] >>> (i-1));
                yp[i] <= yp[i-1] - (xp[i-1] >>> (i-1));
                zn[i] <= zn[i-1] + rot[i-1];
            end
            else begin
                xp[i] <= xp[i-1] - (yp[i-1] >>> (i-1));
                yp[i] <= yp[i-1] + (xp[i-1] >>> (i-1));
                zn[i] <= zn[i-1] - rot[i-1];
            end
        end
        else if( state == S_ROTATE && rotate_num == i) begin
            if( zn[i-1] > angle) begin
                xp[i] <= xp[i-1] + (yp[i-1] >>> (i-1));
                yp[i] <= yp[i-1] - (xp[i-1] >>> (i-1));
                zn[i] <= zn[i-1] - rot[i-1];
            end
            else begin
                xp[i] <= xp[i-1] - (yp[i-1] >>> (i-1));
                yp[i] <= yp[i-1] + (xp[i-1] >>> (i-1));
                zn[i] <= zn[i-1] + rot[i-1];
            end
        end
    end
    end
endgenerate


always@( posedge sys_clk_i ) begin
    if( rotate_num == 'd17 ) begin
        if( normal_num == 'd0 ) begin
            xp_temp <= xp[16];
            yp_temp <= yp[16];
        end
        else if( normal_num == 'd1 ) begin
            xp_temp <= -xp[16];
            yp_temp <= yp[16];
        end
        else if( normal_num == 'd2 ) begin
            xp_temp <= -xp[16];
            yp_temp <= -yp[16];
        end
        else begin
            xp_temp <= xp[16];
            yp_temp <= -yp[16];
        end

    end
    else;
end


//1/2 + 1/16 + 1/32 + 1/128 + 1/256 + 1/1024 + 1/2048 + 1/4096
always@( posedge sys_clk_i ) begin
    if( rotate_num == 'd18 ) begin
        cordic_sin_temp <= (yp_temp >>> 1) + (yp_temp >>> 4);
        cordic_cos_temp <= (xp_temp >>> 1) + (xp_temp >>> 4);
    end
    else if( rotate_num == 'd19 ) begin
        cordic_sin_temp <= cordic_sin_temp + (yp_temp >>> 5);
        cordic_cos_temp <= cordic_cos_temp + (xp_temp >>> 5);
    end
    else if( rotate_num == 'd20 ) begin
        cordic_sin_temp <= cordic_sin_temp +(yp_temp >>> 7);
        cordic_cos_temp <= cordic_cos_temp +(xp_temp >>> 7);
    end
    else if( rotate_num == 'd21 ) begin
        cordic_sin_temp <= cordic_sin_temp + (yp_temp >>> 8);
        cordic_cos_temp <= cordic_cos_temp + (xp_temp >>> 8);
    end
    else if( rotate_num == 'd22 ) begin
        cordic_sin_temp <= cordic_sin_temp + (yp_temp >>> 10);
        cordic_cos_temp <= cordic_cos_temp + (xp_temp >>> 10);
    end
    else if( rotate_num == 'd23 ) begin
        cordic_sin_temp <= cordic_sin_temp + (yp_temp >>> 11);
        cordic_cos_temp <= cordic_cos_temp + (xp_temp >>> 11);
    end
    else if( rotate_num == 'd24 ) begin
        cordic_sin_temp <= cordic_sin_temp + (yp_temp >>> 12);
        cordic_cos_temp <= cordic_cos_temp + (xp_temp >>> 12);
    end
    else;
end



always@( posedge sys_clk_i  ) begin
    if(  rotate_num == 'd25 ) begin
        cordic_sin_o <= {cordic_sin_temp[16],cordic_sin_temp};
        cordic_cos_o <= {cordic_cos_temp[16],cordic_cos_temp};
    end 
    else begin
        cordic_sin_o <= cordic_sin_o;
        cordic_cos_o <= cordic_cos_o;
    end
end 



always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        cordic_arctan_o <= 16'd0;
    else if( state == S_ROTATE && rotate_num == 'd17 ) begin
        if( normal_num == 'd0 )
            cordic_arctan_o <= zn[16];
        else if( normal_num == 'd1)
            cordic_arctan_o <= zn[16] + (( angle90 - zn[16]) <<< 1);
        else if(  normal_num == 'd2)
            cordic_arctan_o <= zn[16] + ( angle90 <<< 1);
        else
            cordic_arctan_o <= zn[16] + ( angle90 <<< 1) +  (( angle90 - zn[16]) <<< 1);
    end
    else ;
end

always@( posedge sys_clk_i or negedge sys_rst_n_i ) begin
    if( sys_rst_n_i == 1'b0 )
        cordic_mod_temp <= 'd0;
    else if(  state == S_ROTATE && rotate_num == 'd17 )
        cordic_mod_temp <= (xp[16] * K);
    else
        cordic_mod_temp <= cordic_mod_temp;
end

always@( posedge sys_clk_i) begin
    if( state == S_ROTATE && rotate_num == 'd18 )
        cordic_mod_o <= cordic_mod_temp >>> 32;
    else
        cordic_mod_o <= cordic_mod_o;
end



always@(posedge sys_clk_i)
begin
    rot[0] <= rot0;
    rot[1] <= rot1;
    rot[2] <= rot2;
    rot[3] <= rot3;
    rot[4] <= rot4;
    rot[5] <= rot5;
    rot[6] <= rot6;
    rot[7] <= rot7;
    rot[8] <= rot8;
    rot[9] <= rot9;
    rot[10] <=rot10;
    rot[11] <=rot11;
    rot[12] <=rot12;
    rot[13] <=rot13;
    rot[14] <=rot14;
    rot[15] <=rot15;
end       

endmodule
                                          