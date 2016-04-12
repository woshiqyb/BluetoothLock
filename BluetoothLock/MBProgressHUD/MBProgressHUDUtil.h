//
//  MBProgressHUDUtil.h
//  BluetoothLock
//
//  Created by 钱洋彪 on 15/11/30.
//  Copyright © 2015年 qianyb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBProgressHUDUtil : NSObject
+ (UIWindow *)sharedWindow;
+ (MBProgressHUD *)sharedHUD;
@end
