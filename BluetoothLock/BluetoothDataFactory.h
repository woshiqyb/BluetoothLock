//
//  BluetoothDataFactory.h
//  BluetoothLock
//
//  Created by qianyb on 16/4/14.
//  Copyright © 2016年 qianyb. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  电池电量
 */
extern NSString * const kDumpEnergyInfoKey;
/**
 *  地锁开关状态
 */
extern NSString * const kLockStateInfoKey;
/**
 *  是否有车
 */
extern NSString * const kParkingStateInfoKey;
/**
 *  系统是否被锁住
 */
extern NSString * const kSystemLockStateInfoKey;

@interface BluetoothDataFactory : NSObject

+ (NSData *)closingDataWithDeviceId:(NSString *)deviceIDHexString;
+ (NSData *)openningDataWithDeviceId:(NSString *)deviceIDHexString;

/**
 *  根据系统状态码获取系统状态描述
 *
 *  @param stateCode 系统状态码
 *
 *  @return 系统状态描述
 */
+ (NSString *)systemStateInfoWithSystemStateCode:(Byte)stateCode;

/**
 *  根据设备状态码获取设备状态描述
 *
 *  @param stateCode 设备状态码
 *
 *  @return 设备状态描述
 */
+ (NSDictionary *)deviceStateInfoWithDeviceStateCode:(Byte)stateCode;
@end
