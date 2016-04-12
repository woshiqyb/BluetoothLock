//
//  peripheralsVC.m
//  BluetoothLock
//
//  Created by qianyb on 15/11/29.
//  Copyright © 2015年 qianyb. All rights reserved.
//

#import "PeripheralsVC.h"
#import "CBPeripheral+RSSI.h"
#import "MJRefresh.h"
#import "BluetoothDataVC.h"
#import "CBPeripheral+Equals.h"

#define CONNECT_MESSAGE @"地锁连接中..."
#define CONNECT_FAILED_MESSAGE @"地锁连接失败"

NSString * const QYBCentralManagerDidDisconnectPeripheralNotification = @"com.vic.qyb.centralManagerDidDisconnectPeripheralNotification";

@interface PeripheralsVC ()<UITableViewDataSource,UITableViewDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,MBProgressHUDTapGestureDelegate>

@property (weak, nonatomic) IBOutlet UITableView *peripheralTableView;
@end

@implementation PeripheralsVC{
    NSIndexPath *selectedIndex;
    NSTimer *timer;
    
    BOOL canFire;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    canFire = YES;
    
    __weak typeof(self) weakSelf = self;
    _peripheralTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        
        strongSelf->selectedIndex = nil;
        [strongSelf.peripheralsArray1 removeAllObjects];
        [strongSelf.peripheralsArray2 removeAllObjects];
        [strongSelf reloadPeripheralTableViewOnMainQueue];
        
        [strongSelf startTimer];
    }];
    
    [[MBProgressHUDUtil sharedHUD] setTapGestureDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //cancel掉连接之后，会自动refresh，refresh的block中已经启用了定时器
    [self cancelPeripheralConnection];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopTimer];
}

- (NSTimer *)timer {
    if (!timer) {
        timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(scanPeripheral) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
    
    return timer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialization
- (NSMutableArray *)peripheralsArray1{
    if (!_peripheralsArray1) {
        _peripheralsArray1 = [NSMutableArray array];
    }
    
    return _peripheralsArray1;
}

- (NSMutableArray *)peripheralsArray2{
    if (!_peripheralsArray2) {
        _peripheralsArray2 = [NSMutableArray array];
    }
    
    return _peripheralsArray2;
}

#pragma mark - UITableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @[@"可连接",@"不可连接"][section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [@[self.peripheralsArray1,self.peripheralsArray2][section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    CBPeripheral *peripheral = @[self.peripheralsArray1,self.peripheralsArray2][indexPath.section][indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"车位：%@", peripheral.QYBName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"信号:%@",peripheral.QYBRSSI];
    if ([peripheral.QYBRSSI intValue] <= NOT_REACHABLE_RSSI) {
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

#pragma mark - UITableView Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {//不可连接的
        return;
    }
    
    showManualHideHud(CONNECT_MESSAGE, MBProgressHUDModeIndeterminate);
    selectedIndex = indexPath;
    [_centralManager connectPeripheral:self.peripheralsArray1[indexPath.row] options:nil];
}

#pragma mark - ReloadTableView
- (void)reloadPeripheralTableViewOnMainQueue{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_peripheralTableView.header endRefreshing];
        [_peripheralTableView reloadData];
    });
}

#pragma mark - MBProgressHUDTapGestureDelegate
- (void)didTapMBProgressHUD:(MBProgressHUD *)hud{
    [hud hide:YES];
    [self cancelPeripheralConnection];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self startTimer];
    }else{
        showErrorHud(@"请检查蓝牙是否打开");
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    //过滤掉信号强度不是负数的
    if ([RSSI floatValue] >= 0) {
        canFire = YES;
        return;
    }
    //过滤掉不是TJSP的蓝牙名
    NSString *localName = advertisementData[CBAdvertisementDataLocalNameKey];
    if (![localName hasPrefix:@"TJSP"]) {
        canFire = YES;
        return;
    }
    
    peripheral.QYBName = localName;
    NSString *deviceID = [peripheral.name substringFromIndex:peripheral.name.length - 4];
    
    unsigned int stringValue;
    NSScanner *scanner = [NSScanner scannerWithString:deviceID];
    [scanner scanHexInt:&stringValue];
    
    if (stringValue <= 0xFFFF) {
        [self savePeripheral:peripheral withRSSI:RSSI];
    }
    canFire = YES;
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    showManualHideHud(CONNECT_MESSAGE, MBProgressHUDModeIndeterminate);
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:BluetoothDataService_UUID],[CBUUID UUIDWithString:SerialDataService_UUID]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    hideManualHud(0);
    showErrorHud(CONNECT_FAILED_MESSAGE);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    hideManualHud(0);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QYBCentralManagerDidDisconnectPeripheralNotification object:error];
    
    [_peripheralTableView.header beginRefreshing];
}


#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (!error) {
        CBService *bluetoothService = [[peripheral.services filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.UUID.UUIDString == %@",BluetoothDataService_UUID]] firstObject];
        CBService * serialService = [[peripheral.services filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.UUID.UUIDString == %@",SerialDataService_UUID]] firstObject];
        
        BluetoothDataVC *vc = Main_SB_VC(@"BluetoothDataVC");
        vc.peripheral = peripheral;
        vc.bluetoothService = bluetoothService;
        vc.serialService = serialService;
        [self.navigationController pushViewController:vc animated:YES];
    }
    hideManualHud(0);
}

#pragma mark - Private Method
- (void)startTimer {
    [self.timer setFireDate:[NSDate date]];
}

- (void)stopTimer {
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)savePeripheral:(CBPeripheral *)peripheral withRSSI:(NSNumber *)RSSI{
    //先移除相同的外设，防止只是RSSI变更而多次添加
    [self.peripheralsArray1 removeObject:peripheral];
    [self.peripheralsArray2 removeObject:peripheral];
    
    [peripheral setQYBRSSI:RSSI];
    
    NSMutableArray *obj = [peripheral.QYBRSSI intValue] <= NOT_REACHABLE_RSSI?self.peripheralsArray2:self.peripheralsArray1;
    //添加到对应的分类数组中
    [obj addObject:peripheral];
    
    if (obj.count >= 2) {
        [obj sortUsingComparator:^NSComparisonResult(CBPeripheral *obj1, CBPeripheral *obj2) {
            return [obj1.QYBRSSI compare:obj2.QYBRSSI] * -1;
        }];
    }
    
    [self reloadPeripheralTableViewOnMainQueue];
}

- (void)scanPeripheral{
    if (canFire) {
        if (_centralManager.state == CBCentralManagerStatePoweredOn) {
            canFire = NO;
            [_centralManager scanForPeripheralsWithServices:nil options:nil];
        }
    }
}

- (void)cancelPeripheralConnection{
    if (selectedIndex) {
        [_centralManager cancelPeripheralConnection:self.peripheralsArray1[selectedIndex.row]];
    }
}
@end
