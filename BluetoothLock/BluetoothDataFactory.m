//
//  BluetoothDataFactory.m
//  BluetoothLock
//
//  Created by qianyb on 16/4/14.
//  Copyright © 2016年 qianyb. All rights reserved.
//

#import "BluetoothDataFactory.h"
#include "crc.h"

@implementation BluetoothDataFactory

+ (NSData *)closingDataWithDeviceId:(NSString *)deviceIDHexString {

    return [self dataWithDeviceId:deviceIDHexString operationCode:0x01];
}

+ (NSData *)openningDataWithDeviceId:(NSString *)deviceIDHexString {
    
    return [self dataWithDeviceId:deviceIDHexString operationCode:0x02];
}

+ (NSData *)dataWithDeviceId:(NSString *)deviceIDHexString operationCode:(unsigned int)operationCode {
    unsigned int deviceID = (unsigned int)[deviceIDHexString intValue];
    
    Byte byte[11];
    byte[0] = 0x7F;
    byte[1] = 0x7F;
    byte[2] = 0x00;
    byte[3] = ((deviceID&0xffff)>>8)&0xff;
    byte[4] = deviceID&0xff;
    byte[5] = operationCode&0xff;
    byte[6] = 0x00;
    
    unsigned char * crcHexChar = byte;
    unsigned int crc = byte_crc(crcHexChar, 7);
    byte[7] = ((crc&0xff00)>>8)&0xff;
    byte[8] = crc&0xff;
    byte[9] = 0x0d;
    byte[10] = 0x0a;
    
    return [NSMutableData dataWithBytes:byte length:11];
}

+ (NSData*)hexToBytes:(NSString *)hexString{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= hexString.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
@end
