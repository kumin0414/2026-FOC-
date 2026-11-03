`timescale 1ns/1ps

/*
���� : ValentineHP
��ϵ��ʽ : ΢�Ź��ں�  FPGA֮��
*/



/*���ڷ���ģ��*/
module  UART_TX(
    input       sys_clk,       /*ϵͳʱ�� 50M*/
    input       rst_n,         /*ϵͳ��λ �͵�ƽ��Ч*/

    input       uart_tx_req,   /*���ڷ�������*/
    output      uart_tx_done,  /*���ڷ������*/

    input[7:0]  idat,          /*��������*/
    output      uarttx         /*uart tx������*/
);



parameter   UARTBaud   = 'd115200;     /*������*/
parameter  SYS_CLK_CYCLE = 'd10;      
localparam  UARTCLKPer =  (('d1000_000_000 / UARTBaud) /SYS_CLK_CYCLE) -1;   /*ÿBit��ռ��ʱ������*/


localparam  UART_Idle       =   4'b0001;    /*����̬*/
localparam  UART_Start      =   4'b0010;    /*��ʼ̬*/
localparam  UART_Data       =   4'b0100;    /*����̬*/
localparam  UART_Stop       =   4'b1000;    /*ֹ̬ͣ*/

reg[3:0]    state , next_state;
reg[19:0]   UARTCnt;           /*����ʱ�����ڼ�*/


reg         UART_Req_Reg;      /*���ڷ�������Ĵ���*/
reg[7:0]    UART_TxData_Reg;   /*���ڷ������ݼĴ���*/
reg         UART_TX_Reg;       /*���ڷ��������߼Ĵ���*/
reg[2:0]    UART_Bit;          /*���ڷ���bit������*/

assign      uarttx = UART_TX_Reg;
assign      uart_tx_done = (state == UART_Stop && (UARTCnt == (UARTCLKPer -'d1))) ? 1'b1 : 1'b0;

always @(posedge sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        state <= UART_Idle;
    else
        state <= next_state;
end

/*״̬��*/
always@(*)
begin
    case (state)
        UART_Idle: 
            if(UART_Req_Reg == 1'b1)    /*�������˺󣬷�������*/
                next_state <= UART_Start;
            else
                next_state <= UART_Idle;
        UART_Start:                     /*��ʼ״̬*/
            if(UARTCnt == UARTCLKPer)
                next_state <= UART_Data;
            else
                next_state <= UART_Start;
        UART_Data:
            if(UART_Bit == 'd7 && UARTCnt == UARTCLKPer)  /*���ݷ������*/
                next_state <= UART_Stop;
            else
                next_state <= UART_Data;
        UART_Stop:
            if(UARTCnt == UARTCLKPer)   
                next_state <= UART_Idle;
            else
                next_state <= UART_Stop;
        default: next_state <= UART_Idle;
    endcase
end



/*��������Ĵ���*/
always @(posedge sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        UART_Req_Reg <= 1'b0;
    else
        UART_Req_Reg <= uart_tx_req;
end

/*�������ݼĴ���*/
always @(posedge sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        UART_TxData_Reg <= 'd0;
    else if(uart_tx_req == 1'b1 && state == UART_Idle)
        UART_TxData_Reg <= idat;
    else if(state == UART_Stop)  /*������ɣ��Ĵ�������*/
        UART_TxData_Reg <= 'd0;
    else
        UART_TxData_Reg <= UART_TxData_Reg;
end

/*����Bitʹ�����ڼ���*/
always @(posedge sys_clk or negedge rst_n) 
begin
    if(rst_n == 1'b0)
        UARTCnt <= 'd0;
    else if(UARTCnt == UARTCLKPer)   /*���������ֵ������*/
        UARTCnt <= 'd0;
    else if(state == UART_Start)
        UARTCnt <= UARTCnt + 1'b1;
    else if(state == UART_Data)
        UARTCnt <= UARTCnt + 1'b1;
    else if(state == UART_Stop)
        UARTCnt <= UARTCnt + 1'b1;
    else
        UARTCnt <= 'd0;
end

/*����bit����*/
always@(posedge sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        UART_Bit <= 'd0;
    else if(state == UART_Stop)  /*һ�����ݷ�������ˣ�bit������*/
        UART_Bit <= 'd0;
    else if(state == UART_Data && UARTCnt == UARTCLKPer)
        UART_Bit <= UART_Bit + 1'b1;
    else
        UART_Bit <= UART_Bit;
end


/*���ݷ���*/
always@(posedge sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        UART_TX_Reg <= 1'b1;
    else if(state == UART_Start)
        UART_TX_Reg <= 1'b0;
    else if(state == UART_Data)
        UART_TX_Reg <= UART_TxData_Reg[UART_Bit];
    else
        UART_TX_Reg <= 1'b1;
end

endmodule