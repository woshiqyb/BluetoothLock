//
//  MBProgressHUD+TapGesture.h
//  BluetoothLock
//
//  Created by qianyb on 16/1/24.
//  Copyright © 2016年 qianyb. All rights reserved.
//

#import "MBProgressHUD.h"

@class MBProgressHUD;

@protocol MBProgressHUDTapGestureDelegate <NSObject>
@required
- (void)didTapMBProgressHUD:(MBProgressHUD *)hud;

@end

@interface MBProgressHUD (TapGesture)
- (void)setTapGestureDelegate:(id<MBProgressHUDTapGestureDelegate>)delegate;

- (id<MBProgressHUDTapGestureDelegate>)tapGestureDelegate;

- (void)addTapGesture;
@end
