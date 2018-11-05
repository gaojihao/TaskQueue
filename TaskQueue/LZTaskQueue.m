//
//  LZTaskQueue.m
//  xingyujiaoyu
//
//  Created by lizhi54 on 2017/6/5.
//  Copyright © 2017年 com.lizhi1026. All rights reserved.
//

#import "LZTaskQueue.h"
#import "LZTask+Private.h"

NSString *const TaskDidRunNotification          = @"LZ_TaskDidRunNotification";
NSString *const TaskDidCancelledNotification    = @"LZ_TaskDidCancelledNotification";
NSString *const TaskDidCompletedNotification    = @"LZ_TaskDidCompletedNotification";
NSString *const TaskUserInfoKey                 = @"lz_task";

@interface LZTaskQueue()<LZTaskDelegate>

@property (nonatomic, strong) NSMutableArray<LZTask *> *tasks;
@property (nonatomic, strong) NSMutableArray *runningTasks;

@end

@implementation LZTaskQueue

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LZTaskQueue *_sharedinstance = nil;
    dispatch_once(&onceToken, ^{
        _sharedinstance = [[self alloc] init];
        [_sharedinstance setAsynchronous:YES];
    });
    return _sharedinstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _tasks = [NSMutableArray array];
    }
    return self;
}

- (LZTask *)currentTask {
    return [_runningTasks firstObject];
}

- (id)response {
    return self.currentTask.response;
}

- (NSError *)error {
    return self.currentTask.error;
}

- (void)addTask:(LZTask *)task {
    @synchronized(self){
        if (![_tasks containsObject:task]) {
            [_tasks addObject:task];
        }
    }
    if (self == [[self class] sharedInstance]) {
        [self runNextTask];
    }
}

- (void)removeTask:(LZTask *)task {
    @synchronized(self){
        if (task.state != TaskStateCancelled || task.state != TaskStateCompleted) {
            [task cancel];
        }
        [_tasks removeObject:task];
    }
}

- (void)addTasks:(NSArray<LZTask *> *)tasks {
    @synchronized(self){
        for (LZTask *task in tasks) {
            if (![_tasks containsObject:task]) {
                [_tasks addObject:task];
            }
        }
    }
    if (self == [[self class] sharedInstance]) {
        [self runNextTask];
    }
}

- (void)removeTasks:(NSArray<LZTask *> *)tasks {
    @synchronized(self){
        for (LZTask *task in tasks) {
            if (task.state != TaskStateCancelled || task.state != TaskStateCompleted) {
                [task cancel];
            }
            [_tasks removeObject:task];
        }
    }
}

- (void)run {
    [super run];
    [self runNextTask];
}

- (void)runNextTask {
    if (self.asynchronous) {
        [self runAsyncTask];
    } else {
        [self runSyncTask];
    }
}

- (void)runAsyncTask {
    LZTask *task;
    @synchronized(self){
        if ([self.tasks count] == 0) {
            return;
        }
        if (self.maxConcurrent > 0 && self.runningTasks.count >= self.maxConcurrent) {
            return;
        }
        task = [_tasks firstObject];
        [_tasks removeObject:task];
    }
    if (!task) {
        return;
    }
    if (!_runningTasks) {
        _runningTasks = [NSMutableArray arrayWithCapacity:self.maxConcurrent > 0 ? self.maxConcurrent : 10];
    }
    [_runningTasks addObject:task];
    task.delegate = self;
    task.preTask = self.preTask;
    [task run];
}

- (void)runSyncTask {
    LZTask *preTask = self.currentTask;
    self.runningTasks = [NSMutableArray arrayWithObject:[self.tasks firstObject]];
    [self.tasks removeObject:self.currentTask];
    [self.currentTask setPreTask:preTask];
    [self.currentTask setDelegate:self];
    [self.currentTask run];
}

- (void)cancel {
    [super cancel];
    [self.currentTask cancel];
    if (self.finalBlock)
        self.finalBlock(self);
}

- (void)completed {
    [super completed];
    if (self.finalBlock)
        self.finalBlock(self);
    [_runningTasks removeAllObjects];
}

- (void)taskDidRun:(LZTask *)task {
    if (self == [[self class] sharedInstance]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TaskDidRunNotification object:nil userInfo:@{TaskUserInfoKey: task}];
    }
}

- (void)taskDidCompleted:(LZTask *)task {
    if (self == [[self class] sharedInstance]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TaskDidCompletedNotification object:nil userInfo:@{TaskUserInfoKey: task}];
    }
    if (self.currentTask.error) {
        if (self.currentTask.stopIfFail) {
            [self completed];
            return;
        }
    }
    if ([self.tasks count] > 0) {
        [self runNextTask];
    } else {
        [self completed];
    }
}

- (void)taskDidCancelled:(LZTask *)task {
    [super cancel];
    if (self == [[self class] sharedInstance]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TaskDidCancelledNotification object:nil userInfo:@{TaskUserInfoKey: task}];
    }
    [_runningTasks removeObject:task];
}

@end
