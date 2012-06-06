#import "RootViewController.h"
#import <UIKit/UIKit.h>
#import <Foundation/NSTimer.h>
//#import "SBApplicationController.h"
//#import "SBApplication.h"
//#import "SBIconModel.h"

#include <stdlib.h>

@implementation RootViewController

- (void)handleTimerTED
{
	system("open com.ted.TED");
}

- (void)handleTimerCamera
{
	system("open com.apple.camera");
}

- (void)handleTimerGoogle
{
	system("open com.google.GoogleMobile");
}

- (void)handleTimerSkype
{
	system("open com.skype.SkypeForiPad");
}

- (void)ButtonClickedTED
{
	system("killall -9 TED");

	NSTimer* timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(handleTimerTED) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode]; 

	//sleep(1.0);

	//[timer fire];

	//[[[SBApplicationController sharedInstance] applicationWithDisplayIdentifier: @"com.ted.TED"] kill];
	//[[[SBIconModel sharedInstance] applicationIconForDisplayIdentifier: @"com.ted.TED"] performSelector: @selector(launch) withObject:nil afterDelay:1];
}

- (void)ButtonClickedCamera
{
	system("killall -9 camera");
	NSTimer* timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(handleTimerCamera) userInfo:nil repeats:NO]; 
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)ButtonClickedGoogle
{
	system("killall -9 Google");
	NSTimer* timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(handleTimerGoogle) userInfo:nil repeats:NO]; 
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)ButtonClickedSkype
{
	system("killall -9 Skype");
	NSTimer* timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(handleTimerSkype) userInfo:nil repeats:NO]; 
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

}

- (void)loadView {
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	self.view.backgroundColor = [UIColor whiteColor];

}

//viewDidLoad method declared in RootViewController.m
- (void)viewDidLoad {
	[super viewDidLoad];
	 
	UIButton* buttonTED = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	buttonTED.frame = CGRectMake(20, 20, 100, 100);
	[buttonTED setTitle: @"TED" forState:UIControlStateNormal];
	[buttonTED setTitle: @"TED" forState:UIControlStateHighlighted];
	[buttonTED addTarget:self action:@selector(ButtonClickedTED) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:buttonTED];
	[self.view bringSubviewToFront:buttonTED];

	UIButton* buttonCamera = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	buttonCamera.frame = CGRectMake(180, 20, 100, 100);
	[buttonCamera setTitle: @"Camera" forState:UIControlStateNormal];
	[buttonCamera setTitle: @"Camera" forState:UIControlStateHighlighted];
	[buttonCamera addTarget:self action:@selector(ButtonClickedCamera) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:buttonCamera];
	[self.view bringSubviewToFront:buttonCamera];

	UIButton* buttonGoogle = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	buttonGoogle.frame = CGRectMake(20, 180, 100, 100);
	[buttonGoogle setTitle: @"Google" forState:UIControlStateNormal];
	[buttonGoogle setTitle: @"Google" forState:UIControlStateHighlighted];
	[buttonGoogle addTarget:self action:@selector(ButtonClickedGoogle) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:buttonGoogle];
	[self.view bringSubviewToFront:buttonGoogle];

	UIButton* buttonSkype = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	buttonSkype.frame = CGRectMake(180, 180, 100, 100);
	[buttonSkype setTitle: @"Skype" forState:UIControlStateNormal];
	[buttonSkype setTitle: @"Skype" forState:UIControlStateHighlighted];
	[buttonSkype addTarget:self action:@selector(ButtonClickedSkype) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:buttonSkype];
	[self.view bringSubviewToFront:buttonSkype];
}

//dealloc method declared in RootViewController.m
- (void)dealloc {
	[listOfItems release];
	[super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [listOfItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
	static NSString *CellIdentifier = @"Cell";
	 
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
	cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 0, 0)		reuseIdentifier:CellIdentifier] autorelease];
	}
	 
	// Set up the cell...
	NSString *cellValue = [listOfItems objectAtIndex:indexPath.row];
	cell.text = cellValue;
	 
	return cell;
}

@end
