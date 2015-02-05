//
//  BFLoginViewController.m
//  BiteFeed
//
//  Created by Stephen Chan on 2/4/15.
//  Copyright (c) 2015 Delta. All rights reserved.
//

#import "BFLoginViewController.h"

@interface BFLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation BFLoginViewController

- (IBAction)startButtonPressed:(id)sender {
    if (self.usernameTextField.text.length <= 0){
        UIAlertView *noUsernameAlert = [[UIAlertView alloc] initWithTitle:@"no username" message:@"please enter a username" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noUsernameAlert show];
    }
    if (self.emailTextField.text.length <= 0) {
        UIAlertView *noEmailAlert = [[UIAlertView alloc] initWithTitle:@"no email" message:@"please enter an email" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noEmailAlert show];
    }
    if (self.emailTextField.text.length > 0 && self.usernameTextField.text.length > 0) {
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
