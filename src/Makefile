all : u1.prg hello.prg

u1.prg : u1.o u1.cfg
	ld65 -C u1.cfg u1.o -o $@

hello.prg : hello.o hello.cfg
	ld65 -C hello.cfg hello.o -o $@

.s.o :
	ca65 $<

clean :
	find . -name  '*.o' -delete
	find . -name  '*.prg' -delete
