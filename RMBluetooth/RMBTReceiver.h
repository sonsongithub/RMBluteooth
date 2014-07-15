//
//  RMBTReceiver.h
//  RMBTReceiver
//
//  Created by sonson on 2014/07/14.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString	* const RMBTControllerDidChangePeripheralManagerStatus;

@class RMBTPeripheralInfo;

@interface RMBTReceiver : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic, readonly) NSMutableArray *peripherals;
- (void)connectPeripheral:(RMBTPeripheralInfo*)peripheral;
- (BOOL)isConnected;
- (void)disconnect;
- (void)sendString:(NSString*)string;
@end
