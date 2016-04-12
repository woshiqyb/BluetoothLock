//
//  MBProgressHUDUtil.m
//  BluetoothLock
//
//  Created by 钱洋彪 on 15/11/30.
//  Copyright © 2015年 qianyb. All rights reserved.
//

#import "MBProgressHUDUtil.h"
static UIWindow *sharedWindow;
static MBProgressHUD *sharedHUD;

@implementation MBProgressHUDUtil

+ (UIWindow *)sharedWindow{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWindow = [[UIApplication sharedApplication] keyWindow];
    });
    
    return sharedWindow;
}

+ (MBProgressHUD *)sharedHUD{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHUD = [MBProgressHUD new];
        [sharedHUD addTapGesture];
        sharedHUD.removeFromSuperViewOnHide = YES;
    });
    
    return sharedHUD;
}
@end
