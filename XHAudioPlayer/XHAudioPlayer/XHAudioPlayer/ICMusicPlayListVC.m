//
//  ICMusicPlayListVC.m
//  DWTeacher
//
//  Created by icochu on 2018/12/6.
//  Copyright © 2018年 Mxionlly. All rights reserved.
//

#import "ICMusicPlayListVC.h"
#import "ICMusicPlayListCell.h"
#import "XHComMacro.h"

@interface ICMusicPlayListVC ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) NSMutableArray *statueArray;

@property(nonatomic, assign) NSInteger currentSelectIndex;
@end

@implementation ICMusicPlayListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _statueArray = @[].mutableCopy;
    self.title = @"播放列表";
    _currentSelectIndex = self.currentModel.rownum;
    [self setStatueWithAllData:self.allListModelArray CurrentIndex:_currentSelectIndex];
    [self initView];
//    [_tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSIndexPath *path = [NSIndexPath indexPathForRow:self.currentModel.rownum inSection:0];
        [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
    });
}

- (void)initView {
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, XHScreenWidth, XHScreenHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 52, 0, 0);
    _tableView.separatorColor = XHAPPSeparateColor;
    _tableView.rowHeight = 67;
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return  _allListModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellContent = @"cellContent";
    ICMusicPlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellContent];
    if (!cell) {
        cell = [[ICMusicPlayListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellContent];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    cell.playModel = self.allListModelArray[indexPath.row];
    cell.playStatue = self.isPlaying;
    cell.isPlaying =[_statueArray[indexPath.row] isEqualToString:@"1"] ? YES : NO;
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.navigationController popViewControllerAnimated:YES];
    if (indexPath.row == _currentSelectIndex) return;
    _currentSelectIndex = indexPath.row;
    [self setStatueWithAllData:self.allListModelArray CurrentIndex:_currentSelectIndex];
    if (self.readPlayMusic) self.readPlayMusic(indexPath.row, self.allListModelArray[indexPath.row]);
}

- (void)setStatueWithAllData:(NSArray *)allDate CurrentIndex:(NSInteger)currentIndex {
    [_statueArray removeAllObjects];
    for (NSInteger i = 0; i < allDate.count; i++) {
        if (currentIndex == i) {
            [_statueArray addObject:@"1"];
        }else {
            [_statueArray addObject:@"0"];
        }
    }
}
@end
