//
//  ControllerView.h
//  RMBTController
//
//  Created by sonson on 2014/07/15.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ControllerView : NSView {
	IBOutlet NSTextView *_textView;
	NSMutableString *_log;
}

@end
