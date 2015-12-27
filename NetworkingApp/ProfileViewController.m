//
//  ProfileViewController.m
//  NetworkingApp
//
//  Created by Akash Subramanian on 11/21/15.
//  Copyright © 2015 Akash Subramanian. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileurlLabel;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UITextView *profileurlTextView;
@property (nonatomic) MFMailComposeViewController *mailComposer;
@property (weak, nonatomic) IBOutlet UIView *topView;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    if (self.profileData == NULL) {
//        self.profileData = [[NSUserDefaults standardUserDefaults] objectForKey:@"profileData"];
//    }
    

   
   NSString *imageURL = [[[_profileData objectForKey:@"pictureUrls"] objectForKey:@"values"] firstObject];
    // Fetch and switch to a default priority background queue.
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [self.profileData objectForKey:@"firstName"], [self.profileData objectForKey:@"lastName"]];
    [self.emailButton setTitle:[self.profileData objectForKey:@"emailAddress"] forState:UIControlStateNormal];
    self.headlineLabel.text = [self.profileData objectForKey:@"headline"];
    
    self.profileurlLabel.text = [self.profileData objectForKey:@"publicProfileUrl"];
    //self.profileurlLabel.userInteractionEnabled = YES;
    self.profileurlTextView.text = [self.profileData objectForKey:@"publicProfileUrl"];
    self.profileurlTextView.editable = NO;
    self.profileurlTextView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.profileurlTextView.userInteractionEnabled = YES;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        // Switch to Main Queue as we will be updating the UI.
        dispatch_async(dispatch_get_main_queue(), ^{
                     self.profileImageView.frame = CGRectIntegral(self.profileImageView.frame);
            self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.profileImageView.image = [UIImage imageWithData:imageData];
             self.profileImageView.frame = CGRectIntegral(self.profileImageView.frame);
   
        });
    });
    
}

-(void)viewWillAppear:(BOOL)animated {
    UIImage *back = [UIImage imageNamed:@"penn"];
    UIImageView *background = [[UIImageView alloc] initWithImage:back];
    background.frame = self.view.bounds;
    [self.view addSubview:background];
    // _topView.backgroundColor = [[UIColor alloc] initWithWhite:0.5 alpha:0.5];
    _topView.frame = self.view.bounds;
    _topView.userInteractionEnabled = YES;
    [background addSubview:_topView];
    [_topView addSubview:_emailButton];
    [background bringSubviewToFront:_topView];
    [_topView bringSubviewToFront:_emailButton];
    [background setUserInteractionEnabled:YES];
    [_topView setUserInteractionEnabled:YES];

    

}

- (IBAction)sendEmail:(UIButton *)sender {
    _mailComposer = [[MFMailComposeViewController alloc] init];
    _mailComposer.mailComposeDelegate = self;
    [_mailComposer setToRecipients:[NSArray arrayWithObject:_emailButton.titleLabel.text]];
    [_mailComposer setSubject:@"It was great meeting you today."];
    [_mailComposer setMessageBody:[NSString stringWithFormat:@"Dear %@, ", [self.profileData objectForKey:@"firstName"]] isHTML:NO];
     [self presentViewController:_mailComposer animated:YES completion:^{
         // no nothing
     }];
     }
     
#pragma mark - mail compose delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (result) {
        NSLog(@"Result : %d",result);
    }
    if (error) {
        NSLog(@"Error : %@",error);
    }
    [self dismissViewControllerAnimated:YES completion:^{
        // do nothing
    }];
                 
}







@end
