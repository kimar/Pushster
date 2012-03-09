//
//  PushtaAppDelegate.m
//  Pushta
//
//  Created by Marcus Kida on 23.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Constants.h"

#import "PushtaAppDelegate.h"

@implementation PushtaAppDelegate

@synthesize window=_window;
@synthesize tabBarController=_tabBarController;
@synthesize settingsDict,lastMessagesRefreshDate,messagesArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
        
    /*** prepare stuff ***/
    lastMessagesRefreshDate = [[NSDate alloc] init];
    [self readSettings];
    [self readMessages];
    
    /***
        APNS
    ***/
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    /***
        Get Messages 
     ***/
    [self getOwnMessages];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [self writeMessages];
    [self writeSettings];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */    
    if(kDebug) NSLog(@"lastMessagesRefreshDate=%@",lastMessagesRefreshDate);
    
    [self readSettings];
    [self readMessages];
    
    if ([settingsDict objectForKey:kDefaultsLastRefreshTime]!=NULL) 
    {
        lastMessagesRefreshDate = [settingsDict objectForKey:kDefaultsLastRefreshTime];
    }
    
    if(([[settingsDict objectForKey:kDefaultsLastRefreshTime] timeIntervalSince1970]+0)<[[NSDate date] timeIntervalSince1970])
    {
        [self getOwnMessages];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

#pragma mark - System functions
- (void)readSettings
{
    FLog();
    settingsDict=[[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:kSettingsDictPath]];
}

- (void)writeSettings
{
    FLog();
    [settingsDict writeToFile:kSettingsDictPath atomically:YES];
}

- (void)readMessages
{
    FLog();
    messagesArray=[[NSMutableArray alloc] initWithArray:[NSArray arrayWithContentsOfFile:kMessagesArrayPath]];
}

- (void)writeMessages
{
    FLog();
    [messagesArray writeToFile:kMessagesArrayPath atomically:YES];
}

#pragma mark - APNS
// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken 
{
   //const void *devTokenBytes = [devToken bytes];
   	NSString *devTok = @"";
	devTok = [NSString stringWithFormat:@"%@", devToken];
	devTok = [devTok stringByReplacingOccurrencesOfString:@"<" withString:@""];
	devTok = [devTok stringByReplacingOccurrencesOfString:@">" withString:@""];
	devTok = [devTok stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //[self sendProviderDeviceToken:devTokenBytes]; // custom method
    [self registerForPushNotificationWithDevToken:[NSString stringWithFormat:@"%@", devTok]];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err 
{
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo 
{
    
    for (id key in userInfo) 
    {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }    
    
    [self getOwnMessages];
}

#pragma mark - JSON functions
- (NSData *)jsonRegisterForPushNotificationWithUdid:(NSString *)udid andDevToken:(NSString *)devToken
{
	NSDictionary *jsonData = [[NSDictionary alloc] initWithObjectsAndKeys:
							  @"reg_apns", @"command",
                              udid, @"udid",
							  devToken, @"token",
							  nil];
	SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
	NSString *jsonString = [jsonWriter stringWithObject:jsonData];
	if(kDebug) {
		NSLog(@"DEBUG: jsonRegisterForPushNotificationWithDevToken: %@", jsonString);
	}
	return [jsonString dataUsingEncoding:kJsonStringEncoding];	
}

- (NSData *)jsonGetMessagesWithUdid:(NSString *)udid
{
	NSDictionary *jsonData = [[NSDictionary alloc] initWithObjectsAndKeys:
							  @"get_messages", @"command",
							  udid, @"udid",
							  nil];
	SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
	NSString *jsonString = [jsonWriter stringWithObject:jsonData];
	if(kDebug) {
		NSLog(@"DEBUG: jsonGetMessagesWithUdid: %@", jsonString);
	}
	return [jsonString dataUsingEncoding:kJsonStringEncoding];	
}

- (NSData*)jsonDeleteMessageWithId:(NSString *)msgId forUdid:(NSString*)udid
{
    NSDictionary *jsonData = [[NSDictionary alloc] initWithObjectsAndKeys:
							  @"del_message", @"command",
							  udid, @"udid",
                              msgId, @"message_id",
							  nil];
	SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
	NSString *jsonString = [jsonWriter stringWithObject:jsonData];
	if(kDebug) {
		NSLog(@"DEBUG: jsonDeleteMessageWithId: %@", jsonString);
	}
	return [jsonString dataUsingEncoding:kJsonStringEncoding];
}

#pragma mark - ASI functions
- (void)registerForPushNotificationWithDevToken:(NSString *)devToken 
{
	ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kServiceUrl]];  
	//[request setValidatesSecureCertificate:NO];
	[request setDelegate:self];
	[request setRequestMethod:@"POST"];
	[request appendPostData:[NSMutableData dataWithData:[self jsonRegisterForPushNotificationWithUdid:kUDID andDevToken:devToken]]];
    [request setTimeOutSeconds:kHttpTimeout];  
    [request setTag:REGISTER];
	[request startAsynchronous];	
}

- (void)getOwnMessages 
{
	ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kServiceUrl]];  
	//[request setValidatesSecureCertificate:NO];
	[request setDelegate:self];
	[request setRequestMethod:@"POST"];
	[request appendPostData:[NSMutableData dataWithData:[self jsonGetMessagesWithUdid:kUDID]]];
    [request setTimeOutSeconds:kHttpTimeout];  
    [request setTag:GETMESSAGES];
	[request startAsynchronous];	
}

- (void)deleteMessageWithId:(NSString *)msgId 
{
	ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kServiceUrl]];  
	//[request setValidatesSecureCertificate:NO];
	[request setDelegate:self];
	[request setRequestMethod:@"POST"];
	[request appendPostData:[NSMutableData dataWithData:[self jsonDeleteMessageWithId:msgId forUdid:kUDID]]];
    [request setTimeOutSeconds:kHttpTimeout];  
    [request setTag:DELMESSAGE];
	[request startAsynchronous];	
}

#pragma mark - ASI delegate functions
- (void)requestFinished:(ASIFormDataRequest *)request
{
	NSString *response = [request responseString];
	if(kDebug)
    {
		NSLog(@"DEBUG: requestFinished: %@", response);
	}
    
    switch (request.tag)
    {
        case REGISTER:
        case GETMESSAGES:
        {
            NSDictionary *responseDict = [response JSONValue];
            NSString *errorCode = [responseDict objectForKey:@"error_code"];
            NSArray *messagesResponseArray = [responseDict objectForKey:@"messages"];
            if([errorCode intValue] == 1000)
            {
                if([messagesResponseArray isKindOfClass:[NSArray class]])
                {
                    if([messagesResponseArray count]>0)
                    {
                        [messagesArray removeAllObjects];
                        for (int i=0; i<[messagesResponseArray count]; i++) 
                        {
                            if (kDebug) 
                            {
                                NSLog(@"DEBUG: message: %@", [[messagesResponseArray objectAtIndex:i] objectForKey:@"message"]);
                            }
                            [messagesArray addObject:
                             [NSDictionary dictionaryWithObjects:
                              [NSArray arrayWithObjects:
                               [[messagesResponseArray objectAtIndex:i] objectForKey:@"id"],
                               [[messagesResponseArray objectAtIndex:i] objectForKey:@"time"], 
                               [[messagesResponseArray objectAtIndex:i] objectForKey:@"message"], 
                               nil]
                                                         forKeys:
                              [NSArray arrayWithObjects:
                               @"id",
                               @"time",
                               @"message",
                               nil]
                              ]
                             ];
                        }
                    }
                }
                
                lastMessagesRefreshDate = [NSDate date];
                [settingsDict setObject:lastMessagesRefreshDate forKey:kDefaultsLastRefreshTime];
            }
            if (kDebug) 
            {
                NSLog(@"DEBUG: messagesArray Count: %d", [messagesArray count]);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kMessagesDataSourceFinishedLoading object:nil];
        }
            break;
        case DELMESSAGE:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMessageDeleteSuccessful object:nil];
        }
            break;
        default:
            break;
    }
}

- (void)requestFailed:(ASIFormDataRequest *)request
{
	NSString *response = [request responseString];
	if(kDebug) 
    {
		NSLog(@"DEBUG: requestFailed: %@", response);
	}	
    
    switch (request.tag)
    {
        case REGISTER:
        case GETMESSAGES:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMessagesDataSourceFinishedLoading object:nil];
        }
            break;
        case DELMESSAGE:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMessageDeleteFailed object:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Helpers
-(NSString *)dateInFormat:(NSString*) stringFormat
{
	char buffer[80];
	const char *format = [stringFormat UTF8String];
	time_t rawtime;
	struct tm * timeinfo;
	time(&rawtime);
	timeinfo = localtime(&rawtime);
	strftime(buffer, 80, format, timeinfo);
	return [NSString  stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

@end
