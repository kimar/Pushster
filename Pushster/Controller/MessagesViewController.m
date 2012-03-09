//
//  MessagesViewController.m
//  Pushta
//
//  Created by Marcus Kida on 23.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Constants.h"

#import "MessagesViewController.h"


@implementation MessagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view addSubview:[navigationController view]];
    appDelegate = (PushtaAppDelegate *)[[UIApplication sharedApplication] delegate];

    /*** Pull to refresh ***/
    refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.view.bounds.size.height, 320.0f, self.view.bounds.size.height)];
	[refreshHeaderView setLastUpdatedDate:[appDelegate lastMessagesRefreshDate]];
	[theTableView addSubview:refreshHeaderView];
	theTableView.showsVerticalScrollIndicator = YES;
	
	// pre-load sounds
	psst1Sound = [[SoundEffect alloc] initWithContentsOfFile:
				  [[NSBundle mainBundle] pathForResource:@"psst1"
												  ofType:@"wav"]];
	psst2Sound  = [[SoundEffect alloc] initWithContentsOfFile:
				   [[NSBundle mainBundle] pathForResource:@"psst2"
												   ofType:@"wav"]];
	popSound  = [[SoundEffect alloc] initWithContentsOfFile:
				 [[NSBundle mainBundle] pathForResource:@"pop"
												 ofType:@"wav"]];
    
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"LLLL Y"];
	NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
	[dateLabel setText:dateString];
	[dateFormat release];
    
    /*** Notifications ***/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedLoadingNewData) name:kMessagesDataSourceFinishedLoading object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (appDelegate.lastMessagesRefreshDate == NULL) {
        [self showReloadAnimationAnimated:YES];
        [appDelegate getOwnMessages];
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [appDelegate.messagesArray count];
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
 return 60.0;
 }*/

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *rNum = [[NSNumber alloc] initWithInt:(arc4random() % 49) +1];
	static NSString *CellIdentifier;
	CellIdentifier=[NSString stringWithFormat:@"messages-%d-%d-%d-%@", indexPath.section, indexPath.row, rNum, [appDelegate dateInFormat:@"%s"]];

    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.textLabel.text = [NSString stringWithFormat:@"%@", [[appDelegate.messagesArray objectAtIndex:indexPath.row] objectForKey:@"message"]];
    
    return cell;
}

- (void)finishedLoadingNewData
{
    [theTableView reloadData];
    [self dataSourceDidFinishLoadingNewData];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma mark - Pull to Refresh

- (void)showReloadAnimationAnimated:(BOOL)animated {
	reloading = YES;
	[refreshHeaderView toggleActivityView:YES];
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		theTableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	} else {
		theTableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
	}
}

- (void)reloadTableViewDataSource {
    [appDelegate getOwnMessages];
}

- (void)dataSourceDidFinishLoadingNewData {
	reloading = NO;
	[refreshHeaderView flipImageAnimated:NO];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[theTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[refreshHeaderView setStatus:kPullToReloadStatus];
	[refreshHeaderView toggleActivityView:NO];
	[UIView commitAnimations];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if (!reloading) checkForRefresh = YES;  //  only check offset when dragging
} 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
	if (reloading) return;
	if (checkForRefresh) {
		if (refreshHeaderView.isFlipped && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !reloading) {
			[refreshHeaderView flipImageAnimated:YES];
			[refreshHeaderView setStatus:kPullToReloadStatus];
			[popSound play];
		} else if (!refreshHeaderView.isFlipped && scrollView.contentOffset.y < -65.0f) {
			[refreshHeaderView flipImageAnimated:YES];
			[refreshHeaderView setStatus:kReleaseToReloadStatus];
			[psst1Sound play];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (reloading) return;
	if (scrollView.contentOffset.y <= - 65.0f) {
		if ([theTableView.dataSource respondsToSelector:@selector(reloadTableViewDataSource)]) {
			[self showReloadAnimationAnimated:YES];
			[psst2Sound play];
			[self reloadTableViewDataSource];
		}
	} 
	checkForRefresh = NO;
}

@end
