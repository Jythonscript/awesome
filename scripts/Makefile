CFLAGS:=-O2

all: cpu-usage cat-loop temperature

cpu-usage: cpu-usage.c
	$(CC) $(CFLAGS) -o $@ $^

cat-loop: cat-loop.c
	$(CC) $(CFLAGS) -o $@ $^

temperature: temperature.c
	$(CC) $(CFLAGS) -lsensors -o $@ $^

clean:
	rm -rf cpu-usage cat-loop temperature
