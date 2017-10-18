#import "RCTSmooch.h"
#import <Smooch/Smooch.h>

@implementation SmoochManager

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(show) {
  NSLog(@"Smooch Show");

  dispatch_async(dispatch_get_main_queue(), ^{
    [Smooch show];
  });
};

RCT_EXPORT_METHOD(login:(NSString*)userId jwt:(NSString*)jwt resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSLog(@"Smooch Login");

  dispatch_async(dispatch_get_main_queue(), ^{
    [Smooch login:userId jwt:jwt completionHandler:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
      if(error) {
        reject(@"smooch_login_failed", @"Smooch login failed", error);
      } else {
        SKTUser *loggedInUser = userInfo[SKTUserIdentifier];
        resolve([self _smoochUserToJSON:loggedInUser]);
      }
    }];
  });
};

RCT_EXPORT_METHOD(logoutWithCompletionHandler:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSLog(@"Smooch Logout");

  dispatch_async(dispatch_get_main_queue(), ^{
    [Smooch logoutWithCompletionHandler:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
      if(error) {
        reject(@"smooch_logout_failed", @"Smooch logout failed", error);
      } else {
        resolve(RCTJSONStringify(userInfo, NULL));
      };
    }];
  });
};

RCT_EXPORT_METHOD(currentUser:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  SKTUser *smoochUser = [SKTUser currentUser];
  if(smoochUser) {
    resolve([self _smoochUserToJSON:smoochUser]);
  } else {
    reject(@"current_user_failed", @"Unable to retrieve current_user", NULL);
  }
};

- (NSString *)_smoochUserToJSON:(SKTUser *)user {
  NSString *smoochUserJSON = @"{}";
  NSDictionary *smoochUser = @{
                               @"appUserId": [user appUserId] ? [user appUserId] : @"",
                               @"userId": [user userId] ? [user userId] : @"",
                               @"firstName": [user firstName] ? [user firstName] : @"",
                               @"lastName": [user lastName] ? [user lastName] : @"",
                               @"email": [user email] ? [user email] : @""
                               };

  NSError *error = nil;
  if([NSJSONSerialization isValidJSONObject:smoochUser]) {
    smoochUserJSON = RCTJSONStringify(smoochUser, &error);
    if(error) {
      NSLog(@"Error generating smoochUserJSON: %@", error);
      return @"{}";
    };
  };
  return smoochUserJSON;
}

RCT_EXPORT_METHOD(setUserProperties:(NSDictionary*)options) {
  NSLog(@"Smooch setUserProperties with %@", options);

  [[SKTUser currentUser] addProperties:options];
};

RCT_REMAP_METHOD(getUnreadCount,
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  NSLog(@"Smooch getUnreadCount");

  long unreadCount = [Smooch conversation].unreadCount;
  resolve(@(unreadCount));
};

RCT_EXPORT_METHOD(setFirstName:(NSString*)firstName) {
  NSLog(@"Smooch setFirstName");

  [SKTUser currentUser].firstName = firstName;
};

RCT_EXPORT_METHOD(setLastName:(NSString*)lastName) {
  NSLog(@"Smooch setLastName");

  [SKTUser currentUser].lastName = lastName;
};

RCT_EXPORT_METHOD(setEmail:(NSString*)email) {
  NSLog(@"Smooch setEmail");

  [SKTUser currentUser].email = email;
};


RCT_EXPORT_METHOD(setSignedUpAt:(NSDate*)date) {
  NSLog(@"Smooch setSignedUpAt");

  [SKTUser currentUser].signedUpAt = date;
};


@end
