#include <sensors/sensors.h>
#include <stddef.h>
#include <assert.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char **argv) {

	int timeout;
	int chip_number;
	int ret;
	double value;

	const sensors_chip_name *chip;
	sensors_chip_name search_chip;

	if (argc == 3) {
		int ret = sscanf(argv[2], "%d", &timeout);
		if (ret != 1 || timeout < 1) {
			puts("Invalid argument");
			exit(1);
		}
	}
	else if (argc == 2) {
		timeout = 2;
	}
	else {
		puts("Usage: ./temperature [CHIP_NAME] [TIMEOUT]");
		exit(1);
	}

	ret = sensors_init(NULL);
	if (ret) {
		sensors_cleanup();
		return 1;
	}

	search_chip.prefix = argv[1];
	search_chip.bus.type = SENSORS_BUS_TYPE_ANY;
	search_chip.bus.nr = SENSORS_BUS_NR_ANY;
	search_chip.addr = SENSORS_CHIP_NAME_ADDR_ANY;
	chip_number = 0;
	chip = sensors_get_detected_chips(&search_chip, &chip_number);

	while (1) {
		ret = sensors_get_value(chip, 0, &value);
		if (ret) {
			break;
		}
		printf("%lf\n", value);
		fflush(stdout);
		sleep(timeout);
	}

	sensors_cleanup();
	return 0;
}
