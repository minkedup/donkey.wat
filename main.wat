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
(global $SPEED_MULT   (mut f32) (f32.const 0.25))
(global $RSEED        (mut i32) (i32.const 22345512))

(global $MAX_DONKEYS  i32 (i32.const 8))
(global $NUM_DONKEYS  (mut i32) (i32.const 0))
(global $DEALLOC_DONKEY    (mut i32) (i32.const 0))

;; rng constants
(global $A-RAND i32 (i32.const 0x43FD43FD))
(global $C-RAND i32 (i32.const 0xC39EC3))
(global $M-RAND i32 (i32.const 16_777_216))

;; swapiness
(global $DRAW_COLORS_CACHE (mut i32) (i32.const 0))

;;=============;;
;; Funky Datas ;;
;;=============;;

;; donkey position data
;; stored as two u8s per donkey (ypos, roadside)
(global $DONKEY_DATA i32 (i32.const 0x19d0))
(data (i32.const 0x19d0) "\00\00\00\00\00\00\00\00")

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

;; TODO: Remove
(data
  (i32.const 0x2100)
  " \00"
)

(func $pv (param $val i32)
  (local $trans i32)

  (local.set $trans (i32.add (local.get $val) (i32.const 48)))

  (i32.store8 (i32.const 0x2100) (local.get $trans))
  (call $trace (i32.const 0x2100))
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

  ;; swapon new DRAW_COLORS value
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

  ;; reset DRAW_COLORS 
  (call $draw-reset)
)

(func $draw-donkey      
  (local $index  i32)
  (local $mpoint i32)
  (local $dx     i32) ;; donkey x-coord (found)
  (local $dy     i32) ;; donkey y-coord (given)
  (local $dr     i32) ;; donkey road    (given)

  ;; swapin custom DRAW_COLORS
  (call $draw-swap (i32.const 0x6))

  (loop $draw
    (block $cont
      (local.set $mpoint (i32.add
                           (i32.mul (local.get $index) (i32.const 2))
                           (global.get $DONKEY_DATA)))

      (local.set $dy (i32.load8_u (local.get $mpoint)))
      (local.set $dr (i32.load8_u (i32.add (local.get $mpoint) (i32.const 1))))

      (i32.or (i32.eqz (local.get $dr)) (i32.eqz (local.get $dy)))
      br_if $cont

      (i32.eq (local.get $dr) (i32.const 1))
      if
        (local.set $dx (i32.const 52))
      else
        (local.set $dx (i32.const 83))
      end

      (call $blit (i32.const 0x2000)
            (local.get $dx) 
            (local.get $dy)
            (i32.const 24)
            (i32.const 20)
            (global.get $BLIT_2BPP))
    )

    (local.set $index (i32.add (local.get $index) (i32.const 1)))
    (i32.lt_u (local.get $index) (global.get $MAX_DONKEYS))
    br_if $draw
  )
  
  ;; reset DRAW_COLORS to defaults
  (call $draw-reset)
)

(func $upd-player)
(func $upd-donkey
  (local $index  i32)
  (local $mpoint i32)
  (local $dony   i32)

  (call $alloc-donkey (call $ran-int (i32.const 0) (i32.const 2)))

  (local.set $index (i32.const 0))
  
  (loop $upd
    (block $cont
      (local.set $mpoint (i32.add
                          (i32.mul (local.get $index) (i32.const 2))
                          (global.get $DONKEY_DATA)))

      (local.tee $dony (i32.load8_u (local.get $mpoint)))
      i32.eqz
      br_if $cont

      (i32.ge_u (local.get $dony) (i32.const 120))
      if
        ;; zero out donkey memory
        (i32.store16 (local.get $mpoint) (i32.const 0x0000))
        ;; NUM_DONKEYS--
        (global.set $NUM_DONKEYS (i32.sub
                                   (global.get $NUM_DONKEYS)
                                   (i32.const 1)))
        ;; set the latest deallocated donkey
        (global.set $DEALLOC_DONKEY (local.get $index))
        ;; skip updating 
        br $cont
      end

      global.get $SPEED_MULT
      f32.const 8.0  ;; Donkey base speed multiplier
      f32.mul
      i32.trunc_f32_u
      local.get $dony
      i32.add
      local.set $dony

      (local.set $dony (i32.add (local.get $dony) (i32.const 10)))
      (i32.store8 (local.get $mpoint) (local.get $dony))
    )
    
    (local.set $index (i32.add (local.get $index) (i32.const 1)))
    (i32.lt_u (local.get $index) (global.get $MAX_DONKEYS))
    br_if $upd
  )
)

(func $alloc-donkey (param $road i32)
  (local $test  i32)
  (local $addr  i32)
  (local $mmem  i32) ;; max memory

  ;; initial search address is first address
  (local.set $addr (global.get $DONKEY_DATA))

  ;; max memory
  (local.set $mmem (i32.add
                     (i32.mul (global.get $MAX_DONKEYS) (i32.const 2))
                     (global.get $DONKEY_DATA)))

  (block $alloc
    ;; num_donkeys >= max_donkeys
    (i32.ge_u (global.get $NUM_DONKEYS) (global.get $MAX_DONKEYS))
    br_if $alloc

    (block $break
      (loop $faddr
        ;; test mem location under DEALLOC_DONKEY
        (i32.eqz (i32.load8_u (local.get $addr)))
        br_if $break

        (local.set $addr (i32.add (local.get $addr) (i32.const 2)))
        (i32.lt_u (local.get $addr) (local.get $mmem))
        br_if $faddr
      )
    )

    ;; create allocation
    (i32.store8 (local.get $addr) (i32.const 0x01))
    (i32.store8 (i32.add (local.get $addr) (i32.const 1)) (local.get $road))

    ;; NUM_DONKEYS++
    (global.set $NUM_DONKEYS (i32.add
                               (global.get $NUM_DONKEYS) 
                               (i32.const 1)))
  )
)

(func $upd-roads)

(func $draw-swap (param $new i32)
  (global.set $DRAW_COLORS_CACHE (i32.load16_u (global.get $DRAW_COLORS)))
  (i32.store16 (global.get $DRAW_COLORS) (local.get $new))
)

(func $draw-reset
  (i32.store16 (global.get $DRAW_COLORS) (global.get $DRAW_COLORS_CACHE))
)

;; lgc rng 
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
  (;
   We run the LGC algorithm random number generator three times.
   The random function only outputs random bits betwen 30 and 16,
   so we call the function three times, packing the random bits
   into a single number to be used for the rest of the function.
  ;)

  ;; s[0] = ran() 
  call $ran
  i32.const 0x3FFF0000
  i32.and

  ;; s[0] << 2
  i32.const 2
  i32.shl

  ;; s[1] = ran()
  call $ran
  i32.const 0x3FFF0000
  i32.and

  ;; s[1] >> 12
  i32.const 12
  i32.shr_u

  ;; s[0] = s[1] or s[0]
  i32.or

  ;; s[1] = ran()
  call $ran
  i32.const 0x3FFF0000
  i32.and

  ;; s[1] >> 26
  i32.const 20
  i32.shr_u

  ;; s[0] = s[1] or s[0]
  i32.or

  ;; s[1] = (high + 1)
  local.get $high
  i32.const 1
  i32.add

  ;; s[1] = (high + 1) - low
  local.get $low
  i32.sub

  ;; s[0] = s[0] % s[1]
  i32.rem_u

  ;; else: s[0] = s[0] + low
  local.get $low
  i32.add
)
