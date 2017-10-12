//
//  JSDLockView.m
//  JSDLockMechanism
//
//  Created by Richard Stockdale on 05/10/2017.
//  Copyright © 2017 Junction Seven. All rights reserved.
//

#import "JSDLockView.h"
#import "JSDCredentialsModel.h"

@interface JSDLockView ()

@property (strong, nonatomic) IBOutlet UIView *xibView;
@property (weak, nonatomic) IBOutlet UITextField *passcodeTextField;
@property (nonatomic, strong) JSDCredentialsModel *credentials;
@property (weak, nonatomic) IBOutlet UILabel *incorrectPasscode;

@property (nonatomic, strong) NSDate *lastCall;

@end

@implementation JSDLockView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.xibView = [[[NSBundle mainBundle] loadNibNamed:@"JSDLockViewXib" owner:self options:nil] objectAtIndex:0];
        self.xibView.frame = self.bounds;
        
        [self addSubview:self.xibView];
    }
    return self;
}

- (void) addLockScreenIfNeeded {
    
    if (self.credentials.pinNumber) {
        if (!self.superview) {
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            [window addSubview:self];
            
            self.incorrectPasscode.hidden = YES;
        }
    }
}

- (void) returnedToForeground {
    if (self.credentials.bioMetricIsOn) {
        [self showBiometrics];
    }
    else {
        [self.passcodeTextField becomeFirstResponder];
    }
}

- (void) showBiometrics {
    LAContext *context = [LAContext new];
    NSString *reason = @"Authenticate to open WEIGHT";
    NSError *error = nil;
    
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:reason
                          reply:^(BOOL success, NSError * _Nullable error) {
                              if (success) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self removeFromSuperview];
                                  });
                                  
                              } else {
                                  NSLog(@"Error: %@", error.localizedDescription);
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self.passcodeTextField becomeFirstResponder];
                                  });
                              }
                          }];
    }
    else {
        NSLog(@"Error: %@", error.localizedDescription);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.passcodeTextField becomeFirstResponder];
        });
    }
}

#pragma mark - Text Field Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.incorrectPasscode.hidden = YES;
    
    if (textField.text.length == 3) {
        NSString *textString = [NSString stringWithFormat:@"%@%@", textField.text, string];
        textField.text = @"";
        
        if ([textString isEqualToString:self.credentials.pinNumber]) {
            [self.passcodeTextField resignFirstResponder];
            [self removeFromSuperview];
        }
        else {
            NSLog(@"Text String incorrect");
            self.incorrectPasscode.hidden = NO;
            
            return NO;
        }
    }
    
    return YES;
}

- (JSDCredentialsModel *) credentials {
    if (!_credentials) {
        _credentials = [JSDCredentialsModel new];
    }
    
    return _credentials;
}

@end
