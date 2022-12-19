#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include <sys/param.h>

int main(int argc, char **argv) {

	int ret;
	int user, nice, system, idle, iowait;
	int total, active, lasttotal, lastactive;

	int timeout;
	if (argc > 1) {
		int ret = sscanf(argv[1], "%d", &timeout);
		if (ret != 1 || timeout < 1) {
			puts("Invalid argument");
			exit(1);
		}
	}
	else {
		timeout = 2;
	}

	lasttotal = 0;
	lastactive = 0;

	while (1) {
		FILE* fp = fopen("/proc/stat", "r");

		ret = fscanf(fp, "cpu  %d %d %d %d %d", &user, &nice, &system, &idle, &iowait);
		if (ret != 5) {
			fprintf(stderr, "Invalid file format\n");
			exit(1);
		}
		active = user + nice + system;
		total = active + idle + iowait;

		if (lasttotal > 0 && lastactive > 0) {
			double dtotal = total - lasttotal;
			double dactive = active - lastactive;
			double usage = (dactive / dtotal) * 100;
			printf("%.6f\n", usage);
			fflush(stdout);
		}

		lasttotal = total;
		lastactive = active;
		fclose(fp);
		sleep(timeout);
	}

	return 0;
}
