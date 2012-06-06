int main(int argc, char **argv) {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	int ret = UIApplicationMain(argc, argv, @"FeiLaiFeiQuDemoApplication", @"FeiLaiFeiQuDemoApplication");
	[p drain];
	return ret;
}

// vim:ft=objc
