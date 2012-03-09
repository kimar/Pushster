//
//  Constants.h
//  Pushta
//
//  Created by Marcus Kida on 23.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/***
    Enums
***/
typedef enum
{
    REGISTER,
    GETMESSAGES,
    DELMESSAGE
} HttpRequestType;

/***
    System
***/
#define kDebug                                  YES
#define kServiceUrl                             @"http://pushster.com/api.php"
#define kJsonStringEncoding                     NSASCIIStringEncoding
#define kUDID                                   [[UIDevice currentDevice] uniqueIdentifier]
#define kHttpTimeout                            30

/***
    Filesystem
***/
#define kDocumentsFilePath                      [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0] 
#define kMessagesArrayPath                      [kDocumentsFilePath stringByAppendingPathComponent: @"Messages.plist"]
#define kSettingsDictPath                       [kDocumentsFilePath stringByAppendingPathComponent: @"Settings.plist"]

/***
    Pull to refresh
***/
#define kReleaseToReloadStatus                  0
#define kPullToReloadStatus                     1
#define kLoadingStatus                          2

/***
    Notifications
***/
#define kMessagesDataSourceFinishedLoading      @"messagesDataSourceFinishedLoading"
#define kMessageDeleteSuccessful                @"messageDeleteSuccessful"
#define kMessageDeleteFailed                    @"messageDeleteFailed"

/***
    Defaults
***/
#define kDefaultsMessages                       @"defaultsMessages"
#define kDefaultsLastRefreshTime                @"defaultsLastRefreshTime"