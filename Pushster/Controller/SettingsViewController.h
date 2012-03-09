//
//  SettingsViewController.h
//  Pushta
//
//  Created by Marcus Kida on 24.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushtaAppDelegate.h"

@interface SettingsViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    UINavigationController *navigationController;
    PushtaAppDelegate *appDelegate;
    
    /*** TableView ***/
    IBOutlet UITableView *theTableView;
}

@end
