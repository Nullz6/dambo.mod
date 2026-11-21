#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#include <dlfcn.h>

BOOL aimEnabled = YES;
BOOL guidelineEnabled = YES;
BOOL skinchangerEnabled = NO;

UIWindow* getKeyWindow(void) {
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                    if (window.isKeyWindow) return window;
                }
            }
        }
    }
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [[UIApplication sharedApplication].windows firstObject];
    #pragma clang diagnostic pop
}

@interface DamboToggle : UIView
@property (nonatomic, strong) UIView *pill;
@property (nonatomic, strong) UIView *thumb;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, copy) void (^onToggle)(BOOL);
- (instancetype)initWithFrame:(CGRect)frame isOn:(BOOL)on;
@end

@implementation DamboToggle
- (instancetype)initWithFrame:(CGRect)frame isOn:(BOOL)on {
    self = [super initWithFrame:frame];
    self.isOn = on;
    self.pill = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 46, 26)];
    self.pill.backgroundColor = on ? [UIColor colorWithRed:0.6 green:0.1 blue:0.9 alpha:1.0] : [UIColor colorWithWhite:0.25 alpha:1.0];
    self.pill.layer.cornerRadius = 13;
    [self addSubview:self.pill];
    
    self.thumb = [[UIView alloc] initWithFrame:CGRectMake(on ? 22 : 2, 2, 22, 22)];
    self.thumb.backgroundColor = [UIColor whiteColor];
    self.thumb.layer.cornerRadius = 11;
    self.thumb.layer.shadowColor = [UIColor blackColor].CGColor;
    self.thumb.layer.shadowOffset = CGSizeMake(0, 2);
    self.thumb.layer.shadowOpacity = 0.4;
    [self addSubview:self.thumb];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggle)];
    [self addGestureRecognizer:tap];
    return self;
}
- (void)toggle {
    self.isOn = !self.isOn;
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.pill.backgroundColor = self.isOn ? [UIColor colorWithRed:0.6 green:0.1 blue:0.9 alpha:1.0] : [UIColor colorWithWhite:0.25 alpha:1.0];
        self.thumb.frame = CGRectMake(self.isOn ? 22 : 2, 2, 22, 22);
    } completion:nil];
    if (self.onToggle) self.onToggle(self.isOn);
}
@end

@interface DamboMenu : UIView
@end

@implementation DamboMenu
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blur.frame = self.bounds;
    blur.layer.cornerRadius = 16;
    blur.clipsToBounds = YES;
    [self addSubview:blur];
    
    self.layer.borderColor = [UIColor colorWithRed:0.8 green:0.2 blue:1.0 alpha:0.6].CGColor;
    self.layer.borderWidth = 1.2;
    self.layer.cornerRadius = 16;
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
    header.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.4];
    [self addSubview:header];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 200, 44)];
    title.text = @"DAMBO PREMIUM";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBlack];
    [header addSubview:title];
    
    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    close.frame = CGRectMake(frame.size.width - 40, 7, 30, 30);
    [close setTitle:@"✕" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor colorWithRed:1 green:0.3 blue:0.3 alpha:1] forState:UIControlStateNormal];
    [close addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:close];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [header addGestureRecognizer:pan];
    
    CGFloat y = 60;
    [self addRow:@"Aim Assist" y:y tag:1 on:aimEnabled];
    y += 45;
    [self addRow:@"Extended Guideline" y:y tag:2 on:guidelineEnabled];
    y += 45;
    [self addRow:@"Skinchanger" y:y tag:3 on:skinchangerEnabled];
    y += 55;
    
    UIButton *apply = [UIButton buttonWithType:UIButtonTypeSystem];
    apply.frame = CGRectMake(16, y, frame.size.width - 32, 36);
    apply.backgroundColor = [UIColor colorWithRed:0.5 green:0.1 blue:0.8 alpha:0.8];
    apply.layer.cornerRadius = 8;
    [apply setTitle:@"APPLY CONFIG" forState:UIControlStateNormal];
    [apply setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    apply.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    [self addSubview:apply];
    
    return self;
}

- (void)addRow:(NSString *)text y:(CGFloat)y tag:(NSInteger)tag on:(BOOL)on {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, y, 140, 26)];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    [self addSubview:label];
    
    DamboToggle *toggle = [[DamboToggle alloc] initWithFrame:CGRectMake(self.frame.size.width - 60, y, 46, 26) isOn:on];
    toggle.onToggle = ^(BOOL state) {
        if (tag == 1) aimEnabled = state;
        if (tag == 2) guidelineEnabled = state;
        if (tag == 3) skinchangerEnabled = state;
    };
    [self addSubview:toggle];
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.superview];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self.superview];
}
@end

// Pure Objective-C injection without Substrate
__attribute__((constructor)) static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = getKeyWindow();
        if (!window) return;
        
        DamboMenu *menu = [[DamboMenu alloc] initWithFrame:CGRectMake(20, 80, 240, 280)];
        [window addSubview:menu];
        
        CAShapeLayer *aimLayer = [CAShapeLayer layer];
        aimLayer.frame = window.bounds;
        aimLayer.strokeColor = [UIColor greenColor].CGColor;
        aimLayer.fillColor = [UIColor clearColor].CGColor;
        aimLayer.lineWidth = 2.0;
        aimLayer.lineDashPattern = @[@6, @4];
        [window.layer addSublayer:aimLayer];
        
        [NSTimer scheduledTimerWithTimeInterval:0.016 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if (!aimEnabled) {
                aimLayer.path = nil;
                return;
            }
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(window.bounds.size.width/2, window.bounds.size.height - 100)];
            [path addLineToPoint:CGPointMake(window.bounds.size.width/2 + 50, window.bounds.size.height - 300)];
            aimLayer.path = path.CGPath;
        }];
    });
}