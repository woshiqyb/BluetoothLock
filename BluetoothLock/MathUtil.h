//
//  MathUtil.h
//  BluetoothLock
//
//  Created by qianyb on 16/4/18.
//  Copyright © 2016年 qianyb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MathUtil : NSObject

/**
 *  获取一个字节中对应的对应位（bit）的值
 *
 *  @param originByte 字节
 *  @param index      位
 *
 *  @return 返回字节中对应位置的位值
 */
+ (unsigned int)getByte:(Byte)originByte atIndex:(int)index;
@end
