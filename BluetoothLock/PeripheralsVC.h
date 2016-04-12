//
//  peripheralsVC.h
//  BluetoothLock
//
//  Created by qianyb on 15/11/29.
//  Copyright © 2015年 qianyb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define NOT_REACHABLE_RSSI -90

extern NSString * const QYBCentralManagerDidDisconnectPeripheralNotification;

@interface PeripheralsVC : UIViewController

@property (strong, nonatomic) CBCentralManager *centralManager;
//可连接的的外设
@property (strong, nonatomic) NSMutableArray *peripheralsArray1;
//不可连接的外设
@property (strong, nonatomic) NSMutableArray *peripheralsArray2;

- (void)cancelPeripheralConnection;
@end
