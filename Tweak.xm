#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

static NSString * const kCW3BundleIdentifier =
    @"com.gamevil.cartoonwars3.ios.apple.global.normal";

static BOOL CW3IsTargetApplication(void) {
    NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;
    return [bundleID isEqualToString:kCW3BundleIdentifier];
}

@interface CW3Overlay : NSObject
@property (nonatomic, weak) UIWindow *hostWindow;
@property (nonatomic, strong) UIButton *floatingButton;
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) UILabel *statusLabel;
+ (instancetype)shared;
- (void)installIfPossible;
- (void)applicationDidBecomeActive:(NSNotification *)notification;
@end

@implementation CW3Overlay

+ (instancetype)shared {
    static CW3Overlay *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CW3Overlay new];
    });
    return instance;
}

- (UIWindow *)activeWindow {
    UIApplication *application = UIApplication.sharedApplication;

    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in application.connectedScenes) {
            if (scene.activationState != UISceneActivationStateForegroundActive) {
                continue;
            }
            if (![scene isKindOfClass:UIWindowScene.class]) {
                continue;
            }

            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    return window;
                }
            }
            if (windowScene.windows.count > 0) {
                return windowScene.windows.firstObject;
            }
        }
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (application.keyWindow) {
        return application.keyWindow;
    }
#pragma clang diagnostic pop

    for (UIWindow *window in application.windows) {
        if (window.isKeyWindow) {
            return window;
        }
    }
    return application.windows.firstObject;
}

- (UILabel *)labelWithText:(NSString *)text
                      frame:(CGRect)frame
                       size:(CGFloat)size
                      color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size weight:UIFontWeightSemibold];
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

- (void)installIfPossible {
    if (!CW3IsTargetApplication()) {
        return;
    }

    UIWindow *window = [self activeWindow];
    if (!window) {
        return;
    }

    if (self.floatingButton.superview == window) {
        return;
    }

    self.hostWindow = window;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(18.0, 120.0, 56.0, 56.0);
    button.backgroundColor = [UIColor colorWithRed:0.13 green:0.35 blue:0.82 alpha:0.96];
    button.layer.cornerRadius = 28.0;
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.7].CGColor;
    [button setTitle:@"CW3" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [button addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
    [window addSubview:button];
    self.floatingButton = button;

    [self buildPanelInWindow:window];
}

- (void)buildPanelInWindow:(UIWindow *)window {
    CGFloat width = MIN(350.0, window.bounds.size.width - 24.0);
    CGFloat height = 410.0;
    CGFloat x = (window.bounds.size.width - width) / 2.0;
    CGFloat y = MAX(48.0, (window.bounds.size.height - height) / 2.0);

    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    panel.backgroundColor = [UIColor colorWithWhite:0.98 alpha:0.98];
    panel.layer.cornerRadius = 16.0;
    panel.layer.borderWidth = 1.0;
    panel.layer.borderColor = [UIColor colorWithWhite:0.75 alpha:1.0].CGColor;
    panel.layer.shadowColor = UIColor.blackColor.CGColor;
    panel.layer.shadowOpacity = 0.24;
    panel.layer.shadowRadius = 14.0;
    panel.layer.shadowOffset = CGSizeMake(0.0, 5.0);
    panel.hidden = YES;

    [panel addSubview:[self labelWithText:@"CW3 Unit Editor"
                                    frame:CGRectMake(16, 14, width - 72, 28)
                                     size:19
                                    color:UIColor.blackColor]];

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.frame = CGRectMake(width - 46, 10, 36, 34);
    [closeButton setTitle:@"✕" forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [closeButton addTarget:self action:@selector(closePanel) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:closeButton];

    UILabel *subtitle = [self labelWithText:@"Prototype · chưa kết nối dữ liệu game"
                                      frame:CGRectMake(16, 45, width - 32, 22)
                                       size:11
                                      color:[UIColor darkGrayColor]];
    [panel addSubview:subtitle];

    self.statusLabel = [self labelWithText:@"Inventory: chưa được phân tích"
                                     frame:CGRectMake(16, 76, width - 32, 38)
                                      size:12
                                     color:[UIColor colorWithRed:0.65 green:0.25 blue:0.08 alpha:1.0]];
    [panel addSubview:self.statusLabel];

    NSArray<NSString *> *statNames = @[
        @"Movement Speed",
        @"Attack Speed",
        @"Damage",
        @"Level (1–30)"
    ];

    CGFloat rowY = 125.0;
    for (NSString *name in statNames) {
        UILabel *nameLabel = [self labelWithText:name
                                          frame:CGRectMake(16, rowY, width * 0.48, 32)
                                           size:13
                                          color:UIColor.blackColor];
        [panel addSubview:nameLabel];

        UITextField *valueField = [[UITextField alloc] initWithFrame:CGRectMake(width * 0.54, rowY, width * 0.40 - 12, 32)];
        valueField.borderStyle = UITextBorderStyleRoundedRect;
        valueField.font = [UIFont systemFontOfSize:12];
        valueField.placeholder = @"Chưa đọc từ game";
        valueField.enabled = NO;
        valueField.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
        [panel addSubview:valueField];
        rowY += 48.0;
    }

    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    refreshButton.frame = CGRectMake(16, 324, width - 32, 34);
    refreshButton.backgroundColor = [UIColor colorWithRed:0.13 green:0.35 blue:0.82 alpha:1.0];
    refreshButton.layer.cornerRadius = 8.0;
    [refreshButton setTitle:@"Refresh Inventory" forState:UIControlStateNormal];
    [refreshButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    refreshButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [refreshButton addTarget:self action:@selector(refreshInventoryPlaceholder) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:refreshButton];

    UIButton *applyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    applyButton.frame = CGRectMake(16, 366, (width - 40) / 2.0, 30);
    applyButton.backgroundColor = [UIColor colorWithWhite:0.83 alpha:1.0];
    applyButton.layer.cornerRadius = 7.0;
    [applyButton setTitle:@"Apply (locked)" forState:UIControlStateNormal];
    [applyButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    applyButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    applyButton.enabled = NO;
    [panel addSubview:applyButton];

    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    resetButton.frame = CGRectMake(24 + (width - 40) / 2.0, 366, (width - 40) / 2.0, 30);
    resetButton.backgroundColor = [UIColor colorWithWhite:0.83 alpha:1.0];
    resetButton.layer.cornerRadius = 7.0;
    [resetButton setTitle:@"Reset (locked)" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    resetButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    resetButton.enabled = NO;
    [panel addSubview:resetButton];

    [window addSubview:panel];
    self.panel = panel;
}

- (void)togglePanel {
    if (!self.panel) {
        [self installIfPossible];
    }
    self.panel.hidden = !self.panel.hidden;
}

- (void)closePanel {
    self.panel.hidden = YES;
}

- (void)refreshInventoryPlaceholder {
    self.statusLabel.text =
        @"Chưa có Inventory adapter. Cần xác định model/class unit trong CW3 trước.";
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self installIfPossible];
}

@end

__attribute__((constructor))
static void CW3UnitEditorInitialize(void) {
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!CW3IsTargetApplication()) {
                return;
            }

            CW3Overlay *overlay = [CW3Overlay shared];
            [[NSNotificationCenter defaultCenter] addObserver:overlay
                                                     selector:@selector(applicationDidBecomeActive:)
                                                         name:UIApplicationDidBecomeActiveNotification
                                                       object:nil];
            [overlay installIfPossible];
        });
    }
}
