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

  
  
  



