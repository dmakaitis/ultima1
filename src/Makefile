all : u1.prg hello.prg lo.prg in.prg

u1.prg : u1.o u1.cfg
	ld65 -C u1.cfg u1.o -o $@ -vm -m u1.map

hello.prg : hello.o hello.cfg
	ld65 -C hello.cfg hello.o -o $@ -vm -m hello.map

lo.prg : lo.o lo.cfg
	ld65 -C lo.cfg lo.o -o $@ -vm -m lo.map

in.prg : in.o in.cfg
	ld65 -C in.cfg in.o -o $@ -vm -m in.map

hello_1541_bootstrap.prg : hello_1541_bootstrap.o hello_1541_bootstrap.cfg
	ld65 -C hello_1541_bootstrap.cfg hello_1541_bootstrap.o -o $@ -vm -m hello_1541_bootstrap.map

hello_1541_fastload.prg : hello_1541_fastload.o hello_1541_fastload.cfg
	ld65 -C hello_1541_fastload.cfg hello_1541_fastload.o -o $@ -vm -m hello_1541_fastload.map

hello.o : hello.s hello_1541_bootstrap.prg hello_1541_fastload.prg
	ca65 $<
	
.s.o :
	ca65 $<

clean :
	find . -name  '*.o' -delete
	find . -name  '*.prg' -delete
	find . -name  '*.map' -delete
