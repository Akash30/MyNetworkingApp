//
//  AppDelegate.m
//  NetworkingApp
//
//  Created by Akash Subramanian on 11/20/15.
//  Copyright © 2015 Akash Subramanian. All rights reserved.
//

#import "AppDelegate.h"

#import <Parse/Parse.h>
#import <linkedin-sdk/LISDK.h>


@interface AppDelegate ()


@end

@implementation AppDelegate: UIResponder
UIWindow *window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Parse setApplicationId:@"SQKkgku4KoL4HuMdoOANAhowkIsjUNAyIBJqhGxx"
                  clientKey:@"8sT8xFprR20fqYqfwAfGCd773Ca5qzjth86MzK5n"];
    

    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if ([PFUser currentUser] == nil) {
        NSLog(@"%@", @"need to sign in");
        //UINavigationController *navCon = [storyBoard instantiateInitialViewController];
        UIViewController *rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"signIn"];
        //navCon.viewControllers = [NSArray arrayWithObject:rootViewController];
        self.window.rootViewController = rootViewController;
    } else {
        NSLog(@"%@", @"signed in");
        UINavigationController *navCon = [storyBoard instantiateInitialViewController];
        UIViewController *rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"peers"];
        navCon.viewControllers = [NSArray arrayWithObject:rootViewController];
        self.window.rootViewController = navCon;
    }
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([LISDKCallbackHandler shouldHandleUrl:url]) {
        return [LISDKCallbackHandler application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    return YES;
}

@end