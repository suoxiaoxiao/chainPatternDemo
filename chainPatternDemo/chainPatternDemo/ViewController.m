//
//  ViewController.m
//  chainPatternDemo
//
//  Created by suoxiaoxiao on 2020/12/21.
//

#import "ViewController.h"
#import "ChainDemo.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 开启任务
    [[ChainTaskManager shared] start];
    
    // Do any additional setup after loading the view.
}


@end
