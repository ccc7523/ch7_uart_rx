# 串口数字控制 LED（ACG720-60K）

打开 `uart_rx.gprj`，顶层模块仍为 `uart_rx_test`，器件为
`GW5AT-LV60PG484AC1/I0`（GW5AT-60B）。板载时钟 50 MHz。

串口助手设置：9600 波特率、8 数据位、无校验、1 停止位、无流控，
发送格式选择 ASCII。每次发送一个字符 `0`～`7`。

- LED0 禁用，始终熄灭。
- 收到 `1`～`7` 时，只点亮对应的 LED1～LED7，其余熄灭。
- 收到 `0` 时，LED0～LED7 全部熄灭，LED8 仍翻转一次。
- LED8 每收到一个有效字符翻转一次，包括重复数字。
- 回车、换行、`8`、`9`、字母等字节被忽略，不翻转 LED8。
- 复位后九路 LED 输出全部为零。复位输入沿用原工程的 F15，对应按键 S0。
- 串口 TX 保持高电平（空闲），本版不发送回显。
- 连续输入 `17` 是两条命令：先选择 LED1，再选择 LED7；
  最终 LED7 亮，LED8 翻转两次，回到原来的状态。

端口编号直接使用 LED0～LED8，输出为高电平时点亮。
LED8 按管脚表及用户确认连接 N19。

| 功能编号 | 顶层端口 | 原理图网络 | FPGA 引脚 |
| --- | --- | --- | --- |
| LED0 | led[0] | LED0 | M22 |
| LED1 | led[1] | LED1 | N22 |
| LED2 | led[2] | LED2 | L21 |
| LED3 | led[3] | LED3 | K21 |
| LED4 | led[4] | LED4 | K22 |
| LED5 | led[5] | LED5 | J22 |
| LED6 | led[6] | LED6 | H22 |
| LED7 | led[7] | LED7 | M21 |
| LED8（翻转） | led[8] | LED8 | N19 |

资料来源：用户提供的 `ACG720-138&60K通用原理图.pdf` 第 1、10 页，
以及 `高云 ACG720-138&60K通用管脚分配表.xlsx` 的 Sheet1。
管脚表中额外的 LED8/N19 与原理图冲突：原理图将 N19 用于 DDR3_ADDR8，
用户已确认以管脚表为准，LED8 使用 N19，本工程据此设置约束。

九路 LED 逻辑已通过仿真，LED8 已设置 N19 位置约束。
下载九路版本的 `build/uart_led/impl/pnr/uart_led.fs` 验证功能。
原来的 `impl/pnr/ao_0.fs` 属于旧版工程。
也可在 Gowin IDE 中重新执行综合和布局布线，再下载新生成的 `.fs` 文件。
也可以在工程根目录执行 `gw_sh tests/build_led.tcl`，
单独生成 `build/uart_led` 下的编译结果。
LED0、LED1 使用的 M22、N22 是复用配置引脚，已启用 SSPI 作为普通 GPIO。
若创建新工程，需要在配置选项中开启 SSPI 引脚作为普通 IO，否则布局布线会报错。
如果 IDE 已经打开工程后仍提示 `dedicated pin (SSPI)`，在左侧右键
`Place & Route` 打开配置，进入 `Place & Route` 的 `Dual-Purpose Pin`，
勾选 `Use SSPI as regular IO`，确认并保存后重新运行布局布线。
已打开的 IDE 可能仍保留修改前的选项，需要在界面中同步设置。
若出现 `VCC '0.95' is set to default`，在布局布线配置中将 VCC 恢复为
当前器件的默认选项；该警告表示软件回退到了默认值，并非 LED 引脚错误的原因。
`src/uart_rx.sdc` 给板载 50 MHz 时钟设置了 20 ns 周期约束。

仿真：在工程根目录执行 `vsim -c -do tests/run_led.do`。
测试使用独立的 9600 波特率串口输入，检查所有编号、连续字节、重复编号、
无效字符、复位，以及每条有效命令只翻转一次。
