//
//  AppDelegate.m
//  TrackPushEvent
//
//  Created by HeHongling on 2020/10/31.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <SensorsAnalyticsSDK.h>



@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 初始化神策分析 SDK
    SAConfigOptions *options = [[SAConfigOptions alloc] initWithServerURL:@"https://newsdktest.datasink.sensorsdata.cn/sa?project=hehongling&token=5a394d2405c147ca"
                                                            launchOptions:launchOptions];
    options.autoTrackEventType = 0xff;
#ifdef DEBUG
    options.enableLog = YES;
#endif
    [SensorsAnalyticsSDK startWithConfigOptions:options];
    
    
    // 请求通知权限
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
    [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert| UNAuthorizationOptionBadge| UNAuthorizationOptionSound
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"用户%@了推送权限", granted? @"允许": @"拒绝");
    }];
    
    // 检查推送配置
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        
        // 设置用户推送权限开关
        [[SensorsAnalyticsSDK sharedInstance] set:@{@"PushAuthored": @(settings.authorizationStatus == UNAuthorizationStatusAuthorized),
                                                    @"PushSoundStatus": @(settings.soundSetting),
                                                    @"PushBadgeSetting": @(settings.badgeSetting),
                                                    @"PushAlertSetting": @(settings.alertSetting)}];
    }];
    
    // 注册推送
    [application registerForRemoteNotifications];
    
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self trackTapPushEvent];
    }

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenString = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
     stringByReplacingOccurrencesOfString:@">" withString:@""]
    stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceToken:%@", deviceTokenString);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateInactive) {
        
        [self trackTapPushEvent];
    }
    completionHandler();
}

- (void)trackTapPushEvent {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 记录推送打开事件
        [[SensorsAnalyticsSDK sharedInstance] track:@"TapPush"];
    });
}

// 取出 PushService Extension 中的事件数据
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[SensorsAnalyticsSDK sharedInstance] trackEventFromExtensionWithGroupIdentifier:@"group.cn.sensorsdata"
                                                                          completion:nil];
}


@end
