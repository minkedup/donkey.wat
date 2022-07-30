;; declare page of memory
(import "env" "memory" (memory 1))

;;===============;;
;; Env Functions ;;
;;===============;;

(; Sprite-drawing function ;)
(import "env" "blit" (func $blit (param i32 i32 i32 i32 i32 i32)))

(; Basic shape drawing functions ;)
(import "env" "line" (func $line (param i32 i32 i32 i32)))
(import "env" "rect" (func $rect (param i32 i32 i32 i32)))
(import "env" "text" (func $text (param i32 i32 i32)))

(; Persistent disk rw functions ;)
(import "env" "diskr" (func $diskr (param i32 i32)))
(import "env" "diskw" (func $diskw (param i32 i32)))

(; Prints a null-terminated string to the debug console ;)
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
;; Global Constants ;;
;;==================;;

(; Address of to-decstr string ;)
(global $DCADDR i32 (i32.const 0x2100))

(; Max strlen for to-decstr ;)
(global $PVMAXL i32 (i32.const 8))

(; Maximum number of donkeys allowed on screen at a time ;)
(global $MAX_DONKEYS    i32 (i32.const 8))

(; RNG Constants; see LGC Algorithm on Wikipedia ;)
(global $A-RAND   i32 (i32.const 0x43FD43FD))
(global $C-RAND   i32 (i32.const 0xC39EC3))
(global $M-RAND   i32 (i32.const 16_777_216))

;;=================;;
;; Global Counters ;;
;;=================;;

(; Driver & Donkey score counters ;)
(global $DRIVER_SCORE (mut i32) (i32.const 0))
(global $DONKEY_SCORE (mut i32) (i32.const 0))

(; Side of the road the driver is on ;)
(global $DRIVER_ROAD (mut i32) (i32.const 1))

(; Driver Progress - Used to derive Driver ypos ;)
(global $DRIVER_PROG (mut i32) (i32.const 0))

(; Counts number of frames since game start ;)
(global $FCOUNT       (mut i32) (i32.const 0))

(; Global game speed multiplier ;)
(global $SPEED_MULT   (mut f32) (f32.const 1.00))

(; Number of donkeys that currently exist ;)
;; TODO: Replace after test
(global $NUM_DONKEYS    (mut i32) (i32.const 1))

(; Rough position of last-allocated donkey ;)
(global $LDONKEY_LOC    (mut i32) (i32.const 0))

(; Counter for road drawing offset from origin ;)
(global $ROAD_OFFSET    (mut i32) (i32.const 0))

(; Starting random seed; modifiable by ran func ;)
(global $RSEED    (mut i32) (i32.const 22345512))

(; DRAW_COLORS cache; used for swapping temp vals in ;)
(global $DRAW_COLORS_CACHE (mut i32) (i32.const 0))

(; Previous GAMEPAD state ;)
(global $PREV_GAMEPAD (mut i32) (i32.const 0))

;;===========;;
;; Heap Data ;;
;;===========;;

(; Donkey location data:
     Stored as pairs of u8s representing (y-pos, road).
     A pair is considered empty if road == 0x00.
;)
(global $DONKEY_DATA i32 (i32.const 0x19d0))
(data (i32.const 0x19d0) "\00\02\00\00\00\00\00\00")

(; Static Display Strings ;)
(data (i32.const 0x19a0) "Driver\00")
(data (i32.const 0x19a9) "Donkey\00")
(data (i32.const 0x19b0) " X to\nswitch\nlanes\00")

(data (i32.const 0x2100) "        \00")

(; Data for to-decstr; address at DCADDR ;)
(data (i32.const 0x2100) "        \00")

;;=============;;
;; Sprite Data ;;
;;=============;;

;; donkey ( width: 24, height: 20, flags: BLIT_2BPP )
(data
  (i32.const 0x2000)
  "\ff\ff\ff\ff\0f\fc\ff\ff\ff\ff\03\00\ff\ff\ff\ff\c0\03\ff\ff\ff\ff\c0\01\ff\00\00\00\0a\28\fc\00\00\00\00\00\fc\00\00\00\00\00\f0\00\00\00\00\03\f0\00\00\00\03\03\c3\00\00\00\03\c0\1f\00\00\00\0f\f0\ff\0c\3f\c3\0f\ff\ff\0c\3f\c3\0f\ff\ff\0c\3f\c3\0f\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff"
)

;; car ( width: 20, height: 32, flags: BLIT_2BPP )
;; TODO: Fix this car sprite from source
(data
  (i32.const 0x2080)
  "\aa\aa\00\aa\aa\aa\aa\00\aa\aa\aa\a8\00\2a\aa\aa\a8\00\2a\aa\aa\a8\00\2a\aa\aa\a0\00\0a\aa\aa\a0\00\0a\aa\a0\a0\00\0a\0a\a0\80\00\02\0a\a0\80\00\02\0a\a0\80\00\02\0a\a0\a0\00\0a\0a\aa\a0\00\0a\aa\aa\a0\14\0a\aa\aa\a0\55\0a\aa\aa\a0\41\0a\aa\aa\a1\41\4a\aa\aa\a1\00\4a\aa\aa\a1\41\4a\aa\00\a0\55\0a\00\00\a0\00\0a\00\00\a0\00\0a\00\00\a1\55\4a\00\00\81\14\42\00\00\81\14\42\00\00\a1\55\4a\00\00\a1\14\4a\00\00\a1\14\4a\00\aa\a1\55\4a\aa\aa\a0\00\0a\aa\aa\a0\00\0a\aa\aa\a8\00\2a\aa"
)

(func (export "start")
)

(func (export "update")
  (global.set $FCOUNT (i32.add (global.get $FCOUNT) (i32.const 1)))

  ;; handle player input
  (call $pinput)

  ;; run position update logic every ( FRAME % 15 )
  (if (i32.eqz (i32.rem_u (global.get $FCOUNT) (i32.const 15)))
    (then
      (call $update-driver)
      (call $update-donkeys)
      (call $update-roads)
    )
  )

  ;; drawing logic
  (call $draw-static)
  (call $draw-donkey)
  (call $draw-driver)
)

(func $pinput
  (local $gamepad i32)
  (local $pressed i32)

  (local.set $gamepad (i32.load8_u (global.get $GAMEPAD1)))

  (local.set $pressed (i32.and
                        (local.get $gamepad)
                        (i32.xor
                          (local.get $gamepad)
                          (global.get $PREV_GAMEPAD))))

  (global.set $PREV_GAMEPAD (local.get $gamepad))

  ;; process road switching logic when user presses BUTTON_1 (x)
  (i32.and (local.get $pressed) (global.get $BUTTON_1))
  if
    ;; invert last two bits
    global.get $DRIVER_ROAD
    i32.const 0x3
    i32.xor
    global.set $DRIVER_ROAD
  end
)

(func $draw-static
  (local $rspace i32)
  (local $old    i32)

  ;; overdraw above to account for movement
  (local.set $rspace (i32.const -20))

  ;; draw static intructions and scoreboard headers
  (call $text (i32.const 0x19b0) (i32.const 111) (i32.const 120))
  (call $text (i32.const 0x19a0) (i32.const 001) (i32.const 018))
  (call $text (i32.const 0x19a9) (i32.const 111) (i32.const 018))

  ;; convert to string, then draw DRIVER_SCORE
  (call $to-decstr (global.get $DRIVER_SCORE) (i32.const 2))
  (call $text (global.get $DCADDR) (i32.const 012) (i32.const 032))

  ;; convert to string, then draw DONKEY_SCORE
  (call $to-decstr (global.get $DONKEY_SCORE) (i32.const 2))
  (call $text (global.get $DCADDR) (i32.const 123) (i32.const 032))

  ;; draw the road in the center of the screen
  (call $rect (i32.const 50) (i32.const 0) (i32.const 60) (i32.const 160))

  ;; swapon new DRAW_COLORS value
  (call $draw-swap (i32.const 0x2))

  (loop $stripes
    ;; rect(x=79, y=((rspace + 2) + offset), w=6, h=16)
    (call $rect (i32.const 79)
                (i32.add
                  (i32.add (local.get $rspace) (i32.const 2))
                  (global.get $ROAD_OFFSET))
                (i32.const 3)
                (i32.const 16))

    ;; rspace += 20
    (local.set $rspace (i32.add (local.get $rspace) (i32.const 20)))

    ;; while( rspace < 180 )
    ;; [we overdraw below to account for movement]
    (i32.lt_s (local.get $rspace) (i32.const 180))
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
  (local $chunk  i32) ;; fooooobarrrrr

  ;; swapin custom DRAW_COLORS
  (call $draw-swap (i32.const 0x6))

  (loop $draw
    (block $cont
      (local.set $mpoint (i32.add
                           (i32.mul (local.get $index) (i32.const 2))
                           (global.get $DONKEY_DATA)))


      (local.set $chunk (i32.load16_u (local.get $mpoint)))

      (call $to-decstr (local.get $chunk) (i32.const 2))
      (call $trace (global.get $DCADDR))

      (local.set $dy (i32.and (local.get $chunk) (i32.const 0x00FF)))
      (local.set $dr (i32.and (local.get $chunk) (i32.const 0xFF00)))

      (local.set $dy (i32.load8_u (local.get $mpoint)))
      (local.set $dr (i32.load8_u (i32.add (local.get $mpoint) (i32.const 1))))

      (i32.eqz (local.get $dr))
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

    ;; TODO: Remove skip
    (call $draw_reset)
    return

    (local.set $index (i32.add (local.get $index) (i32.const 1)))
    (i32.lt_u (local.get $index) (global.get $MAX_DONKEYS))
    br_if $draw
  )

  ;; reset DRAW_COLORS to defaults
  (call $draw-reset)
)

(func $draw-driver
  (local $dx i32)
  (local $dy i32)

  ;; dy = 120 + ( DRIVER_PROG * 8 )
  (local.set $dy (i32.sub
                   (i32.const 120)
                   (i32.mul (global.get $DRIVER_PROG) (i32.const 8))))

  ;; if( DRIVER_ROAD == 1 ) : dx = 54
  ;; else : dx = 86
  (i32.eq (global.get $DRIVER_ROAD) (i32.const 1))
  if
    (local.set $dx (i32.const 54))
  else
    (local.set $dx (i32.const 86))
  end

  ;; swapon custom DRAW_COLORS
  (call $draw-swap (i32.const 6))

  (call $blit (i32.const 0x2080)
        (local.get $dx)
        (local.get $dy)
        (i32.const 20)
        (i32.const 32)
        (global.get $BLIT_2BPP))

  ;; reset DRAW_COLORS
  (call $draw-reset)
)

(func $update-driver
  ;; DRIVER_PROG = DRIVER_PROG % 12
  (global.set $DRIVER_PROG (i32.rem_u
                             (global.get $DRIVER_PROG)
                             (i32.const 12)))
)

(func $update-donkeys
  (local $index  i32)
  (local $mpoint i32)
  (local $dony   i32)
  (local $donr   i32)
  (local $drivy  i32)

  ;;(call $alloc-donkey (call $ran-int (i32.const 1) (i32.const 2)))

  ;; drivy = 120 + ( DRIVER_PROG * 8 )
  (local.set $drivy (i32.sub
                   (i32.const 120)
                   (i32.mul (global.get $DRIVER_PROG) (i32.const 8))))

  (local.set $index (i32.const 0))

  (block $break
    (loop $upd
      (block $cont
        (local.set $mpoint (i32.add
                            (i32.mul (local.get $index) (i32.const 2))
                            (global.get $DONKEY_DATA)))

        (local.set $dony (i32.load8_u (local.get $mpoint)))
        (local.set $donr (i32.load8_u (i32.add
                                        (local.get $mpoint)
                                        (i32.const 1))))

        ;; check that this memory location is a donkey and not empty
        (i32.and (i32.eqz (local.get $donr)) (i32.eqz (local.get $donr)))
        br_if $cont

        ;; update donkey y value
        global.get $SPEED_MULT
        f32.const 8.00
        f32.mul
        i32.trunc_f32_u

        local.get $dony
        i32.add
        local.set $dony

        ;; remove donkey if off-screen and update scores
        (i32.ge_u (local.get $dony) (i32.const 150))
        if
          ;;; increase the speed multiplier
          (global.set $SPEED_MULT (f32.add
                                    (global.get $SPEED_MULT)
                                    (f32.const 0.05)))

          ;; increase the driver score
          (global.set $DRIVER_SCORE (i32.add
                                      (global.get $DRIVER_SCORE)
                                      (i32.const 1)))

          ;; increase driver progress
          (global.set $DRIVER_PROG (i32.add (global.get $DRIVER_PROG) (i32.const 1)))

          ;; zero out donkey memory
          (i32.store16 (local.get $mpoint) (i32.const 0x0000))
          ;; NUM_DONKEYS--
          (global.set $NUM_DONKEYS (i32.sub
                                     (global.get $NUM_DONKEYS)
                                     (i32.const 1)))
          ;; skip updating
          br $cont
        end

        (block $collision
          ;; if ( donkey_road != driver_road ) : continue
          (i32.ne (local.get $donr) (global.get $DRIVER_ROAD))
          br_if $collision

          ;; ! ( (donkey_y + (donkey_size / 2))  >= driver_y ) && ( donkey_y <= (driver_y + driver_size) )
          (i32.and
            (i32.ge_u (i32.add (local.get $dony) (i32.const 10)) (local.get $drivy))
            (i32.le_u (local.get $dony) (i32.add (local.get $drivy) (i32.const 32)))
          )
          i32.const 1
          i32.xor
          br_if $collision

          (global.set $DONKEY_SCORE (i32.add (global.get $DONKEY_SCORE) (i32.const 1)))

          (call $reset-game)

          br $break
        )

        ;; store updated donkey y back into donkey
        (i32.store8 (local.get $mpoint) (local.get $dony))
      )

      (local.set $index (i32.add (local.get $index) (i32.const 1)))
      (i32.lt_u (local.get $index) (global.get $MAX_DONKEYS))
      br_if $upd
    )
  )
)

(func $reset-game
  ;; reset everything
  (global.set $NUM_DONKEYS   (i32.const 0))
  (global.set $DRIVER_PROG   (i32.const 0))
  (global.set $SPEED_MULT    (f32.const 1.0))

  (i32.store (global.get $DONKEY_DATA) (i32.const 0))
)

(func $alloc-donkey (param $road i32)
  (local $addr  i32) ;; search pointer
  (local $mmem  i32) ;; max memory

  ;; if ( NUM_DONKEYS > MAX_DONKEYS ) : return
  (i32.gt_u (global.get $NUM_DONKEYS) (global.get $MAX_DONKEYS))
  if
    return
  end

  ;; delta = ( SPEED_MULT * 10.00 )
  global.get $SPEED_MULT
  f32.const 10.0
  f32.mul
  i32.trunc_f32_u

  ;; LDONKEY_LOC += delta
  global.get $LDONKEY_LOC
  i32.add
  global.set $LDONKEY_LOC

  ;; if( LDONKEY_LOC < 14 ) : return
  ;; else : LDONKEY_LOC = 0
  (i32.le_u (global.get $LDONKEY_LOC) (i32.const 77))
  if
    return
  else
    i32.const 0
    global.set $LDONKEY_LOC
  end

  ;; search ptr starts at first addr
  (local.set $addr (global.get $DONKEY_DATA))

  ;; max memory
  (local.set $mmem (i32.add
                     (i32.mul (global.get $MAX_DONKEYS) (i32.const 2))
                     (global.get $DONKEY_DATA)))

  (block $break
    (loop $faddr
      ;; alloc at first chunk with zeroed road
      (i32.eqz (i32.load8_u (i32.add
                              (local.get $addr)
                              (i32.const 1))))
      br_if $break

      ;; while( addr < max-mem ) : addr += 2
      (local.set $addr (i32.add (local.get $addr) (i32.const 2)))
      (i32.lt_u (local.get $addr) (local.get $mmem))
      br_if $faddr
    )
  )

  ;; starting donkey-y = 0x00
  (i32.store8 (local.get $addr) (i32.const 0x00))
  ;; starting donkey-r = 0x01
  (i32.store8 (i32.add (local.get $addr) (i32.const 1)) (local.get $road))

  ;; NUM_DONKEYS++
  (global.set $NUM_DONKEYS (i32.add
                             (global.get $NUM_DONKEYS)
                             (i32.const 1)))
)

(func $update-roads
  ;; s[0] = ROAD_OFFSET
  global.get $ROAD_OFFSET

  ;; s[1] = ( SPEED_MULT * 1.25 )
  global.get $SPEED_MULT
  f32.const 5.25
  f32.mul
  i32.trunc_f32_u

  ;; s[0] = ROAD_OFFSET + ( SPEED_MULT * 1.25 )
  i32.add

  ;; ROAD_OFFSET = s[0] % 18
  i32.const 18
  i32.rem_u
  global.set $ROAD_OFFSET
)

;; swap current value off DRAW_COLORS and onto DRAW_COLORS_CACHE
(func $draw-swap (param $new i32)
  ;; prevent double swap by making sure DRAW_COLORS_CACHE is uninit (0x0000)
  (if (i32.ne (global.get $DRAW_COLORS_CACHE) (i32.const 0x0000)) (then return))
  (global.set $DRAW_COLORS_CACHE (i32.load16_u (global.get $DRAW_COLORS)))
  (i32.store16 (global.get $DRAW_COLORS) (local.get $new))
)

;; swap value in DRAW_COLORS_CACHE back into DRAW_COLORS
(func $draw-reset
  (i32.store16 (global.get $DRAW_COLORS) (global.get $DRAW_COLORS_CACHE))
  ;; re-uninit DRAW_COLORS_CACHE for future writes
  (global.set $DRAW_COLORS_CACHE (i32.const 0x0000))
)

(func $to-decstr (param $val i32) (param $strlen i32)
  (local $index      i32)
  (local $digit_char i32)
  (local $digit_val  i32)

  (i32.gt_u (local.get $strlen) (global.get $PVMAXL))
  if
    (local.set $strlen (global.get $PVMAXL))
  end

  local.get $strlen
  local.set $index

  (i32.eqz (local.get $val))
  if
    local.get $index
    i32.const 1
    i32.sub
    local.set $index

    (i32.store8 (i32.add (local.get $index) (global.get $DCADDR)) (i32.const 48))
  end

  (loop $digit_loop (block $break
    (i32.eqz (local.get $index))
    br_if $break

    local.get $val
    i32.const 10
    i32.rem_u

    local.set $digit_val

    (i32.eqz (local.get $val))
    if
      i32.const 32
      local.set $digit_char
    else
      local.get $digit_val
      i32.const 48
      i32.add

      local.set $digit_char
    end

    local.get $index
    i32.const 1
    i32.sub
    local.set $index
    ;; store
    (i32.store8
      (i32.add (global.get $DCADDR) (local.get $index)) (local.get $digit_char))

    local.get $val
    i32.const 10
    i32.div_u
    local.set $val
    br $digit_loop
  ))
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

  ;; set RSEED and return it
  global.set $RSEED
  global.get $RSEED
)

(func $ran-int (param $low i32) (param $high i32) (result i32)
  (;
   We run the LGC algorithm random number generator three times.
   The random function only outputs random bits betwen; 30 and 16,
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
  ;; s[0] = s[1] or s[0];
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
