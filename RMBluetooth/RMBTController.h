//
//  RMBTController.h
//  RMBTController
//
//  Created by sonson on 2014/07/14.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RMBTController;

@protocol  RMBTControllerDelegate <NSObject>
- (void)controller:(RMBTController*)controller didReceiveLog:(NSString*)log;
@end

@interface RMBTController : NSObject

@property (nonatomic, assign) id <RMBTControllerDelegate> delegate;

+ (instancetype)sharedInstance;

@end
