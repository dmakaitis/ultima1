.PHONY: all u1files verify clean utils origsrc assets compileassets

# OLD_SHELL := $(SHELL)
# SHELL = $(warning [$@ ($^) ($?)])$(OLD_SHELL)

# U1 files original order: 
#		u1, tc, ma, fi, hello, tw, st, 
#		dd, lo, ge, ou, ro, p0, ca, pr, 
#		in , dn, mi, tm, sp, p1, p2, p3
U1FILES = u1 hello st \
			lo ge \
			in
PRG_OBJ = build/prgobj
PRG_OUT = build/prg
ASSETS_OUT = build/assets
MAPS_OUT = build/maps
ORIG_PRG_OUT = build/orig/prg
ORIG_SRC_OUT = build/orig/src
BIN_OBJ = build/binobj
BIN_OUT = build/bin
INC_OUT = build/include

CA65 = /usr/local/bin/ca65
LD65 = /usr/local/bin/ld65
DA65 = /usr/local/bin/da65

CIMAGE = $(BIN_OUT)/cimage
DIMAGE = $(BIN_OUT)/dimage
MAP2INC = $(BIN_OUT)/map2inc

u1files: $(addprefix $(PRG_OUT)/, $(addsuffix .prg, $(U1FILES)))

all: build/u1.d64

build/u1.d64: u1files
	c1541 -format "ultima 1,aa" d64 $@ \
		-write build/prg/u1.prg u1 \
		-write build/prg/hello.prg hello \
		-write build/prg/st.prg st \
		-write build/prg/lo.prg lo \
		-write build/prg/ge.prg ge \
		-write build/prg/in.prg in

u1_obj = $(addprefix $(PRG_OBJ)/u1/, $(addsuffix .o, $(basename $(notdir $(wildcard src/u1/*.s)))))
$(u1_obj): $(INC_OUT)/hello.inc
$(PRG_OUT)/u1.prg $(MAPS_OUT)/u1.map: src/u1/u1.cfg $(u1_obj)
	@mkdir -p $(@D)
	@mkdir -p $(MAPS_OUT)
	$(LD65) -C $< $(u1_obj) -o $@ -vm -m $(MAPS_OUT)/u1.map

hello_obj = $(addprefix $(PRG_OBJ)/hello/, $(addsuffix .o, $(basename $(notdir $(wildcard src/hello/*.s)))))
# $(hello_obj): $(INC_OUT)/lo.inc
$(PRG_OUT)/hello.prg $(MAPS_OUT)/hello.map: src/hello/hello.cfg $(hello_obj)
	@mkdir -p $(@D)
	@mkdir -p $(MAPS_OUT)
	$(LD65) -C $< $(hello_obj) -o $@ -vm -m $(MAPS_OUT)/hello.map

st_obj = $(addprefix $(PRG_OBJ)/st/, $(addsuffix .o, $(basename $(notdir $(wildcard src/st/*.s)))))
$(st_obj): $(INC_OUT)/lo.inc
$(PRG_OUT)/st.prg $(MAPS_OUT)/st.map: src/st/st.cfg $(st_obj)
	@mkdir -p $(@D)
	@mkdir -p $(MAPS_OUT)
	$(LD65) -C $< $(st_obj) -o $@ -vm -m $(MAPS_OUT)/st.map

lo_obj = $(addprefix $(PRG_OBJ)/lo/, $(addsuffix .o, $(basename $(notdir $(wildcard src/lo/*.s)))))
$(lo_obj): $(INC_OUT)/in.inc
$(PRG_OUT)/lo.prg $(MAPS_OUT)/lo.map: src/lo/lo.cfg $(lo_obj)
	@mkdir -p $(@D)
	@mkdir -p $(MAPS_OUT)
	$(LD65) -C $< $(lo_obj) -o $@ -vm -m $(MAPS_OUT)/lo.map

ge_obj = $(addprefix $(PRG_OBJ)/ge/, $(addsuffix .o, $(basename $(notdir $(wildcard src/ge/*.s)))))
$(ge_obj): $(INC_OUT)/hello.inc $(INC_OUT)/st.inc
$(PRG_OUT)/ge.prg $(MAPS_OUT)/ge.map: src/ge/ge.cfg $(ge_obj)
	@mkdir -p $(@D)
	@mkdir -p $(MAPS_OUT)
	$(LD65) -C $< $(ge_obj) -o $@ -vm -m $(MAPS_OUT)/ge.map

in_obj = $(addprefix $(PRG_OBJ)/in/, $(addsuffix .o, $(basename $(notdir $(wildcard src/in/*.s)))))
$(in_obj): $(INC_OUT)/hello.inc
$(PRG_OUT)/in.prg $(MAPS_OUT)/in.map: src/in/in.cfg $(in_obj)
	@mkdir -p $(@D)
	@mkdir -p $(MAPS_OUT)
	$(LD65) -C $< $(in_obj) -o $@ -vm -m $(MAPS_OUT)/in.map

$(INC_OUT)/%.inc: $(MAPS_OUT)/%.map $(MAP2INC)
	@mkdir -p $(@D)
	$(MAP2INC) -m $< -i src/$*/$*.exp -o $@


verify: u1files $(addprefix $(ORIG_PRG_OUT)/, $(addsuffix .prg, $(U1FILES)))
	./chkfile u1.prg
	./chkfile hello.prg
	./chkfile st.prg
	./chkfile lo.prg
	./chkfile ge.prg
	./chkfile in.prg

clean:
	-rm -Rf build
	-rm -Rf assets/*.png

lo_assets = font osibig
in_assets = intro_studio intro_title intro_horse0 intro_horse1 intro_horse2 \
			intro_horse3 intro_horse4 intro_horse5 intro_horse6 intro_backdrop \
			intro_car intro_knight0 intro_knight1 intro_sword intro_sword_mask \
			intro_sword_hand intro_hand intro_bird_body0 intro_bird_body1 \
			intro_bird_body2 intro_bird_body3 intro_bird_head0 intro_bird_head1 \
			intro_bird_head2 intro_bird_head3
st_assets = tiles

$(PRG_OBJ)/lo/data.o: $(addprefix $(ASSETS_OUT)/, $(addsuffix .bin, $(lo_assets)))
$(PRG_OBJ)/in/data.o: $(addprefix $(ASSETS_OUT)/, $(addsuffix .bin, $(in_assets)))
$(PRG_OBJ)/st/data.o: $(addprefix $(ASSETS_OUT)/, $(addsuffix .bin, $(st_assets)))

$(PRG_OBJ)/%.o: src/%.s
	@mkdir -p $(@D)
	$(CA65) $< -o $@ -I include -I $(INC_OUT) --bin-include-dir $(ASSETS_OUT)

###########################################################
# The following rules are for building command line
# utilities that are used by other parts of the build

utils = dimage cimage

utils: build $(addprefix $(BIN_OUT)/, $(utils))

$(DIMAGE): $(BIN_OBJ)/dimage.o
	@mkdir -p $(@D)
	c++ -o $@ $(BIN_OBJ)/dimage.o -lpng

$(CIMAGE): $(BIN_OBJ)/cimage.o
	@mkdir -p $(@D)
	c++ -o $@ $(BIN_OBJ)/cimage.o -lpng

$(MAP2INC): $(BIN_OBJ)/map2inc.o
	@mkdir -p $(@D)
	c++ -o $@ $(BIN_OBJ)/map2inc.o

$(BIN_OBJ)/%.o: util/%.cpp
	@mkdir -p $(@D)
	c++ -Wno-c++11-extensions -c -o $@ $<

###########################################################
# The following rules are for extracting disassembled code
# from a .d64 image of an original Ultima 1 C64 floppy
# named 'ultima1.d64' and located in the root directory
# of the project.

infofiles = $(addprefix $(ORIG_SRC_OUT)/, $(addsuffix .s, $(basename $(notdir $(wildcard orig/*.info)))))
origsrc: $(infofiles)

$(ORIG_PRG_OUT)/%.prg: ultima1.d64
	@mkdir -p $(@D)
	c1541 $< -read $* $@

$(ORIG_SRC_OUT)/%.s: orig/%.info
	@mkdir -p $(@D)
	$(DA65) -i $<

$(ORIG_SRC_OUT)/u1.s: $(ORIG_PRG_OUT)/u1.prg
$(ORIG_SRC_OUT)/hello.s: $(ORIG_PRG_OUT)/hello.prg
$(ORIG_SRC_OUT)/hello_hi.s: $(ORIG_PRG_OUT)/hello.prg
$(ORIG_SRC_OUT)/hello_1541.s: $(ORIG_PRG_OUT)/hello.prg
$(ORIG_SRC_OUT)/hello_1541_0500.s: $(ORIG_PRG_OUT)/hello.prg
$(ORIG_SRC_OUT)/lo.s: $(ORIG_PRG_OUT)/lo.prg
$(ORIG_SRC_OUT)/in.s: $(ORIG_PRG_OUT)/in.prg
$(ORIG_SRC_OUT)/mi.s: $(ORIG_PRG_OUT)/mi.prg include/milib.inc orig/st.inc
$(ORIG_SRC_OUT)/ge.s: $(ORIG_PRG_OUT)/ge.prg include/milib.inc orig/st.inc
$(ORIG_SRC_OUT)/st.s: $(ORIG_PRG_OUT)/st.prg orig/st.inc

###########################################################
# The following rules extract assets from the original
# game files.

pngassets =	font osibig intro_studio intro_title intro_horse0 intro_horse1 \
			intro_horse2 intro_horse3 intro_horse4 intro_horse5 intro_horse6 \
			intro_backdrop intro_car intro_knight0 intro_knight1 intro_sword \
			intro_sword_mask intro_hand intro_bird_body0 intro_bird_body1 \
			intro_bird_body2 intro_bird_body3 intro_bird_head0 intro_bird_head1 \
			intro_bird_head2 intro_bird_head3 tiles

assets: $(addprefix assets/, $(addsuffix .png, $(pngassets)))

assets/font.png: $(ORIG_PRG_OUT)/lo.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -b -w 128 -s 2 -n 1024

assets/osibig.png: $(ORIG_PRG_OUT)/lo.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -b -w 280 -s 1184 -n 2240

assets/intro_studio.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 104 -s 1962 -n 273

assets/intro_title.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -b -w 184 -s 2242 -n 1104

assets/intro_horse0.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 3369 -n 42

assets/intro_horse1.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 3411 -n 42

assets/intro_horse2.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 3453 -n 42

assets/intro_horse3.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 3495 -n 42

assets/intro_horse4.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 3537 -n 42

assets/intro_horse5.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 3579 -n 42

assets/intro_horse6.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 3621 -n 42

assets/intro_backdrop.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -bc -w 320 -h 200 -s 5021 -n 2367 -C 192

assets/intro_car.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 3354 -n 15

assets/intro_knight0.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 3679 -n 39

assets/intro_knight1.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 3718 -n 39

assets/intro_sword.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 3767 -n 342

assets/intro_sword_mask.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 4258 -n 363

assets/intro_sword_hand.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 4111 -n 39

assets/intro_hand.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 4151 -n 99

assets/intro_bird_body0.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 4621 -n 48

assets/intro_bird_body1.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 4669 -n 48

assets/intro_bird_body2.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 4717 -n 48

assets/intro_bird_head0.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 4773 -n 48

assets/intro_bird_head1.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 4821 -n 48

assets/intro_bird_head2.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 4869 -n 48

assets/intro_bird_body3.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 4925 -n 48

assets/intro_bird_head3.png: $(ORIG_PRG_OUT)/in.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 24 -s 4973 -n 48

assets/tiles.png: $(ORIG_PRG_OUT)/st.prg $(DIMAGE)
	$(DIMAGE) -q -i $< -o $@ -w 128 -h 96 -s 2 -n 1536 -B

###########################################################
# The following rules compile assets for inclusion in
# game files.

compileassets: $(addprefix $(ASSETS_OUT)/, $(addsuffix .bin, $(pngassets)))

$(ASSETS_OUT)/font.bin: assets/font.png $(CIMAGE)
	@mkdir -p $(@D)
	$(CIMAGE) -qb -i $< -o $@

$(ASSETS_OUT)/osibig.bin: assets/osibig.png $(CIMAGE)
	@mkdir -p $(@D)
	$(CIMAGE) -qb -i $< -o $@

$(ASSETS_OUT)/intro_studio.bin: assets/intro_studio.png $(CIMAGE)
	@mkdir -p $(@D)
	$(CIMAGE) -q -i $< -o $@

$(ASSETS_OUT)/intro_title.bin: assets/intro_title.png $(CIMAGE)
	@mkdir -p $(@D)
	$(CIMAGE) -qb -i $< -o $@

$(ASSETS_OUT)/intro_horse%.bin: assets/intro_horse%.png $(CIMAGE)
	@mkdir -p $(@D)
	$(CIMAGE) -q -i $< -o $@

$(ASSETS_OUT)/intro_backdrop.bin: assets/intro_backdrop.png $(CIMAGE)
	@mkdir -p $(@D)
	$(CIMAGE) -qbc -C 192 -i $< -o $@

$(ASSETS_OUT)/intro_car.bin: assets/intro_car.png $(CIMAGE)
	@mkdir -p $(@D)
	$(CIMAGE) -q -i $< -o $@

$(ASSETS_OUT)/intro_knight%.bin: assets/intro_knight%.png $(CIMAGE)
	@mkdir -p $(@D)
	$(CIMAGE) -q -i $< -o $@

$(ASSETS_OUT)/intro_sword.bin: assets/intro_sword.png $(CIMAGE)
	@mkdir -p $(@D)
	$(CIMAGE) -q -i $< -o $@

$(ASSETS_OUT)/intro_sword_mask.bin: assets/intro_sword_mask.png $(CIMAGE)
	@mkdir -p $(@D)
	$(CIMAGE) -q -i $< -o $@

$(ASSETS_OUT)/intro_sword_hand.bin: assets/intro_sword_hand.png $(CIMAGE)
	@mkdir -p $(@D)
	$(CIMAGE) -q -i $< -o $@

$(ASSETS_OUT)/intro_hand.bin: assets/intro_hand.png $(CIMAGE)
	@mkdir -p $(@D)
	$(CIMAGE) -q -i $< -o $@

$(ASSETS_OUT)/intro_bird_body%.bin: assets/intro_bird_body%.png $(CIMAGE)
	@mkdir -p $(@D)
	$(CIMAGE) -q -i $< -o $@

$(ASSETS_OUT)/intro_bird_head%.bin: assets/intro_bird_head%.png $(CIMAGE)
	@mkdir -p $(@D)
	$(CIMAGE) -q -i $< -o $@

$(ASSETS_OUT)/tiles.bin: assets/tiles.png $(CIMAGE)
	@mkdir -p $(@D)
	$(CIMAGE) -qB -i $< -o $@
