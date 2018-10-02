The following asset files are required by the build:

File 				Used by 	Description

intro/horse0.bin	IN.PRG		Animation frames for the horse on the intro page. Each frame is
intro/horse1.bin	IN.PRG		stored as a 24x14 bitmap stored in row sequential order (the
intro/horse2.bin	IN.PRG		remaining bytes of the C64 sprite are set to zeros by the intro 
intro/horse3.bin	IN.PRG		code).
intro/horse4.bin	IN.PRG
intro/horse5.bin	IN.PRG
intro/horse6.bin	IN.PRG

intro/image.bin 	IN.PRG		Compressed 320x200 image to display on the intro page when loading the game.

intro/osi.bin		IN.PRG		104x21 Origin systems logo, arranged top row of pixels, then second, etc.

intro/ultima.bin	IN.PRG		184x48 Ultima I logo, arranged in C64 bitmap format (first 8x8 block, then second 8x8, etc.)

lo/font.bin			LO.PRG		The game font, stored as a 128x64 bitmap arranged in C64 bitmap format (8x8 blocks)

st/tiles.bin        ST.PRG      The game tile image (16x16 blocks)
