#include <ApplicationServices/ApplicationServices.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    if (argc != 3) return 64;
    CGPoint point = CGPointMake(strtod(argv[1], NULL), strtod(argv[2], NULL));
    CGWarpMouseCursorPosition(point);
    CGAssociateMouseAndMouseCursorPosition(true);
    return 0;
}
