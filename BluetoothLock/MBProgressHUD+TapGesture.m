//
//  MBProgressHUD+TapGesture.m
//  BluetoothLock
//
//  Created by qianyb on 16/1/24.
//  Copyright © 2016年 qianyb. All rights reserved.
//

#import "MBProgressHUD+TapGesture.h"
#import <objc/runtime.h>

#define DELEGATE_KEY_NAME @"tapGestureDelegate"

@implementation MBProgressHUD (TapGesture)

- (void)setTapGestureDelegate:(id<MBProgressHUDTapGestureDelegate>)delegate{
    objc_setAssociatedObject(self, DELEGATE_KEY_NAME, delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<MBProgressHUDTapGestureDelegate>)tapGestureDelegate{
    return objc_getAssociatedObject(self, DELEGATE_KEY_NAME);
}

- (void)addTapGesture{
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction)]];
}

#pragma mark - Tap Gesture Action
- (void)tapGestureAction{
    [self.tapGestureDelegate performSelector:@selector(didTapMBProgressHUD:) withObject:self];
}
@end
