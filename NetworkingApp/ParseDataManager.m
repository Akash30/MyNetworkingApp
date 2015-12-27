//
//  ParseDataManager.m
//  Chatter
//
//  Created by Josh Pearlstein on 11/3/15.
//  Copyright © 2015 SEAS. All rights reserved.
//

#import "ParseDataManager.h"

#import <Parse/Parse.h>
#import "SignupViewController.h"

@implementation ParseDataManager

+ (ParseDataManager *)sharedManager {
  static ParseDataManager *obj;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    obj = [[ParseDataManager alloc] init];
    /// TODO: Any other setup you'd like to do.
  });
  return obj;
}

- (BOOL)isUserLoggedIn {
  return [[PFUser currentUser] isAuthenticated];
}

-(BOOL)signUpUser:(NSString *)name Password:(NSString *)password email:(NSString *)email {
    PFUser *newUser = [[PFUser user] init];
    newUser.username = name;
    newUser.password = password;
    newUser.email = email;
    
    return [newUser signUp];
}

- (void)loadNearbyPeersWithCallback: (void (^) (NSMutableArray *))callback {
  
    PFQuery *query = [PFQuery queryWithClassName:@"_User"] ;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (PFObject *obj in objects) {
                
                        [obj fetchIfNeeded];
                        
                        double toLat = [[obj objectForKey:@"latitude"] doubleValue];
                        double toLng = [[obj objectForKey:@"longitude"] doubleValue];
                        double fromLat = [[[PFUser currentUser] objectForKey:@"latitude"] doubleValue];
                        double fromLng = [[[PFUser currentUser] objectForKey:@"longitude"] doubleValue];
                        CLLocation *to = [[CLLocation alloc] initWithLatitude:toLat longitude:toLng];
                        CLLocation *from = [[CLLocation alloc] initWithLatitude:fromLat longitude:fromLng];
                        double distance = [to distanceFromLocation:from];
                    if (distance < 10) {
                        [result addObject:obj];
                    }
                    
            }
                //NSLog(@"NO OF RESULT = %lu", [result count]);
                callback(result);
        });
            
        }
    }];
    
}

@end
