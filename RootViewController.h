
@interface RootViewController: UIViewController {
	UIButton*  mStartButton;
	
	NSString* mIp; 
	NSString* mPort;
}

- (void)MessageReceiverTimer;
- (NSArray *)runningProcesses;
@end
