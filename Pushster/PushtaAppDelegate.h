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

@interface PushtaAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> 
{    
    /*** System ***/
    NSMutableDictionary*settingsDict;
    
    /*** Pull to refresh ***/
    NSDate *lastMessagesRefreshDate;
    
    /*** Messages ***/
    NSMutableArray *messagesArray;
}

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) IBOutlet UITabBarController *tabBarController;

@property (strong, nonatomic) NSDate *lastMessagesRefreshDate;
@property (strong, nonatomic) NSMutableDictionary*settingsDict;
@property (strong, nonatomic) NSMutableArray *messagesArray;

#pragma mark - System functions
- (void)readSettings;
- (void)writeSettings;
- (void)readMessages;
- (void)writeMessages;

#pragma mark - JSON functions
- (NSData*)jsonRegisterForPushNotificationWithUdid:(NSString*)udid andDevToken:(NSString*)devToken;
- (NSData*)jsonGetMessagesWithUdid:(NSString*)udid;
- (NSData*)jsonDeleteMessageWithId:(NSString*)msgId forUdid:(NSString*)udid;

#pragma mark - ASI functions
- (void)registerForPushNotificationWithDevToken:(NSString*)devToken;
- (void)getOwnMessages;
- (void)deleteMessageWithId:(NSString*)msgId;

#pragma mark - Helpers
- (NSString*)dateInFormat:(NSString*) stringFormat;
- (void)showAlertWithTitle:(NSString*)title andMessage:(NSString*)message;

@end
