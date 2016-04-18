//
//  MathUtil.m
//  BluetoothLock
//
//  Created by qianyb on 16/4/18.
//  Copyright © 2016年 qianyb. All rights reserved.
//

#import "MathUtil.h"

@implementation MathUtil

+ (unsigned int)getByte:(Byte)originByte atIndex:(int)index {
    unsigned int returnByte;
    switch(index){
        case 0:
            returnByte = originByte&1;
            break;
        case 1:
            returnByte = (originByte&2)>>1;
            break;
        case 2:
            returnByte = (originByte&4)>>2;
            break;
        case 3:
            returnByte = (originByte&8)>>3;
            break;
        case 4:
            returnByte = (originByte&16)>>4;
            break;
        case 5:
            returnByte = (originByte&32)>>5;
            break;
        case 6:
            returnByte = (originByte&64)>>6;
            break;
        default:
            returnByte = originByte&0x80>>7;
    }
    
    return returnByte;
}
@end
