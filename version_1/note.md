# 环境搭建

## NASM编译器

下载地址：[The Netwide Assembler - Browse Files at SourceForge.net](https://sourceforge.net/projects/nasm/files/)

选择Win32 binaries

选择最新版本

选择所有安装选项

按照提示安装即可

下载完后可以用NASM shell来打开NASM编译器

## 虚拟机

下载地址：[VirtaulBox](https://www.virtualbox.org/wiki/Downloads)

下载地址：[VMWare](https://tanzu.vmware.com/get-started)

也可以使用大部分人装ubuntu会用到的[VMware Workstation Pro](https://www.vmware.com/hk/products/workstation-pro/workstation-pro-evaluation.html)

## bochs

下载地址：[bochs](http://bochs.sourceforge.net/)

进入上方的网址，找到左边蓝色菜单的 See All Releases

然后点击上方的Download The lastest version 2.7

直接下载，安装即可，阅读Bochs的说明文档可以发现这是一个硬件模拟器

## 其他工具

fixvhdw2：用于写入硬盘

HexView：用于查看二进制文件

notepad++：用于写代码

***具体查看tool_pkg.rar***

在Gitee上找到SZUEAOS，下载对应压缩包，解压

打开 szueaos-main/version_1  

解压里面的tool_pkg得到文件夹booktool

可得到所需的全套工具以及配套的源码

# 调试方式

## 编译

* 命令行编译

  右键此电脑->>属性->>高级系统设置->>环境变量path->>加上nasm所在的目录

  打开cmd

  cd 待处理文件所在的文件夹

  nasm 待处理文件名 -f bin -o 输出文件名

  最后一步可以查看nasm手册

* notepad++内嵌nasm快捷编译

  点击菜单行的运行

  点击子项目的运行(F5)

  输入cmd /k pushd "\$(CURRENT_DIRECTORY)" & nasm所在的目录\nasm.exe -f bin  "\$(FULL_CURRENT_PATH)" -o "\$(NAME_PART).bin" -l "$(NAME_PART).lst" & PAUSE & EXIT

  保存并起名“nasm编译”并自定义快捷键，注意快捷键不要和其他编译重复

  此编译会生成bin文件和lst文件

## 创建硬盘

* VirtualBox

  点击菜单栏的管理

  点击子项目的虚拟介质管理

  点击虚拟硬盘

  点击创建，选择VHD，选择固定分配，自定义大小和位置即可

## 载入OS

* FixVhdWr

  打开软件后，点击选择虚拟硬盘文件，选择虚拟硬盘，点击下一步

  点击选择，选择nasm生成的bin文件，点击下一步

  选择LBA模式，起始扇区号为0，点击写入文件，点击完成

## 运行代码

* bochs

  选择disk&boot，点击edit

  选择ATA channel0

  勾选Enable ATA channel

  点击First HD/CD channel0

  type of ATA device选择disk

  path or physical device name选择所有文件中的虚拟硬盘

  type of disk image选择flat

  输入柱面数Cylinders、磁头数Heads、扇区数Sectors per track

  点击Boot Options

  Boot device #1选择disk

  Boot device #2选择cdrom

  点击OK

  点击Start
  
* bochsdbg

  操作同上，OK后程序并不会运行，而是停在0xffff0，此时为调试状态

  输入sreg 查看寄存器内容和状态

  输入r 查看通用寄存器

  输入creg 看cr寄存器

  输入s 执行下一条指令

  输入n 执行下一条指令或者循环体

  输入b 地址 用于标记断点

  输入c 执行指令直到断点

  输入q 退出bochs

  输入help 可以显示所有命令和解析命令

# 计算机运行流程

## 上电阶段

电源在触发一段时间之后（触发原理略），发出一个power good的逻辑信号

cpu停止复位，此时除cs为ffffh外，其他寄存器为0（？？？不确定）

![img](http://hi.csdn.net/attachment/201009/21/0_1285047330a77D.gif)

## BIOS

cpu执行ffffh:0000h处的代码，即jmp f000h:e05bh

（这个地址还要经过MCH和ICH的映射处理，BIOS的厂商不同跳转地址不同，而这个地址就是BIOS程序的入口地址）

用于转跳到bios代码，这块代码会检测一些外设信息POST(power on self test)，并初始化好硬件，建立中断向量表并填写中断例程，如下

\- interrupts are disabled 
关中断 
\- CPU flags are set, read/write/read test of CPU registers 
设置CPU标志位，用读、写、读来测试CPU寄存器 
\- checksum test of ROM BIOS 
检测ROM BIOS的校验和 
\- Initialize DMA (verify/init 8237 timer, begin DMA RAM refresh) 
初始化DMA（校验、初始化 8237时钟控制器，开始DMA 内存刷新） 
\- save reset flag then read/write test the first 32K of memory 
保存复位标志，然后对内存的前32K字节进行读写测试 
\- Initialize the Programmable Interrupt Controller (8259) 
and set 8 major BIOS ~interrupt~ vectors (interrupts 10h-17h) 
初始化8259可编程中断控制器，设置好8个主要的BIOS中断向量(INT 10h-17H) 
\- determine and set configuration information 
检测并设置好CMOS配置信息 
\- initialize/test CRT controller & test video memory (unless 1234h 
found in reset word) 
初始化/测试CRT控制器，测试显存（除非在复位字的位置找到1234h） 
\- test ~8259~ Programmable Interrupt Controller 
测试8259可编程中断控制器 
\- test Programmable Interrupt Timer (~8253~) 
测试8253可编程时钟中断控制器 
\- reset/enable keyboard, verify scan code (AAh), clear keyboard, 
check for stuck keys, setup interrupt vector lookup table 
复位、激活键盘，校验扫描码，清除键盘缓冲区，检查是否有卡住的键，设置中断查找表 
\- hardware interrupt vectors are set 
设置硬件中断向量

\- test for expansion box, test additional RAM 
测试扩展设备，测试扩充内存 
\- read/write memory above 32K (unless 1234h found in reset word) 
读写测试32K字节以上的内存（除非在复位字的位置找到1234h） 
\- addresses C800:0 through F400:0 are scanned in 2Kb blocks in 
search of valid ROM. If found, a far call to byte 3 of the ROM 
is executed. 
以2K字节大小的块为单位，从c800:0到f400:0扫描，查找有效映射的ROM。找到后，对ROM的第3个字节进行远程调用。 
\- test ROM cassette BASIC (checksum test) 
检测ROM BASIC（校验和测试，现在的BIOS已取消ROM BASIC了……） 
\- test for installed diskette drives & ~FDC~ recalibration & seek 
检测安装了的硬盘驱动器、软盘控制器。

在这里寻找一个启动设备，这些设备包括Floppy Disk(A:)，或者Hard Disk(C:)，还可以包括CD-ROM Driver或者其它设备。
\- test printer and RS-232 ports. store printer port addresses 
at 400h and RS-232 port addresses at 408h. store printer 
time-out values at 478h and Serial time-out values at 47Ch.

检测打印机口和RS-232串口。把打印口地址保存在内存的400h，串口地址保存在408h。打印机超时值保存在478h，串口超时值保存在47Ch。 
\- NMI interrupts are enabled 
激活NMI中断 
\- perform ~INT 19~ (bootstrap loader), pass control to boot record 
or cassette BASIC if no bootable disk found 
执行INT 19h（引导装载程序），把控制权转交给引导程序

 

当找到响应的启动设备之后，BIOS将会查找Boot信息时能后续开始OS的启动过程。如果它找到了一个Hard Disk，它将会查找一个位于Cylinder 0, Head 0, Sector 1的Master Boot Record（硬盘的第一个扇区）,如果它找到的是Floppy Disk，它也会读区软盘的第一个扇区。 如果找不到任何启动设备，系统将会显示一条错误信息，然后冻结系统。如果找到了响应的启动设备，BIOS会将读到的扇区放在内存7C00h的位置，并跳转到那里执行它。

## mbr

执行完bios后，转跳到0000:7c00

此处代码加载操作系统

# 实模式内存结构

;                     ┃□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□┃0xfffff(16b)
;                     ┃□□□□□□□□□□□jmp f000:e05b □□□□□□□□□□□┃(与下面64k同为rom芯片的映射)	
;              0xffff0┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
;                     ┃□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□┃0xfffef(64k)
;                     ┃□□□□□□□□□□□□□□bios代码□□□□□□□□□□□□□□┃ (映射原理和地址识别原理略)
;              0xf0000┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
;                     ┃□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□┃0xeffff(160k)(以下为外设映射)
;                     ┃□□□□□□□□□□□□映射ROM或I/O□□□□□□□□□□□□┃(映射方向略)
;              0xc8000┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
;                     ┃□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□┃0xc7fff(32k)
;                     ┃□□□□□□□□□□□bios显示适配器□□□□□□□□□□□┃

;               BIOS 里的信息被映射到了内存 0xC0000 - 0xFFFFF 位置（256K）

;              0xc0000┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
;                     ┃□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□┃0xbffff(32k)
;                     ┃□□□□□□□□□□□文本显示适配器□□□□□□□□□□□┃
;              0xb8000┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
;                     ┃□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□┃0xb7fff(32k) 
;                     ┃□□□□□□□□□□□□□黑白适配器□□□□□□□□□□□□□┃
;              0xb0000┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
;                     ┃□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□┃0xaffff(64k) 
;                     ┃□□□□□□□□□□□□□彩色适配器□□□□□□□□□□□□□┃
;              0xA0000┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
;                     ┃□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□┃0x9ffff(1k)(以下640k为ram)
;                     ┃□□□□□□□□□□□拓展BIOS数据区□□□□□□□□□□□┃ (实际大小取决于物理芯片)
;              0x9fc00┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
;                     ┃                                 ┃0x9fbff(622080b)
;		     0x70000<-kernel.bin，0x9f000<-main的PCB的页顶(4k对齐)，0x9a000<-位图
;                     ┃             空白可用               ┃				 
;               0x7e00┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
;                     ┃■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■┃0x7dff(512b)
;                     ┃■■■■■■■■■■■■■ MBR.bin ■■■■■■■■■■■■■■┃
;               0x7c00┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
;                     ┃                                    ┃0x7bff(50464b)
;	0x7c00<-mbr栈顶，0x600<-loader.bin和loader栈顶，0x1500<-main(分析后的kernel)
;                     ┃             空白可用               ┃	
;                0x500┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
;                     ┃□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□┃0x4ff(256b)
;                     ┃□□□□□□□□□□□□□BIOS数据区□□□□□□□□□□□□□┃
;                0x400┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
;                     ┃◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇       
;                     ┃0x3ff(1k)
;                     ┃◇◇◇◇◇◇◇◇◇◇◇◇中断向量表◇◇◇◇◇◇◇    ┃
;                  0x0┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ 

# other

https://github.com/treelite/8086/blob/master/README.md

通电后，BIOS首先连接到南桥(ESB)，然后是北桥(MCH)，最后连接CPU<img src="https://img-blog.csdnimg.cn/20191029154939933.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3R5bHQ2Njg4,size_16,color_FFFFFF,t_70" alt="天宇龙腾出品" style="zoom:25%;" />

1MB以下比较特殊，里面全部都是已经被淘汰的传统BIOS和DOS关心的内容，我们叫它DOS Space或者Legacy Region

640KB~1MB 上台内存（这一地区的地址分派给ROM，相对应的384KB的RAM被屏蔽。说白了的身影内存技术性，便是把ROM具体内容读取到相匹配地址的RAM中，之后系统软件就从RAM中读取数据信息，而不是从原先的ROM读取数据信息，进而提高速度。）

BIOS 运行初期，CPU 其实是不能访问内存的，BIOS 所在的 FLASH 是那种可以被 CPU 直接寻址的 FLASH 芯片，BIOS 初始化代码开始通过寄存器和北桥芯片沟通
搞定内存之后， BIOS 终于可以使用内存啦！ BIOS 将内存的前 4k 作为临时stack
然后BIOS 通过检查可用的内存值，将自己使用的临时 stack 移步到 >  640K 的地方
然后BIOS 该开始检测 CPU 了。主要的工作是比较 CPU 的微代码版本是否和BIOS 里带的对应CPU的代码一致。否则更新 CPU 的微代码。所以刷新 BIOS 支持新 CPU 的道理就在这里！ 
然后BIOS 会通过北桥重新映射 BIOS FLASH 的地址到内存空间的顶端，原有的映射没有断开
这个时候由于 A20 gate 没有打开，高 12 位被忽略，导致 CPU寻址仍然在 640k ~ 1M，也就是 BIOS 现在在的地址，所以 BIOS 继续运行
若打开bios shadow，BIOS 切换到 32 位寻址，但是还是 16 位 模式，映射 BIOS FLASH 的地址在4G或者更高，bios跳到这执行，然后将原先自己所在的  640k~1M 地址区间通过操作北桥，断开映射，将自己从高位64k内存拷贝回  640k ~1M 区间的地位内存。 然后关闭 A20. 关闭 A20 后， CPU 寻址重新回到低位内存。 BIOS 完成了将自己拷贝到同一个地址的工作. 但是 BIOS 将运行在 SDRAM 中，而不是FLASH 里
然后继续检测基本硬件啦。基本硬件一般都已经固定使用某个 IO端口了。 BIOS 就是发送一个无害的请求看是否有返回就可以知道硬件在不在



上电power good后停止reset，执行0xffff0
post：线检测内存显卡等等
查找并调用显卡和其他设备bios
bios显示启动画面
检测cpu，测试ram
检查标准硬件设备，设置内存参数
分配中断、DMA通道，IO端口
更新ESCD（存在cmos中）
读取主引导记录（55aa）



内存地址分配

[8086PC机内存地址空间分配的基本情况 - 哔哩哔哩 (bilibili.com)](https://www.bilibili.com/read/cv16105500/)

[汇编语言学习笔记(三):8086地址内存分配_Stepfen Shawn的博客-CSDN博客_汇编语言地址分布](https://blog.csdn.net/qq_43933657/article/details/105356764?ops_request_misc=&request_id=&biz_id=102&utm_term=8086地址分配&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-3-105356764.142^v70^control,201^v4^add_ask)

http://tianyu-code.top/Linux%E5%86%85%E6%A0%B8/x86CPU%E5%9C%B0%E5%9D%80%E7%A9%BA%E9%97%B4%E5%88%86%E9%85%8D/

**Shadow RAM**也称之为"身影内存",是因为提升计算机软件高效率而采取的一种专业技术性，所运用的物理学集成ic依然是CMOS DRAM

https://blog.csdn.net/weixin_30443075/article/details/97883736

[(121条消息) 关于BIOS的入口地址0xFFFF0_Alix_sz的博客-CSDN博客_bios地址](https://blog.csdn.net/humanof/article/details/53844243)

一般来说，ROM 的运行速度比 RAM 慢得多。由于硬件代码通常存储在 ROM 中，因此每次执行硬件代码时性能都会受到影响。可以通过将慢速 ROM 中的代码复制到 RAM 中并从 RAM 中执行代码来提高性能。包含复制代码的 RAM 称为**“影子 RAM”。**尽管 RAM 阴影可以显着提高性能，但它会使用一些额外的 RAM，这些 RAM 将不再可供应用程序使用。

 

许多 BIOS（基本输入/输出系统）允许禁用 RAM 阴影。（执行此操作的方法因计算机而异；您可以参考计算机的用户手册，或联系 OEM。）禁用影子 RAM 的通常原因是回收扩展内存以供其他程序使用。它只能作为最后的手段来使用，因为禁用影子 RAM 通常会显着降低计算机速度。（一些低质量的计算机可能会减慢很多，以至于它们几乎无法使用。）由于性能成本，在大多数情况下，应该启用影子 RAM。

Shadow RAM占有了系统主存的一部分地址室内空间。其编址范畴为C0000～FFFFF，即是1MB主存中的768KB～1024KB区域，这一地区通常也称之为内存 保留区，可执行程序不可以立即浏览

386 以前与386以后，这一地址是不一样的，但都是在系统软件内存的最大 地址段。在386下以 FFFFFFF0H

因而，386应用硬件配置置1的形式将A20～A31地址线置1，就变为FFFFFFF0H，并以此来做为Bios地址

当开展一次段间自动跳转后，置1就改变了

例子：

在386之前系统软件可寻址方式范畴为1MB即 00000H~FFFFFH，CS＝F000H，IP＝FFF0H

在386下CS＝F000H，IP＝FFF0H，但硬件后把高地址线初始化为1

64KB限制一直是硬件限制，而不是软件限制，如今许多BIOS都超过了64KB，通常超过10MB，要重新控制从内存到固件Flash ROM的内存访问

CPU通过至少一个外部芯片访问固件（用于获取指令或数据）
**Core** **--**[QPI/UPI]**--**> **System** **Agent** **--**[DMI]**--**> **PCH** **--**[SPI/LPC]**--**> **FLASH** **ROM**
**CPU** --[FSB]--> North Bridge/MCH --[DMI/Proprietary]--> South Bridge/ICH --[LPC] --> FLASH ROM
**CPU** **--**[BUS]**--**> **System** **Controller** **--**> **FLASH** **ROM**

为了使CPU能够访问固件，一些内存地址被盗并重定向到Flash ROM。
这是通过配置CPU和Flash ROM之间的所有中间节点来完成的

主板上电后开始初始化其固件。固件是一些固化在芯片组上的程序，它会试图去启动 CPU。如果启动失败（例如 CPU 坏了或没插好），计算机就会死机并给出错误提示（如某些版本的主板固件会发出蜂鸣警告）。这种状态称为 “zoombie-with-fans”

在多 CPU 或多核 CPU 情况下，某一个 CPU 会被随机选取作为启动 CPU（bootstrap processor，BSP）运行 BIOS 内部的程序。其余的 CPU（application processor，AP）保持停机直到操作系统内核显式地使用它们

2000 年以前的计算机主板上均使用 BIOS，如今绝大多数计算机采用的是 EFI（Mac 用的就是 EFI）或 UEFI。BIOS 正在逐步被淘汰。基于 EFI、UEFI 的开机过程与传统的BIOS不尽相同

BIOS和uefi 

https://blog.csdn.net/z15732621736/article/details/49407123#reply

https://mp.weixin.qq.com/s?__biz=MzIyNzIxNjM2MA==&mid=486777136&idx=2&sn=c3589491491dd5b689658e8e165ee46d&chksm=70939fb747e416a19a974c5ba5317ed0effad4f795207bc75c499edf84cd55b12991de76da22&scene=27

https://www.zhihu.com/question/535062479/answer/2506279466
