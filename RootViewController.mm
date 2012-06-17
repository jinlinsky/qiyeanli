#import "RootViewController.h"
// import
#import <Foundation/NSTimer.h>
#import <sys/sysctl.h>
/*
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBUIController.h>
*/
// include
#include <string.h>
#include "Config.h"
#include "File.h"
#include "Socket.h"

std::string gAppList[10];

/*
@interface SBUIController (iOS40)
- (void)activateApplicationFromSwitcher:(SBApplication *)application;
@end
*/

@implementation RootViewController
- (void)loadView {
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	self.view.backgroundColor = [UIColor whiteColor];
	
	CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
	
	//----------------------------------------------------------
	// background
	//----------------------------------------------------------
	UIImageView* bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad_background.jpg"]];
	
	[self.view addSubview:bgImage];
	[self.view bringSubviewToFront:bgImage];
	[bgImage release];
	
	//----------------------------------------------------------
	// logo
	//----------------------------------------------------------
	UIImageView* logImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipad_icon.png"]];
	
	[self.view addSubview:logImage];
	[self.view bringSubviewToFront:logImage];
	[logImage release];
	
	//----------------------------------------------------------
	// start button
	//----------------------------------------------------------
	UIImage* buttonImage = [UIImage imageNamed:@"ipad_button.png"];
	
	float buttonWidth = buttonImage.size.width;
	float buttonHeight = buttonImage.size.height;
	
	mStartButton = [UIButton buttonWithType:UIButtonTypeCustom];
	mStartButton.frame = CGRectMake((screenFrame.size.width/2) - (buttonWidth/2), (screenFrame.size.height) - buttonHeight - 100, buttonWidth, buttonHeight);
	//[mStartButton setTitle: @"Start" forState:UIControlStateNormal];
	//[mStartButton setBackgroundImage:[UIImage imageNamed:@"ipad_button.png"] forState:UIControlStateNormal];
	[mStartButton setImage: buttonImage forState:UIControlStateNormal];
	[self.view addSubview:mStartButton];
	[self.view bringSubviewToFront:mStartButton];
	[mStartButton addTarget:self action:@selector(ButtonClickedStart) forControlEvents:UIControlEventTouchUpInside];
	
	//----------------------------------------------------------
	// initialize socket connection
	//----------------------------------------------------------
	Config config;
	bool loadConfig = config.LoadConfig("/config/config.txt");
	if (!loadConfig)
	{
		self.view.backgroundColor = [UIColor blueColor];
		return;
	}

	std::string ip   = config.GetText("ip");
	std::string port = config.GetText("port");
	for (int i = 0; i < 10; ++i)
	{
		char buffer[64];
		sprintf(buffer, "app_id_%d", i);

		gAppList[i] = config.GetText(buffer);
	}

	int connectResult = Socket::gSharedSocket.Connect(ip.c_str(), atoi(port.c_str()), false);
	if (connectResult == -1)
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
	[mStartButton release];
	mIsConnected = false;
	Socket::gSharedSocket.Disconnect();
}

- (void)ButtonClickedStart
{
	if (!Socket::gSharedSocket.IsConnected())
		return;
	
	const char* data = "START";

	int dataLength = strlen(data);

	Socket::gSharedSocket.Send(data, dataLength);
	
	mStartButton.hidden = YES;
	
	[self runningProcesses];
}

- (void)MessageReceiverTimer
{
	if (!Socket::gSharedSocket.IsConnected())
		return;
		
	char data[512] = "";
	
	Socket::gSharedSocket.Recv(data, 512);

	if(strcmp(data, "FINISHED") == 0)
	{
		mStartButton.hidden = NO;
		
		std::string cmd;
		cmd += "open";
		cmd += " ";
		cmd += gAppList[0];
		
		cmd.erase(std::remove(cmd.begin(), cmd.end(), '\t'), cmd.end());
		cmd.erase(std::remove(cmd.begin(), cmd.end(), '\r'), cmd.end());
		cmd.erase(std::remove(cmd.begin(), cmd.end(), '\n'), cmd.end());
		
		
		const char* data = "OPENED";

		int dataLength = strlen(data);

		Socket::gSharedSocket.Send(data, dataLength);
		
		system(cmd.c_str());
		 
		/*
		NSString* appId = [[NSString alloc] initWithUTF8String: gAppList[0].c_str()];
		
		SBApplication *application = [[SBApplicationController sharedInstance] applicationWithDisplayIdentifier:appId];
		[[SBUIController sharedInstance] activateApplicationFromSwitcher:application];
		*/
	}
}

- (NSArray *)runningProcesses {    
	File file;
	if (!file.Open("/config/process_info.txt", File::OM_WRITE))
		return nil;
  
	int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};     
	size_t miblen = 4;      
	size_t size;     
	int st = sysctl(mib, miblen, NULL, &size, NULL, 0);      
	struct kinfo_proc * process = NULL;     
	struct kinfo_proc * newprocess = NULL;      
	
	do {          
		size += size / 10;         
		newprocess = (struct kinfo_proc *)realloc(process, size);          
		if (!newprocess)
		{              
			if (process)
			{                 
				free(process);             
			}              
			return nil;         
		}          
		
		process = newprocess;         
		st = sysctl(mib, miblen, process, &size, NULL, 0);      
	} while (st == -1 && errno == ENOMEM);     
	
	if (st == 0)
	{          
		if (size % sizeof(struct kinfo_proc) == 0)
		{             
			int nprocess = size / sizeof(struct kinfo_proc); 
			if (nprocess)
			{                  
				NSMutableArray * array = [[NSMutableArray alloc] init];                  
				for (int i = nprocess - 1; i >= 0; i--)
				{
					NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];                     
					NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];                      
					
					std::string text = [processID UTF8String];
					file.WriteLine(text);
					text = [processName UTF8String];
					file.WriteLine(text);

					NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, nil]                                                                          
					forKeys:[NSArray arrayWithObjects:@"ProcessID", @"ProcessName", nil]];                     
					[processID release];                     
					[processName release];                     
					[array addObject:dict];                     
					[dict release];                 
				}
				                  
				free(process);                 
				return [array autorelease];             
			}         
		}     
	}      
	return nil; 
} 
@end
