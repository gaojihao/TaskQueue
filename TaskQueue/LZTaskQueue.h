/*
 *LZTaskQueue
 *
 *Copyright ©com.lizhi1026. All rights reserved.
 */

#import "LZTask.h"

FOUNDATION_EXPORT NSString *const TaskDidRunNotification;
FOUNDATION_EXPORT NSString *const TaskDidCancelledNotification;
FOUNDATION_EXPORT NSString *const TaskDidCompletedNotification;
FOUNDATION_EXPORT NSString *const TaskUserInfoKey;

NS_ASSUME_NONNULL_BEGIN

#define TASK_POOL_PUSH          [[LZTaskQueue sharedInstance] addTasks:@[
#define TASK_POOL_END           ]];

#define TASK_QUEUE_SYNC_START   ({ LZTaskQueue *queue = [[LZTaskQueue alloc] init]; NSArray *tasks = @
#define TASK_QUEUE_ASYNC_START  ({ LZTaskQueue *queue = [[LZTaskQueue alloc] init];  queue.asynchronous = YES; NSArray *tasks = @
#define TASK_QUEUE_END          ;[queue addTasks:tasks];queue;}),
#define TASK_QUEUE_FINAL_START  ];[queue setFinalBlock:^(LZTaskQueue *queue)
#define TASK_QUEUE_FINAL_END

#define TASK_START              [[LZTask alloc] initWithBlock:^(LZTask * preTask, void (^ complete)(id, NSError *))
#define TASK_END                ],

@interface LZTaskQueue : LZTask

@property (nonatomic,strong, readonly) LZTask *currentTask;

@property (nonatomic, strong) void(^finalBlock)(LZTaskQueue *queue);

/// Default: NO
@property (nonatomic, assign) BOOL asynchronous;

/// 最大并发数，0代表不限制，默认是0
@property (nonatomic, assign) NSUInteger maxConcurrent;

+ (instancetype)sharedInstance;

- (void)addTask:(LZTask *)task;
- (void)removeTask:(LZTask *)task;

- (void)addTasks:(NSArray<LZTask *> *)tasks;
- (void)removeTasks:(NSArray<LZTask *> *)tasks;

@end

NS_ASSUME_NONNULL_END
