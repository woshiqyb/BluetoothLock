//
//  CBPeripheral+RSSI.m
//  BluetoothLock
//
//  Created by qianyb on 15/11/29.
//  Copyright © 2015年 qianyb. All rights reserved.
//

#import <objc/runtime.h>
#import "CBPeripheral+RSSI.h"

NSString *const RSSIKey = @"qyb_rssi";

const char *nameKey = "qyb_name";

@implementation CBPeripheral (RSSI)

- (NSNumber *)QYBRSSI{
    return objc_getAssociatedObject(self, (__bridge const void *)(RSSIKey));
}

- (void)setQYBRSSI:(NSNumber *)RSSI{
    objc_setAssociatedObject(self, (__bridge const void *)(RSSIKey), RSSI, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setQYBName:(NSString *)name{
    objc_setAssociatedObject(self, nameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)QYBName {
    return objc_getAssociatedObject(self, nameKey);
}
@end
