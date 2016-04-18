//
//  BluetoothDataFactory.m
//  BluetoothLock
//
//  Created by qianyb on 16/4/14.
//  Copyright © 2016年 qianyb. All rights reserved.
//

#import "BluetoothDataFactory.h"
#include "crc.h"
#import "MathUtil.h"

NSString * const kDumpEnergyInfoKey = @"com.qyb.kDumpEnergyInfoKey";
NSString * const kLockStateInfoKey = @"com.qyb.kLockStateInfoKey";
NSString * const kParkingStateInfoKey = @"com.qyb.kParkingStateInfoKey";
NSString * const kSystemLockStateInfoKey = @"com.qyb.kSystemLockStateInfoKey";

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

+ (NSString *)systemStateInfoWithSystemStateCode:(Byte)stateCode {
    NSString *stateInfo;
    switch (stateCode) {
        //－－－－－－－开锁相关状态－－－－－－－
        case 0x01:
            stateInfo = @"433请求开锁";
            break;
        case 0x02:
            stateInfo = @"ZIGBEE请求开锁";
            break;
        case 0x03:
            stateInfo = @"BLE请求开锁";
            break;
        case 0x04:
            stateInfo = @"BLE请求开锁(高级用户)";
            break;
        case 0x05:
            stateInfo = @"倒下去3分钟未检测到车辆自动抬起";
            break;
        case 0x06:
            stateInfo = @"车走后自动抬起";
            break;
        //－－－－－－－关锁相关状态－－－－－－－
        case 0x08:
            stateInfo = @"433请求关锁";
            break;
        case 0x09:
            stateInfo = @"ZIGBEE请求关锁";
            break;
        case 0x0A:
            stateInfo = @"BLE请求关锁";
            break;
        case 0x0B:
            stateInfo = @"BLE请求关锁(高级用户)";
            break;
        case 0x0C:
            stateInfo = @"上升过载重试中关锁";
            break;
        case 0x0D:
            stateInfo = @"上升过载重试三次也法完成";
            break;
        //－－－－－－－D相关状态－－－－－－－
        case 0xD0:
            stateInfo = @"系统被ZIGBEE锁住";
            break;
        case 0xD2:
            stateInfo = @"系统被433锁住";
            break;
        case 0xD5:
            stateInfo = @"系统被ZIGBEE解锁";
            break;
        case 0xD7:
            stateInfo = @"系统被433解锁";
            break;
        //－－－－－－－正常状态－－－－－－－
        //正常完成, 上传数据后自动加0X40
        case 0x51:
        case 0x91:
            stateInfo = @"433请求开锁";
            break;
        case 0x52:
        case 0x92:
            stateInfo = @"ZIGBEE请求开锁";
            break;
        case 0x53:
        case 0x93:
            stateInfo = @"BLE请求开锁";
            break;
        case 0x54:
        case 0x94:
            stateInfo = @"BLE请求开锁(高级用户)";
            break;
        case 0x55:
        case 0x95:
            stateInfo = @"倒下去3分钟未检测到车辆自动抬起";
            break;
        case 0x56:
        case 0x96:
            stateInfo = @"车走后自动抬起";
            break;
        case 0x58:
        case 0x98:
            stateInfo = @"433请求关闭";
            break;
        case 0x59:
        case 0x99:
            stateInfo = @"ZIGBEE请求关闭";
            break;
        case 0x5A:
        case 0x9A:
            stateInfo = @"BLE请求关闭";
            break;
        case 0x5B:
        case 0x9B:
            stateInfo = @"BLE请求关锁(高级用户)";
            break;
        case 0x5C:
        case 0x9C:
            stateInfo = @"上升过载重试中关锁";
            break;
        case 0x5D:
        case 0x9D:
            stateInfo = @"上升过载重试三次也法完成";
            break;
        //－－－－－－－过电流状态－－－－－－－
        //正常完成, 上传数据后自动加0X40
        case 0x61:
        case 0xA1:
            stateInfo = @"433请求开锁";
            break;
        case 0x62:
        case 0xA2:
            stateInfo = @"ZIGBEE请求开锁";
            break;
        case 0x63:
        case 0xA3:
            stateInfo = @"BLE请求开锁";
            break;
        case 0x64:
        case 0xA4:
            stateInfo = @"BLE请求开锁(高级用户)";
            break;
        case 0x65:
        case 0xA5:
            stateInfo = @"倒下去3分钟未检测到车辆自动抬起";
            break;
        case 0x66:
        case 0xA6:
            stateInfo = @"车走后自动抬起";
            break;
        case 0x68:
        case 0xA8:
            stateInfo = @"433请求关闭";
            break;
        case 0x69:
        case 0xA9:
            stateInfo = @"ZIGBEE请求关闭";
            break;
        case 0x6A:
        case 0xAA:
            stateInfo = @"BLE请求关闭";
            break;
        case 0x6B:
        case 0xAB:
            stateInfo = @"BLE请求关锁(高级用户)";
            break;
        case 0x6C:
        case 0xAC:
            stateInfo = @"上升过载重试中关锁";
            break;
        case 0x6D:
        case 0xAD:
            stateInfo = @"上升过载重试三次也法完成";
            break;
        //－－－－－－－超时状态－－－－－－－
        //正常完成, 上传数据后自动加0X40
        case 0x71:
        case 0xB1:
            stateInfo = @"433请求开锁";
            break;
        case 0x72:
        case 0xB2:
            stateInfo = @"ZIGBEE请求开锁";
            break;
        case 0x73:
        case 0xB3:
            stateInfo = @"BLE请求开锁";
            break;
        case 0x74:
        case 0xB4:
            stateInfo = @"BLE请求开锁(高级用户)";
            break;
        case 0x75:
        case 0xB5:
            stateInfo = @"倒下去3分钟未检测到车辆自动抬起";
            break;
        case 0x76:
        case 0xB6:
            stateInfo = @"车走后自动抬起";
            break;
        case 0x78:
        case 0xB8:
            stateInfo = @"433请求关闭";
            break;
        case 0x79:
        case 0xB9:
            stateInfo = @"ZIGBEE请求关闭";
            break;
        case 0x7A:
        case 0xBA:
            stateInfo = @"BLE请求关闭";
            break;
        case 0x7B:
        case 0xBB:
            stateInfo = @"BLE请求关锁(高级用户)";
            break;
        case 0x7C:
        case 0xBC:
            stateInfo = @"上升过载重试中关锁";
            break;
        case 0x7D:
        case 0xBD:
            stateInfo = @"上升过载重试三次也法完成";
            break;
        //－－－－－－－系统异常复位状态－－－－－－－
        case 0x80:
        case 0xC0:
            stateInfo = @"系统开机代码(复位或者重启)";
            break;
        default:
            break;
    }
    
    return stateInfo;
}

+ (NSDictionary *)deviceStateInfoWithDeviceStateCode:(Byte)stateCode {
    unsigned int i0 = [MathUtil getByte:stateCode atIndex:0];
    unsigned int i1 = [MathUtil getByte:stateCode atIndex:1];
    unsigned int i2 = [MathUtil getByte:stateCode atIndex:2];
    unsigned int i3 = [MathUtil getByte:stateCode atIndex:3];
    unsigned int i4 = [MathUtil getByte:stateCode atIndex:4];
    unsigned int i5 = [MathUtil getByte:stateCode atIndex:5];
    
    NSString *dumpEnergyInfo;
    NSString *lockStateInfo;
    NSString *parkingStateInfo;
    NSString *systemLockStateInfo;
    if (i0 == i1 && i1 == i2) {
        if (i0 == 0) {
            dumpEnergyInfo = @"00%";
        }else {
            dumpEnergyInfo = @"100%";
        }
    }else if (i0 == 1 && i1 == i2 && i2 == 0) {
        dumpEnergyInfo = @"15%";
    }else if (i0 == i1 && i1 == 1 && i2 == 0) {
        dumpEnergyInfo = @"30%";
    }else if (i0 == i2 && i2 == 0 && i1 == 1) {
        dumpEnergyInfo = @"45%";
    }else if (i0 == i1 && i1 == 0 && i2 == 1) {
        dumpEnergyInfo = @"60%";
    }else if (i0 == i2 && i2 == 1 && i1 == 0) {
        dumpEnergyInfo = @"75%";
    }else if (i0 == 0 && i1 == i2 && i2 == 1) {
        dumpEnergyInfo = @"90%";
    }
    
    if (i3 == 1) {
        lockStateInfo = @"地锁开";
    }else {
        lockStateInfo = @"地锁关";
    }
    
    if (i4 == 1) {
        parkingStateInfo = @"有车";
    }else {
        parkingStateInfo = @"没有车";
    }
    
    if (i5 == 1) {
        systemLockStateInfo = @"系统被锁住";
    }else {
        systemLockStateInfo = @"系统没有被锁住";
    }
    
    return @{kDumpEnergyInfoKey:dumpEnergyInfo,
             kLockStateInfoKey:lockStateInfo,
             kParkingStateInfoKey:parkingStateInfo,
             kSystemLockStateInfoKey:systemLockStateInfo
             };
}
@end
