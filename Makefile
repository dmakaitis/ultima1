all : build/u1.prg build/hello.prg build/lo.prg build/in.prg

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

verify: all
	./chkfile u1.prg
	./chkfile hello.prg
	./chkfile lo.prg
	./chkfile in.prg

clean:
	rm -Rf build
	rm -Rf tmp
	rm -Rf maps

#build/hello.o: src/hello.s build/hello_1541_bootstrap.prg build/hello_1541_fastload.prg
#	ca65 $<
	
build/%.o: src/%.s build maps
	ca65 $< -o $@ -I include

# SUBDIRS = src

# all : subdirs

# subdirs:
# 	for dir in $(SUBDIRS); do \
# 		$(MAKE) -C $$dir; \
# 	done

# clean :
# 	for dir in $(SUBDIRS); do \
# 		$(MAKE) -C $$dir clean; \
# 	done
