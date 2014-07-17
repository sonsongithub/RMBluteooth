//
//  ViewController.m
//  RMBTControllerSample
//
//  Created by sonson on 2014/07/14.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "ViewController.h"

#import "RMBTController.h"

@interface ViewController () <RMBTControllerDelegate> {
	IBOutlet UITextView *_textView;
	NSMutableString *_log;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[[RMBTController sharedInstance] setDelegate:self];
	_log = [NSMutableString string];
}

- (void)controller:(RMBTController*)controller didReceiveLog:(NSString*)log {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateStyle = NSDateFormatterMediumStyle;
	formatter.timeStyle = NSDateFormatterMediumStyle;
	[_log appendFormat:@"[%@] %@\r", [formatter stringFromDate:[NSDate date]], log];
	_textView.text = _log;
}

- (IBAction)forward:(id)sender {
	[[RMBTController sharedInstance] sendChar:'f'];
}

- (IBAction)backward:(id)sender {
	[[RMBTController sharedInstance] sendChar:'b'];
}

- (IBAction)right:(id)sender {
	[[RMBTController sharedInstance] sendChar:'r'];
}

- (IBAction)left:(id)sender {
	[[RMBTController sharedInstance] sendChar:'l'];
}

- (IBAction)stop:(id)sender {
	[[RMBTController sharedInstance] sendChar:'s'];
}

- (IBAction)tiltPlus:(id)sender {
	[[RMBTController sharedInstance] sendChar:'p'];
}

- (IBAction)tiltMinus:(id)sender {
	[[RMBTController sharedInstance] sendChar:'m'];
}

@end
