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

#import <XCTest/XCTest.h>
#import "CBTextField.h"

static NSString * const kEmailTextValidatorRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
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

@interface CBTextFieldDemoTests : XCTestCase<CBTextFieldValidationDelegate>

@property (nonatomic, strong) CBTextField * textField;

@end

static BOOL shouldValidateContentMethodCalled = NO;
static BOOL willValidateContentMethodCalled = NO;
static BOOL didValidateContentMethodCalled = NO;
static BOOL didPassVerificationNotificationCalled = NO;
static BOOL didFailVerificationNotificationCalled = NO;

@implementation CBTextFieldDemoTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.textField = [[CBTextField alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSuccessNotification:) name:CBTextFieldDidPassValidationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveFailureNotification:) name:CBTextFieldDidFailValidationNotification object:nil];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    // Reset the text field
    [self.textField reset];
    
     shouldValidateContentMethodCalled = NO;
     willValidateContentMethodCalled = NO;
     didValidateContentMethodCalled = NO;
     didPassVerificationNotificationCalled = NO;
     didFailVerificationNotificationCalled = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CBTextFieldDidPassValidationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CBTextFieldDidFailValidationNotification object:nil];
}

// Test Cases

/*
    Test Setters
 
    Test validateInput:(NSError **)error
        Test error case
            Test no border color changes
        Test success state
            Test border color changes for invalid input
            Test border color changes for valid input
 
    Test validateInput:(CBTextFieldCompletionHandler)handler
        Test error case
            Test no border color changes
        Test success state
            Test border color changes for invalid input
            Test border color changes for valid input
 
    Test validateInput:(CBTextFieldPredicate)predicate
        Test error case
            Test no border color changes
        Test success state
            Test border color changes for invalid input
            Test border color chagnes for valid input

    Test Reset
        Test border color changes back to normal
 */


// Test -(BOOL)validateInput:(NSError **)error

- (void)test_validateInput_ErrorCase_1
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the Validation Strategy object to nil
    self.textField.CBTextFieldValidationStrategy = nil;
    
    // Give the Text Field some text
    self.textField.text = @"someone@gmail.com";
    
    // Validate the input
    NSError * error = nil;
    BOOL succeeded = [self.textField validateInput:&error];
    
    XCTAssertFalse(succeeded, @"Validate Input did not return false for the error case");
    
    // Make sure that the error object is set
    XCTAssertNotNil(error, @"-(BOOL)validateInput:(NSError**)error did not set the error appropriately");
    
    // Make sure that the border color did not change
    XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error erroniously changed the border color");
    
    // Verify that none of the delegate methods were called
    [self verifyNoDelegateCalls];
    
    // Verify that none of the notifications got posted
    [self verifyNoNotificationCalls];
}

- (void)test_validateInput_ErrorCase_2
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the Validation Strategy object to nil
    self.textField.CBTextFieldValidationStrategy = nil;
    
    // Set the Validation Delegate
    self.textField.CBTextFieldValidationDelegate = self;
    
    // Give the Text Field some text
    self.textField.text = @"someone@gmail.com";
    
    // Validate the input
    NSError * error = nil;
    BOOL succeeded = [self.textField validateInput:&error];
    
    XCTAssertFalse(succeeded, @"Validate Input did not return false for the error case");
    
    // Make sure that the error object is set
    XCTAssertNotNil(error, @"-(BOOL)validateInput:(NSError**)error did not set the error appropriately");
    
    // Make sure that the border color did not change
    XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error erroniously changed the border color");
    
    // Verify that none of the delegate methods were called
    [self verifyNoDelegateCalls];
    
    // Verify that none of the notifications got posted
    [self verifyNoNotificationCalls];
}

- (void)test_validateInput_SuccessCase_1_0
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the Delegate to nil
    self.textField.CBTextFieldValidationDelegate = nil;
    
    // Set the Validation Strategy object to validate emails
    EmailValidationStrategy * strategy = [[EmailValidationStrategy alloc] init];
    [self.textField setCBTextFieldValidationStrategy:strategy];
    
    // Give the Text Field some valid text ( according to EmailValidationStrategy )
    self.textField.text = @"someone@gmail.com";
    
    // validate the input
    NSError * error = nil;
    BOOL succeeded = [self.textField validateInput:&error];
    
    XCTAssertTrue(succeeded, @"Validate Input did not indicate success");
    
    // Make sure that the error object is still nil
    XCTAssertNil(error, @"-(BOOL)validateInput:(NSError**)error did not set the error appropriately");
    
    // Make sure the border color changed to success
        XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldSuccessBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error did not change the border color to success");
    
    // Make sure that no Delegaet Methods were called
    [self verifyNoDelegateCalls];
    
    // Make sure we got a success notification
    [self verifySuccessNotificationCalls];
    
    // Make sure we did not get a failure call
    [self verifyNoFailureNotificationCalls];
}

- (void)test_validateInput_SuccessCase_1_1
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the delegate to self
    self.textField.CBTextFieldValidationDelegate = self;
    
    // Set the Validation Strategy object to validate emails
    EmailValidationStrategy * strategy = [[EmailValidationStrategy alloc] init];
    [self.textField setCBTextFieldValidationStrategy:strategy];
    
    // Give the Text Field some valid text ( according to EmailValidationStrategy )
    self.textField.text = @"someone@gmail.com";
    
    // validate the input
    NSError * error = nil;
    BOOL succeeded = [self.textField validateInput:&error];
    
    XCTAssertTrue(succeeded, @"Validate Input did not indicate success");
    
    // Make sure that the error object is still nil
    XCTAssertNil(error, @"-(BOOL)validateInput:(NSError**)error did not set the error appropriately");
    
    // Make sure the border color changed to success
    XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldSuccessBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error did not change the border color to success");
    
    // Make sure we got all the delegate calls
    [self verifyAllDelegateCalls];
    
    // Make sure we got a success notification
    [self verifySuccessNotificationCalls];
    
    // Make sure we did not get a failure notification
    [self verifyNoFailureNotificationCalls];
}

-(void)test_validateInput_SuccessCase_2_0
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the Delegate to nil
    self.textField.CBTextFieldValidationDelegate = nil;
    
    // Set the Validation Strategy object to validate emails
    EmailValidationStrategy * strategy = [[EmailValidationStrategy alloc] init];
    [self.textField setCBTextFieldValidationStrategy:strategy];
    
    // Give the Text Field some invalid text ( according to EmailValidationStrategy )
    self.textField.text = @"asdfew";
    
    // validate the input
    NSError * error = nil;
    BOOL succeeded = [self.textField validateInput:&error];
    
    XCTAssertFalse(succeeded, @"Validate Input did not indicate success");
    
    // Make sure that the error object is still nil
    XCTAssertNil(error, @"-(BOOL)validateInput:(NSError**)error did not set the error appropriately");
    
    // Make sure the border color changed to failure
    XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldErrorBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error did not change the border color to success");
    
    // Make sure that no Delegaet Methods were called
    [self verifyNoDelegateCalls];
    
    // Make sure we got a failure notification
    [self verifyFailureNotificationCalls];
    
    // make sure we did not get a success notification
    [self verifyNoSuccessNotificationCalls];
}

// Test validateInputWithCompletionHandler:(CBTextFieldCompletionHandler)handler

-(void)test_validateInputHandler_ErrorCase_1
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the Validation Strategy object to nil
    self.textField.CBTextFieldValidationStrategy = nil;
    
    // Give the Text Field some mock text
    self.textField.text = @"someone@gmail.com";
    
    // Validate the input
    [self.textField validateInputWithCompletionHandler:^(BOOL succeeded, NSError * error){
       
        // Make sure that the succeeded flag is set
        XCTAssertFalse(succeeded, @"-(BOOL)validateInputWithCompletionHandler:(CBTextFieldComplationHandler)handler did not set the success flag appropriatly");
        // Make sure that the error object is set
        XCTAssertNotNil(error, @"-(BOOL)validateInput:(NSError**)error did not set the error appropriately");
        // Make sure that the border color did not change
        XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error erroniously changed the border color");
        
        // Verify that none of the delegate methods were called
        [self verifyNoDelegateCalls];
        
        // Verify that none of the notifications got posted
        [self verifyNoNotificationCalls];
    }];
}

-(void)test_validateInputHandler_ErrorCase_2
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the delegate
    self.textField.CBTextFieldValidationDelegate = self;
    
    // Set the Validation Strategy object to nil
    self.textField.CBTextFieldValidationStrategy = nil;
    
    // Give the Text Field some mock text
    self.textField.text = @"someone@gmail.com";
    
    // Validate the input
    [self.textField validateInputWithCompletionHandler:^(BOOL succeeded, NSError * error){
        
        // Make sure that the succeeded flag is set
        XCTAssertFalse(succeeded, @"-(BOOL)validateInputWithCompletionHandler:(CBTextFieldComplationHandler)handler did not set the success flag appropriatly");
        // Make sure that the error object is set
        XCTAssertNotNil(error, @"-(BOOL)validateInput:(NSError**)error did not set the error appropriately");
        // Make sure that the border color did not change
        XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error erroniously changed the border color");
        
        // Verify that none of the delegate methods were called
        [self verifyNoDelegateCalls];
        
        // Verify that none of the notifications got posted
        [self verifyNoNotificationCalls];
    }];
}

-(void)test_validateInputHandler_SuccessCase_1_0
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the Delegate to nil
    self.textField.CBTextFieldValidationDelegate = nil;
    
    // Set the Validation Strategy object to validate emails
    EmailValidationStrategy * strategy = [[EmailValidationStrategy alloc] init];
    [self.textField setCBTextFieldValidationStrategy:strategy];
    
    // Give the Text Field some valid text ( according to EmailValidationStrategy )
    self.textField.text = @"someone@gmail.com";
    
    // validate the input
    [self.textField validateInputWithCompletionHandler:^(BOOL succeeded, NSError * error){
        
        // Make sure that the succeeded flag is set
        XCTAssertTrue(succeeded, @"-(BOOL)validateInputWithCompletionHandler:(CBTextFieldComplationHandler)handler did not set the success flag appropriatly");
        
        // Make sure that the error object is nil
        XCTAssertNil(error, @"-(BOOL)validateInputWithCompletionHandler:(CBTextFieldCompletionHandler)handler did not set the error appropriately");
        
        // Make sure the border color changed to success
        XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldSuccessBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error did not change the border color to success");
        
        // Make sure we didn't get any delegate calls
        [self verifyNoDelegateCalls];
        
        // Make sure we succeded
        [self verifySuccessNotificationCalls];
        
        // Make sure we didn't fail
        [self verifyNoFailureNotificationCalls];
    }];
}

-(void)test_validateInputHandler_SuccessCase_1_1
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the Delegate to nil
    self.textField.CBTextFieldValidationDelegate = self;
    
    // Set the Validation Strategy object to validate emails
    EmailValidationStrategy * strategy = [[EmailValidationStrategy alloc] init];
    [self.textField setCBTextFieldValidationStrategy:strategy];
    
    // Give the Text Field some valid text ( according to EmailValidationStrategy )
    self.textField.text = @"someone@gmail.com";
    
    // validate the input
    [self.textField validateInputWithCompletionHandler:^(BOOL succeeded, NSError * error){
        
        // Make sure that the succeeded flag is set
        XCTAssertTrue(succeeded, @"-(BOOL)validateInputWithCompletionHandler:(CBTextFieldComplationHandler)handler did not set the success flag appropriatly");
        
        // Make sure that the error object is nil
        XCTAssertNil(error, @"-(BOOL)validateInputWithCompletionHandler:(CBTextFieldCompletionHandler)handler did not set the error appropriately");
        
        // Make sure the border color changed to success
        XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldSuccessBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error did not change the border color to success");
        
        // Make sure we didn't get any delegate calls
        [self verifyAllDelegateCalls];
        
        // Make sure we succeded
        [self verifySuccessNotificationCalls];
        
        // Make sure we didn't fail
        [self verifyNoFailureNotificationCalls];
    }];
}

-(void)test_validateInputHandler_SuccessCase_2_0
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the delegate
    self.textField.CBTextFieldValidationDelegate = nil;
    
    // Set the Validation Strategy object to validate emails
    EmailValidationStrategy * strategy = [[EmailValidationStrategy alloc] init];
    [self.textField setCBTextFieldValidationStrategy:strategy];
    
    // Give the Text Field some valid text ( according to EmailValidationStrategy )
    self.textField.text = @"asdferw";
    
    // validate the input
    [self.textField validateInputWithCompletionHandler:^(BOOL succeeded, NSError * error){
        
        // Make sure that the succeeded flag is set
        XCTAssertFalse(succeeded, @"-(BOOL)validateInputWithCompletionHandler:(CBTextFieldComplationHandler)handler did not set the success flag appropriatly");
        
        // Make sure that the error object is nil
        XCTAssertNil(error, @"-(BOOL)validateInputWithCompletionHandler:(CBTextFieldCompletionHandler)handler did not set the error appropriately");
        
        // Make sure the border color changed to failure
        XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldErrorBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error did not change the border color to success");
        
        // Make sure we didn't get any delegate calls
        [self verifyNoDelegateCalls];
        
        // Make sure we failed
        [self verifyFailureNotificationCalls];
        
        // Make sure we didn't succeed
        [self verifyNoSuccessNotificationCalls];
    }];
}

-(void)test_validateInputHandler_SuccessCase_2_1
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the delegate
    self.textField.CBTextFieldValidationDelegate = self;
    
    // Set the Validation Strategy object to validate emails
    EmailValidationStrategy * strategy = [[EmailValidationStrategy alloc] init];
    [self.textField setCBTextFieldValidationStrategy:strategy];
    
    // Give the Text Field some valid text ( according to EmailValidationStrategy )
    self.textField.text = @"asdferw";
    
    // validate the input
    [self.textField validateInputWithCompletionHandler:^(BOOL succeeded, NSError * error){
        
        // Make sure that the succeeded flag is set
        XCTAssertFalse(succeeded, @"-(BOOL)validateInputWithCompletionHandler:(CBTextFieldComplationHandler)handler did not set the success flag appropriatly");
        
        // Make sure that the error object is nil
        XCTAssertNil(error, @"-(BOOL)validateInputWithCompletionHandler:(CBTextFieldCompletionHandler)handler did not set the error appropriately");
        
        // Make sure the border color changed to failure
        XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldErrorBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error did not change the border color to success");
        
        // Make sure we didn't get any delegate calls
        [self verifyAllDelegateCalls];
        
        // Make sure we failed
        [self verifyFailureNotificationCalls];
        
        // Make sure we didn't succeed
        [self verifyNoSuccessNotificationCalls];
    }];
}

// Test validateInputWithPredicate:(CBTextFieldPredicate)predicate

-(void)test_validateInputPredicate_ErrorCase_1
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the delegate
    self.textField.CBTextFieldValidationDelegate = nil;
    
    // Set the Validation Strategy object to nil
    self.textField.CBTextFieldValidationStrategy = nil;
    
    // Give the Text Field some mock text
    self.textField.text = @"someone@gmail.com";
    
    // Validate the input
    NSError * error = nil;
    BOOL succeeded = [self.textField validateInputWithPredicate:nil error:&error];
    
    XCTAssertFalse(succeeded, @"-(BOOL)validateInputWithPredicate did not indicate failure correctly");
    
    // Make sure that the error object is set
    XCTAssertNotNil(error, @"-(BOOL)validateInputWithPredicate did not set the error appropriately");
    
    // Make sure that the border color did not change
    XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error erroniously changed the border color");
    
    // Make sure we don't get any delegate calls
    [self verifyNoDelegateCalls];
    
    // Make sure we didn't get any notification calls
    [self verifyNoNotificationCalls];
}

-(void)test_validateInputPredicate_ErrorCase_2
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the delegate
    self.textField.CBTextFieldValidationDelegate = self;
    
    // Set the Validation Strategy object to nil
    self.textField.CBTextFieldValidationStrategy = nil;
    
    // Give the Text Field some mock text
    self.textField.text = @"someone@gmail.com";
    
    // Validate the input
    NSError * error = nil;
    BOOL succeeded = [self.textField validateInputWithPredicate:nil error:&error];
    
    XCTAssertFalse(succeeded, @"-(BOOL)validateInputWithPredicate did not indicate failure correctly");
    
    // Make sure that the error object is set
    XCTAssertNotNil(error, @"-(BOOL)validateInputWithPredicate did not set the error appropriately");
    
    // Make sure that the border color did not change
    XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error erroniously changed the border color");
    
    // Make sure we don't get any delegate calls
    [self verifyNoDelegateCalls];
    
    // Make sure we didn't get any notification calls
    [self verifyNoNotificationCalls];
}

-(void)test_validateInputPredicate_SuccessCase_1_0
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the delegate
    self.textField.CBTextFieldValidationDelegate = nil;
    
    // Set the Validation Strategy object to nil
    self.textField.CBTextFieldValidationStrategy = nil;
    
    // Give the Text Field some valid text ( according to EmailValidation Strategy )
    self.textField.text = @"someone@gmail.com";
    
    // Validate the input
    NSError * error = nil;
    BOOL succeeded = [self.textField validateInputWithPredicate:^BOOL(NSString * content){
        NSPredicate * regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kEmailTextValidatorRegex];
        return [regexPredicate evaluateWithObject:content];
    }error:&error];
    
    XCTAssertTrue(succeeded, @"-(BOOL)validateInputWithPredicate did not indicate failure correctly");
    
    // Make sure that the error object is set
    XCTAssertNil(error, @"-(BOOL)validateInputWithPredicate did not set the error appropriately");
    
    // Make sure that the border color changed to success
    XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldSuccessBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error erroniously changed the border color");
    
    [self verifyNoDelegateCalls];
    
    [self verifySuccessNotificationCalls];
    
    [self verifyNoFailureNotificationCalls];
}

-(void)test_validateInputPredicate_SuccessCase_1_1
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the delegate
    self.textField.CBTextFieldValidationDelegate = self;
    
    // Set the Validation Strategy object to nil
    self.textField.CBTextFieldValidationStrategy = nil;
    
    // Give the Text Field some valid text ( according to EmailValidation Strategy )
    self.textField.text = @"someone@gmail.com";
    
    // Validate the input
    NSError * error = nil;
    BOOL succeeded = [self.textField validateInputWithPredicate:^BOOL(NSString * content){
        NSPredicate * regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kEmailTextValidatorRegex];
        return [regexPredicate evaluateWithObject:content];
    }error:&error];
    
    XCTAssertTrue(succeeded, @"-(BOOL)validateInputWithPredicate did not indicate failure correctly");
    
    // Make sure that the error object is set
    XCTAssertNil(error, @"-(BOOL)validateInputWithPredicate did not set the error appropriately");
    
    // Make sure that the border color changed to success
    XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldSuccessBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error erroniously changed the border color");
    
    [self verifyAllDelegateCalls];
    
    [self verifySuccessNotificationCalls];
    
    [self verifyNoFailureNotificationCalls];
}

-(void)test_validateInputPredicate_SuccessCase_2_0
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the delegate
    self.textField.CBTextFieldValidationDelegate = nil;
    
    // Set the Validation Strategy object to nil
    self.textField.CBTextFieldValidationStrategy = nil;
    
    // Give the Text Field some valid text ( according to EmailValidation Strategy )
    self.textField.text = @"asdfew";
    
    // Validate the input
    NSError * error = nil;
    BOOL succeeded = [self.textField validateInputWithPredicate:^BOOL(NSString * content){
        NSPredicate * regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kEmailTextValidatorRegex];
        return [regexPredicate evaluateWithObject:content];
    }error:&error];
    
    XCTAssertFalse(succeeded, @"-(BOOL)validateInputWithPredicate did not indicate failure correctly");
    
    // Make sure that the error object is set
    XCTAssertNil(error, @"-(BOOL)validateInputWithPredicate did not set the error appropriately");
    
    // Make sure that the border color changed to success
    XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldErrorBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error erroniously changed the border color");
    
    [self verifyNoDelegateCalls];
    
    [self verifyFailureNotificationCalls];
    
    [self verifyNoSuccessNotificationCalls];
}

-(void)test_validateInputPredicate_SuccessCase_2_1
{
    // The Text Field should have a Normal Border Color to start out
    XCTAssert(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldNormalBorderColor.CGColor), @"Text Field was not initialize with the proper color");
    
    // Set the delegate
    self.textField.CBTextFieldValidationDelegate = self;
    
    // Set the Validation Strategy object to nil
    self.textField.CBTextFieldValidationStrategy = nil;
    
    // Give the Text Field some valid text ( according to EmailValidation Strategy )
    self.textField.text = @"asdfew";
    
    // Validate the input
    NSError * error = nil;
    BOOL succeeded = [self.textField validateInputWithPredicate:^BOOL(NSString * content){
        NSPredicate * regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kEmailTextValidatorRegex];
        return [regexPredicate evaluateWithObject:content];
    }error:&error];
    
    XCTAssertFalse(succeeded, @"-(BOOL)validateInputWithPredicate did not indicate failure correctly");
    
    // Make sure that the error object is set
    XCTAssertNil(error, @"-(BOOL)validateInputWithPredicate did not set the error appropriately");
    
    // Make sure that the border color changed to success
    XCTAssertTrue(CGColorEqualToColor(self.textField.layer.borderColor, self.textField.CBTextFieldErrorBorderColor.CGColor), @"-(BOOL)validateInput:(NSError**)error erroniously changed the border color");
    
    [self verifyAllDelegateCalls];
    
    [self verifyFailureNotificationCalls];
    
    [self verifyNoSuccessNotificationCalls];
}

#pragma mark - Private Helper Methods

-(void)verifyAllDelegateCalls
{
    //Check Method was called -(BOOL)CBTextField:(UITextField *)textField shouldValidateContent:(NSString *)content
    XCTAssertTrue(shouldValidateContentMethodCalled, @"shouldValidateContent Not called");
    
    //Check Method was called -(BOOL)CBTextField:(UITextField *)textField willValidateContent:(NSString *)content
    XCTAssertTrue(willValidateContentMethodCalled, @"willValidateContent Not called");
    
    //Check Method was called -(BOOL)CBTextField:(UITextField *)textField didValidateContent:(NSString *)content
    XCTAssertTrue(didValidateContentMethodCalled, @"didvalidatecontent Not called");
}

-(void)verifyNoDelegateCalls
{
    //Check Method was called -(BOOL)CBTextField:(UITextField *)textField shouldValidateContent:(NSString *)content
    XCTAssertFalse(shouldValidateContentMethodCalled, @"shouldValidateContent Not called");
    
    //Check Method was called -(BOOL)CBTextField:(UITextField *)textField willValidateContent:(NSString *)content
    XCTAssertFalse(willValidateContentMethodCalled, @"willValidateContent Not called");
    
    //Check Method was called -(BOOL)CBTextField:(UITextField *)textField didValidateContent:(NSString *)content
    XCTAssertFalse(didValidateContentMethodCalled, @"didvalidatecontent Not called");
}

-(void)verifySuccessNotificationCalls
{
    //Check Method was called
    XCTAssertTrue(didPassVerificationNotificationCalled, @"Success Notification Not posted");
}

-(void)verifyNoSuccessNotificationCalls
{
    //Check Method was called
    XCTAssertFalse(didPassVerificationNotificationCalled, @"Success Notification Not posted");
}

-(void)verifyFailureNotificationCalls
{
    //Check Method was called
    XCTAssertTrue(didFailVerificationNotificationCalled, @"Failure  Not called");
}

-(void)verifyNoFailureNotificationCalls
{
    //Check Method was called
    XCTAssertFalse(didFailVerificationNotificationCalled, @"Failure  Not called");
}

-(void)verifyNoNotificationCalls
{
    //Check Method was called
    XCTAssertFalse(didPassVerificationNotificationCalled, @"Success Notification posted erroneously");
    
    //Check Method was called
    XCTAssertFalse(didFailVerificationNotificationCalled, @"Failure Notification posted erroneouslt");

}

#pragma mark - Action Methods

-(void)didReceiveSuccessNotification:(NSNotification *)notification
{
    didPassVerificationNotificationCalled = YES;
}

-(void)didReceiveFailureNotification:(NSNotification *)notification
{
    didFailVerificationNotificationCalled = YES;
}

#pragma mark - CBTextFieldVaidationDelegate Methods

-(BOOL)CBTextField:(UITextField *)textField shouldValidateContent:(NSString *)content
{
    shouldValidateContentMethodCalled = YES;
    return YES;
}
-(void)CBTextField:(UITextField *)textField willValidateContent:(NSString *)content
{
    willValidateContentMethodCalled = YES;
}
-(void)CBTextField:(UITextField *)textField didValidateContent:(NSString *)content withSuccess:(BOOL)succeeded error:(NSError *)error
{
    didValidateContentMethodCalled = YES;
}

@end
