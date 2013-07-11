//
//  AppDelegate.m
//  piecemaker2
//
//  Created by Matthias Kadenbach on 11.07.13.
//  Copyright (c) 2013 motionbank. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize testButton = _testButton;
@synthesize textField = _textField;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

-(IBAction)testButton:(id)sender {
    NSString *workingDir = [[NSBundle mainBundle] bundlePath];
    NSString *resourcesDir = [workingDir stringByAppendingString:@"/Contents/Resources"];
    NSString *node = [resourcesDir stringByAppendingString:@"/local/bin/node"];
    
    // NSString *node = [NSString stringWithFormat:@"cd %@ && ./local/bin/node", resourcesDir];
    
    _textField.stringValue = [NSString stringWithFormat:@"workingDir:\n%@\n\nwhich node:\n%@\n\nstdout:\n%@", workingDir, node, @"waiting..."];
    
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: node];

    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: [resourcesDir stringByAppendingString:@"/app/test.js"], nil];
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *taskOutput;
    taskOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"task returned:\n%@", taskOutput);
    
    _textField.stringValue = [NSString stringWithFormat:@"workingDir:\n%@\n\nwhich node:\n%@\n\nstdout:\n%@", workingDir, node, taskOutput];
}

@end
