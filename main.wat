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
(global $frame-count (mut i32) (i32.const 0))
(global $rseed (mut i32) (i32.const 123456789))

;; rng constants
(global $arand i32 (i32.const 214013))
(global $crand i32 (i32.const 2531011))
(global $mrand i32 (i32.const 2_147_483_648))


;;===============;;
;; Funky Sprites ;;
;;===============;;

(data (i32.const 0x19a0) "\c3\81\24\24\00\24\99\c3")
(data (i32.const 0x19b0) "I LOVE ONE PIECE\00")

(func (export "start")
)

(func (export "update")
  (global.set $frame-count (i32.add (global.get $frame-count) (i32.const 1)))

  ;; gated update logic 
  (if (i32.eqz (i32.rem_u (global.get $frame-count) (i32.const 15)))
    (then
      (call $upd-player)
      (call $upd-donkey)
    )
  )

  ;; drawing logic
  (call $draw-backg)
)

(func $draw-backg
  (local $offset i32)
  (local $pal2 i32)

  (local.set $offset (i32.const 2))

  (local.set $pal2 (i32.load (global.get $PALETTE2)))
  (i32.store (global.get $PALETTE2) (i32.const 0x2))
  
  (loop $stripes
    ;; offset += 18
    (local.set $offset (i32.add (local.get $offset) (i32.const 18)))

    ;; rect(x: 77, y: offset, w: 6, h: 16)
    (call $rect (i32.const 77) (local.get $offset) (i32.const 6) (i32.const 16))

    ;; while(offset < 160 [SCREEN HEIGHT])
    (i32.lt_u (local.get $offset) (i32.const 160))
    br_if $stripes
  )

  (i32.store (global.get $PALETTE2) (local.get $pal2))

  (call $rect (i32.const 50) (i32.const 0) (i32.const 60) (i32.const 160))
)

(func $upd-player)
(func $upd-donkey)

;; lgc algorithm random number generator
(func $ran (result i32)
  ;; a * seed
  global.get $rseed
  global.get $arand
  i32.mul

  ;; (a * seed) + c
  global.get $crand
  i32.add

  ;; (a * seed + c) % m
  global.get $mrand
  i32.rem_u

  global.set $rseed
  global.get $rseed
)

