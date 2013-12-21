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

#import <UIKit/UIKit.h>
#import "CBTextFieldValidationStrategy.h"

typedef void (^CBTextFieldCompletionHandler)(BOOL succeeded, NSError * error);
typedef BOOL (^CBTextFieldValidationPredicate)(NSString * content);

/**
    The CBTextFieldValidationDelegate defines the delegate pattern for validating the input of the 
    CBTextField class. The CBTextField will query these methods in order to determine when to perform 
    certain functions on the CBTextField class. This protocol is also a sub-protocol of the UITextFieldDelegate
    protocol to prevent client code convienence reasons.
 **/

@protocol CBTextFieldValidationDelegate  <UITextFieldDelegate>

@optional
-(BOOL)CBTextField:(UITextField *)textField shouldValidateContent:(NSString *)content;
-(void)CBTextField:(UITextField *)textField willValidateContent:(NSString *)content;
-(void)CBTextField:(UITextField *)textField didValidateContent:(NSString *)content withSuccess:(BOOL)succeeded error:(NSError *)error;
@end


/**
 
 'CBTextField' provides an easy to use way of validating user input to a UITextField. The validation of the input is handled by the Validation object. 
 The CBTextField also encapsulates the error border color, and the normal border color, and the success border color.
 
 ##Automatic Content Validation
 
 The CBTextField will automatically validate it's content based on either the Strategy object, or the Strategy Predicate
 
 The CBTextField provides a delegate pattern, notification, and bolck based API for performing the validation
 
 Example Code:
 
 {
 }
 
 ##Subclassing Notes
 
 One should not have to make subclasses of the CBTextField object directly. To create new textfield validation styles, simply create a new validation strategy, define the appropriate colors
 
 
 */

@interface CBTextField : UITextField

/** Validation strategy of this CBTextField ( default: nil ) */
@property (nonatomic, strong) id<CBTextFieldValidationStrategy> CBTextFieldValidationStrategy;

/** Delegate for performing Validation */
@property (nonatomic, strong) id<CBTextFieldValidationDelegate> CBTextFieldValidationDelegate;

/** Error Border color    */
@property (nonatomic, strong) UIColor * CBTextFieldNormalBorderColor;       // Default lightGray

/** Normal Border color   */
@property (nonatomic, strong) UIColor * CBTextFieldErrorBorderColor;        // Default (197, 64, 42)

/** Success Border color  */
@property (nonatomic, strong) UIColor * CBTextFieldSuccessBorderColor;      // Default (120, 202, 81)

/** Speed ( in seonds ) with which the TextField should change its border color **/
@property (nonatomic, assign) CGFloat CBTextFieldBorderTransitionSpeed;     // Default 0.350s

/* Corner Radius */
@property (nonatomic, assign) CGFloat CBTextFieldBorderCornerRadius;        // Default 5

/* Border Thickness*/
@property (nonatomic, assign) CGFloat CBTextFieldBorderThickness;           // Default 0.5

/** Flag to indicate whether the CBTextField should perform validation when the TextField receives the UITextField
 delegate method -(void)textFieldDidEndEditing; */
@property (nonatomic, assign) BOOL CBTextFieldValidateOnEndEdit;            // Default NO

/** Flag to indicate whether the CBTextField should perform reset the border color back to Normal when the TextField receives the UITextField
 delegate method -(void)textFieldDidBeginEditing; */
@property (nonatomic, assign) BOOL CBTextFieldResetValidationOnBeginEdit;   // Default YES


/**
 Validates the input of the UITextField according to the Validation Strategy, if one is set. If one is not set, this
 function will hydrate the error object. This operation will query the validationDelegate object for proper instructions on how and when
 to perform validation, if one is set. If a delegate is not set, this function will ignore it, and continue with the
 validation. If validation is going to be performed, this method will change the border of the text field according to
 the validationDelegate's wishes, and will notify any observers of whether the validaton succeeded or failed
 
 @param error - output paramter giving information to the user as to why this operation falied
 
 @return true if the input is valid according to the Validation Strategy, false otherwise
 */
-(BOOL)validateInput:(NSError **)error;


/**
 Validates the input of the UITextField according to the Predicate passed into this method. This operation will query the validationDelegate object for 
 proper instructions on how and when to perform validation, if one is set. If a delegate is not set, this function will ignore it, and continue with the
 validation. If validation is going to be performed, this method will change the border of the text field according to
 the validationDelegate's wishes, and will notify any observers of whether the validaton succeeded or failed. This fucntion will
 ignore any previously set validation strategies
 
 @return true if the input is valid according to the Validation Predicate
 */
-(BOOL)validateInputWithPredicate:(CBTextFieldValidationPredicate)predicate error:(NSError **)error;


/**
 Validates the input of the UITextField according to the Validation Strategy, and will notify the handler when
 the validation is complete. This operation will query the validationDelegate object for proper instructions, 
 will change the border of the text field according to the validationDelegate's wishes, and will notify any observers 
 of whether the validaton succeeded or failed
 
 @return Completion handler will get called with YES if the validation succeeds
 */
-(void)validateInputWithCompletionHandler:(CBTextFieldCompletionHandler)handler;


/**
 Resets the TextField to a known state.
 
 @discussion Resets the border color to the Normal Border color. Clears the Text, and removes
 the first responder status of the TextField ( if it has first responder ).
 */
-(void)reset;

@end

