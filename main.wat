;; declare page of memory
(import "env" "memory" (memory 1))

;;===============;;
;; Env Functions ;;
;;===============;;

(; Sprite-drawing function ;)
(import "env" "blit" (func $blit (param i32 i32 i32 i32 i32 i32)))
(import "env" "blitSub" (func $blitsub (param i32 i32 i32 i32 i32 i32 i32 i32 i32)))

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

(; Address of character sprite ;)
(global $CHAR_DATA     i32 (i32.const 0x2000))

(; Max string length for cstr ;)
(global $CSTR_MAXLEN   i32 (i32.const 7))

(; Address of cstr function output ;)
(global $CSTR_ADDR     i32 (i32.const 0x2100))

(; Maximum number of donkeys allowed on screen at a time ;)
(global $MAX_DONKEYS   i32 (i32.const 8))

(; Last memory location of the DONKEY_DATA; set at start ;)
(global $DDATA_MAXMEM (mut i32) (i32.const 0))

(; glibc RNG constants; see LGC Algorithm on Wikipedia ;)
(global $M-RAND   i32 (i32.const   2_147_483_648)) ;; 2^31
(global $A-RAND   i32 (i32.const   1103515245))
(global $C-RAND   i32 (i32.const   12345))

;;=================;;
;; Global Counters ;;
;;=================;;

(; Driver & Donkey score counters ;)
(global $DRIVER_SCORE  (mut i32) (i32.const 0))
(global $DONKEY_SCORE  (mut i32) (i32.const 0))

(; Side of the road the driver is on ;)
(global $DRIVER_ROAD   (mut i32) (i32.const 1))

(; Driver Progress - Used to derive Driver ypos ;)
(global $DRIVER_PROG   (mut i32) (i32.const 0))

(; Counts number of frames since game start ;)
(global $FCOUNT        (mut i32) (i32.const 0))

(; Global game speed multiplier ;)
(global $SPEED_MULT    (mut f32) (f32.const 1.00))

(; Number of donkeys that currently exist ;)
(global $NUM_DONKEYS   (mut i32) (i32.const 0))

(; A counter since the last donkey was allocated ;)
(global $LAST_ALLOCED  (mut i32) (i32.const 0))

(; Counter for road drawing offset from origin ;)
(global $ROAD_OFFSET   (mut i32) (i32.const 0))

(; Starting random seed; modified by ran function ;)
(global $RSEED         (mut i32) (i32.const 123456789))

(; DRAW_COLORS cache; used for swapping temp vals in ;)
(global $DRAW_CACHE    (mut i32) (i32.const 0))

(; Previous GAMEPAD state ;)
(global $PREV_GAMEPAD  (mut i32) (i32.const 0))

;;===========;;
;; Heap Data ;;
;;===========;;

(; Donkey location data:
     Stored as pairs of u8s representing (y-pos, road).
     A pair is considered empty if road == 0x00.
;)
(global $DONKEY_DATA i32 (i32.const 0x1ae2))
(data (i32.const 0x19da) "\00\00\00\00\00\00\00\00")

(; Static Display Strings ;)
(data (i32.const 0x19a0) "Driver\00")
(data (i32.const 0x19a7) "Donkey\00")
(data (i32.const 0x19ae) "X\24to\25switch\25lanes\00")

(; Data for cstr conversion function ;)
(data (i32.const 0x2100) "\00\00\00\00\00\00\00\00\00")

;;=============;;
;; Sprite Data ;;
;;=============;;

;; donkey ( width: 24, height: 20, flags: BLIT_2BPP )
(data
  (i32.const 0x19ca)
  "\ff\ff\ff\ff\0f\fc\ff\ff\ff\ff\03\00\ff\ff\ff\ff\c0\03\ff\ff\ff\ff\c0\01\ff\00\00\00\0a\28\fc\00\00\00\00\00\fc\00\00\00\00\00\f0\00\00\00\00\03\f0\00\00\00\03\03\c3\00\00\00\03\c0\1f\00\00\00\0f\f0\ff\0c\3f\c3\0f\ff\ff\0c\3f\c3\0f\ff\ff\0c\3f\c3\0f\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff\ff"
)

;; car ( width: 20, height: 32, flags: BLIT_2BPP )
(data
  (i32.const 0x1a42)
  "\aa\aa\00\aa\aa\aa\aa\00\aa\aa\aa\a8\00\2a\aa\aa\a8\00\2a\aa\aa\a8\00\2a\aa\aa\a0\00\0a\aa\aa\a0\00\0a\aa\a0\a0\00\0a\0a\a0\80\00\02\0a\a0\80\00\02\0a\a0\80\00\02\0a\a0\a0\00\0a\0a\aa\a0\00\0a\aa\aa\a0\14\0a\aa\aa\a0\55\0a\aa\aa\a0\41\0a\aa\aa\a1\41\4a\aa\aa\a1\00\4a\aa\aa\a1\41\4a\aa\00\a0\55\0a\00\00\a0\00\0a\00\00\a0\00\0a\00\00\a1\55\4a\00\00\81\14\42\00\00\81\14\42\00\00\a1\55\4a\00\00\a1\14\4a\00\00\a1\14\4a\00\aa\a1\55\4a\aa\aa\a0\00\0a\aa\aa\a0\00\0a\aa\aa\a8\00\2a\aa"
)

;; charset ( width: 216, height: 6, flags: BLIT_1BPP )
(data
  (i32.const 0x2000)
  "\7b\e7\be\ff\f7\a3\78\fc\f0\8e\37\be\7b\e7\bf\8e\38\e3\cf\f7\8c\7b\e7\be\7b\f7\9e\9f\3c\e7\c3\0c\e3\30\6d\b0\df\3c\f3\c7\3c\0c\8e\38\d6\cc\7c\dc\9c\7d\b0\c0\39\e7\9f\ec\27\fb\0c\3f\30\6f\30\ff\bc\f3\c7\37\8c\8e\3a\cc\78\ec\cc\1d\e9\be\f8\67\a7\ff\3c\27\c3\ed\e3\33\6f\30\ae\fc\fe\d7\e1\cc\8e\3f\dc\31\cc\cc\78\79\87\cc\c9\df\9f\3c\e7\c3\0c\e3\33\6d\b0\8e\7c\f0\cb\49\cc\9d\6d\f2\33\8c\cc\e0\7f\e7\cd\c9\c7\9f\e7\be\ff\07\e3\79\cc\ff\8e\37\b0\77\37\8c\78\c8\e1\33\f7\9e\ff\e1\9e\79\c7\9e"
)


(func (export "start")
  (global.set $DDATA_MAXMEM (i32.add
                             (global.get $DONKEY_DATA)
                             (i32.mul (global.get $MAX_DONKEYS) (i32.const 2))))
)

(func (export "update")
  (global.set $FCOUNT (i32.add (global.get $FCOUNT) (i32.const 1)))

  ;; handle player input
  (call $handle-input)

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

(func $handle-input
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

  ;; set DRAW_COLORS for text
  (call $draw-swap (i32.const 0x3e))

  ;; draw static intructions and scoreboard headers
  (call $ctext (i32.const 0x19ae) (i32.const 111) (i32.const 120)) ;; switch
  (call $ctext (i32.const 0x19a0) (i32.const 003) (i32.const 038)) ;; driver
  (call $ctext (i32.const 0x19a7) (i32.const 114) (i32.const 038)) ;; donkey

  ;; convert to string, then draw DRIVER_SCORE
  (call $cstr (global.get $DRIVER_SCORE) (i32.const 2))
  (call $ctext (global.get $CSTR_ADDR) (i32.const 016) (i32.const 050))

  ;; convert to string, then draw DONKEY_SCORE
  (call $cstr (global.get $DONKEY_SCORE) (i32.const 2))
  (call $ctext (global.get $CSTR_ADDR) (i32.const 128) (i32.const 050))

  ;; reset DRAW_COLORS for road
  (call $draw-reset)

  ;; draw the road in the center of the screen
  (call $rect (i32.const 50) (i32.const 0) (i32.const 60) (i32.const 160))

  ;; swapon new DRAW_COLORS value for roads+stripes
  (call $draw-swap (i32.const 0x2))

  ;; draw 'yellow' lines on sides of the road
  (call $line (i32.const 052) (i32.const 0) (i32.const 052) (i32.const 160))
  (call $line (i32.const 107) (i32.const 0) (i32.const 107) (i32.const 160))

  (loop $stripes
    ;; rect(x=79, y=((rspace + 2) + offset), w=6, h=16)
    (call $rect (i32.const 79)
                (i32.add
                  (i32.add (local.get $rspace) (i32.const 2))
                  (global.get $ROAD_OFFSET))
                (i32.const 2)
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
  (local $mpoint i32)
  (local $dx     i32) ;; donkey x-coord (found)
  (local $dy     i32) ;; donkey y-coord (given)
  (local $dr     i32) ;; donkey road    (given)
  (local $chunk  i32) ;; donkey tuple   (given)

  ;; swapin custom DRAW_COLORS
  (call $draw-swap (i32.const 0x6))

  ;; set start of pointer at start of data
  (local.set $mpoint (global.get $DONKEY_DATA))

  (loop $draw
    (block $cont
      ;; do one read of current chunk
      (local.set $chunk (i32.load16_u (local.get $mpoint)))

      ;; extract first and last 8 bit values
      (local.set $dy (i32.and (local.get $chunk) (i32.const 0x00FF)))
      (local.set $dr (i32.shr_u
                      (i32.and (local.get $chunk) (i32.const 0xFF00))
                      (i32.const 8)))

      ;; skip uninitialized chunk
      (i32.eqz (local.get $dr))
      br_if $cont

      ;; set dx dependent on road side
      (i32.eq (local.get $dr) (i32.const 1))
      if
        (local.set $dx (i32.const 54))
      else
        (local.set $dx (i32.const 82))
      end

      (call $blit (i32.const 0x19ca)
            (local.get $dx)
            (local.get $dy)
            (i32.const 24)
            (i32.const 20)
            (global.get $BLIT_2BPP))
    )

    ;; while( mpoint < MAX_MEM )
    (local.set $mpoint (i32.add (local.get $mpoint) (i32.const 2)))
    (i32.lt_u (local.get $mpoint) (global.get $DDATA_MAXMEM))
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

  (call $blit (i32.const 0x1a42)
        (local.get $dx)
        (local.get $dy)
        (i32.const 20)
        (i32.const 32)
        (global.get $BLIT_2BPP))

  ;; reset DRAW_COLORS
  (call $draw-reset)
)

(func $update-driver
  ;; put !( DRIVER_PROG == 0 ) on the stack
  (i32.xor (i32.const 1) (i32.eqz (global.get $DRIVER_PROG)))

  ;; DRIVER_PROG = DRIVER_PROG % 12
  (global.set $DRIVER_PROG (i32.rem_u
                             (global.get $DRIVER_PROG)
                             (i32.const 12)))

  ;; put ( DRIVER_PROG == 0 ) on the stack
  (i32.eqz (global.get $DRIVER_PROG))

  ;; if ( OLD_DRIVER_PROG != 0 ) && ( NEW_DRIVER_PROG == 0 ) : zero-ddata
  i32.and
  if
    (call $zero-ddata)
  end
)

(func $update-donkeys
  (local $mpoint i32)
  (local $dony   i32)
  (local $donr   i32)
  (local $drivy  i32)

  ;; attempt to allocate a new donkey with random generated value
  (call $alloc-donkey)

  ;; drivy = 120 + ( DRIVER_PROG * 8 )
  (local.set $drivy (i32.sub
                   (i32.const 120)
                   (i32.mul (global.get $DRIVER_PROG) (i32.const 8))))

  ;; start mem location at DONKEY_DATA
  (local.set $mpoint (global.get $DONKEY_DATA))

  (loop $upd
    (block $cont
      ;; load road side to check for initialization
      (local.set $donr (i32.load8_u (i32.add
                                      (local.get $mpoint)
                                      (i32.const 1))))

      ;; continue if chunk uninitialized
      (i32.eqz (local.get $donr))
      br_if $cont

      ;; load y after check to avoid mem read before needed
      (local.set $dony (i32.load8_u (local.get $mpoint)))

      ;; if( donkey-y > 150 ) : remove-from-screen && increase-player-progress
      (i32.ge_u (local.get $dony) (i32.const 140))
      if
        ;; SPEED_MULT += 0.025
        (global.set $SPEED_MULT (f32.add (global.get $SPEED_MULT) (f32.const 0.025)))

        ;; DRIVER_SCORE += 1
        (global.set $DRIVER_SCORE (i32.add (global.get $DRIVER_SCORE) (i32.const 1)))

        ;; DRIVER_PROGRESS += 1
        (global.set $DRIVER_PROG (i32.add (global.get $DRIVER_PROG) (i32.const 1)))

        ;; store 0 in road to mark current donkey as uninitialized
        (i32.store8 (i32.add (local.get $mpoint) (i32.const 1)) (i32.const 0))

        ;; NUM_DONKEYS -= 1
        (global.set $NUM_DONKEYS (i32.sub (global.get $NUM_DONKEYS) (i32.const 1)))

        ;; skip processing this donkey
        br $cont
      end

      ;; process player collision with a donkey. responsible for resetting the
      ;; game to its starting values.
      (block $collision
        ;; TODO: Remove
        br $collision
        ;; if ( donkey_road != driver_road ) : continue
        (i32.ne (local.get $donr) (global.get $DRIVER_ROAD))
        br_if $collision

        ;;  if ( ( (donkey-y + 19) >= driver-y ) && \
        ;;       ( donkey-y <= (driver-y + 32) ) ) : hit!
        (i32.and
          (i32.ge_u (i32.add (local.get $dony) (i32.const 19)) (local.get $drivy))
          (i32.le_u (local.get $dony) (i32.add (local.get $drivy) (i32.const 32)))
        )
        i32.const 1
        i32.xor
        br_if $collision

        ;; store 0 in road to mark current donkey as uninitialized
        (i32.store8 (i32.add (local.get $mpoint) (i32.const 1)) (i32.const 0))

        ;; DONKEY_SCORE += 1
        (global.set $DONKEY_SCORE (i32.add (global.get $DONKEY_SCORE) (i32.const 1)))

        ;; NUM_DONKEYS = 0
        (global.set $NUM_DONKEYS   (i32.const 0))

        ;; DRIVER_PROG = 0
        (global.set $DRIVER_PROG   (i32.const 0))

        ;; SPEED_MULT = [BASE_SPEED_MULT]
        (global.set $SPEED_MULT    (f32.const 1.0))

        ;; zeroes out all DONKEY_DATA
        (call $zero-ddata)

        ;; we no longer have any donkeys to update; any more computation
        ;; would be wasted here
        return
      )

      ;; dv = ( SPEED_MULT * 8.00 )
      global.get $SPEED_MULT
      f32.const 8.00
      f32.mul
      i32.trunc_f32_u

      ;; dony += dv
      local.get $dony
      i32.add
      local.set $dony

      ;; store donkey-y in the correct place
      (i32.store8 (local.get $mpoint) (local.get $dony))
    )

    ;; while( mem-pointer < MAX_MEM ) : mpoint += 2
    (local.set $mpoint (i32.add (local.get $mpoint) (i32.const 2)))
    (i32.lt_u (local.get $mpoint) (global.get $DDATA_MAXMEM))
    br_if $upd
  )
)

;; TODO: Figure out why this works...
(func $zero-ddata
  (local $addr i32)

  (local.set $addr (global.get $DONKEY_DATA))

  (loop $zero
    (i32.store16 (local.get $addr) (i32.const 0))

    (local.set $addr (i32.add (local.get $addr) (i32.const 2)))
    (i32.lt_u (local.get $addr) (global.get $DDATA_MAXMEM))
    br_if $zero
  )
)

(func $alloc-donkey
  (local $addr i32) ;; search pointer

  ;; delta = ( SPEED_MULT * 10.00 )
  global.get $SPEED_MULT
  f32.const 10.0
  f32.mul
  i32.trunc_f32_u

  ;; LAST_ALLOCED += delta
  global.get $LAST_ALLOCED
  i32.add
  global.set $LAST_ALLOCED

  ;; if( LAST_ALLOCED < 14 ) ? return : LAST_ALLOCED = 0
  (i32.le_u (global.get $LAST_ALLOCED) (i32.const 77))
  if
    return
  end

  ;; LAST_ALLOCED = 0 // we're doing an allocation now
  (global.set $LAST_ALLOCED (i32.const 0))

  ;; if ( NUM_DONKEYS > MAX_DONKEYS ) : return
  (i32.gt_u (global.get $NUM_DONKEYS) (global.get $MAX_DONKEYS))
  if
    return
  end

  ;; set search ptr to the start address
  (local.set $addr (global.get $DONKEY_DATA))

  (block $break
    (loop $faddr
      ;; alloc at first chunk with zeroed road
      (i32.eqz (i32.load8_u (i32.add
                              (local.get $addr)
                              (i32.const 1))))
      br_if $break

      ;; while( addr < max-mem ) : addr += 2
      (local.set $addr (i32.add (local.get $addr) (i32.const 2)))
      (i32.lt_u (local.get $addr) (global.get $DDATA_MAXMEM))
      br_if $faddr
    )
  )

  ;; starting donkey-y = 0x00
  (i32.store8 (local.get $addr) (i32.const 0x00))
  ;; starting donkey-r = ran-int(1, 2)
  (i32.store8
    (i32.add (local.get $addr) (i32.const 1))
    (call $ran-int (i32.const 1) (i32.const 2)))

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

  ;; ROAD_OFFSET = s[0] % 19
  i32.const 19
  i32.rem_u
  global.set $ROAD_OFFSET
)

;; swap current value off DRAW_COLORS and onto DRAW_CACHE
(func $draw-swap (param $new i32)
  ;; prevent double swap by making sure DRAW_CACHE is uninit (0x0000)
  (if (i32.ne (global.get $DRAW_CACHE) (i32.const 0x0000)) (then return))
  (global.set $DRAW_CACHE (i32.load16_u (global.get $DRAW_COLORS)))
  (i32.store16 (global.get $DRAW_COLORS) (local.get $new))
)

;; swap value in DRAW_CACHE back into DRAW_COLORS
(func $draw-reset
  (i32.store16 (global.get $DRAW_COLORS) (global.get $DRAW_CACHE))
  ;; re-uninit DRAW_CACHE for future writes
  (global.set $DRAW_CACHE (i32.const 0x0000))
)

;; draws an ASCII or custom formatted string to the screen
(func $ctext (param $strptr i32) (param $x i32) (param $y i32)
  (local $dchar  i32) ;; character to decode
  (local $offset i32)
  (local $ox     i32)

  (local.set $ox (local.get $x))

  (block $break (loop $draw
    (block $cont
      ;; load new value
      (local.set $dchar (i32.load8_u (local.get $strptr)))

      ;; break on null-termination
      (i32.eqz (local.get $dchar))
      br_if $break

      ;; handle space case
      (i32.eq (local.get $dchar) (i32.const 38))
      if
        ;; s[0] = DRAW_COLORS
        (i32.load16_u (global.get $DRAW_COLORS))
        (i32.store16 (global.get $DRAW_COLORS) (i32.const 0x2e))

        ;; draw rect size of character
        (call $rect
              (local.get $x)
              (local.get $y)
              (i32.const 6)
              (i32.const 6))

        ;; restore DRAW_COLORS
        (i32.store16 (global.get $DRAW_COLORS))

        br $cont
      end

      ;; padding case
      (i32.eq (local.get $dchar) (i32.const 0x24))
      br_if $cont

      ;; handle newline case
      (i32.eq (local.get $dchar) (i32.const 0x25))
      if
        (local.set $x (i32.sub (local.get $ox) (i32.const 7))) ;; offset x+=7
        (local.set $y (i32.add (local.get $y) (i32.const 7)))  ;; incr y
        br $cont
      end

      ;; decode
      (block $dec
        (i32.ge_u (local.get $dchar) (i32.const 97))
        if
          (local.set $offset (i32.const 97))
          br $dec
        end

        (i32.ge_u (local.get $dchar) (i32.const 65))
        if
          (local.set $offset (i32.const 65))
          br $dec
        end

        (i32.ge_u (local.get $dchar) (i32.const 48))
        if
          (local.set $offset (i32.const 22))
          br $dec
        end

        (local.set $offset (i32.const 0))
      )
      (local.set $dchar (i32.sub
                          (local.get $dchar)
                          (local.get $offset)))

      ;;draw
      (call $blitsub
            (global.get $CHAR_DATA) ;; spriteptr
            (local.get $x)          ;; x
            (local.get $y)          ;; y
            (i32.const 6)           ;; width
            (i32.const 6)           ;; height
            (i32.mul
              (local.get $dchar)
              (i32.const 6))        ;; srcx
            (i32.const 0)           ;; srcy
            (i32.const 216)         ;; stride
            (global.get $BLIT_1BPP))

    )

    (local.set $x (i32.add (local.get $x) (i32.const 7))) ;; x+=6
    (local.set $strptr (i32.add (local.get $strptr) (i32.const 1))) ;; strptr+=1

    br $draw
  ))
)

(func $cstr (param $num i32) (param $strlen i32)
  (local $index      i32)
  (local $digit-val  i32)
  (local $digit-char i32)

  ;; bounds check strlen in an admittedly weird way
  (local.set $strlen
             (i32.rem_u (local.get $strlen)
                        (global.get $CSTR_MAXLEN)))


  (local.set $index (local.get $strlen))

  (loop $digit_loop (block $break
    (i32.eqz (local.get $index))
    br_if $break

    ;; digit-val = ( num % 10 )
    (local.set $digit-val (i32.rem_u (local.get $num) (i32.const 10)))

    ;; if ( num == 0 ) ? digit-char = 32 : digit-char = ( val + 25 )
    (i32.eqz (local.get $num))
    if
      ;; fill blank spaces with a 0 char
      (local.set $digit-char (i32.const 26))
    else
      ;; offset number into custom characters
      (local.set $digit-char (i32.add
                               (local.get $digit-val)
                               (i32.const 26)))
    end

    (local.set $index (i32.sub (local.get $index) (i32.const 1)))

    ;; store char value intro string
    (i32.store8
      (i32.add (global.get $CSTR_ADDR) (local.get $index))
      (local.get $digit-char))

    ;; num = ( num / 10 )
    (local.set $num (i32.div_u (local.get $num) (i32.const 10)))
    br $digit_loop
  ))
)

(func $ran (result i32)
  (;
   LGC Algorithm implementation; this implementation uses glibc's constants for
   the a (multiplier), c (increment), and m (modulus) values. This alogrithm
   leaves bits 30..0 as output, so we run the algorithm twice packing the
   random bits onto the stack each time.
  ;)

  ;; seed = ((a * seed) + c) % m
  global.get $RSEED
  global.get $A-RAND
  i32.mul
  global.get $C-RAND
  i32.add
  global.get $M-RAND
  i32.rem_u
  global.set $RSEED

  ;; fill in bits 32..2
  global.get $RSEED
  i32.const 2
  i32.shl

  ;; seed = ((a * seed) + c) % m
  global.get $RSEED
  global.get $A-RAND
  i32.mul
  global.get $C-RAND
  i32.add
  global.get $M-RAND
  i32.rem_u
  global.set $RSEED

  ;; fill in bits 2..0
  global.get $RSEED
  i32.const 28
  i32.shr_u
  i32.or
)

(func $ran-int (param $low i32) (param $high i32) (result i32)
  ;; s[0] = ran()
  call $ran

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
