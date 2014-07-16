//
//  RMBTCommon.h
//  RMBTController
//
//  Created by sonson on 2014/07/14.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __MAC_OS_X_VERSION_MIN_REQUIRED
	#import <IOBluetooth/IOBluetooth.h>
#elif defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
	#import <CoreBluetooth/CoreBluetooth.h>
#endif

#define CBUUIDEqual(a, b) CFEqual((__bridge CFUUIDRef)a, (__bridge CFUUIDRef)b)

// Bluetooth LE UUID String
extern NSString	* const RMBTServiceUUIDString;
extern NSString	* const RMBTWriteLogCharacteristicUUIDString;
extern NSString	* const RMBTNotifyCommandCharacteristicUUIDString;
extern NSString * const RMBTWriteROMOAckCharacteristicUUIDString;

// Bluetooth LE UUID
#define	RMBTServiceUUID									[CBUUID UUIDWithString:RMBTServiceUUIDString]
#define RMBTWriteLogCharacteristicUUID					[CBUUID UUIDWithString:RMBTWriteLogCharacteristicUUIDString]
#define RMBTNotifyCommandCharacteristicUUID				[CBUUID UUIDWithString:RMBTNotifyCommandCharacteristicUUIDString]
#define RMBTWriteROMOAckCharacteristicUUID				[CBUUID UUIDWithString:RMBTWriteROMOAckCharacteristicUUIDString]

#define _DEBUG

#if TARGET_IPHONE_SIMULATOR
	#import <objc/objc-runtime.h>
#else
	#import <objc/runtime.h>
#endif

#ifdef	_DEBUG
	#define	DNSLog(...)		NSLog(__VA_ARGS__);
	#define DNSLogMethod	NSLog(@"[%s] %@", class_getName([self class]), NSStringFromSelector(_cmd));
	#define DNSLogPoint(p)	NSLog(@"%f,%f", p.x, p.y);
	#define DNSLogSize(p)	NSLog(@"%f,%f", p.width, p.height);
	#define DNSLogRect(p)	NSLog(@"%f,%f %f,%f", p.origin.x, p.origin.y, p.size.width, p.size.height);
#else
	#define DNSLog(...)		//
	#define DNSLogMethod	//
	#define DNSLogPoint(p)	//
	#define DNSLogSize(p)	//
	#define DNSLogRect(p)	//
#endif

@interface CBService (RMBTCommon)
- (void)log;
- (CBCharacteristic*)characteristicOfCharacteristicUUID:(CBUUID*)characteristicUUID;
@end


@interface CBPeripheral (RMBTCommon)
- (void)log;
- (CBCharacteristic*)characteristicOfCharacteristicUUID:(CBUUID*)characteristicUUID inService:(CBUUID*)serviceUUID;
@end