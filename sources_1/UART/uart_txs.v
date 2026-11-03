`timescale 1ns/1ps


/*
���� : ValentineHP
��ϵ��ʽ : ΢�Ź��ں�  FPGA֮��
*/




/*��η���*/
module UART_MulTX #( 
    parameter MulTXNum = 5)   /*ÿ�η��͵��ֽ���*/
(
    
    input                           sys_clk,
    input                           rst_n,

    input                           uart_tx_req,   /*���ڷ�������*/
    output                          uart_txs_done,  /*���ڷ������*/       

    input[MulTXNum*'d8 - 'd1:0]     idats,          /*���͵�����*/
    output                          uarttx         /*uart tx������*/
);



reg [MulTXNum*'d8 - 'd1:0] idatsReg;   /*�����ݴ�*/
reg[7:0]  txdata;   /*���͵�����*/
reg       UART_TX_Reg;   /*��������Ĵ���*/
reg[5:0]  MulTxCnt;     /*����byte������*/
reg        UART_TXing;  /*���������б�־*/
wire      uart_tx_done;

assign    uart_txs_done = ((MulTxCnt == (MulTXNum -'d1)) && uart_tx_done == 1'b1) ? 1'b1 : 1'b0;   

/*�����ݴ�*/
always@(posedge sys_clk  or negedge rst_n)
begin
    if(rst_n == 1'b0)
        UART_TX_Reg <= 1'b0;
    else if(uart_txs_done == 1'b1)   /*���ݷ�����ɣ��������*/
        UART_TX_Reg <= 1'b0;
    else if(uart_tx_req == 1'b1 && UART_TXing == 1'b0)   /*�����������ˣ��ݴ�����*/
        UART_TX_Reg <= 1'b1;
    else
        UART_TX_Reg <= UART_TX_Reg;
end

/*�������ݱ�־*/
always@(posedge sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        UART_TXing <= 1'b0;
    else if(uart_txs_done == 1'b1)
        UART_TXing <= 1'b0;
    else if(uart_tx_req == 1'b1)
        UART_TXing <= 1'b1;
    else
        UART_TXing <= UART_TXing;
        


end


/*�������ݼ���*/
always@(posedge sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        MulTxCnt <= 'd0;
    else if(uart_txs_done == 1'b1)
        MulTxCnt <= 'd0;
    else if(uart_tx_done == 1'b1)
        MulTxCnt <= MulTxCnt + 1'b1;
    else
        MulTxCnt <= MulTxCnt;
end

/*���������ݴ�*/
always@(posedge sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        idatsReg <= 'd0;
    else if(uart_tx_done == 1'b1)
        idatsReg <= idatsReg << 8;//idatsReg >> 8;
    else if(uart_tx_req == 1'b1 && UART_TXing == 1'b0)
        idatsReg <=  idats << 8;//idats >> 8;
    else
        idatsReg <= idatsReg;
end


/*��ȡ���η��͵�����*/
always@(posedge sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        txdata <= 'd0;
    else if(uart_tx_done == 1'b1)
        txdata <= idatsReg[MulTXNum*'d8 - 'd1:MulTXNum*'d8 - 'd8];//idatsReg[7:0];   MulTXNum*'d8 - 'd1:0
    else if(uart_tx_req == 1'b1 && UART_TXing == 1'b0)
        txdata <= idats[MulTXNum*'d8 - 'd1:MulTXNum*'d8 - 'd8];//idats[7:0];
    else
        txdata <= txdata;
end

 UART_TX #(
    .UARTBaud(921600)   /*���ò�����*/
 )UART_TXHP
 (
    .sys_clk           (sys_clk),       /*ϵͳʱ�� 50M*/
    .rst_n              (rst_n),         /*ϵͳ��λ �͵�ƽ��Ч*/

    .uart_tx_req        (UART_TX_Reg),   /*���ڷ�������*/
    .uart_tx_done       (uart_tx_done),  /*���ڷ������*/

    .idat               (txdata),          /*��������*/
    .uarttx             (uarttx)        /*uart tx������*/
);

    
endmodule