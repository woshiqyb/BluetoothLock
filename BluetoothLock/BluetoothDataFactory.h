//
//  BluetoothDataFactory.h
//  BluetoothLock
//
//  Created by qianyb on 16/4/14.
//  Copyright © 2016年 qianyb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BluetoothDataFactory : NSObject

+ (NSData *)closingDataWithDeviceId:(NSString *)deviceIDHexString;
+ (NSData *)openningDataWithDeviceId:(NSString *)deviceIDHexString;

@end
