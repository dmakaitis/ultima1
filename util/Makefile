all: viewsprite viewbitmap

viewsprite: viewsprite.o bitmaputils.o
	c++ -o viewsprite viewsprite.o bitmaputils.o

viewbitmap: viewbitmap.o bitmaputils.o
	c++ -o viewbitmap viewbitmap.o bitmaputils.o

clean:
	rm *.o
