; ---------------------------------------------------------------------------
; Global routines

font				:= $0800

in_main             := $6800

lo_main 			:= $0C00

mi_main             := $7400

; ---------------------------------------------------------------------------
; Defines and macros




; This define calculates the offset from the start of bitmap memory where the
; pixel at the given zero-based row and column can be found:

.define BITMAP_OFFSET(col, row) ((320 * (row / 8)) + (row .mod 8)) + (8 * (col / 8))
