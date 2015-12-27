//
//  ParseDataManager.h
//  Chatter
//
//  Created by Josh Pearlstein on 11/3/15.
//  Copyright © 2015 SEAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseDataManager : NSObject

+ (ParseDataManager *)sharedManager;

- (BOOL)isUserLoggedIn;

- (void)loadNearbyPeersWithCallback: (void (^) (NSMutableArray *))callback;



// TODO: Handle User signup
- (BOOL)signUpUser:(NSString *)name
          Password:(NSString *)password
             email:(NSString *)email;

@end
