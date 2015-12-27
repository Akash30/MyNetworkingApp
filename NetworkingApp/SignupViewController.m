//
//  SignupViewController.m
//  Chatter
//
//  Created by Josh Pearlstein on 11/3/15.
//  Copyright © 2015 SEAS. All rights reserved.
//

#import "SignupViewController.h"
#import "ParseDataManager.h"


@interface SignupViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (nonatomic) ParseDataManager* pdm;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pdm = [[ParseDataManager alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUp:(UIButton *)sender {
    BOOL authenticated = [self.pdm signUpUser: self.usernameTextField.text Password:self.passwordTextField.text email:self.emailTextField.text];
    if (authenticated) {
        NSLog(@"true");
        [[NSUserDefaults standardUserDefaults] setValue:self.usernameTextField.text forKey:@"senderDisplayName"];
        [self performSegueWithIdentifier:@"authenticated" sender:self];
    } else {
        NSLog(@"false");
        
    }
    
}

@end
