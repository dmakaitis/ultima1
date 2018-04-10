all: viewbitmap

viewbitmap-objects = viewbitmap.o bitmaputils.o
viewbitmap: $(viewbitmap-objects)
	c++ -o $@ $(viewbitmap-objects)

clean:
	rm viewbitmap *.o
