CFLAGS:=-O2

all: cpu-usage cat-loop

cpu-usage: cpu-usage.c
	$(CC) $(CFLAGS) -o $@ $^

cat-loop: cat-loop.c
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -rf cpu-usage cat-loop
