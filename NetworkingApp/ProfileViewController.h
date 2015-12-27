//
//  ProfileViewController.h
//  NetworkingApp
//
//  Created by Akash Subramanian on 11/21/15.
//  Copyright © 2015 Akash Subramanian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface ProfileViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) NSMutableDictionary *profileData;
@end
