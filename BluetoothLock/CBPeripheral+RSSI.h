//
//  CBPeripheral+RSSI.h
//  BluetoothLock
//
//  Created by qianyb on 15/11/29.
//  Copyright © 2015年 qianyb. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (RSSI)

- (NSNumber *)QYBRSSI;
- (NSString *)QYBName;
- (void)setQYBRSSI:(NSNumber *)RSSI;
- (void)setQYBName:(NSString *)name;
@end
