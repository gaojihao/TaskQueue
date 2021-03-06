/*
 *LZTask+Private
 *
 *Copyright ©com.lizhi1026. All rights reserved.
 */

#import "LZTask.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LZTaskDelegate <NSObject>
@optional
- (void)taskDidRun:(LZTask *)task;
- (void)taskDidCancelled:(LZTask *)task;
- (void)taskDidCompleted:(LZTask *)task;
@end

@interface LZTask (Private)

@property (nonatomic, strong) LZTask *preTask;
@property (nonatomic, weak) id<LZTaskDelegate> delegate;

- (void)completed;

@end

NS_ASSUME_NONNULL_END
