; by sadeem sajid 21L-1870
; and foad ahmed 21L-5488

[org 0x0100]
jmp start

bg: dw 0x3020       ; background pixels     0 - 8
mg: dw 0x2020       ; middleground pixels   9 - 16
fg: dw 0x70B1       ; foreground pixels     17 - 25

color_road: dw 0x0020       ; color of road
color_rddts: dw 0xF020      ; color of road details

color_strn: dw 0x0020       ; color of steering wheel

color_clouds: dw 0x3FB1     ; color of clouds

color_trunk: dw 0x6FDD     ; color of tree trunk

color_ac: dw 0x04DC         ; color of car ac

sadeem: db 'SADEEM SAJID', 0
foad: db 'FOAD AHMED', 0
name_atr: db 01001111b

color_red: dw 0x4020        ; red light color
color_green: dw 0x2020      ; green light color

color_map_bg: dw 0x7020     ; map background color

color_grass: dw 0x20B1      ; color of grass

color_sign: dw 0x0FB1       ; color of sign

tickcount:	dd	0

oldkisr: dd 0
oldtime: dd 0

offset_grass: dw 0

map_marker: dw 0
map_mode: dw 0      ; 0 for increment, 1 for decrement, 2 for shifting

speed_dec: dw 0x0

road_offset: dw 1200
grass_offset: dw 1140

; state handlers -----------------------------------

game_state: dw 0    ; 0 for playing, 1 for finished

track_state: dw 0   ; finish at 3

turn_state: dw 0    ; turn at 1, straight at 0

fail_state: dw 0    ; win at 0, fail at 1

; state handlers -----------------------------------

; Messages -----------------------------------------

msg_fail: db 'Off Track, Please Restart!', 0
msg_succeed: db '--- RESULTS ---', 0
pos_text: db 'POSITION', 0
lap_text_1: db 'LAP:', 0
lap_text_2: db '/3', 0

; Messages -----------------------------------------

; NPC Data -----------------------------------------

npc_1: db 'Karachi Resident', 0
npc_2: db 'Sir Zeeshan', 0
npc_3: db 'Hassan Mudassir', 0
npc_4: db 'Foad Siraiki', 0
npc_5: db 'Shahzaib Shahbaz', 0
npc_6: db 'Nofil Tufail', 0
npc_times: dw 0, 10, 18, 23, 27, 28 
player_name: dw 'PLAYER', 0
player_time: dw 0 
player_pos: dw 0


keyISR:

    push ax
    push es
    in al, 0x60
    
    ; Checking for Escape Key
    cmp al, 0x1
    je keyISR_exit

    ; Checking for UP key
    cmp al, 0x48
    je keyISR_UP

    ; Checking for RIGHT key
    cmp al, 0x4d
    je keyISR_RIGHT

    ; Checking for LEFT key
    cmp al, 0x4b
   je keyISR_LEFT

    ; Checking for DOWN key
    cmp al, 0x50 
    je keyISR_DOWN


    jmp keyISR_return

    keyISR_exit:

        mov word [game_state], 1
        jmp keyISR_return

    keyISR_UP:

        cmp word [turn_state], 0
        je keyISR_UP_1

        mov word [fail_state], 1

        keyISR_UP_1:

            jmp keyISR_return

    keyISR_DOWN:

        mov word [fail_state], 1
        jmp keyISR_return
    
    keyISR_LEFT:

        mov word [fail_state], 1
        jmp keyISR_return

    keyISR_RIGHT:
        
        cmp word [turn_state], 1
        je keyISR_RIGHT_1

        mov word [fail_state], 1

        keyISR_RIGHT_1:

            jmp keyISR_return

    keyISR_return:

        pop es
        pop ax
        jmp far [cs:oldkisr] 


printnum:	
        
        push bp
		mov bp, sp
		push es
		push ax
		push bx
		push cx
		push dx
		push di

		mov ax, 0xb800
		mov es, ax
		mov ax, [bp+4]
		mov bx, 10
		mov cx, 0

    nextdigit:	

            mov dx, 0
            div bx
            add dl, 0x30
            push dx
            inc cx
            cmp ax, 0
            jnz nextdigit

            mov di, [bp + 6]

    nextpos:	

            pop dx
            mov dh, 0x07
            mov [es:di], dx
            add di, 2
            loop nextpos

            pop di
            pop dx
            pop cx
            pop bx
            pop ax
            pop es
            pop bp
            ret 4

timer:		

    pusha

    inc word [player_time]
    mov ax, [player_time]
    mov dx, 0
    mov bx, 1
    div bx
    cmp dx, 0
    jne end_timer

    push word 0
    push word [player_time]
    call printnum

    end_timer:	

        mov al, 0x20
        out 0x20, al

    popa
    iret

; clear the screen
clrscr:

    push ax
    push es
    push di
    push cx

    mov ax, 0xb800
    mov es, ax
    mov ax, 0x0720
    mov cx, 2000
    xor di, di

    cld
    rep stosw

    pop cx
    pop di
    pop es
    pop ax
    ret

; subroutine for drawing base colours for bg, mg, and fg
draw_base:

    push bp
    mov bp, sp

    push ax
    push es
    push di
    push cx

    mov ax, 0xb800
    mov es, ax
    xor di, di
    cld
    
    ; print bg

    mov cx, 560
    mov ax, [bp + 8]
    rep stosw

    ; print mg

    mov cx, 720
    mov ax, [bp + 6]
    rep stosw

    ; print fg

    mov cx, 720
    mov ax, [bp + 4]
    rep stosw

    pop cx
    pop di
    pop es
    pop ax
    pop bp
    ret 6

; prints the road from col 10 - 70, row 8 - 15
prnt_road:

    push bp
    mov bp, sp

    push ax
    push es
    push di
    push cx
    push bx
    push si
    push dx

    mov ax, 0xb800
    mov es, ax
    xor di, di

    mov di, 1120
    mov cx, 720
    mov ax, [mg]
    rep stosw

    mov ax, [bp + 4]
    ; mov dx, 1334        ; starting position of the road
    mov dx, 1178
    mov si, 9           ; height of road
    mov bx, 22          ; length of road

    prnt_road_l1:

        mov di, dx
        mov cx, bx
        rep stosw 
        add dx, 156     ; row increment
        add bx, 4       ; length increase
        dec si
        jnz prnt_road_l1

    pop dx
    pop si
    pop bx
    pop cx
    pop di
    pop es
    pop ax
    pop bp
    ret 2


; print the road details from col 12, 68 - row 8, 15
prnt_rddts:

    push bp
    mov bp, sp

    push ax
    push es
    push di
    push cx
    push dx ; offset
    push bx
    push si

    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov ax, [bp + 4]
    mov dx, 1182    ; offset for di
    mov bx, 32      ; offset for road right end mark
    mov si, 9

    prnt_rddts_l1:

        mov di, dx
        stosw
        add di, bx
        stosw
        add dx, 156
        add bx, 8
        dec si
        jnz prnt_rddts_l1

    pop si
    pop bx
    pop dx
    pop cx
    pop di
    pop es
    pop ax
    pop bp
    ret 2

prnt_road_spc:

    push bp
    mov bp, sp

    push ax
    push es
    push di
    push cx
    push dx ; offset
    push bx
    push si


    mov ax, 0xb800
    mov es, ax

    mov dx, 1200
    mov ax, [color_rddts]
    mov si, 9

    prnt_road_spc_clr:  ; middle line

        mov di, dx
        stosw
        add dx, 160
        dec si
        jnz prnt_road_spc_clr

    mov dx, [bp + 6]    ; starting print
    mov ax, [bp + 4]    ; attribute
    mov si, 4

    prnt_road_spc_1:

        mov di, dx
        stosw
        add dx, 320
        dec si
        jnz prnt_road_spc_1

    pop si
    pop bx
    pop dx
    pop cx
    pop di
    pop es
    pop ax
    pop bp
    ret 4

; prints the clouds from row 2, 6
prnt_clouds:

    push bp
    mov bp, sp

    push ax
    push es
    push di
    push cx
    push dx
    push bx
    push si

    mov ax, 0xb800
    mov es, ax
    mov ax, [bp + 4]

    mov di, 370
    mov cx, 3
    rep stosw

    sub di, 4
    add di, 160
    sub di, 6
    mov cx, 7
    rep stosw

    sub di, 20
    add di, 160
    mov cx, 18
    rep stosw

    pop si
    pop bx
    pop dx
    pop cx
    pop di
    pop es
    pop ax
    pop bp
    ret 2

;prints the steering wheel
prnt_strng:

    push bp
    mov bp, sp

    push ax
    push es
    push di
    push cx
    push bx

    mov ax, 0xb800
    mov es, ax
    mov ax, [bp + 4] ; color of steering

    ; begin coloring 
    
    ; 18th row

    mov word [es:2950], ax 
    mov word [es:2952], ax 
    mov word [es:2954], ax 
    mov word [es:2956], ax   
    mov word [es:2958], ax  

    mov word [es:2960], ax  

    mov word [es:2962], ax  
    mov word [es:2964], ax  
    mov word [es:2966], ax  
    mov word [es:2968], ax  
    mov word [es:2970], ax  

    ; 19th row

    mov word [es:3110 - 4], ax  
    mov word [es:3112 - 4], ax  
    mov word [es:3114 - 4], ax 
     
    mov word [es:3126 + 4], ax  
    mov word [es:3128 + 4], ax  
    mov word [es:3130 + 4], ax  

   ; 20th Row

    mov word [es:3268 - 4], ax 
    mov word [es:3270- 4], ax  

    mov word [es:3130 + 160 + 4], ax
    mov word [es:3130 + 162 + 4], ax

    ; 21st Row

    mov word [es:3428 - 4], ax 
    mov word [es:3130 + 322 + 4], ax

    ; 22nd Row

    mov word [es:3588 - 4], ax 
    mov word [es:3590 - 4], ax 

    mov word [es:3130 + 480 + 4], ax
    mov word [es:3130 + 482 + 4], ax

    ; 23rd Row

    mov word [es:3110 + 640 - 4], ax  
    mov word [es:3112 + 640 - 4], ax  
    mov word [es:3114 + 640 - 4], ax 
     
    mov word [es:3126 + 640 + 4], ax  
    mov word [es:3128 + 640 + 4], ax  
    mov word [es:3130 + 640 + 4], ax  

    pop bx
    pop cx
    pop di
    pop es
    pop ax
    pop bp
    ret 2

update_strng:

    push bp
    mov bp, sp

    push ax
    push es
    push di
    push cx
    push bx

    mov bx, [color_strn]
    mov ax, 0xb800
    mov es, ax
    mov di, [bp + 4]
    shl di, 2

    mov word [es:2960], bx
    mov word[es: 2964], bx

    mov word [es:2960 + di], 0x4020

    pop bx
    pop cx
    pop di
    pop es
    pop ax
    pop bp
    ret 2

prnt_stats:

    push bp
    mov bp, sp

    push ax
    push es
    push di
    push cx
    push dx
    push bx
    push si

    ; string printing

    ; print 'time'

    push word 0
    push word [bp + 8]
    call getlen
    pop cx

    mov ax, 0xb800
    mov es, ax

    cld
    mov si, [bp + 8]
    mov ah, [name_atr]
    mov di, 160

    prnt_stats_l1:

        lodsb
        stosw
        loop prnt_stats_l1

    
    ; print starting lights
    mov ax, [bp + 6]
    mov di, 230
    stosw
    stosw
    add di, 4
    stosw
    stosw
    add di, 4
    stosw
    stosw

    ; print speed
    push word 0
    push word [bp + 10]
    call getlen
    pop cx

    mov si, [bp + 10]
    mov ah, [name_atr]
    mov di, 320

    prnt_stats_l2:

        lodsb
        stosw
        loop prnt_stats_l2


    pop si
    pop bx
    pop dx
    pop cx
    pop di
    pop es
    pop ax
    pop bp
    ret 6


; print map
prnt_map:

    push bp
    mov bp, sp

    push ax
    push es
    push di
    push cx
    push dx
    push bx
    push si

    mov ax, 0xb800
    mov es, ax
    mov ax, [bp + 4]

    mov dx, 122
    mov si, 6

    ; print map background
    prnt_map_l1:

        mov di, dx
        mov cx, 19
        rep stosw
        add dx, 160
        dec si
        jnz prnt_map_l1

    ; print map trace

    mov ax, 0x0020
    mov di, 288
    mov cx, 13
    rep stosw

    mov di, 446
    stosw
    mov di, 474
    stosw

    mov di, 606
    stosw
    mov di, 634
    stosw

    mov di, 288 + 480
    mov cx, 13
    rep stosw

    pop si
    pop bx
    pop dx
    pop cx
    pop di
    pop es
    pop ax
    pop bp
    ret 2

print_ac:

    push bp
    mov bp, sp

    push ax
    push es
    push di
    push cx
    push dx
    push bx
    push si

    mov ax, 0xb800
    mov es, ax
    mov ax, [bp + 4]

    mov dx, 3540
    mov si, 4

    print_ac_l1:

        mov di, dx
        mov cx, 10
        rep stosw
        add di, 80
        mov cx, 10
        rep stosw
        add dx, 160
        dec si
        jnz print_ac_l1

    mov dx, 2740
    mov si, 3
    mov ax, 0x0020

    print_ac_l2:

        mov di, dx
        mov cx, 10
        rep stosw
        add di, 80
        mov cx, 10
        rep stosw
        add dx, 160
        dec si
        jnz print_ac_l2

    pop si
    pop bx
    pop dx
    pop cx
    pop di
    pop es
    pop ax
    pop bp
    ret 2

; get length of the string to print
getlen:

    push bp
    mov bp, sp

    push ax
    push di
    push cx
    push es

    push ds
    pop es
    mov di, [bp + 4]
    mov cx, 0xffff
    xor al, al
    repne scasb
    mov ax, 0xffff
    sub ax, cx
    dec ax
    mov [bp + 6], ax

    pop es
    pop cx
    pop di
    pop ax
    pop bp
    ret 2

delay:

    push ax
    push cx
    push di

    mov ax, 0x0300

    sub word ax, [speed_dec]
    mov di, ax

    delay_l1:

        mov cx, di
        dec ax
        jz delay_exit

        delay_l2:

            dec cx
            jnz delay_l2
            jmp delay_l1

    delay_exit:

        pop di
        pop cx
        pop ax
        ret


prnt_sign_l:

    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push di
    push si


    mov ax, 0xb800
    mov es, ax

    ; reset grass

    mov ax, [mg]
    mov dx, 1120
    mov si, 9

    prnt_sign_l_1:

        mov di, dx
        mov cx, 13
        rep stosw
        add dx, 160
        dec si
        jnz prnt_sign_l_1

    mov di, [bp + 4]        ; starting point
    mov ax, [color_sign]   

    mov word [es:di], 0x04020
    add di, 160
    mov word [es:di], ax
    add di, 156
    mov cx, 5
    rep stosw

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp

    ret 2

prnt_sign_r:

    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push di
    push si

    mov ax, 0xb800
    mov es, ax

    ; reset grass

    mov ax, [mg]
    mov dx, 1254
    mov si, 9

    prnt_sign_r_1:

        mov di, dx
        mov cx, 13
        rep stosw
        add dx, 160
        dec si
        jnz prnt_sign_r_1

    mov di, [bp + 4]        ; starting point
    mov ax, [color_sign]

    add di, 118
    add di, [offset_grass]   

    mov word [es:di], 0x01020
    add di, 160
    mov word [es:di], ax
    add di, 156
    mov cx, 5
    rep stosw

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp

    ret 2

reset_grass:

    push ax
    push bx
    push cx
    push dx
    push di
    push si


    mov ax, 0xb800
    mov es, ax

    ; reset grass

    mov ax, [mg]
    mov dx, 1120
    mov si, 9

    reset_grass_1:

        mov di, dx
        mov cx, 13
        rep stosw
        add dx, 160
        dec si
        jnz reset_grass_1

    mov dx, 1254
    mov si, 9

    reset_grass_2:

        mov di, dx
        mov cx, 13
        rep stosw
        add dx, 160
        dec si
        jnz reset_grass_2

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

turn_right:

    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push di
    push si

    mov ax, 0xb800
    mov es, ax

    ; clear grass

    mov di, 1120
    mov cx, 720
    mov ax, [mg]
    rep stosw

    mov ax, [bp + 4]
    mov bx, [color_rddts]

    mov dx, 1200
    mov cx, 22
    mov di, dx
    rep stosw

    
    mov word [es:di - 4], bx
    mov di, dx
    mov word [es:di + 2], bx

    add dx, 150
    mov cx, 24
    mov di, dx
    rep stosw

    mov word [es:di - 4], bx
    mov di, dx
    mov word [es:di + 2], bx

    add dx, 152
    mov cx, 26
    mov di, dx
    rep stosw

    mov word [es:di - 4], bx
    mov di, dx
    mov word [es:di + 2], bx

    add dx, 152
    mov cx, 28
    mov di, dx
    rep stosw

    mov word [es:di - 4], bx
    mov di, dx
    mov word [es:di + 2], bx

    add dx, 154
    mov cx, 30
    mov di, dx
    rep stosw

    mov word [es:di - 4], bx
    mov di, dx
    mov word [es:di + 2], bx

    add dx, 154
    mov cx, 34
    mov di, dx
    rep stosw

    mov word [es:di - 4], bx
    mov di, dx
    mov word [es:di + 2], bx

    add dx, 156
    mov cx, 38
    mov di, dx
    rep stosw

    mov word [es:di - 4], bx
    mov di, dx
    mov word [es:di + 2], bx

    add dx, 154
    mov cx, 44
    mov di, dx
    rep stosw

    mov word [es:di - 4], bx
    mov di, dx
    mov word [es:di + 2], bx

    add dx, 154
    mov cx, 50
    mov di, dx
    rep stosw

    mov word [es:di - 4], bx
    mov di, dx
    mov word [es:di + 2], bx

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 2

update_map:

    push ax
    push bx
    push cx
    push dx
    push di
    push si

    ; right turns
    ; 446   
    ; 474   

    ; 606
    ; 634

    mov ax, 0xb800
    mov es, ax

    push word [color_map_bg]
    call prnt_map
    
    mov di, [map_marker] ; map trace point
    mov word [es:di], 0x0020

    cmp di, 312
    je update_map_1

    cmp di, 474
    je update_map_2

    cmp di, 634
    je update_map_3

    cmp di, 768
    je update_map_5

    cmp di, 606
    je update_map_6

    cmp di, 446
    je update_map_7


    cmp word [map_mode], 0
    je update_map_inc

    cmp word [map_mode], 1
    je update_map_dec
 

    update_map_1:

        mov word [map_mode], 2
        mov di, 474
        jmp update_map_exit
    
    update_map_2:

        mov di, 634
        jmp update_map_exit

    update_map_3:

        mov word [map_mode], 1
        mov di, 792
        jmp update_map_exit

    update_map_4:

        mov di, 792
        jmp update_map_exit

    update_map_5:

        mov word [map_mode], 2
        mov di, 606
        jmp update_map_exit

    update_map_6:

        mov di, 446
        jmp update_map_exit

    update_map_7:

        mov word [map_mode], 0
        mov di, 288
        jmp update_map_exit

    update_map_inc:

        add di, 2
        jmp update_map_exit

    update_map_dec:

        sub di, 2

    update_map_exit:

        mov word [es:di], 0x4020
        mov word [map_marker], di

    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret


prnt_string:

    push bp
    mov bp, sp

    push ax
    push es
    push di
    push cx
    push dx
    push bx
    push si

    mov ax, 0xb800
    mov es, ax

    push word 0
    push word [bp + 6]
    call getlen
    pop cx

    mov si, [bp + 6]
    mov di, [bp + 4]
    mov ah, 0x07

    prnt_string_1:

        lodsb
        stosw
        loop prnt_string_1


    pop si
    pop bx
    pop dx
    pop cx
    pop di
    pop es
    pop ax
    pop bp
    ret 4

prnt_results:

    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push di
    push si
    push es

    xor di, di
    xor si, si
    mov ax, 0xb800
    mov es, ax

    ; ; printing top bar ---

    ; mov cx, 80
    ; mov ax, 0x7020
    ; rep stosw

    ; mov cx, 320
    ; mov ax, 0x4020
    ; rep stosw

    ; mov ax, 0x7020
    ; mov cx, 80
    ; rep stosw

    ; ; -------------------

    push word msg_succeed
    push word 60
    call prnt_string

    mov bx, 350
    
    push word npc_1
    push word bx
    call prnt_string

    add bx, 160

    push word npc_2
    push word bx
    call prnt_string

    add bx, 160

    push word npc_3
    push word bx
    call prnt_string

    add bx, 160

    push word npc_4
    push word bx
    call prnt_string

    add bx, 160

    push word npc_5
    push word bx
    call prnt_string

    add bx, 160

    push word npc_6
    push word bx
    call prnt_string

    mov bx, 420
    mov si, npc_times
    mov cx, 6

    prnt_results_1:

        push bx
        push word [si]
        call printnum
        add si, 2
        add bx, 160
        loop prnt_results_1

    
    mov bx, 1470

    push word player_name
    push bx
    call prnt_string

    mov bx, 1540

    push bx
    push word [player_time]
    call printnum

    ; position calculater

    xor di, di
    xor si, si

    mov si, npc_times
    mov dx, [player_time]
    mov cx, 6

    prnt_results_2:

        cmp dx, [si]
        jle prnt_results_3
        inc word [player_pos]
        add si, 2
        loop prnt_results_2

        prnt_results_3:

            push word 2152
            push word [player_pos]
            call printnum

            push word pos_text
            push word 1984
            call prnt_string

    pop es
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret


prnt_fail:

    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push di
    push si
    push es

    mov ax, 0xb800
    mov es, ax

    xor di, di

    mov cx, 80
    mov ax, 0x7020
    rep stosw

    mov cx, 320
    mov ax, 0x4020
    rep stosw

    mov ax, 0x7020
    mov cx, 80
    rep stosw

    push word msg_fail
    push word 530
    call prnt_string

    pop es
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret

prnt_lap:

    push ax
    push bx
    push cx
    push dx
    push di
    push si
    push es

    mov ax, 0xb800
    mov es, ax
    xor di, di

    push word lap_text_1
    push word 70
    call prnt_string

    push word lap_text_2
    push word 84
    call prnt_string

    mov bx, [track_state]
    inc bx
    push word 80
    push bx
    call printnum

    pop es
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ================================ START ================================ 
start:

    call clrscr

    ; reset states

    mov word [fail_state], 0
    mov word [game_state], 0
    mov word [turn_state], 0
    mov word [track_state], 0
    mov word [player_time], 0
    mov word [player_pos], 0

   ; print bg, mg, and fg
    push word [bg]
    push word [mg]
    push word [fg]
    call draw_base

    push word [color_strn]
    call prnt_strng

    ; print the road
    push word [color_road]
    call prnt_road

    ; print road details
    push word [color_rddts]
    call prnt_rddts

    ; print clouds
    push word [color_clouds]
    call prnt_clouds

    ; print stats such as time and red light
    push word sadeem
    push word foad
    push word [color_red]
    push word [color_green]
    call prnt_stats

    ; print map
    push word [color_map_bg]
    call prnt_map
    mov word [map_marker], 288

    ; print car ac
    push word [color_ac]
    call print_ac

    ; xor di, di
    ; mov ax, 0xb800
    ; mov es, ax
    ; xor ax, ax

    ; KEY ISR --------------------

    xor ax, ax
    mov es, ax

    mov ax, [es:9*4]
    mov [oldkisr], ax

    mov ax, [es:9*4+2]
    mov [oldkisr + 2], ax
    cli
    mov word [es:9*4], keyISR
    mov word [es:9*4+2], cs
    sti

    ; ----------------------------

    ; TIMER -----------------------------


    xor ax, ax
    mov es, ax
    mov ax, [es:8*4]
    mov [oldtime], ax

    mov ax, [es:8*4+2]
    mov [oldtime + 2], ax

    cli
    mov word [es:8*4], timer
    mov [es:8*4+2], cs
    sti

    mov dx, start
    add dx, 15
    mov cl, 4
    shr dx, cl

    xor ax, ax

    ; -----------------------------------

    ; mov word dx, [road_offset]
    ; mov word bx, [grass_offset]


    mov ax, 0xb800
    mov es, ax
    xor di, di

    mov cx, 80
    mov ax, 0x0720
    rep stosw

    ;REPITION --------------------------

    mainloop:

        mov ah, 0
        int 0x16

        call prnt_lap

        push word [road_offset]
        push word [color_road]
        call prnt_road_spc

        push word [grass_offset]
        call prnt_sign_r

        push word [grass_offset]
        call prnt_sign_l

        call update_map

        ; check when to turn right

        cmp word [map_marker], 312
        je turn
        cmp word [map_marker], 634
        je turn
        cmp word [map_marker], 768
        je turn
        cmp word [map_marker], 446
        je turn

        add word [offset_grass], 12
        add word [grass_offset], 314
        add word [road_offset], 160
        
        check_reset:
        
            cmp word [road_offset], 1520
            ja reset
            jmp continue

        turn:

            push word [color_road]
            call turn_right
            push word 1
            call update_strng

            mov word [turn_state], 1
            
            mov ah, 0
            int 0x16

            push word [color_road]
            call prnt_road
            push word [color_rddts]
            call prnt_rddts
            push word 0
            call update_strng

            mov word [turn_state], 0

            jmp check_reset

        reset:

            mov word [offset_grass], 0
            mov word [grass_offset], 1140
            mov word [road_offset], 1200

            call reset_grass

        continue:

            cmp word [fail_state], 1
            je failgame

            cmp word [game_state], 1
            je exit

            cmp word [map_marker], 288
            jne jump_loop

            next_track_state:

                inc word [track_state]
                cmp word [track_state], 3
                je succeedgame

            jump_loop:

                jmp mainloop

    ; -----------------------------------

; =======================================================================

failgame:

    xor ax, ax
    mov es, ax
    
    cli
    mov ax, [oldtime]
    mov word [es:8*4], ax
    mov ax, [oldtime + 2]
    mov word [es:8*4+2], ax
    sti

    call clrscr

    call prnt_fail

    jmp exit

succeedgame:

    xor ax, ax
    mov es, ax

    cli
    mov ax, [oldtime]
    mov word [es:8*4], ax
    mov ax, [oldtime + 2]
    mov word [es:8*4+2], ax
    sti

    call clrscr
    
    shr word [player_time], 4

    call prnt_results

    jmp exit


exit:

mov ax, 0x3100
int 0x21