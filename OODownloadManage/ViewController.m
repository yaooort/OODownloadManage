//
//  ViewController.m
//  OODownloadManage
//
//  Created by bunny on 2019/4/10.
//  Copyright © 2019 Oort. All rights reserved.
//

#import "ViewController.h"
#import "OODownload.h"

#define task_name @"taskoort"


static NSString *kCellIdentifier = @"SmartCell";


#pragma mark - cell
@interface SmartTableViewCell : UITableViewCell
@property(nonatomic, strong)TaskBean *task;
@property(nonatomic, strong)UILabel *nameLabel;
@property(nonatomic, strong)UILabel *speed;
@property(nonatomic, strong)UILabel *status;
@property(nonatomic, strong)UIButton *button;
@property(nonatomic, strong)UIProgressView *progress;
@end

@implementation SmartTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        [self.contentView addSubview:_nameLabel];
        _speed = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 200, 40)];
        [self.contentView addSubview:_speed];
        _status = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 200, 40)];
        [self.contentView addSubview:_status];
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 150, 200, 40)];
        [self.contentView addSubview:_button];
        _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 200, 200, 10)];
        [self.contentView addSubview:_progress];
    }
    return self;
}

- (void)setTask:(TaskBean *)task{
    _task = task;
    self.nameLabel.text = _task.model[@"name"];
    _button.hidden = YES;
    if(_task.status==YHFileDownloadBegin){
        self.status.text = @"准备";
    }else if(_task.status==YHFileDownloaddownload){
        self.status.text = @"下载中";
        _button.hidden = NO;
        [_button setTitle:@"暂停" forState:UIControlStateNormal];
    }else if(_task.status==YHFileDownloadSuspend){
        self.status.text = @"暂停";
        _button.hidden = NO;
        [_button setTitle:@"开始" forState:UIControlStateNormal];
    }else if(_task.status==YHFileDownloadFinshed){
        self.status.text = @"完成";
    }else if(_task.status==YHFileDownloadWaiting){
        self.status.text = @"等待";
    }else if(_task.status==YHFileDownloadFailure){
        self.status.text = @"失败";
    }
    _progress.progress = _task.percentage;
    _speed.text = [NSString stringWithFormat:@"当前速度%f",_task.speed];
    __weak typeof(self) weakSelf = self;
    [_task setBlock:^(NSInteger mode_id) {
        NSString* where = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"model_id"),bg_sqlValue([NSNumber numberWithInteger:mode_id])];
        NSArray* arr = [TaskBean bg_find:weakSelf.bg_tableName where:where];
        [weakSelf setTask:arr[0]];
    }];
}

@end

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,OODownloadDelegate>

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong) NSMutableArray<TaskBean *> *arrayData;

@property(nonatomic,strong) UIButton *startAll;

@property(nonatomic,strong) UIButton *stopAll;

@property(nonatomic,strong) UIButton *removeAll;

@property(nonatomic,strong) OODownload *oo;

@end

@implementation ViewController

#pragma mark--准备数据
-(NSMutableArray*)arrayData{
    if(!_arrayData){
        _arrayData = @[].mutableCopy;
        TaskBean *bean;
        for (int i=0; i<10; i++) {
            // 实例化
            bean = [TaskBean new];
            // 需要保存的名称后缀
            bean.file_Name = @"你是谁.zip";
            // ID，一个队列中唯一的KEY
            bean.model_id = i;
            // 下载路径
            bean.url = @"https://github.com/oldj/SwitchHosts/releases/download/v3.3.12/SwitchHosts-macOS-x64_v3.3.12.5349.zip";
            // 对应保存你自己的model的
            bean.model = @{@"name":@"任务",@"as":[NSNumber numberWithInt:i]};
            // 添加到队列
            [_arrayData addObject:bean];
        }
    }
    return _arrayData;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _startAll = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [_startAll setTitle:@"开始任务" forState:UIControlStateNormal];
    [_startAll addTarget:self action:@selector(startAllTask) forControlEvents:UIControlEventTouchUpOutside];
    [self.view addSubview:_startAll];
    
    _stopAll = [[UIButton alloc] initWithFrame:CGRectMake(55, 0, 50, 30)];
    [_stopAll setTitle:@"停止任务" forState:UIControlStateNormal];
    [_stopAll addTarget:self action:@selector(stopAllTask) forControlEvents:UIControlEventTouchUpOutside];
    [self.view addSubview:_stopAll];
    
    _removeAll = [[UIButton alloc] initWithFrame:CGRectMake(110, 0, 50, 30)];
    [_removeAll setTitle:@"删除任务" forState:UIControlStateNormal];
    [_removeAll addTarget:self action:@selector(removeAllTask) forControlEvents:UIControlEventTouchUpOutside];
    [self.view addSubview:_removeAll];
    
    _tableView = [UITableView new];
    _tableView.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.allowsSelection = NO;
    [_tableView registerClass:[SmartTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    [self.view addSubview:_tableView];
    _tableView.rowHeight = 210;
    
    _oo = [OODownload shareOODownload];
    _oo.delegate = self;
    [_oo createTask:task_name :self.arrayData];
//    TaskBean *beanq = [TaskBean new];
//    beanq.bg_tableName = tab_name;
//    //        bean.tableName = tab_name;
//    beanq.file_Name = @"你是谁";
//    [beanq setModel_id:200];
//    beanq.url = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.0.dmg";
////    beanq.model = @{@"abc":@"qwe",@"as":[NSNumber numberWithInt:200]};
//    [beanq bg_saveOrUpdate];
//    NSString* where = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"model_id"),bg_sqlValue([NSNumber numberWithInt:200])];
//    NSArray* arr = [TaskBean bg_find:tab_name where:where];
    //创建一个任务队列
//    [[OODownload shareOODownload] createTask:tab_name :as];
//    [[OODownload shareOODownload] startAll:tab_name];
//    //删除一个任务队列，如果正在下载则停止并删除
//    [[OODownload shareOODownload] deleteTaskData:@"yigerenwu"];
//    //停止一个任务队列
//    [[OODownload shareOODownload] stopAll:@"yigerenwu"];
//
//    //停止队列中的某个任务
//    [[OODownload shareOODownload] stop:@"yigerenwu" model_id:123];
//    //向队列中添加一个任务
//    [[OODownload shareOODownload] add:@"yigerenwu" model:bean];
//    //删除队列中的某个任务，如果正在下载则停止并删除
//    [[OODownload shareOODownload] remove:@"yigerenwu" model_id:123];
//    //开启队列中一个任务
//    [[OODownload shareOODownload] start:@"yigerenwu" model_id:123];
//    //开启队列
//    [[OODownload shareOODownload] startAll:@"yigerenwu"];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)updateAllTask:(NSMutableArray<TaskBean *> *) tasks{
    [self.arrayData removeAllObjects];
    [self.arrayData addObjectsFromArray:tasks];
    [_tableView reloadData];
}

-(void)startAllTask{
    [_oo startAll:task_name];
}

-(void)stopAllTask{
    
}

-(void)removeAllTask{
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrayData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SmartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[SmartTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    NSInteger row = [indexPath row];
    cell.task = self.arrayData[row];
    return cell;
}

@end
