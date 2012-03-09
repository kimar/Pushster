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

@synthesize defaults, lastMessagesRefreshDate, messagesArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    /*** prepare stuff ***/
    messagesArray = [[[NSMutableArray alloc] init] retain];
    lastMessagesRefreshDate = [[[NSDate alloc] init] retain];
    
    /***
        APNS
    ***/
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [defaults setObject:messagesArray forKey:kDefaultsMessages];
    [defaults synchronize];
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
    messagesArray = [[defaults objectForKey:kDefaultsMessages] mutableCopy];
    
    if ([defaults objectForKey:kDefaultsLastRefreshTime] != NULL) {
        lastMessagesRefreshDate = [defaults objectForKey:kDefaultsLastRefreshTime];
    }

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [messagesArray release];
    
    [_window release];
    [_tabBarController release];
    [super dealloc];
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
    
    for (id key in userInfo) {
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
	[jsonWriter release];
	[jsonData release];
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
	[jsonWriter release];
	[jsonData release];
	if(kDebug) {
		NSLog(@"DEBUG: jsonGetMessagesWithUdid: %@", jsonString);
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
	[request appendPostData:[NSMutableData dataWithData:[self jsonRegisterForPushNotificationWithUdid:[[UIDevice currentDevice] uniqueIdentifier] andDevToken:devToken]]];
    [request setTimeOutSeconds:45];  
	[request setDidFinishSelector:@selector(getOwnMessageRequestFinished:)];
	[request setDidFailSelector:@selector(getOwnMessageRequestFailed:)];
	[request startAsynchronous];	
}

- (void)getOwnMessages 
{
	ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kServiceUrl]];  
	//[request setValidatesSecureCertificate:NO];
	[request setDelegate:self];
	[request setRequestMethod:@"POST"];
	[request appendPostData:[NSMutableData dataWithData:[self jsonGetMessagesWithUdid:[[UIDevice currentDevice] uniqueIdentifier]]]];
    [request setTimeOutSeconds:45];  
	[request setDidFinishSelector:@selector(getOwnMessageRequestFinished:)];
	[request setDidFailSelector:@selector(getOwnMessageRequestFailed:)];
	[request startAsynchronous];	
}

#pragma mark - ASI delegate functions
- (void)getOwnMessageRequestFinished:(ASIFormDataRequest *)request
{
	NSString *response = [request responseString];
	if(kDebug) {
		NSLog(@"DEBUG: getOwnMessageRequestFinished: %@", response);
	}
    NSDictionary *responseDict = [response JSONValue];
	NSString *errorCode = [responseDict objectForKey:@"error_code"];
    NSArray *messagesResponseArray = [responseDict objectForKey:@"messages"];
	if([errorCode intValue] == 1000)
    {
        [messagesArray removeAllObjects];
        for (int i=0; i<[messagesResponseArray count]; i++) 
        {
            if (kDebug) {
                NSLog(@"DEBUG: message: %@", [[messagesResponseArray objectAtIndex:i] objectForKey:@"message"]);
            }
            [messagesArray addObject:
             [NSDictionary dictionaryWithObjects:
              [NSArray arrayWithObjects:
               [[messagesResponseArray objectAtIndex:i] objectForKey:@"time"], 
               [[messagesResponseArray objectAtIndex:i] objectForKey:@"message"], 
               nil]
                                         forKeys:
              [NSArray arrayWithObjects:
               @"time",
               @"message",
               nil]
              ]
             ];
        }
        lastMessagesRefreshDate = [NSDate date];
        [defaults setObject:lastMessagesRefreshDate forKey:kDefaultsLastRefreshTime];
        [defaults synchronize];
    }
    if (kDebug) {
        NSLog(@"DEBUG: messagesArray Count: %d", [messagesArray count]);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessagesDataSourceFinishedLoading object:nil];
}

- (void)getOwnMessageRequestFailed:(ASIFormDataRequest *)request
{
	NSString *response = [request responseString];
	if(kDebug) {
		NSLog(@"DEBUG: getOwnMessageRequestFailed: %@", response);
	}	
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessagesDataSourceFinishedLoading object:nil];
}

- (void)requestFinished:(ASIFormDataRequest *)request
{
	NSString *response = [request responseString];
	if(kDebug) {
		NSLog(@"DEBUG: requestFinished: %@", response);
	}		
}

- (void)requestFailed:(ASIFormDataRequest *)request
{
	NSString *response = [request responseString];
	if(kDebug) {
		NSLog(@"DEBUG: requestFailed: %@", response);
	}	
}

#pragma mark - Helpers
-(NSString *)dateInFormat:(NSString*) stringFormat {
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
