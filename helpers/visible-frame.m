#import <Cocoa/Cocoa.h>

int main(int argc, char **argv) {
    if (argc != 3) return 64;

    @autoreleasepool {
        CGFloat quartzX = strtod(argv[1], NULL);
        CGFloat quartzY = strtod(argv[2], NULL);
        CGFloat mainHeight = NSScreen.screens.firstObject.frame.size.height;
        NSPoint appKitPoint = NSMakePoint(quartzX, mainHeight - quartzY);
        NSScreen *target = nil;

        for (NSScreen *screen in NSScreen.screens) {
            if (NSPointInRect(appKitPoint, screen.frame)) {
                target = screen;
                break;
            }
        }

        if (target == nil) return 1;

        NSRect visible = target.visibleFrame;
        CGFloat quartzVisibleY = mainHeight - NSMaxY(visible);
        printf("{\"x\":%.0f,\"y\":%.0f,\"w\":%.0f,\"h\":%.0f}\n",
               visible.origin.x, quartzVisibleY,
               visible.size.width, visible.size.height);
    }

    return 0;
}
