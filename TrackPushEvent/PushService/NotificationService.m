//
//  NotificationService.m
//  PushService
//
//  Created by HeHongling on 2020/10/31.
//

#import "NotificationService.h"
#import "SAAppExtensionDataManager.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    
    // 记录推送到达事件
    [[SAAppExtensionDataManager sharedInstance] writeEvent:@"ReceivePush"
                                                properties:@{@"PushTitle": request.content.title?: @""}
                                           groupIdentifier:@"cn.sensorsdata.share"];
    
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
