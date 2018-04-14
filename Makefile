.PHONY: all u1files verify clean utils origsrc assets compileassets

U1FILES = u1 hello lo in
PRG_OBJ = build/prgobj
PRG_OUT = build/prg
ASSETS_OUT = build/assets
MAPS_OUT = build/maps
ORIG_PRG_OUT = build/orig/prg
ORIG_SRC_OUT = build/orig/src
BIN_OBJ = build/binobj
BIN_OUT = build/bin

u1files: $(addprefix $(PRG_OUT)/, $(addsuffix .prg, $(U1FILES)))

all: u1files

$(PRG_OUT)/hello.prg: src/hello.cfg $(PRG_OBJ)/hello.o $(PRG_OBJ)/hello_1541_bootstrap.o $(PRG_OBJ)/hello_1541_fastload.o
	ld65 -C $< $(PRG_OBJ)/hello.o $(PRG_OBJ)/hello_1541_bootstrap.o $(PRG_OBJ)/hello_1541_fastload.o -o $@ -vm -m $(MAPS_OUT)/hello.map

$(PRG_OUT)/%.prg: src/%.cfg $(PRG_OBJ)/%.o
	ld65 -C $< $(PRG_OBJ)/$*.o -o $@ -vm -m $(MAPS_OUT)/$*.map

build: 
	-@mkdir -p $(PRG_OBJ)
	-@mkdir -p $(PRG_OUT)
	-@mkdir -p $(MAPS_OUT)
	-@mkdir -p $(ASSETS_OUT)
	-@mkdir -p $(ORIG_PRG_OUT)
	-@mkdir -p $(ORIG_SRC_OUT)
	-@mkdir -p $(BIN_OBJ)
	-@mkdir -p $(BIN_OUT)

verify: u1files $(addprefix $(ORIG_PRG_OUT)/, $(addsuffix .prg, $(U1FILES)))
	./chkfile u1.prg
	./chkfile hello.prg
	./chkfile lo.prg
	./chkfile in.prg

clean:
	-rm -Rf build
	-rm -Rf assets/*.png

lo_assets = font
in_assets = osi ultima horse0 horse1 horse2 horse3 horse4 horse5 horse6 image

$(PRG_OBJ)/lo.o: $(addprefix $(ASSETS_OUT)/, $(addsuffix .bin, $(lo_assets)))
$(PRG_OBJ)/in.o: $(addprefix $(ASSETS_OUT)/, $(addsuffix .bin, $(in_assets)))

$(PRG_OBJ)/%.o: src/%.s build
	ca65 $< -o $@ -I include -I $(ASSETS_OUT)

###########################################################
# The following rules are for building command line
# utilities that are used by other parts of the build

utils = dimage cimage

utils: $(addprefix $(BIN_OUT)/, $(utils))

$(BIN_OUT)/dimage: $(BIN_OBJ)/dimage.o
	c++ -o $@ $(BIN_OBJ)/dimage.o -lpng

$(BIN_OUT)/cimage: $(BIN_OBJ)/cimage.o
	c++ -o $@ $(BIN_OBJ)/cimage.o -lpng

$(BIN_OBJ)/%.o: util/%.cpp build
	c++ -Wno-c++11-extensions -c -o $@ $<

###########################################################
# The following rules are for extracting disassembled code
# from a .d64 image of an original Ultima 1 C64 floppy
# named 'ultima1.d64' and located in the root directory
# of the project.

infofiles = $(addprefix $(ORIG_SRC_OUT)/, $(addsuffix .s, $(basename $(notdir $(wildcard orig/*.info)))))
origsrc: $(infofiles)

$(ORIG_PRG_OUT)/%.prg: ultima1.d64 build
	c1541 $< -read $* $@

$(ORIG_SRC_OUT)/%.s: orig/%.info
	da65 -i $<

$(ORIG_SRC_OUT)/u1.s: $(ORIG_PRG_OUT)/u1.prg
$(ORIG_SRC_OUT)/hello.s: $(ORIG_PRG_OUT)/hello.prg
$(ORIG_SRC_OUT)/hello_hi.s: $(ORIG_PRG_OUT)/hello.prg
$(ORIG_SRC_OUT)/hello_1541.s: $(ORIG_PRG_OUT)/hello.prg
$(ORIG_SRC_OUT)/hello_1541_0500.s: $(ORIG_PRG_OUT)/hello.prg
$(ORIG_SRC_OUT)/lo.s: $(ORIG_PRG_OUT)/lo.prg
$(ORIG_SRC_OUT)/in.s: $(ORIG_PRG_OUT)/in.prg

###########################################################
# The following rules extract assets from the original
# game files.

pngassets =	font osi ultima horse0 horse1 horse2 horse3 horse4 horse5 horse6 \
			image

assets: $(addprefix assets/, $(addsuffix .png, $(pngassets)))

assets/font.png: $(ORIG_PRG_OUT)/lo.prg $(BIN_OUT)/dimage
	$(BIN_OUT)/dimage -q -i $< -o $@ -b -w 128 -s 2 -n 1024

assets/osi.png: $(ORIG_PRG_OUT)/in.prg $(BIN_OUT)/dimage
	$(BIN_OUT)/dimage -q -i $< -o $@ -w 104 -s 1962 -n 273

assets/ultima.png: $(ORIG_PRG_OUT)/in.prg $(BIN_OUT)/dimage
	$(BIN_OUT)/dimage -q -i $< -o $@ -b -w 184 -s 2242 -n 1104

assets/horse0.png: $(ORIG_PRG_OUT)/in.prg $(BIN_OUT)/dimage
	$(BIN_OUT)/dimage -q -i $< -o $@ -w 24 -s 3369 -n 42

assets/horse1.png: $(ORIG_PRG_OUT)/in.prg $(BIN_OUT)/dimage
	$(BIN_OUT)/dimage -q -i $< -o $@ -w 24 -s 3411 -n 42

assets/horse2.png: $(ORIG_PRG_OUT)/in.prg $(BIN_OUT)/dimage
	$(BIN_OUT)/dimage -q -i $< -o $@ -w 24 -s 3453 -n 42

assets/horse3.png: $(ORIG_PRG_OUT)/in.prg $(BIN_OUT)/dimage
	$(BIN_OUT)/dimage -q -i $< -o $@ -w 24 -s 3495 -n 42

assets/horse4.png: $(ORIG_PRG_OUT)/in.prg $(BIN_OUT)/dimage
	$(BIN_OUT)/dimage -q -i $< -o $@ -w 24 -s 3537 -n 42

assets/horse5.png: $(ORIG_PRG_OUT)/in.prg $(BIN_OUT)/dimage
	$(BIN_OUT)/dimage -q -i $< -o $@ -w 24 -s 3579 -n 42

assets/horse6.png: $(ORIG_PRG_OUT)/in.prg $(BIN_OUT)/dimage
	$(BIN_OUT)/dimage -q -i $< -o $@ -w 24 -s 3621 -n 42

assets/image.png: $(ORIG_PRG_OUT)/in.prg $(BIN_OUT)/dimage
	$(BIN_OUT)/dimage -q -i $< -o $@ -bc -w 320 -h 200 -s 5021 -n 2367 -C 192

###########################################################
# The following rules compile assets for inclusion in
# game files.

compileassets: $(addprefix $(ASSETS_OUT)/, $(addsuffix .bin, $(pngassets)))

$(ASSETS_OUT)/font.bin: assets/font.png $(BIN_OUT)/cimage
	$(BIN_OUT)/cimage -qb -i $< -o $@

$(ASSETS_OUT)/osi.bin: assets/osi.png $(BIN_OUT)/cimage
	$(BIN_OUT)/cimage -q -i $< -o $@

$(ASSETS_OUT)/ultima.bin: assets/ultima.png $(BIN_OUT)/cimage
	$(BIN_OUT)/cimage -qb -i $< -o $@

$(ASSETS_OUT)/horse%.bin: assets/horse%.png $(BIN_OUT)/cimage
	$(BIN_OUT)/cimage -q -i $< -o $@

# The intro image needs to be read from the original IN file since
# it includes data beyond the actual end of the image

$(ASSETS_OUT)/image.bin: $(ORIG_PRG_OUT)/in.prg build
	dd if=$< of=$@ bs=1 skip=5021 count=2366

# $(ASSETS_OUT)/image.bin: assets/image.png $(BIN_OUT)/cimage
# 	$(BIN_OUT)/cimage -qbc -i $< -o $@
