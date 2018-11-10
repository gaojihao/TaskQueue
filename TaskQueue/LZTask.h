/*
 *LZTask
 *
 *Copyright ©com.lizhi1026. All rights reserved.
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, TaskState) {
    TaskStateWait         = 0,
    TaskStateRunning,
    TaskStateSuspended,
    TaskStateCancelled,
    TaskStateCompleted,
};

NS_ASSUME_NONNULL_BEGIN

@interface LZTask : NSObject

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, assign) TaskState state;

/*
 *Default: YES*
 */
@property (nonatomic, assign) BOOL stopIfFail;

@property (nonatomic, assign) NSUInteger progressRate;

@property (readonly) int64_t countOfBytesReceived;
@property (readonly) int64_t countOfBytesSent;
@property (readonly) int64_t countOfBytesExpectedToSend;
@property (readonly) int64_t countOfBytesExpectedToReceive;

@property (readonly, copy) NSError *error;
@property (readonly, strong) id response;

- (void)run;
- (void)cancel;

- (instancetype)initWithBlock:(void(^)(LZTask * preTask, void(^ complete)(id response, NSError * error)))block;

@end

NS_ASSUME_NONNULL_END
