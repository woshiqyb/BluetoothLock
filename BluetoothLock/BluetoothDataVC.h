//
//  BluetoothDataVC.h
//  BluetoothLock
//
//  Created by qianyb on 15/11/29.
//  Copyright © 2015年 qianyb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface BluetoothDataVC : UIViewController

@property (weak, nonatomic) PeripheralsVC *perVC;
@property (copy, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) CBService *bluetoothService;
@property (strong, nonatomic) CBService *serialService;
@end
