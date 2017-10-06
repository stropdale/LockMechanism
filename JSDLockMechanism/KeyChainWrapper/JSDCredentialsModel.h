//
//  JSDCredentialsModel.h
//  JSDLockMechanism
//
//  Created by Richard Stockdale on 04/10/2017.
//  Copyright © 2017 Junction Seven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>

@interface JSDCredentialsModel : NSObject

@property (nonatomic) NSString *pinNumber;

@property (nonatomic) BOOL bioMetricIsOn;

@property (nonatomic, readonly) LABiometryType biometricType;

- (void) clearCredentials;

@end
