
@interface RootViewController: UIViewController {
	
	bool       mIsConnected;
	UIButton*  mStartButton;
}

- (void)MessageReceiverTimer;
- (NSArray *)runningProcesses;
@end
