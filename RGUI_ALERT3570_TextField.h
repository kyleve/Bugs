//
//  RGUI_ALERT3570_TextField.h
//  RegisterUI
//


#import <UIKit/UIKit.h>


typedef void (^RGUI_ALERT3570_TextFieldFailedToApplyFixBlock)(NSError *_Nonnull error);

extern NSString *_Nonnull const RGUI_ALERT3570_ErrorDomain;

typedef NS_ENUM(NSInteger, RGUI_ALERT3570_ErrorCode) {
    /// An exception was thrown when attempting to apply the fix
    RGUI_ALERT3570_ErrorCodeException = 1,

    /// After applying the fix, text fields are still over-retained
    RGUI_ALERT3570_ErrorCodeNoFix = 2
};


/// Fixes a bug in UITextField, starting in iOS 11.2, where text fields contain a retain cycle.
/// This causes them to leak, and under certain circustances* to continually spam text caret
/// blink animations (causing NSNotificationCenter overloads). This kills the CPU.
///
/// <rdar://36029503>
///
/// * Specifically: when -layoutSubviews is called on a text field and it then never becomes
///   the first responder. The -layoutSubviews results in the text caret blink animation to start.
///   The lack of first responder means -resignFirstResponder is never called resulting in endless
///   blinking animations and their corresponding notifications.
@interface RGUI_ALERT3570_TextField : UITextField

/// Sets a block that will be called when the fix fails to apply cleanly (to be used to logging)
/// The block will only be called once, the first time the fix is attempted. If the fix has already
/// failed when `setFailedToApplyALERT3570FixBlock:` is called, the given block will be called with
/// the previous error.
+ (void)setFailedToApplyALERT3570FixBlock:(nullable RGUI_ALERT3570_TextFieldFailedToApplyFixBlock)block;

@end
