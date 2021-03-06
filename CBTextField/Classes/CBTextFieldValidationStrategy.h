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

#import <Foundation/Foundation.h>

/*
    The CBtextFieldValidationStrategy Protocol is required of all objects that want to become
    validation objects for the CBTextField. THe single method defines how each instance of this
    protocol will validate its input.
 */

@protocol CBTextFieldValidationStrategy <NSObject>

@required

-(BOOL)validateContent:(NSString *)content;

@end
