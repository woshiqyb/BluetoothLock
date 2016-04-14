//
//  BluetoothDataVC.m
//  BluetoothLock
//
//  Created by qianyb on 15/11/29.
//  Copyright © 2015年 qianyb. All rights reserved.
//
#import "PeripheralsVC.h"
#import "BluetoothDataVC.h"
#import "BluetoothDataFactory.h"

/**
 *  当前操作指令类型
 */
typedef NS_ENUM(NSInteger,BluetoothOperationType) {
    /**
     *  未操作
     */
    BluetoothOperationTypeNone = 0,
    /**
     *  打开设备
     */
    BluetoothOperationTypeOpen = 1,
    /**
     *  关闭设备
     */
    BluetoothOperationTypeClose = 2,
};

#define OperationStatePrefix @"操作状态："

@interface BluetoothDataVC ()<CBPeripheralDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *operationStateLabel;
@property (weak, nonatomic) IBOutlet UIButton *openButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *openButton2;
@property (weak, nonatomic) IBOutlet UIButton *closeButton2;
@property (weak, nonatomic) IBOutlet UIImageView *lockStateImageView;

@end

@implementation BluetoothDataVC{
    CBCharacteristic *bluetoothCharacteristic;
    CBCharacteristic *serialCharacteristic;
    
    BluetoothOperationType operationType;
    
    NSString *deviceIDHexString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _operationStateLabel.text = OperationStatePrefix;
    
    self.title = _peripheral.QYBName;
    
    _peripheral.delegate = self;
    if (_bluetoothService) {
        [_peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:BluetoothDataCharacteristics_UUID]] forService:_bluetoothService];
    }
    if (_serialService) {
        [_peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:SerialDataCharacteristics_UUID]] forService:_serialService];
    }
    
    deviceIDHexString = [_peripheral.name substringFromIndex:_peripheral.name.length - 4];
    
    [_openButton2 layoutIfNeeded];
    _openButton2.layer.cornerRadius = CGRectGetHeight(_openButton2.bounds)/2;
    _openButton2.layer.masksToBounds = YES;
    
    [_closeButton2 layoutIfNeeded];
    _closeButton2.layer.cornerRadius = CGRectGetHeight(_closeButton2.bounds)/2;
    _closeButton2.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(centralManagerDidDisconnectPeripheralNotificationAction:) name:QYBCentralManagerDidDisconnectPeripheralNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QYBCentralManagerDidDisconnectPeripheralNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    
}

#pragma mark - Initialization


- (void)lockStateOpened{
    _lockStateImageView.image = [UIImage imageNamed:@"openState.jpeg"];
}

- (void)lockStateClosed{
    _lockStateImageView.image = [UIImage imageNamed:@"closeState.jpeg"];
}

#pragma mark - UIButton Action
- (IBAction)openThePeripheral {
    [self.view endEditing:YES];
    
    if (bluetoothCharacteristic) {
        operationType = BluetoothOperationTypeOpen;
        showManualHideHud(@"开锁中请等待...", MBProgressHUDModeIndeterminate);
        [_peripheral writeValue:[BluetoothDataFactory openningDataWithDeviceId:deviceIDHexString] forCharacteristic:bluetoothCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (IBAction)closeThePeripheral {
    if (bluetoothCharacteristic) {
        operationType = BluetoothOperationTypeClose;
        showManualHideHud(@"关锁中请等待...", MBProgressHUDModeIndeterminate);
        [_peripheral writeValue:[BluetoothDataFactory closingDataWithDeviceId:deviceIDHexString] forCharacteristic:bluetoothCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark - CBPeripheralDelegate
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(nullable NSError *)error NS_DEPRECATED(NA, NA, 5_0, 8_0) {

}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error NS_AVAILABLE(NA, 8_0) {
    if ([RSSI floatValue] <= NOT_REACHABLE_RSSI) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        showErrorHud(@"未发现特征");
    }
    
    if ([service isEqual:_serialService]){
        serialCharacteristic = [[service.characteristics filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.UUID.UUIDString == %@",SerialDataCharacteristics_UUID]] firstObject];
        if (serialCharacteristic) {
            //数据串口通道连接以后去获取设备状态
            [_peripheral setNotifyValue:YES forCharacteristic:serialCharacteristic];
        }
    }
    
    if ([service isEqual:_bluetoothService]){
        bluetoothCharacteristic = [[service.characteristics filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.UUID.UUIDString == %@",BluetoothDataCharacteristics_UUID]] firstObject];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (!error && serialCharacteristic) {
        [_peripheral setNotifyValue:YES forCharacteristic:serialCharacteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (!error && [serialCharacteristic isEqual:characteristic]) {
        [_peripheral setNotifyValue:NO forCharacteristic:serialCharacteristic];
    }
    
    if (!error) {
        NSData *data = characteristic.value;
        
        NSString *dataString = [NSString stringWithFormat:@"%@",data];
        _operationStateLabel.text = dataString;
        
        Byte *byteAll = (Byte *)[data bytes];
        
        Byte deviceState = byteAll[4];
        
        hideManualHud(0);
        if (deviceState == 0x01) {//成功
            showSuccessHud(@"操作成功");
            if (operationType != BluetoothOperationTypeNone) {
                if (operationType == BluetoothOperationTypeClose) {
                    [self lockStateClosed];
                }else{
                    [self lockStateOpened];
                }
            }
            
        }else if (deviceState == 0x02){//失败
            showSuccessHud(@"操作失败");
        }else if (deviceState == 0x05){//地锁打开状态
            [self lockStateOpened];
        }else if (deviceState == 0x06){//地锁关闭状态
            [self lockStateClosed];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if ([serialCharacteristic isEqual:characteristic]) {
        NSLog(@"串口数据监听调整");
    }
}

#pragma mark - NSNotificationAction
- (void)centralManagerDidDisconnectPeripheralNotificationAction:(NSNotification *)notification{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Tap Gesture Action
- (void)didTapMBProgressHUD:(MBProgressHUD *)hud{
    [hud hide:YES];
    [_perVC cancelPeripheralConnection];
}
@end
