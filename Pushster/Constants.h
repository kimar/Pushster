//
//  Constants.h
//  Pushta
//
//  Created by Marcus Kida on 23.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/***
    System
***/
#define kDebug YES
#define kServiceUrl @"http://pushster.com/api.php"
#define kJsonStringEncoding NSASCIIStringEncoding

/***
    Pull to refresh
***/
#define kReleaseToReloadStatus 0
#define kPullToReloadStatus 1
#define kLoadingStatus 2

/***
    Notifications
***/
#define kMessagesDataSourceFinishedLoading @"messagesDataSourceFinishedLoading"

/***
    Defaults
***/
#define kDefaultsMessages @"defaultsMessages"
#define kDefaultsLastRefreshTime @"defaultsLastRefreshTime"