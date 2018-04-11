.PHONY: all verify clean utils origsrc compileassets

U1FILES = u1 hello lo in
PRG_OUT = build/prg
ASSETS_OUT = build/assets
MAPS_OUT = build/maps
ORIG_PRG_OUT = build/orig/prg
ORIG_SRC_OUT = build/orig/src

all: $(addprefix $(PRG_OUT)/, $(addsuffix .prg, $(U1FILES)))

$(PRG_OUT)/hello.prg: src/hello.cfg build/hello.o build/hello_1541_bootstrap.o build/hello_1541_fastload.o
	ld65 -C $< build/hello.o build/hello_1541_bootstrap.o build/hello_1541_fastload.o -o $@ -vm -m $(MAPS_OUT)/hello.map

$(PRG_OUT)/%.prg: src/%.cfg build/%.o
	ld65 -C $< build/$*.o -o $@ -vm -m $(MAPS_OUT)/$*.map

build: 
	-@mkdir -p $(PRG_OUT)
	-@mkdir -p $(MAPS_OUT)
	-@mkdir -p $(ASSETS_OUT)
	-@mkdir -p $(ORIG_PRG_OUT)
	-@mkdir -p $(ORIG_SRC_OUT)

verify: all $(addprefix $(ORIG_PRG_OUT)/, $(addsuffix .prg, $(U1FILES)))
	./chkfile u1.prg
	./chkfile hello.prg
	./chkfile lo.prg
	./chkfile in.prg

clean:
	-$(MAKE) -C util clean
	-rm -Rf build
	-rm -Rf orig/files
	-rm -Rf orig/src

lo_assets = font
in_assets = osi ultima horse0 horse1 horse2 horse3 horse4 horse5 horse6 image

build/lo.o: $(addprefix $(ASSETS_OUT)/, $(addsuffix .bin, $(lo_assets)))
build/in.o: $(addprefix $(ASSETS_OUT)/, $(addsuffix .bin, $(in_assets)))

build/%.o: src/%.s build
	ca65 $< -o $@ -I include -I $(ASSETS_OUT)

utils:
	$(MAKE) -C util

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
# The following rules compile assets for inclusion in
# game files.

assets =	font osi ultima horse0 horse1 horse2 horse3 horse4 horse5 horse6 \
			image

compileassets: $(addprefix $(ASSETS_OUT)/, $(addsuffix .bin, $(assets)))

$(ASSETS_OUT)/font.bin: $(ORIG_PRG_OUT)/lo.prg build
	dd if=$< of=$@ bs=1 skip=2 count=1024

$(ASSETS_OUT)/osi.bin: $(ORIG_PRG_OUT)/in.prg build
	dd if=$< of=$@ bs=1 skip=1962 count=273

$(ASSETS_OUT)/ultima.bin: $(ORIG_PRG_OUT)/in.prg build
	dd if=$< of=$@ bs=1 skip=2242 count=1104

$(ASSETS_OUT)/horse0.bin: $(ORIG_PRG_OUT)/in.prg build
	dd if=$< of=$@ bs=1 skip=3369 count=42

$(ASSETS_OUT)/horse1.bin: $(ORIG_PRG_OUT)/in.prg build
	dd if=$< of=$@ bs=1 skip=3411 count=42

$(ASSETS_OUT)/horse2.bin: $(ORIG_PRG_OUT)/in.prg build
	dd if=$< of=$@ bs=1 skip=3453 count=42

$(ASSETS_OUT)/horse3.bin: $(ORIG_PRG_OUT)/in.prg build
	dd if=$< of=$@ bs=1 skip=3495 count=42

$(ASSETS_OUT)/horse4.bin: $(ORIG_PRG_OUT)/in.prg build
	dd if=$< of=$@ bs=1 skip=3537 count=42

$(ASSETS_OUT)/horse5.bin: $(ORIG_PRG_OUT)/in.prg build
	dd if=$< of=$@ bs=1 skip=3579 count=42

$(ASSETS_OUT)/horse6.bin: $(ORIG_PRG_OUT)/in.prg build
	dd if=$< of=$@ bs=1 skip=3621 count=42

$(ASSETS_OUT)/image.bin: $(ORIG_PRG_OUT)/in.prg build
	dd if=$< of=$@ bs=1 skip=5021 count=2367
