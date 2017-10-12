//
//  JSDLockView.h
//  JSDLockMechanism
//
//  Created by Richard Stockdale on 05/10/2017.
//  Copyright © 2017 Junction Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSDLockView : UIView


/**
 Adds the lock screen as the app goes into the background
 */
- (void) addLockScreenIfNeeded;

// Shows touch ID or the keyboard when the app returns to the foreground
- (void) returnedToForeground

@end
