//
//  JSDCredentialsModel.m
//  JSDLockMechanism
//
//  Created by Richard Stockdale on 04/10/2017.
//  Copyright © 2017 Junction Seven. All rights reserved.
//

#import "JSDCredentialsModel.h"
#import "KFKeychain.h"

@interface JSDCredentialsModel ()

@property (nonatomic) NSUserDefaults *defs;

@end

@implementation JSDCredentialsModel

static NSString *pinNumberKey = @"pinNumberKey";
static NSString *bioMetricKey = @"bioMetricKey";

#pragma mark - Username

- (NSString *) pinNumber {
    return [KFKeychain loadObjectForKey:pinNumberKey];
}

- (void) setPinNumber:(NSString *)pinNumber {
    [KFKeychain saveObject:pinNumber forKey:pinNumberKey];
}

#pragma mark - Clear Credentials

- (void) clearCredentials {
    [KFKeychain deleteObjectForKey:pinNumberKey];
    [self.defs removeObjectForKey:bioMetricKey];
}

#pragma mark - Biometric ID

- (BOOL) bioMetricIsOn {
    return [self.defs boolForKey:bioMetricKey];
}

- (void) setBioMetricIsOn:(BOOL)bioMetricIsOn {
    [self.defs setBool:bioMetricIsOn forKey:bioMetricKey];
}

- (LABiometryType) biometricType {
    LAContext *context = [LAContext new];
    
    // iOS 11
//    if ([context respondsToSelector:@selector(biometryType)]) {
//        return context.biometryType;
//    }
    
    // Else iOS 10
    BOOL available =  [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    if (available) {
        return 1;
    }
    
    return available;
}

- (NSUserDefaults *) defs {
    if (!_defs) {
        _defs = [NSUserDefaults standardUserDefaults];
    }
    
    return _defs;
}

@end
