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
mov dx,0x1f2
mov al,AMOUNT_OF_SECTOR
out dx,al
mov eax,BASE_OF_SECTOR
mov dx,0x1f3
out dx,al
shr eax,8
mov dx,0x1f4
out dx,al
shr eax,8
mov dx,0x1f5
out dx,al
shr eax,8
and al,0x0f
or al,0xe0
mov dx,0x1f6
out dx,al
mov al,0x20
mov dx,0x1f7
out dx,al
mov bx,LOADER_ADDR
READ_DISK_WAIT:
nop
in al,dx
and al,0x88
cmp al,0x08
jnz READ_DISK_WAIT
mov ax,AMOUNT_OF_SECTOR
mov dx,256
mul dx
mov cx,ax
mov dx,0x1f0
READ_DISK_ING:
in ax,dx
mov [bx],ax
add bx,2
loop READ_DISK_ING

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