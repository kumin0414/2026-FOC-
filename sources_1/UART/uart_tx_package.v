`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/27 11:13:23
// Design Name: 
// Module Name: uart_tx_package
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


module uart_tx_package(
    input           sys_clk_i,
    input           sys_rst_n_i,

    input           package_tx_req,
    output          package_tx_ack,

    input[7:0]      package_head,
    input[7:0]      package_func1,
    input[7:0]      package_func2,
    input[7:0]      package_func3,
    input[31:0]     package_data1,
    input[31:0]     package_data2,
    input[31:0]     package_data3,
    input[31:0]     package_data4,
    input[15:0]     package_motor_id,
    input[7:0]      package_id,
    input[7:0]      package_tail,


    output          uart_tx_pin_o
);

reg [ 'd24 * 'd8 - 'd1 : 0] data;


always@( posedge sys_clk_i ) begin
    if( package_tx_req == 1'b1 )
        data <= { package_head , package_func1 , package_func2 , package_func3 , 
                package_data1[7:0] , package_data1[15:8] , package_data1[23:16] , package_data1[31:24] , 
                package_data2[7:0] , package_data2[15:8] , package_data2[23:16] , package_data2[31:24] , 
                package_data3[7:0] , package_data3[15:8] , package_data3[23:16] , package_data3[31:24] , 
                package_data4[7:0] , package_data4[15:8] , package_data4[23:16] , package_data4[31:24] , 
                package_motor_id[7:0] ,  package_motor_id[15:8],
                package_id , package_tail };
    else
        data <= data;

end





// assign data = { package_head , package_func1 , package_func2 , package_func3 , package_data1 , package_data2 , package_data3 , package_data4 , package_motor_id ,
//                 package_id , package_tail };

UART_MulTX #( 
    .MulTXNum   (24)   /*ÿ�η��͵��ֽ���*/
)UART_MulTX_hp
(
    
    .sys_clk                        (   sys_clk_i           ),
    .rst_n                          (   sys_rst_n_i         ),

    .uart_tx_req                    (   package_tx_req      ),   /*���ڷ�������*/
    .uart_txs_done                  (   package_tx_ack      ),  /*���ڷ������*/       

    .idats                          (   data                ),          /*���͵�����*/
    .uarttx                         (   uart_tx_pin_o       ) /*uart tx������*/
);

endmodule
