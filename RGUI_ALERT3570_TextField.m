//
//  RGUI_ALERT3570_TextField.m
//  RegisterUI
//

#import "RGUI_ALERT3570_TextField.h"


// UITextField uses an internal content view to manage the display of text.
// That content view maintains a reference back to the text field itself
// via the text field’s `_textContentView`’s `_provider` (which is the
// text field itself).
//
// In iOS 11.2, that reference became strong. This causes a retain cycle.
// To fix this, we replace that reference with an instance of WeakProxy
// that points back to the text field. This lets us fix the reference (we
// make it weak) without impacting the communication between content view
// and text field.


id SQEmptyStringIfNil(id object)
{
    if (object) {
        return object;
    } else {
        return @"";
    }
}


@interface RGUI_ALERT3570_WeakProxy : NSProxy

@property (weak, nonatomic) id target;

- (instancetype)initWithTarget:(id)target;

@end


@implementation RGUI_ALERT3570_WeakProxy

- (instancetype)initWithTarget:(id)target
{
    _target = target;
    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:self.target];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [self.target methodSignatureForSelector:sel];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [self.target respondsToSelector:aSelector];
}

@end


NSString *_Nonnull const RGUI_ALERT3570_ErrorDomain = @"RGUI_ALERT3570_ErrorDomain";


@interface UITextField (RGUI_ALERT3570_PrivateMethods)

- (id)_fieldEditor;

@end


@interface RGUI_ALERT3570_TextField ()

@property (nonatomic) BOOL ALERT_3570_isDeallocating;
@property (nonatomic) BOOL ALERT_3570_fixApplied;

@end


@implementation RGUI_ALERT3570_TextField

#pragma mark - Observing Failures

static RGUI_ALERT3570_TextFieldFailedToApplyFixBlock _static_ALERT_3570_failedToApplyBlock = nil;
static NSError *_static_ALERT_3570_errorFromApplyingFix = nil;

+ (void)setFailedToApplyALERT3570FixBlock:(RGUI_ALERT3570_TextFieldFailedToApplyFixBlock)block;
{
    _static_ALERT_3570_failedToApplyBlock = [block copy];

    // Go ahead and send the error if we've already encountered it before the block is set
    // (run on the next runloop cycle to avoid synchronously calling the block back)
    if (_static_ALERT_3570_failedToApplyBlock && _static_ALERT_3570_errorFromApplyingFix) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _static_ALERT_3570_failedToApplyBlock(_static_ALERT_3570_errorFromApplyingFix);
        });
    }
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    NSParameterAssert(self);

    _ALERT_3570_fixApplied = [RGUI_ALERT3570_TextField __alert3570__shouldApplyFix];

    if (_ALERT_3570_fixApplied) {
        [self __alert3570__applyFix];
    }

    return self;
}

- (instancetype)initWithALERT3570Fix;
{
    self = [super initWithFrame:CGRectZero];
    NSParameterAssert(self);

    _ALERT_3570_fixApplied = YES;

    [self __alert3570__applyFix];

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (!self) {
        return nil;
    }

    _ALERT_3570_fixApplied = [RGUI_ALERT3570_TextField __alert3570__shouldApplyFix];

    if (_ALERT_3570_fixApplied) {
        [self __alert3570__applyFix];
    }

    return self;
}

- (void)dealloc
{
    _ALERT_3570_isDeallocating = YES;
}

#pragma mark - ALERT Fixes

- (id)_fieldEditor
{
    if (_ALERT_3570_fixApplied && _ALERT_3570_isDeallocating) {
        // The base UITextField implementation crashes in dealloc while calling
        // _fieldEditor (it tries to lazily instantiate some internal components
        // which try to form a weak reference to the text field which is deallocating
        // causing an exception). Bail early to prevent this.
        return nil;
    }

    return [super _fieldEditor];
}

+ (BOOL)__alert3570__shouldApplyFix
{
    static BOOL shouldApply = NO;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shouldApply = [self __alert3570__shouldApplyFix:UIDevice.currentDevice];
    });

    return shouldApply;
}

- (void)__alert3570__applyFix;
{
    NSString *textContentViewKey = [self.class RGUI_ALERT3570_stringWithReversedComponents:@[ @"View", @"Content", @"text", @"_" ]];
    NSString *providerKey = [self.class RGUI_ALERT3570_stringWithReversedComponents:@[ @"provider", @"_" ]];

    // Get the content view (instance of _UITextFieldContentView)
    id contentView = [self valueForKey:textContentViewKey];

    if ([contentView valueForKey:providerKey] == self) {
        // Instantiate a proxy to hold a weak reference to self.
        RGUI_ALERT3570_WeakProxy *proxy = [[RGUI_ALERT3570_WeakProxy alloc] initWithTarget:self];

        // Assign the proxy as the content view's provider, breaking the
        // retain cycle.
        [contentView setValue:proxy forKey:providerKey];
    }
}

+ (BOOL)__alert3570__shouldApplyFix:(UIDevice *)device;
{
    NSParameterAssert(device);

    // 1) Check if we're running on 11 or later. If we're not, return NO.
    
    if ([@"11.2" compare:device.systemVersion options:NSNumericSearch] == NSOrderedDescending) {
        return NO;
    }

    // 2) If the text field was deallocated normally, don't apply the fix.

    {
        __weak UITextField *weakTextField = nil;

        @autoreleasepool
        {
            __strong UITextField *strongTextField = [[UITextField alloc] init];
            weakTextField = strongTextField;
            strongTextField = nil;
        }

        if (!weakTextField) {
            return NO;
        }
    }

    // 3) Can we apply the fix? Do the properties exist?

    {
        @try {
            UITextField *const textField = [[UITextField alloc] init];

            NSString *textContentViewKey = [self.class RGUI_ALERT3570_stringWithReversedComponents:@[ @"View", @"Content", @"text", @"_" ]];
            NSString *providerKey = [self.class RGUI_ALERT3570_stringWithReversedComponents:@[ @"provider", @"_" ]];

            __unused id contentView = [textField valueForKey:textContentViewKey];
            __unused id provider = [contentView valueForKey:providerKey];
        } @catch (NSException *exception) {
            if (_static_ALERT_3570_failedToApplyBlock) {
                NSDictionary *userInfo = @{
                    @"exception" : SQEmptyStringIfNil(exception),
                    @"file" : SQEmptyStringIfNil(@(__FILE__)),
                    @"line" : SQEmptyStringIfNil(@(__LINE__))
                };
                NSError *error = [[NSError alloc] initWithDomain:RGUI_ALERT3570_ErrorDomain code:RGUI_ALERT3570_ErrorCodeException userInfo:userInfo];
                _static_ALERT_3570_errorFromApplyingFix = error;
                _static_ALERT_3570_failedToApplyBlock(error);
            }

            return NO;
        }
    }

    // 4) Finally, verify that applying the fix actually does what we expect.

    {
        @try {
            __weak UITextField *weakTextField = nil;

            @autoreleasepool
            {
                __strong RGUI_ALERT3570_TextField *strongTextField = [[RGUI_ALERT3570_TextField alloc] initWithALERT3570Fix];
                weakTextField = strongTextField;
                strongTextField = nil;
            }


            if (weakTextField) {
                if (_static_ALERT_3570_failedToApplyBlock) {
                    NSDictionary *userInfo = @{
                        @"description" : @"The text field was still over-retained",
                        @"file" : SQEmptyStringIfNil(@(__FILE__)),
                        @"line" : SQEmptyStringIfNil(@(__LINE__))
                    };
                    NSError *error = [[NSError alloc] initWithDomain:RGUI_ALERT3570_ErrorDomain code:RGUI_ALERT3570_ErrorCodeNoFix userInfo:userInfo];
                    _static_ALERT_3570_errorFromApplyingFix = error;
                    _static_ALERT_3570_failedToApplyBlock(error);
                }
                return NO;
            }
        } @catch (NSException *exception) {
            if (_static_ALERT_3570_failedToApplyBlock) {
                NSDictionary *userInfo = @{
                    @"exception" : SQEmptyStringIfNil(exception),
                    @"file" : SQEmptyStringIfNil(@(__FILE__)),
                    @"line" : SQEmptyStringIfNil(@(__LINE__))
                };
                NSError *error = [[NSError alloc] initWithDomain:RGUI_ALERT3570_ErrorDomain code:RGUI_ALERT3570_ErrorCodeException userInfo:userInfo];
                _static_ALERT_3570_errorFromApplyingFix = error;
                _static_ALERT_3570_failedToApplyBlock(error);
            }

            return NO;
        }
    }

    // 5) Everything has passed, apply the fix.

    return YES;
}

#pragma mark - Helper Methods

+ (NSString *)RGUI_ALERT3570_stringWithReversedComponents:(NSArray *)strings;
{
    NSMutableString *const string = [NSMutableString new];
    
    for (NSString *component in strings.reverseObjectEnumerator) {
        [string appendString:component];
    }
    
    return string.copy;
}

@end
