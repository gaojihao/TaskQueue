//
//  LZTask.m
//  xingyujiaoyu
//
//  Created by lizhi54 on 2017/6/5.
//  Copyright © 2017年 com.lizhi1026. All rights reserved.
//

#import "LZTask.h"
#import "LZTask+Private.h"

@interface LZTask()

@property (nonatomic, copy) void(^block)(LZTask *preTask, void(^complete)(id response, NSError *error));

@property (nonatomic, copy) NSError *error;
@property (nonatomic, strong) id response;

@end

@implementation LZTask

- (instancetype)init {
    if (self = [super init]) {
        _stopIfFail = YES;
    }
    return self;
}

- (instancetype)initWithBlock:(void(^)(LZTask * preTask, void(^ complete)(id response, NSError * error)))block{
    if (self = [self init]) {
        _block = block;
    }
    return self;
}

- (void)run{
    self.state = TaskStateRunning;
    if (self.block) {
        __weak LZTask *weak_self = self;
        self.block(self.preTask, ^(id response, NSError *error) {
            weak_self.error = error;
            weak_self.response = response;
            [weak_self completed];
        });
    }
    if ([self.delegate respondsToSelector:@selector(taskDidRun:)]) {
        [self.delegate taskDidRun:self];
    }
}

- (void)cancel {
    self.state = TaskStateCancelled;
    if ([self.delegate respondsToSelector:@selector(taskDidCancelled:)]) {
        [self.delegate taskDidCancelled:self];
    }
}

- (void)completed {
    self.state = TaskStateCompleted;
    if ([self.delegate respondsToSelector:@selector(taskDidCompleted:)]) {
        [self.delegate taskDidCompleted:self];
    }
}

@end
