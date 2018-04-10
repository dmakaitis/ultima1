The following asset files are required by the build:

File 				Used by 	Description

intro/horse0.bin	IN.PRG		Animation frames for the horse on the intro page. Each frame is
intro/horse1.bin	IN.PRG		stored as the first two columns of sprite data (the third is
intro/horse2.bin	IN.PRG		set to zeros by the intro code).
intro/horse3.bin	IN.PRG
intro/horse4.bin	IN.PRG
intro/horse5.bin	IN.PRG
intro/horse6.bin	IN.PRG

intro/image.bin 	IN.PRG		Compressed image to display on the intro page when loading the game.

intro/osi.bin		IN.PRG		104x21 Origin systems logo, arranged top row of pixels, then second, etc.

intro/ultima.bin	IN.PRG		Ultima I logo, arranged in C64 bitmap format (first 8x8 block, then second 8x8, etc.)