.PHONY = default clean

default: helpers.c
	gcc helpers.c -o helpers.so -shared -fpic -Wall $(pkg-config lua5.3) -lrt -export-dynamic
	cp helpers.so ..

clean:
	rm -f helpers.so
