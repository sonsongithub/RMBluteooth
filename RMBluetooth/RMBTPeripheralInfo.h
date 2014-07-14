//
//  RMBTPeripheralInfo.h
//  RMBTReceiver
//
//  Created by sonson on 2014/07/14.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMBTCommon.h"

@interface RMBTPeripheralInfo : NSObject

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, copy) NSDictionary *advertisementData;

@end
