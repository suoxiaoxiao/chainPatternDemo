//
//  ChainDemo.h
//  chainPatternDemo
//
//  Created by suoxiaoxiao on 2020/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChainTaskManager : NSObject
+ (instancetype)shared;
- (void)start;
@end

NS_ASSUME_NONNULL_END
