//
//  PushtaAppDelegate.h
//  Pushta
//
//  Created by Marcus Kida on 23.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "Reachability.h"

@interface PushtaAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    /*** Common stuff ***/
    NSUserDefaults *defaults;
    
    /*** Pull to refresh ***/
    NSDate *lastMessagesRefreshDate;
    
    /*** Messages ***/
    NSMutableArray *messagesArray;
    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) NSUserDefaults *defaults;
@property (nonatomic, retain) NSDate *lastMessagesRefreshDate;
@property (nonatomic, retain) NSMutableArray *messagesArray;

#pragma mark - JSON functions
- (NSData *)jsonRegisterForPushNotificationWithUdid:(NSString *)udid andDevToken:(NSString *)devToken;
- (NSData *)jsonGetMessagesWithUdid:(NSString *)udid;

#pragma mark - ASI functions
- (void)registerForPushNotificationWithDevToken:(NSString *)devToken;
- (void)getOwnMessages;

#pragma mark - Helpers
-(NSString *)dateInFormat:(NSString*) stringFormat;

@end
