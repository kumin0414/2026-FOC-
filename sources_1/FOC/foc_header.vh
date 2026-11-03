


//电流输出  x 15bit 分辨率
//速度输出  x 100
//位置输出  x 14bit 分辨率



//定时器运行周期
`define TIME_ARR                $signed(16'd1000)      
`define TIME_ARR_MUL2           `TIME_ARR*2              //FOC执行频率   周期 = (TIME_ARR*2) * 5 ns



//死去时间设置
`define PWM_DEATH_TIME_SET      16'd2          //range 0 ~  10  *sys_clk
`define Udc                     16'd12         //母线电压


//FOC运行模式
`define FOC_MODE_STOP           7'b000_0001    //暂停
`define FOC_MODE_CALIBRATION    7'b000_0010    //校准
`define FOC_MODE_OPEN           7'b000_0100    //开环
`define FOC_MODE_TORQUE         7'b000_1000    //力矩
`define FOC_MODE_SPEED          7'b001_0000    //速度
`define FOC_MODE_POSTION        7'b010_0000    //位置
`define FOC_MODE_SELFTEST       7'b100_0000    //自测

//FOC 速度/位置环控制周期 执行几次力矩环后执行一次速度/位置
`define FOC_SPEED_POSTION_CYC   3'd5


`define SELFTEST_UQ             25'd2000   //自测模式下的Uq
`define CALIBRATION_UD          25'd3500   //校准模式下的Ud 

//UQ UD 参数的最大最小值
`define UQ_MAX      ( $signed(25'd10000) )
`define UQ_MIN      ( $signed(-25'd10000))
`define UD_MAX      ( $signed(25'd10000) )
`define UD_MIN      ( $signed(-25'd10000))


//位置环最大最小圈数
`define POSITION_MAX `ENCODER_ABZ_ONE_CIRCLE * 100
`define POSITION_MIN `ENCODER_ABZ_ONE_CIRCLE * 100


//编码器分辨率
`define ENCODER_ABZ_PLUS_NUM        $signed(16'd2048)
`define ENCODER_ABZ_MIN_RESOLUTION  $signed('d11520)
`define ENCODER_ABS_MIN_RESOLUTION  $signed('d1440)
`define ENCODER_ONE_CIRCLE          $signed('d23592960)