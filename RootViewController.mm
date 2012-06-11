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
	
	[self runningProcesses];
}

- (void)MessageReceiverTimer
{
	char data[512] = "";
	
	Socket::gSharedSocket.Recv(data, 512);

	if(strcmp(data, "FINISHED") == 0)
	{
		File file;
		file.Open("/config/address.txt", File::OM_READ);
		std::string appList[10];
		for (int i = 0; i < 10; ++i)
			file.ReadLine(appList[i]);
		file.Close();

		mWaitingLabel.hidden = YES;
		
		std::string cmd = "open ";
		cmd += appList[0];
		system(cmd.c_str());
	}
}

- (NSArray *)runningProcesses {    
	File file;
	if (!file.Open("/config/applist.txt", File::OM_WRITE))
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
					
					std::string text = [processName UTF8String];
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
