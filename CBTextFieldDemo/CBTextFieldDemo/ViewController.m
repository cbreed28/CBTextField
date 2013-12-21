//
// Copyright 2013 Cory Breed
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "ViewController.h"
#import "CBTextField.h"

static NSString * const kEmailTextValidatorRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
static NSString * const kPhoneNumberValidatorRegex = @"^[1-9][0-9]{9}$";

@interface EmailValidationStrategy : NSObject<CBTextFieldValidationStrategy>
-(BOOL)validateContent:(NSString *)content;
@end

@implementation EmailValidationStrategy

-(BOOL)validateContent:(NSString *)content
{
    NSPredicate * regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kEmailTextValidatorRegex];
    return [regexPredicate evaluateWithObject:content];
}

@end

@interface PhoneNumberValidationStrategy : NSObject<CBTextFieldValidationStrategy>
-(BOOL)validateContent:(NSString *)content;
@end

@implementation PhoneNumberValidationStrategy

-(BOOL)validateContent:(NSString *)content
{
    NSPredicate * regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kPhoneNumberValidatorRegex];
    return [regexPredicate evaluateWithObject:content];
}

@end


@interface ViewController ()<CBTextFieldValidationDelegate>

@property (nonatomic, weak) IBOutlet CBTextField * emailTextField;
@property (nonatomic, weak) IBOutlet CBTextField * passwordTextField;
@property (nonatomic, weak) IBOutlet CBTextField * phoneNumberTextField;

@property (nonatomic, weak) IBOutlet UIButton * validateButton;
@property (nonatomic, weak) IBOutlet UIButton * resetButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Set up a Validation Strategy for the email text field
    [self.emailTextField setCBTextFieldValidationStrategy:[[EmailValidationStrategy alloc] init]];
    
    // Tell the email text field to validate on End Edit
    self.emailTextField.CBTextFieldValidateOnEndEdit = YES;
    
    // Set up a Validation Strategy for the phone number text field
    [self.phoneNumberTextField setCBTextFieldValidationStrategy:[[PhoneNumberValidationStrategy alloc] init]];
    
    // Add a delegate for the phone number text field
    self.phoneNumberTextField.CBTextFieldValidationDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CBTextFieldValidationDelegate Methods

-(void)CBTextField:(UITextField *)textField didValidateContent:(NSString *)content withSuccess:(BOOL)succeeded error:(NSError *)error
{
    if(succeeded) {
        NSLog(@"Phone Number validation succeeded!");
    } else {
        NSLog(@"Phone Number Failed to validate");
    }
}

#pragma mark - Action Methods

-(IBAction)didPressValidateButton:(id)sender
{
    // For each of the text fields, let's validate their input
    
    // For the email text field, we've set up a Strategy to do the validation, so we can just call validateInput
    [self.emailTextField validateInput:nil];
    
    // For the password text field, let's use a predicate to do the validation
    [self.passwordTextField validateInputWithPredicate:^BOOL(NSString * input){
        
        NSRange capitalizedRange = [input rangeOfCharacterFromSet:[NSCharacterSet capitalizedLetterCharacterSet]];
        NSRange letterRange = [input rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
        NSRange decimalRange = [input rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
        
        
        return input.length > 6 && capitalizedRange.length > 0 && letterRange.length > 0 && decimalRange.length > 0;
        
    }error:nil];
    
    // For the phone number validation we can use the validation completion handler to do something else...like display an error!
    [self.phoneNumberTextField validateInputWithCompletionHandler:^(BOOL succeeded, NSError * error){
        
        if(!succeeded)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Oops!!" message:@"You entered an invalid phone number!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

            [alert show];
        }
        
    }];
}

-(IBAction)didPressResetButton:(id)sender
{
    // For each of the text fields we can reset their input back to the original state
    
    [self.emailTextField reset];
    [self.passwordTextField reset];
    [self.phoneNumberTextField reset];
}

@end
