//
//  ChainDemo.m
//  chainPatternDemo
//
//  Created by suoxiaoxiao on 2020/12/21.
//

#import "ChainDemo.h"



/// 首页弹窗链全部执行完成通知
static NSNotificationName const HomeAlertChainAllComplateNotificationKey = @"ChainAllComplateNotificationKey";

/// 定义一个链节点协议
@protocol ChainNodeProtocol <NSObject>
// 这一块使用strong修饰词是为了拥有下一个节点, 不至于下一个节点过早释放
@property (nonatomic , strong) id < ChainNodeProtocol > nextNode;

// 设置下一个节点
- (void)setNextChainNode:(id <ChainNodeProtocol>)chainNodeObject;
// 开始执行当前节点
- (void)action;
// 当前节点执行完成
- (void)complate;
// 提前准备的事情
- (void)preperLoad;
@end

/// 链路节点需要继承的base类,当然也可以不继承,仅仅是少了日志和往下触发事件的代码而已,自己在节点写也是一样
@interface ChainNodeBaseTask : NSObject <ChainNodeProtocol>

@end

@implementation ChainNodeBaseTask

@synthesize nextNode = _nextNode;

- (void)preperLoad {
    // base里面仅仅做日志输出
    NSLog(@"📌📌📌%@类 弹窗链路准备",NSStringFromClass(self.class));
}

- (void)setNextChainNode:(id<ChainNodeProtocol>)chainNodeObject {
    _nextNode = chainNodeObject;
}

- (void)action {
    // base里面仅仅做日志输出
    NSLog(@"📌📌📌弹窗链路执行到了 %@类",NSStringFromClass(self.class));
    
}

- (void)complate {
    
    if (_nextNode) {
        [_nextNode action];
    } else {
        // base里面仅仅做日志输出
        NSLog(@"📌📌📌弹窗链路执行完毕");
        // 触发完成事件
        [[NSNotificationCenter defaultCenter] postNotificationName:HomeAlertChainAllComplateNotificationKey object:nil];
    }
}

@end


@interface AChainNodeTask : ChainNodeBaseTask

@end

@implementation AChainNodeTask

- (void)action {
    [super action];
    // 开始网络请求数据,并对结果做处理, 弹窗处理
    
    // 当事情处理完成之后执行完成事件,将链路传到到下一个链路
    [self complate];
}

@end

@interface BChainNodeTask : ChainNodeBaseTask

@end

@implementation BChainNodeTask

- (void)action {
    [super action];
    // 开始网络请求数据,并对结果做处理, 弹窗处理
    
    // 当事情处理完成之后执行完成事件,将链路传到到下一个链路
    [self complate];
}

@end

@interface CChainNodeTask : ChainNodeBaseTask

@property (nonatomic , assign, getter=isActionFlag) BOOL actionFlag;

@end

@implementation CChainNodeTask

- (void)preperLoad {
    // 有可能是比较费时的操作,写在这
    
    // 判断isLoadComplate
    if (self.isActionFlag) {
        // 执行弹窗逻辑
    } else {
        self.actionFlag = true;
    }
    
}

- (void)action {
    [super action];
    
    // 判断 preperLoad 是否处理完成, 如果处理完成则进行业务处理, 没有就继续等待执行完成,可能要加标记来处理这个逻辑
    if (self.isActionFlag) {
        // 执行弹窗逻辑
    } else {
        // 根据preperLoad处理的结果进行处理业务逻辑/或者没有处理完成,则什么都不做, 等preperLoad处理完成时候处理弹窗逻辑即可
        self.actionFlag = true;
    }
    
    // 当事情处理完成之后执行完成事件,将链路传到到下一个链路
    [self complate];
}

@end

/// 做一个管理类
@interface ChainTaskManager ()
/// 起始节点
@property (nonatomic,strong)id <ChainNodeProtocol> startTask;

@end

@implementation ChainTaskManager

+ (instancetype)shared {
    static ChainTaskManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        // 监听弹窗事件链执行结束
        [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(alertChainDidEnd) name:HomeAlertChainAllComplateNotificationKey object:nil];
    });
    return instance;
}

- (void)start {

    AChainNodeTask *achain = [[AChainNodeTask alloc] init];
    BChainNodeTask *bchain = [[BChainNodeTask alloc] init];
    CChainNodeTask *cchain = [[CChainNodeTask alloc] init];
    [achain setNextChainNode:bchain];
    [bchain setNextChainNode:cchain];
    // 预加载
    [cchain preperLoad];
    self.startTask = achain;
    
    // 开始执行链路头
    [achain action];
}

- (void)alertChainDidEnd {
    // 释放链路头, 会一次释放所有链路节点
    self.startTask = nil;
}

@end
