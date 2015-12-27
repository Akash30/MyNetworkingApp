//
//  SignInViewController.m
//  Chatter
//
//  Created by Akash Subramanian on 11/13/15.
//  Copyright © 2015 SEAS. All rights reserved.
//

#import "SignInViewController.h"
#import <Parse/Parse.h>
#import <linkedin-sdk/LISDK.h>
#import "ParseDataManager.h"
#define profileURL @"https://api.linkedin.com/v1/people/~?format=json"

@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) LISDKSession *session;
@property (nonatomic) ParseDataManager* pdm;
@property (weak, nonatomic) IBOutlet UIView *topView;
//@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@end

@implementation SignInViewController

-(void)viewDidLoad {
    [super viewDidLoad];
       self.pdm = [ParseDataManager sharedManager];
//    _backgroundImage.frame = _backgroundImage.superview.frame;
//    _backgroundImage.contentMode = UIViewContentModeRedraw;
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    UIImage *back = [UIImage imageNamed:@"locust"];
    UIImageView *background = [[UIImageView alloc] initWithImage:back];
    background.frame = self.view.bounds;
//    [back drawInRect:rect];
//    [background sizeToFit];
//    background.contentMode = UIViewContentModeRedraw;
    
    [self.view addSubview:background];
    // _topView.backgroundColor = [[UIColor alloc] initWithWhite:0.5 alpha:0.5];
    _topView.frame = self.view.bounds;
    _topView.center = self.view.center;
    _topView.userInteractionEnabled = YES;
    [background addSubview:_topView];
 

    [_topView addSubview:_signInButton];
    [background bringSubviewToFront:_topView];
    [_topView bringSubviewToFront:_signInButton];
    [background setUserInteractionEnabled:YES];
    [_topView setUserInteractionEnabled:YES];
        [_signInButton setUserInteractionEnabled:YES];

   
    
}

- (IBAction)signIn:(UIButton *)sender {
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (user != NULL) {
            [self performSegueWithIdentifier:@"signedIn" sender:self];
        }
    }];
}

- (IBAction)signInWithLinkedIn:(UIButton *)sender {
    
    [LISDKSessionManager  createSessionWithAuth:[NSArray arrayWithObjects:LISDK_BASIC_PROFILE_PERMISSION, LISDK_EMAILADDRESS_PERMISSION, nil]
                                          state:NULL
                         showGoToAppStoreDialog:YES
                                   successBlock:^(NSString *success) {
                                       NSLog(@"%s","success called!");
                                       _session = [[LISDKSessionManager sharedInstance] session];
                                       if ([LISDKSessionManager hasValidSession]) {
                                           [[LISDKAPIHelper sharedInstance]getRequest:[NSString stringWithFormat:@"%@/people/~:(id,first-name,last-name,maiden-name,headline,email-address,summary,specialties,picture-urls::(original),positions,public-profile-url)?format=json",LINKEDIN_API_URL]
                                       success:^(LISDKAPIResponse *response) {
                                          // NSLog(@"%@", [response data]);
                                           //NSLog(@"%@", [response headers]);
                                           NSData *responseData = [[response data] dataUsingEncoding:NSUTF8StringEncoding];
                                           NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
                                           NSLog(@"%@", dictionary);
                                           [[NSUserDefaults standardUserDefaults] setValue:dictionary forKey:@"profileData"];
                                           PFQuery *query = [[PFQuery queryWithClassName:@"_User"] whereKey:@"email" equalTo:[dictionary objectForKey:@"emailAddress"]];
                                           //NSLog(@"here is the query %@", query);
                                           [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                                               if (object == NULL) {
                                                   [[PFUser currentUser] setValue:[dictionary objectForKey:@"id"] forKey:@"linkedinid"];
                                                   [[PFUser currentUser] saveInBackground];
                                                    NSLog(@"signed up!");
                                                   [self performSegueWithIdentifier:@"signedIn" sender:self];
                                               } else {
                                                   [PFUser logInWithUsernameInBackground:[dictionary objectForKey:@"id"] password:[dictionary objectForKey:@"id"]];
                                                   NSLog(@"signed in!");
                                                   [self performSegueWithIdentifier:@"signedIn" sender:self];
                                               }
//                                               if (!error) {
//                                                   [PFUser logInWithUsernameInBackground:[object objectForKey:@"username"]password:[object objectForKey:@"password"] block:^(PFUser * _Nullable user, NSError * _Nullable error) {
//                                                       if (user != NULL) {
//                                                           NSLog(@"%@", @"signed in user");
//                                                           //[self performSegueWithIdentifier:@"signedIn" sender:self];
//                                                           
//                                                       } else {
//                                                           //NSLog(@"%@", @"kdjhfsd");
//                                                           [self.pdm signUpUser: [dictionary objectForKey:@"id"] Password:[dictionary objectForKey:@"id"] email: [dictionary objectForKey:@"emailAddress"]];
//                                                           NSLog(@"%@", @"signed up user");
//                                                           [[PFUser currentUser] setValue:[dictionary objectForKey:@"id"] forKey:@"linkedinid"];
//                                                           [[PFUser currentUser] saveInBackground];
//                                                           [self performSegueWithIdentifier:@"signedIn" sender:self];
//                                                       }
//                                                   }];
//                                               } else {
//                                                   BOOL auth = [self.pdm signUpUser: [dictionary objectForKey:@"id"] Password:[dictionary objectForKey:@"id"] email: [dictionary objectForKey:@"emailAddress"]];
//                                                   if (auth) {
//                                                       [[PFUser currentUser] setValue:[dictionary objectForKey:@"id"] forKey:@"linkedinid"];
//                                                       [[PFUser currentUser] saveInBackground];
//                                                   }
//                                                   NSLog(@"%@", auth? @"true" : @"false");
//                                                   [self performSegueWithIdentifier:@"signedIn" sender:self];
                                               //}
                                           }];

                                       }
                                       error:^(LISDKAPIError *error) {
                                           // do nothing
                                          // NSLog(@"this is the error %@", error);
                                       }];
                                       }
                                   }
                                     errorBlock:^(LISDKAuthError *error) {
                                         //do nothing
                                         NSLog(@"the error %@", error);
                                     }];
}



            
            
                  
         
        

             
//             // See the defined URL above.
//             NSURL *url = [NSURL URLWithString:profileURL];
//             // Create a MutableURL request with the URL we just made.
//             NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//             // Begin a URL session with the request and then handle the recieved data.
//             [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
//             [[[NSURLSession sharedSession] dataTaskWithRequest:request
//                                              completionHandler:
//               ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//                   NSMutableDictionary *dictionary =
//                   [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//                   dispatch_async(dispatch_get_main_queue(), ^{
//                       //PFQuery *query = [[PFQuery queryWithClassName:@"User"] whereKey:@"email" equalTo:[dictionary objectForKey:@"email-address"]];
//                       //PFUser *aUser = [query getFirstObject];
////                       if (aUser != NULL) {
////                           }];
////                       } else {
////                          // [self.pdm signUpUser:NULL Password:NULL email: [dictionary objectForKey:@"email-address"]];
////                       }
//                     
//                   });
//               }] resume];
//
//         }

            


@end


