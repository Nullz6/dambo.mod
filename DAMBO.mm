#import <UIKit/UIKit.h>

__attribute__((constructor)) static void init() {
    // Wait on the main thread for 5 seconds to ensure the game is fully loaded
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            UIWindow *window = nil;
            if (@available(iOS 13.0, *)) {
                for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                    if ([scene isKindOfClass:[UIWindowScene class]]) {
                        window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
                        break;
                    }
                }
            }
            
            if (window) {
                // Create a massive purple window that CANNOT be missed
                window.windowLevel = UIWindowLevelAlert + 10000;
                window.backgroundColor = [UIColor purpleColor];
                window.rootViewController = [UIViewController new];
                [window makeKeyAndVisible];
                
                UILabel *label = [[UILabel alloc] initWithFrame:window.bounds];
                label.text = @"DAMBO IS ALIVE";
                label.textColor = [UIColor whiteColor];
                label.font = [UIFont boldSystemFontOfSize:40];
                label.textAlignment = NSTextAlignmentCenter;
                [window.rootViewController.view addSubview:label];
            } else {
                NSLog(@"DAMBO: No window scene found!");
            }
        });
    });
}