//
//  CBPeripheral+Equals.m
//  BluetoothLock
//
//  Created by qianyb on 16/1/24.
//  Copyright © 2016年 qianyb. All rights reserved.
//

#import "CBPeripheral+Equals.h"

@implementation CBPeripheral (Equals)

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![self isKindOfClass:[CBPeripheral class]]) {
        return NO;
    } else {
        return self.QYBName == [(CBPeripheral *)other QYBName];
    }
}

- (NSUInteger)hash
{
    return [self.QYBName hash];
}
@end
