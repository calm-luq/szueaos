Win下编写操作系统内核

使用VHD作为硬盘

在bochs中运行代码



早期显存基地址是B0000而不是B8000，占用的内存范围是B0000~BFFF0，早期文本模式占用前4kb

后期发展，B0000\~B7FF0段兼容单色显卡显存，B8000~BFFF0段留给彩色字符显存，如今默认B8000

再后来，显卡发展出VGA模式，显卡的显存也增长到了256KB，A000就用来做VGA的图形模式的显存



文本模式下，一卷的字符数为25*80=2000，一个字符占用2Bytes，一卷4000Bytes

由于ram上映射4kb，即0xb8000到0xb0fff，有？？？面，超出则回绕？？？？？



A0000~AFFFF: VGA图形模式显存空间

B0000~B7FFF: MDA单色字符模式显存空间

B8000~BFFFF: CGA彩色字符模式显存空间

C0000~C7FFF: 显卡ROM空间（后来被改造成多种用途，也可以映射显存）

C8000~FFFFE: 留给BIOS以及其它硬件使用（比如硬盘ROM之类的）



    ;                              0x100000<-内核栈顶
    ;             0x100000┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
    ;                     ┃□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□┃0xfffff(16b)
    ;                     ┃□□□□□□□□□□□jmp f000:e05b □□□□□□□□□□□┃				
    ;              0xffff0┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
    ;                     ┃□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□┃0xfffef(64k)
    ;                     ┃□□□□□□□□□□□□□□bios代码□□□□□□□□□□□□□□┃ 
    ;              0xf0000┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
    ;                     ┃□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□┃0xeffff(160k)
    ;                     ┃□□□□□□□□□□□□映射ROM或I/O□□□□□□□□□□□□┃
    ;              0xc8000┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
    ;                     ┃□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□┃0xc7fff(32k)
    ;                     ┃□□□□□□□□□□□bios显示适配器□□□□□□□□□□□┃
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
    ;                     ┃□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□┃0x9ffff(1k)
    ;                     ┃□□□□□□□□□□□拓展BIOS数据区□□□□□□□□□□□┃ 
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