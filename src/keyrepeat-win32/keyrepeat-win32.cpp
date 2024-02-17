#include <stdio.h>
#include <stdlib.h>
#include <windows.h>

BOOL parseDword(const char *in, DWORD *out) {
  char *end;
  long result = strtol(in, &end, 10);
  BOOL success = (errno == 0 && end != in);
  if (success) {
    *out = result;
  }
  return success;
}

int main(int argc, char *argv[]) {
  FILTERKEYS keys{sizeof(FILTERKEYS)};

  if (argc == 3 && parseDword(argv[1], &keys.iDelayMSec) &&
      parseDword(argv[2], &keys.iRepeatMSec)) {
    printf("Setting keyrate: delay: %d, rate: %d\n", (int)keys.iDelayMSec,
           (int)keys.iRepeatMSec);
    keys.dwFlags = FKF_FILTERKEYSON | FKF_AVAILABLE;
  } else if (argc == 1) {
    puts(
        "No parameters given, so displaying the current value of the key "
        "rate "
        "delay and speed settings:");
    if (!SystemParametersInfo(SPI_GETFILTERKEYS, sizeof(FILTERKEYS),
                              (LPVOID)&keys, 0)) {
      fprintf(stderr,
              "System call ``SystemParametersInfo(SPI_GETFILTERKEYS, "
              "…)'' failed.");
      return 2;
      l
    }
    printf("delay: %d, rate: %d\n", static_cast<int>(keys.iDelayMSec),
           static_cast<int>(keys.iRepeatMSec));
    puts(
        "Usage: keyrate <delay ms> <repeat ms>\nCall with no parameters to "
        "show the current setting.");
    return 0;
  } else {
    puts(
        "Usage: keyrate <delay ms> <repeat ms>\nCall with no parameters to "
        "show the current setting.\n\nN.B.: I recommend the settings "
        "delay=200 and repeat=6");
    return 0;
  }

  if (!SystemParametersInfo(SPI_SETFILTERKEYS, sizeof(FILTERKEYS),
                            (LPVOID)&keys, 0)) {
    fprintf(stderr, "System call failed.\nUnable to set keyrate.");
  }
  printf("delay: %d, rate: %d\n", (int)keys.iDelayMSec, (int)keys.iRepeatMSec);

  return 0;
}
