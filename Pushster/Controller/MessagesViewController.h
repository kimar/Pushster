//
//  MessagesViewController.h
//  Pushta
//
//  Created by Marcus Kida on 23.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushtaAppDelegate.h"

#import "EGORefreshTableHeaderView.h"
#import "SoundEffect.h"

@interface MessagesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate> {
    UINavigationController *navigationController;
    PushtaAppDelegate *appDelegate;
    
    IBOutlet UITableView *theTableView;
    
    /*** Pull to refresh ***/
    EGORefreshTableHeaderView *refreshHeaderView;
	BOOL checkForRefresh;
	BOOL reloading;
	IBOutlet UILabel *dateLabel;
	SoundEffect *psst1Sound;
	SoundEffect *psst2Sound;
	SoundEffect *popSound;
    
}

- (void)finishedLoadingNewData;

- (void)dataSourceDidFinishLoadingNewData;
- (void)showReloadAnimationAnimated:(BOOL)animated;

@end
