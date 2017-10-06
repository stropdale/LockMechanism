//
//  JSDSecuritySettingsViewController.m
//  JSDLockMechanism
//
//  Created by Richard Stockdale on 01/10/2017.
//  Copyright © 2017 Junction Seven. All rights reserved.
//

#import "JSDSecuritySettingsViewController.h"
#import "JSDCredentialsModel.h"

typedef NS_ENUM(NSInteger, ScreenState) {
    InitialCodeEntry, // Nothing entered
    ConfirmCodeEntry, // User has entered the first code
    Complete // A valid code has been set up
};

@interface JSDSecuritySettingsViewController ()

// Initial Entry
@property (weak, nonatomic) IBOutlet UILabel *initialCodeEntryLabel;
@property (weak, nonatomic) IBOutlet UITextField *initialCodeEntryTextField;

// Confirm Entry
@property (weak, nonatomic) IBOutlet UILabel *confirmCodeEntryLabel;
@property (weak, nonatomic) IBOutlet UITextField *confirmCodeEntryTextField;

// Use Biometrics
@property (weak, nonatomic) IBOutlet UILabel *useBioMetricsLabel;
@property (weak, nonatomic) IBOutlet UISwitch *turnOnBioMetricsSwitch;

// Cancel Passcode
@property (weak, nonatomic) IBOutlet UIButton *cancelPasscodeButton;

// Keychain Model
@property (nonatomic, strong) JSDCredentialsModel *credentialsModel;

@end

@implementation JSDSecuritySettingsViewController

- (IBAction)clearPasscodeTapped:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Clear Code"
                                                                   message:@"Are you sure you want to clear the existing passcode"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Clear Code"
                                                       style:UIAlertActionStyleDestructive
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self clearPasscode];
                                                     }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) clearPasscode {
    [self.credentialsModel clearCredentials];
    [self configureState:InitialCodeEntry];
}

- (void) configureState: (ScreenState) state {
    self.initialCodeEntryTextField.alpha = 0.3;
    self.initialCodeEntryTextField.userInteractionEnabled = NO;
    self.initialCodeEntryLabel.alpha = 0.3;
    
    self.confirmCodeEntryTextField.alpha = 0.3;
    self.confirmCodeEntryTextField.userInteractionEnabled = NO;
    self.confirmCodeEntryLabel.alpha = 0.3;
    
    self.turnOnBioMetricsSwitch.alpha = 0.3;
    self.turnOnBioMetricsSwitch.userInteractionEnabled = NO;
    self.useBioMetricsLabel.alpha = 0.3;
    
    self.cancelPasscodeButton.hidden = YES;
    
    [self.initialCodeEntryTextField resignFirstResponder];
    [self.confirmCodeEntryTextField resignFirstResponder];
    
    switch (state) {
        case InitialCodeEntry: {
            self.initialCodeEntryTextField.text = @"";
            self.confirmCodeEntryTextField.text = @"";
            
            self.initialCodeEntryTextField.alpha = 1.0;
            self.initialCodeEntryTextField.userInteractionEnabled = YES;
            self.initialCodeEntryLabel.alpha = 1.0;
            
            [self.initialCodeEntryTextField becomeFirstResponder];
            
            break;
        }
        case ConfirmCodeEntry: {
            self.confirmCodeEntryTextField.alpha = 1.0;
            self.confirmCodeEntryTextField.userInteractionEnabled = YES;
            self.confirmCodeEntryLabel.alpha = 1.0;
            
            [self.confirmCodeEntryTextField becomeFirstResponder];
            
            break;
        }
        case Complete: {
            self.turnOnBioMetricsSwitch.alpha = 1.0;
            self.turnOnBioMetricsSwitch.userInteractionEnabled = YES;
            self.useBioMetricsLabel.alpha = 1.0;
            
            self.cancelPasscodeButton.hidden = NO;
            
            break;
        }
        default:
            break;
    }
}

- (void) validateEntries {
    if ([self.initialCodeEntryTextField.text isEqualToString:self.confirmCodeEntryTextField.text]) {
        [self configureState:Complete];
        [self notifyUser:@"Victory!"
                    body:@"Passcode set"
        withOkButtonText:@"Ok"];
        
        self.credentialsModel.pinNumber = self.initialCodeEntryTextField.text;
    }
    else {
        [self configureState:InitialCodeEntry];
        [self notifyUser:@"Opps!"
                    body:@"Passcodes did not match."
        withOkButtonText:@"Try Again"];
    }
}

- (void) notifyUser:(NSString *) title
               body: (NSString *) body
   withOkButtonText: (NSString *) okText {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:body
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okText
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)bioMetricSwitchChanged:(id)sender {
    self.credentialsModel.bioMetricIsOn = self.turnOnBioMetricsSwitch.isOn;
    
    if (self.turnOnBioMetricsSwitch.isOn) {
        
    }
}

#pragma mark - Text Field Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length == 3) {
        NSString *textString = [NSString stringWithFormat:@"%@%@", textField.text, string];
        textField.text = textString;
        
        if (textField.tag == 0) { // Initial Text Field
            [self configureState:ConfirmCodeEntry];
            
            return NO;
        }
        else { // Confirm Text Field
            [self validateEntries];
            
            return NO;
        }
    }
    
    return YES;
}

- (void)updateForBioMetricAvailability {
    self.turnOnBioMetricsSwitch.hidden = NO;
    self.useBioMetricsLabel.hidden = NO;
    
    switch (self.credentialsModel.biometricType) {
        case LABiometryTypeFaceID:
            self.useBioMetricsLabel.text = @"Use Face ID";
            break;
        case LABiometryTypeTouchID:
            self.useBioMetricsLabel.text = @"Use Touch ID";
            break;
        default:
            self.useBioMetricsLabel.hidden = YES;
            self.turnOnBioMetricsSwitch.hidden = YES;
            break;
    }
    
    self.turnOnBioMetricsSwitch.on = self.credentialsModel.bioMetricIsOn;
}

#pragma mark - Lazy Loading

- (JSDCredentialsModel *) credentialsModel {
    if (!_credentialsModel) {
        _credentialsModel = [JSDCredentialsModel new];
    }
    
    return _credentialsModel;
}

#pragma mark - Life Cycle

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set the state
    if (self.credentialsModel.pinNumber) {
        [self configureState:Complete];
        self.initialCodeEntryTextField.text = @"****";
        self.confirmCodeEntryTextField.text = @"****";
    }
    else {
        [self configureState:InitialCodeEntry];
        self.initialCodeEntryTextField.text = @"";
        self.confirmCodeEntryTextField.text = @"";
    }
    
    // Set up the biometric labels
    [self updateForBioMetricAvailability];
}

@end
