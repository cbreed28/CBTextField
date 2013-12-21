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

@interface CBTextFieldDemoTests : XCTestCase

@end

@implementation CBTextFieldDemoTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
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

- (void)test
{
    
}

@end
