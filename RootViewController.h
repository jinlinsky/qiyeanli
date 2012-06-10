
@interface RootViewController: UIViewController {
	
	bool       mIsConnected;
	UILabel*   mWaitingLabel;
	UIButton*  mStartButton;
}

- (void)MessageReceiverTimer;

@end
