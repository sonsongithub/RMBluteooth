//
//  AppDelegate.m
//  RMBTControllerSampleOSX
//
//  Created by sonson on 2014/07/14.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "AppDelegate.h"
#import "RMBTController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[RMBTController sharedInstance];
	// Insert code here to initialize your application
}

@end
