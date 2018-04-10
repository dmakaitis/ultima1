all: viewbitmap

viewbitmap-objects = viewbitmap.o bitmaputils.o
viewbitmap: $(viewbitmap-objects)
	c++ -o $@ $(viewbitmap-objects) -lpng

clean:
	rm viewbitmap *.o
