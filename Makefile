all : build/u1.prg

builddir :
	mkdir -p build

build/u1.prg : builddir src/u1.cfg src/u1.s
	cl65 -C src/u1.cfg src/u1.s -o build/u1.prg

clean :
	rm -Rf build
	find . -name '*.o' -delete
	