#import <UIKit/UIKit.h>

// STATIC keeps this window alive in memory forever
static UIWindow *damboWindow = nil;

__attribute__((constructor)) static void init() {
    // Wait 5 seconds for the game and Fluorite to finish loading
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // Find the active window scene
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    damboWindow = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
                    break;
                }
            }
        }
        
        // Fallback for older iOS
        if (!damboWindow) {
            damboWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
        
        // Force it above EVERYTHING (Fluorite, alerts, keyboard)
        damboWindow.windowLevel = UIWindowLevelAlert + 10000;
        damboWindow.backgroundColor = [UIColor purpleColor];
        damboWindow.rootViewController = [UIViewController new];
        
        // Add massive text so we know it's there
        UILabel *label = [[UILabel alloc] initWithFrame:damboWindow.bounds];
        label.text = @"DAMBO IS ALIVE";
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:40];
        label.textAlignment = NSTextAlignmentCenter;
        [damboWindow.rootViewController.view addSubview:label];
        
        // Show it
        [damboWindow makeKeyAndVisible];
    });
}