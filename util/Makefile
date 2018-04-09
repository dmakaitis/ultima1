all: viewsprite viewbitmap viewfont

viewsprite-objects = viewsprite.o bitmaputils.o
viewsprite: $(viewsprite-objects)
	c++ -o $@ $(viewsprite-objects)

viewbitmap-objects = viewbitmap.o bitmaputils.o
viewbitmap: $(viewbitmap-objects)
	c++ -o $@ $(viewbitmap-objects)

viewfont-objects = viewfont.o bitmaputils.o
viewfont: $(viewfont-objects)
	c++ -o $@ $(viewfont-objects)

clean:
	rm *.o
