#import "RootViewController.h"
// import
#import "File.h"
#import "Socket.h"
#import <Foundation/NSTimer.h>
#import <sys/sysctl.h>
// include
#include <string.h>

@implementation RootViewController
- (void)loadView {
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	self.view.backgroundColor = [UIColor whiteColor];
	
	CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
	
	//----------------------------------------------------------
	// start button
	//----------------------------------------------------------
	float buttonSize = 300.0f;
	
	mStartButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	mStartButton.frame = CGRectMake((screenFrame.size.width/2) - (buttonSize/2), (screenFrame.size.height) - buttonSize - 100, buttonSize, buttonSize);
	[mStartButton setTitle: @"Start" forState:UIControlStateNormal];
	[mStartButton setTitle: @"Start" forState:UIControlStateHighlighted];
	[mStartButton addTarget:self action:@selector(ButtonClickedStart) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:mStartButton];
	//[self.view bringSubviewToFront:mStartButton];
	
	//----------------------------------------------------------
	// wating label
	//----------------------------------------------------------
	CGRect labelFrame = screenFrame;
	labelFrame.origin.x = 0;
	labelFrame.origin.y = 0;
	
	mWaitingLabel = [[UILabel alloc] initWithFrame:labelFrame];
	mWaitingLabel.numberOfLines = 0;
	mWaitingLabel.textAlignment = UITextAlignmentCenter;
	mWaitingLabel.text = [[NSString alloc] initWithString:@"Waiting..."];
	[self.view addSubview:mWaitingLabel];
	//[self.view bringSubviewToFront:mWaitingLabel];
	mWaitingLabel.hidden = YES;
	
	//----------------------------------------------------------
	// initialize socket connection
	//----------------------------------------------------------
	File file;
	bool isFileOpenOK = (int)file.Open("/config/qiyeanli.txt", File::OM_READ);
	if (!isFileOpenOK)
	{
		self.view.backgroundColor = [UIColor blueColor];
		return;
	}

	std::string ip;
	std::string port;
	file.ReadLine(ip);
	file.ReadLine(port);
	file.Close();

	int result = Socket::gSharedSocket.Connect(ip.c_str(), atoi(port.c_str()));
	if (result == -1)
	{
		self.view.backgroundColor = [UIColor redColor];
		return;
	}
	
	mIsConnected = true;
	
	//----------------------------------------------------------
	// setup timer
	//----------------------------------------------------------
	NSTimer* timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(MessageReceiverTimer) userInfo:nil repeats:YES]; 
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


- (void)viewDidUnload
{
	[mWaitingLabel.text release];
	[mWaitingLabel release];
	[mStartButton release];
	mIsConnected = false;
	Socket::gSharedSocket.Disconnect();
}

- (void)ButtonClickedStart
{
	if (!mIsConnected) return;
	
	const char* data = "START";

	int dataLength = strlen(data);

	Socket::gSharedSocket.Send(data, dataLength);
	
	mWaitingLabel.hidden = NO;
}

- (void)MessageReceiverTimer
{
	char data[512] = "";
	
	Socket::gSharedSocket.Recv(data, 512);

	if(strcmp(data, "FINISHED") == 0)
	{
		mWaitingLabel.hidden = YES;
		system("open com.ted.TED");
	}
}

@end
