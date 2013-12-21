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

#import "CBTextField.h"

static NSString * const kCBTextFieldDomain = @"com.CBTextField";

NSString * const CBTextFieldDidPassValidationNotification = @"com.CBTextField.ValidationDidPass";
NSString * const CBTextFieldDidFailValidationNotification = @"com.CBTextField.ValidationDidFail";

@implementation CBTextField

@synthesize CBTextFieldValidationStrategy           = CBTextFieldValidationStrategy_;
@synthesize CBTextFieldValidationDelegate           = CBTextFieldValidationDelegate_;
@synthesize CBTextFieldNormalBorderColor            = CBTextFieldNormalBorderColor_;
@synthesize CBTextFieldErrorBorderColor             = CBTextFieldErrorBorderColor_;
@synthesize CBTextFieldSuccessBorderColor           = CBTextFieldSuccessBorderColor_;
@synthesize CBTextFieldValidateOnEndEdit            = CBTextFieldValidateOnEndEdit_;
@synthesize CBTextFieldResetValidationOnBeginEdit   = CBTextFieldResetValidationOnBeginEdit_;
@synthesize CBTextFieldBorderTransitionSpeed        = CBTextFieldBorderTransitionSpeed_;
@synthesize CBTextFieldBorderCornerRadius           = CBTextFieldBorderCornerRadius_;
@synthesize CBTextFieldBorderThickness              = CBTextFieldBorderThickness_;


#pragma mark - Initialization Methods

- (id)init
{
    self = [super init];
    if(self)
    {
        [self initialize];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self initialize];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

-(void)initialize
{
    // Initialize Text Validation
    self.CBTextFieldValidationStrategy = nil;
    self.CBTextFieldValidationDelegate = nil;
    self.CBTextFieldValidateOnEndEdit = NO;
    self.CBTextFieldResetValidationOnBeginEdit = YES;
    
    // Initialize Default Colors
    self.CBTextFieldNormalBorderColor = [UIColor lightGrayColor];
    self.CBTextFieldErrorBorderColor  = [UIColor colorWithRed:(197.0f/255.0f) green:(64.0f/255.0f) blue:(34.0f/255.0f) alpha:1.0f];
    self.CBTextFieldSuccessBorderColor= [UIColor colorWithRed:(120.0f/255.0f) green:(202.0f/255.0f) blue:(81.0f/255.0f) alpha:1.0];
    
    // Initialize Default Layer Properties
    self.CBTextFieldBorderTransitionSpeed = 0.350f;
    self.CBTextFieldBorderThickness = 0.5f;
    self.CBTextFieldBorderCornerRadius = 5.0f;
}

#pragma mark - Public Interface Methods

-(BOOL)validateInput:(NSError *__autoreleasing *)error
{
    // See if we have a Strategy Set, otherwise, do nothing, and give an error
    if(!self.CBTextFieldValidationStrategy) {
        
        if(error) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"Validation Strategy was Not set on the target"};
            *error = [NSError errorWithDomain:kCBTextFieldDomain code:-30 userInfo:userInfo];
        }
        return NO;
    }
    
    BOOL shouldVaidate = YES;
    
    // Ask the Delegate is we should validate the input
    if([self.CBTextFieldValidationDelegate respondsToSelector:@selector(CBTextField:shouldValidateContent:)]) {
        
        shouldVaidate = [self.CBTextFieldValidationDelegate CBTextField:self shouldValidateContent:self.text];
    }
    
    if(shouldVaidate) {
        
        // Tell the Delegate that we are about to do the validation
        if([self.CBTextFieldValidationDelegate respondsToSelector:@selector(CBTextField:willValidateContent:)]) {
            [self.CBTextFieldValidationDelegate CBTextField:self willValidateContent:self.text];
        }
        
        // Tell the Strategy to do the validation
        BOOL succeeded = [self.CBTextFieldValidationStrategy validateContent:self.text];
        
        // Udpate our Border Colors
        [self updateTextBoxWithValidationOutput:succeeded];
        
        // Tell the Delegate that we finished the validation
        if([self.CBTextFieldValidationDelegate respondsToSelector:@selector(CBTextField:didValidateContent:withSuccess:error:)]) {
            
            [self.CBTextFieldValidationDelegate CBTextField:self didValidateContent:self.text withSuccess:succeeded error:nil];
        }
        
        // Tell any observers that we have finished the validation
        NSNotification * notification = [self getNotificationForValidationOutput:succeeded];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        return succeeded;
    }
    
    // Our delegate told us that we shouldn't validate the input, so return NO by default, and don't change the border color
    return NO;
}

-(void)validateInputWithCompletionHandler:(CBTextFieldCompletionHandler)handler;
{
    NSError * error;
    
    // Handle the validation normally
    BOOL succeeded = [self validateInput:&error];
    
    // Let the client code know what happened
    handler(succeeded, error);
}

-(BOOL)validateInputWithPredicate:(CBTextFieldValidationPredicate)predicate error:(NSError *__autoreleasing *)error
{
    // If predicate is nil throw an error
    if(!predicate) {
        
        if(error) {
            NSDictionary * userInfo = @{NSLocalizedDescriptionKey: @"Validation Predicate was not provided"};
            *error = [NSError errorWithDomain:kCBTextFieldDomain code:-40 userInfo:userInfo];
        }
        
        return NO;
    }
    
    BOOL shouldVaidate = YES;
    
    // Ask the Delegate is we should validate the input
    if([self.CBTextFieldValidationDelegate respondsToSelector:@selector(CBTextField:shouldValidateContent:)]) {
        
        shouldVaidate = [self.CBTextFieldValidationDelegate CBTextField:self shouldValidateContent:self.text];
    }
    
    if(shouldVaidate) {
        
        // Tell the Delegate that we are about to do the validation
        if([self.CBTextFieldValidationDelegate respondsToSelector:@selector(CBTextField:willValidateContent:)]) {
            [self.CBTextFieldValidationDelegate CBTextField:self willValidateContent:self.text];
        }
        
        // Ask the predicate if we have succeeded
        BOOL succeeded = predicate(self.text);
        
        // Udpate our Border Colors
        [self updateTextBoxWithValidationOutput:succeeded];
        
        // Tell the Delegate that we finished the validation
        if([self.CBTextFieldValidationDelegate respondsToSelector:@selector(CBTextField:didValidateContent:withSuccess:error:)]) {
            
            [self.CBTextFieldValidationDelegate CBTextField:self didValidateContent:self.text withSuccess:succeeded error:nil];
        }
        
        // Tell any observers that we have finished the validation
        NSNotification * notification = [self getNotificationForValidationOutput:succeeded];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        
        return succeeded;
    }
    
    // Our delegate told us that we shouldn't validate the input, so return NO by default, and don't change the border color
    return NO;
}

-(void)reset
{
    // Reset the text back to the empty string
    self.text = @"";
    
    // Reset the border color back to the Normal Border color
    self.layer.borderColor = self.CBTextFieldNormalBorderColor.CGColor;
    
    // Resign the first responder if the textfield is currently the first responder
    if([self isFirstResponder])
        [self resignFirstResponder];
}

#pragma mark - Action Methods

-(void)OnTextFieldDidEndEditing:(NSNotification *)notification
{
    // Only handle notifications that are directed at this instance
    if([notification object] == self)
        [self validateInput:nil];
}

-(void)OnTextFieldDidBeginEditing:(NSNotification *)notification
{
    // Only handle notiifications that are directed at this instance
    if([notification object] == self) {
        CGColorRef transitionBorderColor = self.CBTextFieldNormalBorderColor.CGColor;
        [self animateBorderWithColor:transitionBorderColor];
    }
}

#pragma mark - Getters / Setters

-(void)setCBTextFieldValidateOnEndEdit:(BOOL)CBTextFieldValidateOnEndEdit
{
    if(CBTextFieldValidateOnEndEdit != self.CBTextFieldValidateOnEndEdit) {
        if(CBTextFieldValidateOnEndEdit) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnTextFieldDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
        }
        
        CBTextFieldValidateOnEndEdit_ = CBTextFieldValidateOnEndEdit;
    }
}

-(void)setCBTextFieldResetValidationOnBeginEdit:(BOOL)CBTextFieldResetValidationOnBeginEdit
{
    if(CBTextFieldResetValidationOnBeginEdit != self.CBTextFieldResetValidationOnBeginEdit) {
        if(CBTextFieldResetValidationOnBeginEdit) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnTextFieldDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
        }
        
        CBTextFieldResetValidationOnBeginEdit_ = CBTextFieldResetValidationOnBeginEdit;
    }
}

-(void)setCBTextFieldBorderCornerRadius:(CGFloat)CBTextFieldBorderCornerRadius
{
    if(CBTextFieldBorderCornerRadius != self.CBTextFieldBorderCornerRadius) {
        CBTextFieldBorderCornerRadius_ = CBTextFieldBorderCornerRadius;
        
        self.layer.cornerRadius = CBTextFieldBorderCornerRadius;
    }
}

-(void)setCBTextFieldBorderThickness:(CGFloat)CBTextFieldBorderThickness
{
    if(CBTextFieldBorderThickness != self.CBTextFieldBorderThickness) {
        CBTextFieldBorderThickness_ = CBTextFieldBorderThickness;
        
        self.layer.borderWidth = CBTextFieldBorderThickness;
    }
}

-(void)setCBTextFieldNormalBorderColor:(UIColor *)CBTextFieldNormalBorderColor
{
    if(!CGColorEqualToColor(CBTextFieldNormalBorderColor.CGColor, self.CBTextFieldNormalBorderColor.CGColor)) {
        CBTextFieldNormalBorderColor_ = CBTextFieldNormalBorderColor;
        
        self.layer.borderColor = CBTextFieldNormalBorderColor.CGColor;
    }
}

#pragma mark - Private Helper Methods

-(void)updateTextBoxWithValidationOutput:(BOOL)output
{
    // Get the Appropriate color for this transition
    CGColorRef transitionBorderColor = [self colorForValidationOutput:output].CGColor;
    
    [self animateBorderWithColor:transitionBorderColor];
}

-(UIColor *)colorForValidationOutput:(BOOL)output
{
    if (output) {
        return self.CBTextFieldSuccessBorderColor;
    }
    
    return self.CBTextFieldErrorBorderColor;
}

-(CABasicAnimation*)borderAnimationForBorderColor:(CGColorRef)borderColor
{
    CABasicAnimation * borderAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    borderAnimation.fromValue = [NSValue valueWithPointer:self.layer.borderColor];
    borderAnimation.toValue = [NSValue valueWithPointer:borderColor];
    borderAnimation.duration = self.CBTextFieldBorderTransitionSpeed;
    
    return borderAnimation;
}

-(NSNotification *)getNotificationForValidationOutput:(BOOL)output
{
    if(output) {
        return [NSNotification notificationWithName:CBTextFieldDidPassValidationNotification object:self];
    }
    
    return [NSNotification notificationWithName:CBTextFieldDidFailValidationNotification object:self];
}

#pragma mark - Animation Methods

-(void)animateBorderWithColor:(CGColorRef)transitionBorderColor
{
    // Get the animation to apply to the border
    CABasicAnimation * borderAnimation = [self borderAnimationForBorderColor:transitionBorderColor];
    
    // Apply the animation if the border is not already this color
    if(!CGColorEqualToColor(transitionBorderColor, self.layer.borderColor))
    {
        [self.layer setBorderColor:transitionBorderColor];
        [self.layer addAnimation:borderAnimation forKey:@"borderColorAnimation"];
    }
}

@end
