org 0x900

mov ax,0xb800
mov es,ax
mov byte [es:10],'!'
mov byte [es:11],0x4c
mov byte [es:12],'!'
mov byte [es:13],0x4c
mov byte [es:14],'!'
mov byte [es:15],0x4c
mov byte [es:16],'!'
mov byte [es:17],0x4c
mov byte [es:18],'!'
mov byte [es:19],0x4c
mov byte [es:20],'!'
mov byte [es:21],0x4c

;暂停在此
jmp $

