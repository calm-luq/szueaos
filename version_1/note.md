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





2000 年以前的计算机主板上均使用 BIOS，如今绝大多数计算机采用的是 EFI（Mac 用的就是 EFI）或 UEFI。BIOS 正在逐步被淘汰。基于 EFI、UEFI 的开机过程与传统的BIOS不尽相同

BIOS和uefi 

https://blog.csdn.net/z15732621736/article/details/49407123#reply

https://mp.weixin.qq.com/s?__biz=MzIyNzIxNjM2MA==&mid=486777136&idx=2&sn=c3589491491dd5b689658e8e165ee46d&chksm=70939fb747e416a19a974c5ba5317ed0effad4f795207bc75c499edf84cd55b12991de76da22&scene=27

https://www.zhihu.com/question/535062479/answer/2506279466







