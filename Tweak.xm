#include <substrate.h>
#include <UIKit/UIStatusBar.h>
#import <CoreGraphics/CoreGraphics.h>
#include <SpringBoard/SpringBoard.h>


@interface UIScreen (Priv)
- (UIEdgeInsets)_sceneSafeAreaInsets;
@end


static BOOL properFixedBounds = YES;
static BOOL properBounds = NO;



static BOOL (*old__IS_D2x)();
static BOOL (*old___UIScreenHasDevicePeripheryInsets)();

BOOL _IS_D2x() {
	return YES;
}
BOOL __UIScreenHasDevicePeripheryInsets() {
	return YES;
}

@interface UIStatusBarForegroundView : UIView
@end

@interface _UIStatusBar
+ (void)setDefaultVisualProviderClass:(Class)classOb;
+ (void)setForceSplit:(BOOL)arg1;
@end

@interface _UIStatusBarVisualProvider_iOS : NSObject
+ (CGSize)intrinsicContentSizeForOrientation:(NSInteger)orientation;
@end


%hook _UIStatusBar
+ (BOOL)forceSplit {
	return NO;
}

+ (void)setForceSplit:(BOOL)arg1 {
	%orig(NO);
}

+ (void)setDefaultVisualProviderClass:(Class)classOb {
	%orig(NSClassFromString(@"_UIStatusBarVisualProvider_iOS"));
}

+(void)initialize {
		[NSClassFromString(@"_UIStatusBar") setForceSplit:NO];
		[NSClassFromString(@"_UIStatusBar") 
setDefaultVisualProviderClass:NSClassFromString(@"_UIStatusBarVisualProvider_iOS")];
}

-(void)_prepareVisualProviderIfNeeded {
	%orig;
	[NSClassFromString(@"_UIStatusBar") setForceSplit:NO];
	[NSClassFromString(@"_UIStatusBar") setDefaultVisualProviderClass: NSClassFromString(@"_UIStatusBarVisualProvider_iOS")];
	
}

+ (CGFloat)heightForOrientation:(NSInteger)orientation {
	return [NSClassFromString(@"_UIStatusBarVisualProvider_iOS") intrinsicContentSizeForOrientation:orientation].height;
}

%end

%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
	return NSClassFromString(@"_UIStatusBarVisualProvider_iOS");
}
//+ (CGSize)intrinsicContentSizeForOrientation:(NSInteger)orientation {
//	return CGSizeMake(1125,128);
//}
%end


%hook UIStatusBarForegroundView
- (void)setFrame:(CGRect)frame {
    //frame.size.width -= 25;
    //frame.origin.x = 3;
    frame.origin.y = 16.0;
    //frame.size.height = 64;
    %orig(frame);
}
-(CGRect)frame {
    CGRect result = %orig;
    result.origin.y = 16.0;
    //result.size.height = 64;
    return result;
}
-(void)layoutSubviews {
    UIStatusBar *_statusBar = (UIStatusBar *)self.superview;
    CGRect statusBarFrame = _statusBar.frame;
    //statusBarFrame.size.width -= 25;
    //statusBarFrame.origin.x = 3;
    statusBarFrame.origin.y = 16.0;
    //statusBarFrame.size.height = 64;
    _statusBar.frame = statusBarFrame;
    %orig();
}
%end

%group AppStuff
%hook UINavigationController
- (void)_setUseCurrentStatusBarHeight:(BOOL)arg1 {
	%orig(YES);
}
%end

%hook UIApplication
- (double)statusBarHeight {
	return 64.0;
}
%end
%end

//%hook UIStatusBarWindow
//- (CGRect)statusBarWindowFrame {
//	CGRect frame = %orig;
//	frame.size.height += 48;
//	return frame;
//}
//%end


//%hook _UIStatusBar
//- (void)setFrame:(CGRect)frame {
//    frame.origin.y = -14;
//    frame.size.height = newSBHeight;
//    %orig(frame);
//}
//- (CGRect)bounds {
//    CGRect frame = %orig;
//    frame.origin.y = -14;
//    frame.size.height = newSBHeight;
//    return frame;
//}
//%end

%hook UIStatusBar_Base
+ (BOOL)forceModern {
	return NO;
}
+ (Class)_statusBarImplementationClass {
	return NSClassFromString(@"UIStatusBar");
}
//- (BOOL)isDoubleHeight {
//    return YES;
//}
%end


static void Loader(){
		MSHookFunction(((void*)MSFindSymbol(NULL, "_IS_D2x")),(void*)_IS_D2x, (void**)&old__IS_D2x);
        MSHookFunction(((void*)MSFindSymbol(NULL, "__UIScreenHasDevicePeripheryInsets")),(void*)__UIScreenHasDevicePeripheryInsets, (void**)&old___UIScreenHasDevicePeripheryInsets);
}

%hook UIScreen
- (BOOL)_wantsWideContentMargins {
	return NO;
}
%end

%hook UIScreen
- (UIEdgeInsets)_sceneSafeAreaInsets {
	UIEdgeInsets orig = %orig;
	if (orig.bottom == 34) orig.bottom = 20;
	orig.top = 72;
	return orig;
}
%end
%hook UIRemoteKeyboardWindowHosted
- (UIEdgeInsets)safeAreaInsets {
	UIEdgeInsets orig = %orig;
	if (NSClassFromString(@"JCPBarmojiCollectionView")) {
		orig.bottom = 60;
	} else {
		orig.bottom = 44;
	}
	return orig;
}
%end

%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
	UIEdgeInsets orig = %orig;
	if (orig.bottom == 75) {
		if (NSClassFromString(@"JCPBarmojiCollectionView")) {
			orig.bottom = 60;
		} else {
			orig.bottom = 44;
		}
	}
	if (orig.left == 75) orig.left = 17;
	if (orig.right == 75) orig.right = 17;
	return orig;
}

+(UIEdgeInsets)deviceSpecificStaticHitBufferForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
	UIEdgeInsets orig = %orig;
	if (orig.bottom == 17) orig.bottom = 0;
	return orig;
}
%end

@interface UIKeyboardDockView : UIView
@end

%hook UIKeyboardDockView

- (CGRect)bounds {
	CGRect bounds = %orig;
	if (NSClassFromString(@"JCPBarmojiCollectionView")) {
		bounds.size.height += 4;
	} else {
		bounds.size.height += 15;
	}
	return bounds;
}
- (void)layoutSubviews {
	%orig;

	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:NSClassFromString(@"JCPBarmojiCollectionView")]) {
			CGRect frame = subview.frame;
			frame.origin.y = self.frame.size.height - 17 - frame.size.height;
			subview.frame = frame;
		}
	}
}
%end

%hook UIInputWindowController
- (UIEdgeInsets)_viewSafeAreaInsetsFromScene {
	if (NSClassFromString(@"JCPBarmojiCollectionView")) {
		return UIEdgeInsetsMake(0,0,60,0);
	} else {
		return UIEdgeInsetsMake(0,0,44,0);
	}
}
%end





%group ModifyBounds
%hook UIScreen
- (CGRect)nativeBounds {
	CGRect bounds = %orig;
	if (bounds.size.height > bounds.size.width) {
		bounds.size.height = 2436;
		bounds.size.width = 1125;
	} else { 
		bounds.size.width = 2436;
		bounds.size.height = 1125;
	}
	return bounds;
}
%end


%hook UIView
- (CGRect)_convertViewPointToSceneSpaceForKeyboard:(CGRect)keyboard {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGRect orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}
%end

%hook _UIScreenRectangularBoundingPathUtilities
- (void)_loadBezierPathsForScreen:(id)screen {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		%orig;
		properFixedBounds = YES;
		properBounds = NO;
	} else {
		%orig;
	}
}
%end

%hook _UIPreviewInteractionDecayTouchForceProvider
- (id)initWithTouchForceProvider:(id)thing {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		id orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}
%end

%hook UIPopoverPresentationController
- (CGRect)_sourceRectInContainerView {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGRect orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}
%end

%hook UIPanelBorderView
- (void)layoutSubviews {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		%orig;
		properFixedBounds = YES;
		properBounds = NO;
	} else {
		%orig;
	}
}
%end

%hook UIPeripheralHost
+ (BOOL)pointIsWithinKeyboardContent:(CGPoint)point {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		BOOL orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}

- (void)setInputViews:(id)stuff animationStyle:(id)stuff1 {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		%orig;
		properFixedBounds = YES;
		properBounds = NO;
	} else {
		%orig;
	}
}
%end


@interface _UIScreenFixedCoordinateSpace : NSObject
- (UIScreen *)_screen;
@end

%hook _UIScreenFixedCoordinateSpace
- (CGRect)bounds {
	CGRect bounds = %orig;
	if ([self _screen] == [UIScreen mainScreen] && !properFixedBounds) {
		if (bounds.size.height > bounds.size.width) {
			bounds.size.height = 812;
			bounds.size.width = 375;
		} else { 
			bounds.size.width = 812;
			bounds.size.height = 375;
		}
	}
	return bounds;
}

-(CGRect)convertRect:(CGRect)arg1 toCoordinateSpace:(id)arg2 {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGRect orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}

-(CGRect)convertRect:(CGRect)arg1 fromCoordinateSpace:(id)arg2 {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGRect orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}

-(CGPoint)convertPoint:(CGPoint)arg1 toCoordinateSpace:(id)arg2 {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGPoint orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}

-(CGPoint)convertPoint:(CGPoint)arg1 fromCoordinateSpace:(id)arg2 {
	if (!properBounds) {
		properFixedBounds = YES;
		properBounds = YES;
		CGPoint orig = %orig;
		properFixedBounds = YES;
		properBounds = NO;
		return orig;
	} else {
		return %orig;
	}
}
%end



%hook UIScreenMode
- (CGSize)size {
	return CGSizeMake(1125,2436);
}
%end

%hook UIWindow
- (UIEdgeInsets)safeAreaInsets {
	UIEdgeInsets orig = %orig;
	if (orig.top > 30) orig.bottom = 30;
	else {
		if (orig.left < 10) orig.left = 20;
		else if (orig.right < 10) orig.right = 20;
	} 
	return orig;
}
%end

%hook UIScrollView
- (UIEdgeInsets)adjustedContentInset {
	UIEdgeInsets orig = %orig;
	if (orig.top == 64) orig.top = 88;
	if (orig.top == 32) orig.top = 0;
	return orig;
}
%end
%end
// END OF MODIFYBOUNDS GROUP



%group ExtraStuff
%hook UIScreen
+ (UIEdgeInsets)sc_safeAreaInsets {
	UIEdgeInsets orig = %orig;
	orig.top = 60;
	orig.bottom = [[NSClassFromString(@"UIScreen") mainScreen] _sceneSafeAreaInsets].bottom;
	return orig;
}
+ (UIEdgeInsets)sc_safeAreaInsetsForInterfaceOrientation:(UIInterfaceOrientation)orientation {
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		UIEdgeInsets insets = [[NSClassFromString(@"UIScreen") mainScreen] _sceneSafeAreaInsets];
		return UIEdgeInsetsMake(0, insets.top, 0, insets.bottom);
	} else {
		UIEdgeInsets orig = %orig;
		orig.top = 0;
		orig.bottom = [[NSClassFromString(@"UIScreen") mainScreen] _sceneSafeAreaInsets].bottom;
		return orig;
	}
}
+ (UIEdgeInsets)sc_visualSafeInsets {
 	UIEdgeInsets orig = %orig;
	orig.top = 0;
	orig.bottom = [[NSClassFromString(@"UIScreen") mainScreen] _sceneSafeAreaInsets].bottom;
	return orig;
}
+ (UIEdgeInsets)sc_filterSafeInsets {
 	UIEdgeInsets insets = [[NSClassFromString(@"UIScreen") mainScreen] _sceneSafeAreaInsets];
	return UIEdgeInsetsMake(insets.top,0,0,0);
}
+ (UIEdgeInsets)sc_headerSafeInsets {
	UIEdgeInsets insets = [[NSClassFromString(@"UIScreen") mainScreen] _sceneSafeAreaInsets];
	return UIEdgeInsetsMake(insets.top,0,0,0);
}
+ (UIEdgeInsets)sc_safeFooterButtonInset {
	UIEdgeInsets insets = [[NSClassFromString(@"UIScreen") mainScreen] _sceneSafeAreaInsets];
	UIEdgeInsetsMake(0,0,insets.bottom,0);
	return %orig;
}
+ (CGFloat)sc_headerHeight {
	CGFloat orig = %orig;
	return orig + 54;
}
%end
%end



%group ExtremeButts
%hook UIScreen
- (CGRect)bounds {
	CGRect bounds = %orig;
	if (bounds.size.height > bounds.size.width) {
		bounds.size.height = 812;
	} else { 
		bounds.size.width = 812;
	}
	return bounds;
}
%end
%end





%ctor {
	NSString *mainIdentifier = [NSBundle mainBundle].bundleIdentifier;


	if ([mainIdentifier isEqualToString:@"com.apple.springboard"]) {
		// do springboard thing I guess
	}
	else if ([mainIdentifier isEqualToString:@"com.apple.MobilePhone"]) {
		%init(AppStuff)
		%init(ExtraStuff)
	}
	else {
		%init(ExtremeButts)
		%init(ModifyBounds)
	}
	
	Loader();

	%init;
	[NSClassFromString(@"_UIStatusBar") setDefaultVisualProviderClass: NSClassFromString(@"_UIStatusBarVisualProvider_iOS")];
}
