.PHONY: all verify clean utils origsrc

all: build/u1.prg build/hello.prg build/lo.prg build/in.prg

build/u1.prg: src/u1.cfg build/u1.o
	ld65 -C $< build/u1.o -o $@ -vm -m maps/u1.map

build/hello.prg: src/hello.cfg build/hello.o build/hello_1541_bootstrap.o build/hello_1541_fastload.o
	ld65 -C $< build/hello.o build/hello_1541_bootstrap.o build/hello_1541_fastload.o -o $@ -vm -m maps/hello.map

build/lo.prg: src/lo.cfg build/lo.o
	ld65 -C $< build/lo.o -o $@ -vm -m maps/lo.map

build/in.prg: src/in.cfg build/in.o
	ld65 -C $< build/in.o -o $@ -vm -m maps/in.map

build: 
	mkdir -p build

maps: 
	mkdir -p maps

assets/lo: orig/lo.prg
	mkdir -p assets/lo
	dd if=orig/lo.prg of=assets/lo/font.bin bs=1 skip=2 count=1024

assets/intro: orig/in.prg
	mkdir -p assets/intro
	dd if=orig/in.prg of=assets/intro/osi.bin bs=1 skip=1962 count=273
	dd if=orig/in.prg of=assets/intro/ultima.bin bs=1 skip=2242 count=1104
	dd if=orig/in.prg of=assets/intro/horse0.bin bs=1 skip=3369 count=42
	dd if=orig/in.prg of=assets/intro/horse1.bin bs=1 skip=3411 count=42
	dd if=orig/in.prg of=assets/intro/horse2.bin bs=1 skip=3453 count=42
	dd if=orig/in.prg of=assets/intro/horse3.bin bs=1 skip=3495 count=42
	dd if=orig/in.prg of=assets/intro/horse4.bin bs=1 skip=3537 count=42
	dd if=orig/in.prg of=assets/intro/horse5.bin bs=1 skip=3579 count=42
	dd if=orig/in.prg of=assets/intro/horse6.bin bs=1 skip=3621 count=42
	dd if=orig/in.prg of=assets/intro/image.bin bs=1 skip=5021 count=2367

verify: all
	./chkfile u1.prg
	./chkfile hello.prg
	./chkfile lo.prg
	./chkfile in.prg

clean:
	-$(MAKE) -C util clean
	rm -Rf build
	rm -Rf tmp
	rm -Rf maps
	rm -Rf assets/lo
	rm -Rf assets/intro
	rm -Rf orig/files
	rm -Rf orig/src

build/lo.o: assets/lo
build/in.o: assets/intro

build/%.o: src/%.s build maps
	ca65 $< -o $@ -I include -I assets

utils:
	$(MAKE) -C util

###########################################################
# The following rules are for extract disassembles code
# from a .d64 image of an original Ultima 1 C64 floppy
# named 'ultima1.d64' and located in the root directory
# of the project.

infofiles = $(addprefix orig/src/, $(addsuffix .s, $(basename $(notdir $(wildcard orig/*.info)))))
origsrc: $(infofiles)

orig/files/%.prg: ultima1.d64
	-mkdir -p orig/files
	c1541 $< -read $* $@

orig/src/%.s: orig/%.info
	-mkdir -p orig/src
	da65 -i $<

orig/src/u1.s: orig/files/u1.prg
orig/src/hello.s: orig/files/hello.prg
orig/src/hello_hi.s: orig/files/hello.prg
orig/src/hello_1541.s: orig/files/hello.prg
orig/src/hello_1541_0500.s: orig/files/hello.prg
orig/src/lo.s: orig/files/lo.prg
orig/src/in.s: orig/files/in.prg
