#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include <sys/param.h>

int main(int argc, char **argv) {

	int ret;

	int timeout;
	if (argc < 2) {
		puts("Usage: cat-loop [FILE] [OPTIONAL TIMEOUT]");
		exit(1);
	}
	else if (argc > 2) {
		int ret = sscanf(argv[2], "%d", &timeout);
		if (ret != 1 || timeout < 1) {
			puts("Invalid timeout argument");
			exit(1);
		}
	}
	else {
		timeout = 2;
	}


	while (1) {
		FILE* fp = fopen(argv[1], "r");
		if (fp == NULL) {
			puts("Invalid file path");
			exit(1);
		}
		char c;

		while ((c = fgetc(fp)) != EOF) {
			putchar(c);
		}

		fflush(stdout);
		fclose(fp);
		sleep(timeout);
	}

	return 0;
}
