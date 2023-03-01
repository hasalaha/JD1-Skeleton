//
//  AppDelegate.h
//  JogControl
//
//  Created by Mats on 17.02.13.
//  Copyright (c) 2013 Mats. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hid/IOHIDLib.h>

typedef NS_ENUM(NSInteger, buttons)
{
    Button1 = 12,
    Button2 = 18,
    Button3 = 11,
    Button4 = 17,
    Button5 = 10,
    ButtonDeckFile = 19,
    ButtonLeft = 13,
    ButtonRight = 20,
    ButtonCapUndo = 14,
    ButtonIn = 15,
    ButtonOut = 21,
    ButtonPlayPause = 22,
    ButtonAddDiv = 16,
    ButtonWheelCenter = 23
};

@protocol Jd1Delegate <NSObject>   //define delegate protocol
- (void)onDeviceAttached;
- (void)onDeviceRemoved;
- (void)onJD1ButtonClicked: (enum buttons)button;  //define delegate method to be implemented within another class
- (void)onJD1WheelTurned:(BOOL)turnedClockwise;
@end //end protocol

@interface Jd1: NSObject
{
@private
    IOHIDDeviceRef inIOHIDDeviceRef;
}

@property (nonatomic, weak) id <Jd1Delegate> delegate; //define MyClassDelegate as delegate

- (void)initializeJd1;
- (void)SetLED_State:(CFIndex) tCFIndex;
- (void)onDeviceMatched:(IOHIDDeviceRef) deviceRef;
- (void)onDeviceRemoved:(IOHIDDeviceRef) deviceRef;

@end
