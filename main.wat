(import "env" "memory" (memory 1))

;;===================;;
;; Drawing Functions ;;
;;===================;;

(; Copies pixels to the framebuffer. ;)
(import "env" "blit" (func $blit (param i32 i32 i32 i32 i32 i32)))

(; Copies a subregion within a larger sprite atlas to the framebuffer. ;)
(import "env" "blitSub" (func $blitSub (param i32 i32 i32 i32 i32 i32 i32 i32 i32)))

(; Draws a line between two points. ;)
(import "env" "line" (func $line (param i32 i32 i32 i32)))

(; Draws a horizontal line. ;)
(import "env" "hline" (func $hline (param i32 i32 i32)))

(; Draws a vertical line. ;)
(import "env" "vline" (func $vline (param i32 i32 i32)))

(; Draws a rectangle. ;)
(import "env" "rect" (func $rect (param i32 i32 i32 i32)))

(; Draws text using the built-in system font. ;)
(import "env" "text" (func $text (param i32 i32 i32)))

;;===================;;
;; Storage Functions ;;
;;===================;;

(; Reads up to `size` bytes from persistent storage into the pointer `dest`. ;)
(import "env" "diskr" (func $diskr (param i32 i32)))

(; Writes up to `size` bytes from the pointer `src` into persistent storage. ;)
(import "env" "diskw" (func $diskw (param i32 i32)))

(; Prints a message to the debug console. ;)
(import "env" "trace" (func $trace (param i32)))

;;==================;;
;; Memory Addresses ;;
;;==================;;

(global $PALETTE0 i32 (i32.const 0x04))
(global $PALETTE1 i32 (i32.const 0x08))
(global $PALETTE2 i32 (i32.const 0x0c))
(global $PALETTE3 i32 (i32.const 0x10))
(global $DRAW_COLORS i32 (i32.const 0x14))
(global $GAMEPAD1 i32 (i32.const 0x16))
(global $SYSTEM_FLAGS i32 (i32.const 0x1f))
(global $FRAMEBUFFER i32 (i32.const 0xa0))

(global $BUTTON_1 i32 (i32.const 1))
(global $BUTTON_2 i32 (i32.const 2))
(global $BUTTON_LEFT i32 (i32.const 16))
(global $BUTTON_RIGHT i32 (i32.const 32))
(global $BUTTON_UP i32 (i32.const 64))
(global $BUTTON_DOWN i32 (i32.const 128))

(global $SYSTEM_PRESERVE_FRAMEBUFFER i32 (i32.const 1))
(global $SYSTEM_HIDE_GAMEPAD_OVERLAY i32 (i32.const 2))

(global $BLIT_2BPP i32 (i32.const 1))
(global $BLIT_1BPP i32 (i32.const 0))
(global $BLIT_FLIP_X i32 (i32.const 2))
(global $BLIT_FLIP_Y i32 (i32.const 4))
(global $BLIT_ROTATE i32 (i32.const 8))

;;==================;;
;; Global Variables ;;
;;==================;;
(global $FCOUNT       (mut i32) (i32.const 0))
(global $SMULT        (mut i32) (i32.const 1))
(global $RSEED        (mut i32) (i32.const 123456789))

(global $MAX-DONKEYS  i32 (i32.const 8))
(global $N-DONKEYS    (mut i32) (i32.const 0))
(global $DE-DONKEY    (mut i32) (i32.const 0))

;; rng constants
(global $A-RAND i32 (i32.const 214013))
(global $C-RAND i32 (i32.const 2531011))
(global $M-RAND i32 (i32.const 2_147_483_648))

;; swapiness
(global $DRAW_COLORS_CACHE (mut i32) (i32.const 0))

;;=============;;
;; Funky Datas ;;
;;=============;;

;; donkey position data
;; stored as two u8s per donkey (ypos, roadside)
;; the list of donkeys is null-terminated
(global $DONKEY_DATA i32 (i32.const 0x19d0))
(data (i32.const 0x19d0) "\02\01")

;; static display strings
(data (i32.const 0x19a0) "Driver\00")
(data (i32.const 0x19a9) "Donkey\00")
(data (i32.const 0x19b0) "Space\nto\nswitch\nlanes\00")


;; funky sprites
;; donkey
;; donkey_width: u32 = 24;
;; donkey_height: u32 = 20;
;; donkey_flags: u32 = 1; // BLIT_2BPP
(data
  (i32.const 0x2000)
  "\ff\ff\ff\ff\0f\fc\ff\ff\ff\ff\03\00\ff\ff\ff\ff\c0\03\ff\ff\ff\ff\c0\01\ff\00\00\00\0a\28\fc\00\00\00\00\00\fc\00\00\00\00\00\f0\00\00\00\00\03\f0\00\00\00\03\03\c3\00\00\00\03\c0\1f\00\00\00\0f\f0\ff\0c\3f\c3\0f\ff\ff\0c\3f\c3\0f\ff\ff\0c\3f\c3\0f\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff"
)


(func (export "start")
)

(func (export "update")
  (global.set $FCOUNT (i32.add (global.get $FCOUNT) (i32.const 1)))

  ;; gated update logic 
  (if (i32.eqz (i32.rem_u (global.get $FCOUNT) (i32.const 15)))
    (then
      (call $upd-player)
      (call $upd-donkey)
      (call $upd-roads)
    )
  )

  ;; drawing logic
  (call $draw-backg)
  (call $draw-donkey)
)

(func $draw-backg
  (local $rspace i32)
  (local $old i32)

  (local.set $rspace (i32.const 0))

  ;; draw static intructions and scoreboard headers
  (call $text (i32.const 0x19b0) (i32.const 111) (i32.const 120))
  (call $text (i32.const 0x19a0) (i32.const 001) (i32.const 015))
  (call $text (i32.const 0x19a9) (i32.const 111) (i32.const 015))

  ;; draw road in the center
  (call $rect (i32.const 50) (i32.const 0) (i32.const 60) (i32.const 160))

  (call $draw-swap (i32.const 0x2))
  
  (loop $stripes
    ;; rect(x: 77, y: rspace + 2, w: 6, h: 16)
    (call $rect (i32.const 79)
                (i32.add (local.get $rspace) (i32.const 2))
                (i32.const 3)
                (i32.const 16))

    ;; rspace += 18
    (local.set $rspace (i32.add (local.get $rspace) (i32.const 20)))

    ;; while(rspace < 160 [SCREEN HEIGHT])
    (i32.lt_u (local.get $rspace) (i32.const 160))
    br_if $stripes
  )
  
  (call $draw-reset)
)

(func $draw-donkey      
  (local $donkey-y i32)
  (local $donkey-r i32)
  (local $donkey-x i32)
  (local $mem      i32)
  (local $max-mem  i32)

  (call $draw-swap (i32.const 0x6))

  ;; memp = start
  (local.set $mem (global.get $DONKEY_DATA))
  ;; max = start + (n-donkeys * 2)
  (local.set $max-mem (i32.add
                        (global.get $DONKEY_DATA)
                        (i32.mul (global.get $MAX-DONKEYS) (i32.const 2))))

  (loop $ddraw
    ;; get the upper 8 bits of the memory location
    (local.set $donkey-y (i32.load8_u (local.get $mem)))

    ;; get next 8 bits of memory by adding offset of 1 to pointer 
    (local.set $donkey-r (i32.load8_u (i32.add
                                      (local.get $mem) 
                                      (i32.const 1))))

    ;; (donkey-y == 0 || donkey-r == 0)
    ;; then restore colors and exit
    (i32.eq (local.get $donkey-y) (i32.const 0))
    (i32.eq (local.get $donkey-r) (i32.const 0))
    i32.or
    if
      (call $draw-reset)
      return
    end

    ;; donkey-r == 1 && x = 52
    ;; donkey-r == 2 && x = 84
    (i32.eq (local.get $donkey-r) (i32.const 1))
    if
      (local.set $donkey-x (i32.const 52))
    else
      (local.set $donkey-x (i32.const 84))
    end

    ;; we do a little drawing
    (call $blit (i32.const 0x2000)
          (local.get $donkey-x) 
          (local.get $donkey-y)
          (i32.const 24)
          (i32.const 20)
          (global.get $BLIT_2BPP))


    (local.tee $mem (i32.add (local.get $mem) (i32.const 2)))
    local.get $max-mem
    i32.lt_u
    br_if $ddraw
  )
)

(func $upd-player)
(func $upd-donkey
  (local $donkey-y i32)
  (local $mpoint   i32)
  (local $i        i32)

  (local.set $mpoint (global.get $DONKEY_DATA))
  (local.set $i      (i32.const 0))

  (loop $ddraw
    ;; get the upper 8 bits of the memory location
    (local.set $donkey-y (i32.load8_u (local.get $mpoint)))

    ;; update donkey-y value
    (local.set $donkey-y (i32.add
                           (local.get $donkey-y) 
                           (i32.mul (global.get $SMULT) (i32.const 8))))

    ;; de-allocate donkey
    (i32.ge_u (local.get $donkey-y) (i32.const 146))
    if
      ;; store zeroes in memory to prevent drawing
      (i32.store8 (local.get $mpoint) (i32.const 0))
      (i32.store8
        (i32.add (local.get $mpoint) (i32.const 1))
        (i32.const 0))
      ;; store last de-allocated donkey spot
      (global.set $DE-DONKEY (local.get $i))
    end

    ;; store updated donkey-y value back into the donkey
    (i32.store8 (local.get $mpoint) (local.get $donkey-y))

    ;; (donkey-y == 0 || donkey-r == 0) && return
    (i32.eq (local.get $donkey-y) (i32.const 0))
    if
      return
    end

    ;; advance memory pointer by 2 bytes
    (local.set $mpoint (i32.add
                         (i32.mul (local.get $i) (i32.const 2))
                         (global.get $DONKEY_DATA)))

    ;; i++ && load i onto the stack (s[0])
    (local.tee $i (i32.add (local.get $i) (i32.const 1)))
    global.get $N-DONKEYS
    i32.lt_u

    ;; while( i < N-DONKEYS)
    br_if $ddraw
  )
)
(func $upd-roads)

(func $draw-swap (param $new i32)
  (global.set $DRAW_COLORS_CACHE (i32.load (global.get $DRAW_COLORS)))
  (i32.store16 (global.get $DRAW_COLORS) (local.get $new))
)

(func $draw-reset
  (i32.store16 (global.get $DRAW_COLORS) (global.get $DRAW_COLORS_CACHE))
)

;; lgc algorithm random number generator
(func $ran (result i32)
  ;; a * seed
  global.get $RSEED
  global.get $A-RAND
  i32.mul

  ;; (a * seed) + c
  global.get $C-RAND
  i32.add

  ;; (a * seed + c) % m
  global.get $M-RAND
  i32.rem_u

  global.set $RSEED
  global.get $RSEED
)

(func $ran-int (param $low i32) (param $high i32) (result i32)
  (local $a i32)
  (local $r i32)

  ;; a = high - low
  local.get $high
  local.get $low
  i32.sub
  local.set $a

  ;; s[0] = random 
  call $ran

  ;; r = ran % a
  local.get $a
  i32.rem_u
  local.set $r

  (block $lz
    ;; if: low == 0; return
    local.get $low
    i32.eqz
    br_if $lz

    ;; else: r = r + low
    local.get $low
    local.get $r
    i32.add
    local.set $r
  )

  local.get $r
)
