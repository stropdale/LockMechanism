//
//  AppDelegate.m
//  JSDLockMechanism
//
//  Created by Richard Stockdale on 01/10/2017.
//  Copyright © 2017 Junction Seven. All rights reserved.
//

#import "AppDelegate.h"
#import "JSDLockView.h"
//#import "JSDCredentialsModel.h"

@interface AppDelegate ()

@property (nonatomic, strong) JSDLockView *lockView;
//@property (nonatomic, strong) JSDCredentialsModel *credentials;

@end

@implementation AppDelegate

- (void)applicationDidEnterBackground:(UIApplication *)application {
     [self addInLockView];
}

- (void) addInLockView {
    [self.lockView addLockScreenIfNeeded];
}

- (JSDLockView *) lockView {
    if (!_lockView) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        _lockView = [[JSDLockView alloc] initWithFrame:window.bounds];
    }
    
    return _lockView;
}

//- (JSDCredentialsModel *) credentials {
//    if (!_credentials) {
//        _credentials = [JSDCredentialsModel new];
//    }
//
//    return _credentials;
//}

@end
