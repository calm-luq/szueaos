;前提信息
AMOUNT_OF_SECTOR equ 0x1
BASE_OF_SECTOR equ 0x1;LBA算法
LOADER_ADDR equ 0x900

;初始化编译地址
org 0x7c00

;转跳到代码区
jmp START
nop

;自定义栈顶
Stack_Base equ 0x7c00

START:
;初始化段寄存器
;此处cs=0x0000,ip=0x7c00
mov ax,cs
mov ds,ax
mov ss,ax
mov sp,Stack_Base

;清屏，ah=0x06或者0x07
mov ah,0x06
mov al,0x00
mov bh,0x00
mov cx,0x0000
mov dx,0x184f
int 0x10

;文本模式下的es
mov ax,0xb800
mov es,ax

;使用文本内存显示
mov byte [es:10],'O'
mov byte [es:11],0x4c
mov byte [es:12],'S'
mov byte [es:13],0x4c

;使用bios中断显示
push ds
pop es
mov bp,BOOT_MSG_1
mov cx,5
mov dh,0
mov dl,0
mov bh,0
mov al,0
mov bl,0x4c
mov ah,0x13
int 0x10

mov bp,BOOT_MSG_2
mov cx,10
mov dh,1
mov dl,0
mov bh,0
mov al,0
mov bl,0x4c
mov ah,0x13
int 0x10

;等待键盘按键
mov ah,0
int 0x16

;滚行，屏幕下卷
mov ah,0x07
mov al,23
mov ch,3
mov cl,0
mov dh,24
mov dl,79
mov bh,0x77
int 0x10

;端口读取硬盘
mov dx,0x1f2            ;dx存储端口号，该端口用于记录要读取扇区的数量
mov al,AMOUNT_OF_SECTOR ;al存储要读的扇区数量
out dx,al               ;al发送到dx端口
mov eax,BASE_OF_SECTOR  ;eax存储从哪个扇区开始读，采用LBA方式，就是从0开始数，1，2，3这样子
mov dx,0x1f3            ;dx存储端口号，该端口用于记录LBA0~7位
out dx,al               ;al发送到dx端口
shr eax,8               ;eax右移动8位
mov dx,0x1f4            ;dx存储端口号，该端口用于记录LBA8~15位
out dx,al               ;al发送到dx端口
shr eax,8               ;eax右移动8位
mov dx,0x1f5            ;dx存储端口号，该端口用于记录LBA16~23位
out dx,al               ;al发送到dx端口
shr eax,8               ;eax右移动8位
and al,0x0f             ;保留0~4位，其他设置为0
or al,0xe0              ;5~7位用1110填充，即1110xxxx
mov dx,0x1f6            ;dx存储端口号，该端口用于记录LBA24~27位和1110，1110表示现在采用的是LBA方式
out dx,al               ;al发送到dx端口
mov al,0x20             ;0x20是读命令，告诉硬盘我要读取数据
mov dx,0x1f7            ;dx存储端口号，用于操作硬盘工作状态，也可以用于读取当前硬盘状态
out dx,al               ;al发送到dx端口
mov bx,LOADER_ADDR      ;硬盘读出来的数据存储的地址
READ_DISK_WAIT:         ;
nop                     ;不操作，用来拖时间
in al,dx                ;读取硬盘操作状态到al
and al,0x88             ;保留0和7位
cmp al,0x08             ;判断0和7位，看否是就绪
jnz READ_DISK_WAIT      ;不等于，即没就绪，再继续读取判断
mov ax,AMOUNT_OF_SECTOR ;ax为读取的扇区数量
mov dx,256              ;dx为一个扇区多少个字
mul dx                  ;ax=ax*dx，得出一共多少个字
mov cx,ax               ;存储到cx中
mov dx,0x1f0            ;dx存储端口号，该端口用于读取扇区的内容
READ_DISK_ING:          ;
in ax,dx                ;将内容读取到扇区，此时内容会自动更新为下一字
mov [bx],ax             ;将内容放到要读到的地址处
add bx,2                ;地址加2指向下一个字的位置
loop READ_DISK_ING      ;cx--;如果cx!=0则继续读

;转跳到LOADER
jmp LOADER_ADDR

;暂停在此
infi:
jmp near infi

;信息
BOOT_MSG_1:db 'szuea'
BOOT_MSG_2:db 'booting...'


;填充0，直到510Bytes
times 510-($-$$) db 0

;魔数
db 0x55,0xaa