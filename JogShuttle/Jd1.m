//
//  AppDelegate.m
//  JogControl
//
//  Created by Mats on 17.02.13.
//  Copyright (c) 2013 Mats. All rights reserved.
//

#import "Jd1.h"

// Change these two constants to match your device's idVendor and idProduct.
#define kMyVendorID			0x05E7
#define kMyProductID		0x0006

// function to create a matching dictionary for usage page & usage
static CFMutableDictionaryRef hu_CreateMatchingDictionary()
{
    long usbVendor = kMyVendorID;
    long usbProduct = kMyProductID;
    
    // create a dictionary to add usage page / usages to
    CFMutableDictionaryRef matchingDictionary = CFDictionaryCreateMutable( kCFAllocatorDefault, 0,&kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks );
    if (matchingDictionary == NULL)
    {
        fprintf(stderr, "IOServiceMatching returned NULL.\n");
        return NULL;
    }
    // Create a CFNumber for the idVendor and set the value in the dictionary
    CFNumberRef numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usbVendor);
    CFDictionarySetValue(matchingDictionary, CFSTR(kIOHIDVendorIDKey), numberRef); // hid-manager
    CFRelease(numberRef);
    // Create a CFNumber for the idProduct and set the value in the dictionary
    numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usbProduct);
    CFDictionarySetValue(matchingDictionary, CFSTR(kIOHIDProductIDKey), numberRef); // hid-manager
    CFRelease(numberRef);
    
    return matchingDictionary;
}

// function to create a matching dictionary for usage page & usage
static CFMutableDictionaryRef hu_CreateMatchingDictionaryUsagePageUsage( Boolean isDeviceNotElement,
                                                                        UInt32 inUsagePage,
                                                                        UInt32 inUsage )
{
    // create a dictionary to add usage page / usages to
    CFMutableDictionaryRef result = CFDictionaryCreateMutable( kCFAllocatorDefault,
                                                              0,
                                                              &kCFTypeDictionaryKeyCallBacks,
                                                              &kCFTypeDictionaryValueCallBacks );
    
    if ( result )
    {
        if ( inUsagePage )
        {
            // Add key for device type to refine the matching dictionary.
            CFNumberRef pageCFNumberRef = CFNumberCreate( kCFAllocatorDefault, kCFNumberIntType, &inUsagePage );
            
            if ( pageCFNumberRef )
            {
                if ( isDeviceNotElement )
                {
                    CFDictionarySetValue( result, CFSTR( kIOHIDDeviceUsagePageKey ), pageCFNumberRef );
                }
                else
                {
                    CFDictionarySetValue( result, CFSTR( kIOHIDElementUsagePageKey ), pageCFNumberRef );
                }
                CFRelease( pageCFNumberRef );
                
                // note: the usage is only valid if the usage page is also defined
                if ( inUsage )
                {
                    CFNumberRef usageCFNumberRef = CFNumberCreate( kCFAllocatorDefault, kCFNumberIntType, &inUsage );
                    
                    if ( usageCFNumberRef )
                    {
                        if ( isDeviceNotElement )
                        {
                            CFDictionarySetValue( result, CFSTR( kIOHIDDeviceUsageKey ), usageCFNumberRef );
                        }
                        else
                        {
                            CFDictionarySetValue( result, CFSTR( kIOHIDElementUsageKey ), usageCFNumberRef );
                        }
                        CFRelease( usageCFNumberRef );
                    }
                    else
                    {
                        fprintf( stderr, "%s: CFNumberCreate( usage ) failed.", __PRETTY_FUNCTION__ );
                    }
                }
            }
            else
            {
                fprintf( stderr, "%s: CFNumberCreate( usage page ) failed.", __PRETTY_FUNCTION__ );
            }
        }
    }
    else
    {
        fprintf( stderr, "%s: CFDictionaryCreateMutable failed.", __PRETTY_FUNCTION__ );
    }
    return result;
}	// hu_CreateMatchingDictionaryUsagePageUsage



// this will be called when the HID Manager matches a new (hot plugged) HID device
static void Handle_DeviceMatchingCallback(void *          inContext,       // context from IOHIDManagerRegisterDeviceMatchingCallback
                                          IOReturn        inResult,        // the result of the matching operation
                                          void *          inSender,        // the IOHIDManagerRef for the new device
                                          IOHIDDeviceRef  inIOHIDDeviceRef) // the new HID device
{
    Jd1* jd1 = (__bridge Jd1*)inContext;
    [jd1 onDeviceMatched:inIOHIDDeviceRef];
    [jd1.delegate onDeviceAttached];
}


// this will be called when a HID device is removed (unplugged)
static void Handle_RemovalCallback(void *         inContext,       // context from IOHIDManagerRegisterDeviceMatchingCallback
                                   IOReturn       inResult,        // the result of the removing operation
                                   void *         inSender,        // the IOHIDManagerRef for the device being removed
                                   IOHIDDeviceRef inIOHIDDeviceRef) // the removed HID device
{
    Jd1* jd1 = (__bridge Jd1*)inContext;
    [jd1 onDeviceRemoved:inIOHIDDeviceRef];
    [jd1.delegate onDeviceRemoved];
}



static void Handle_IOHIDInputValueCallback(void *          inContext,      // context from IOHIDManagerRegisterInputValueCallback
                                           IOReturn        inResult,       // completion result for the input value operation
                                           void *          inSender,       // the IOHIDManagerRef
                                           IOHIDValueRef   inIOHIDValueRef) // the new element value
{
    Jd1* jd1 = (__bridge Jd1*)inContext;
    
    // Returns the HID element value associated with this HID value reference.
    IOHIDElementRef elementRef = IOHIDValueGetElement(inIOHIDValueRef);
    
    IOHIDElementCookie cookie = IOHIDElementGetCookie(elementRef);
    
    enum buttons buttonEnum = cookie;
    
    //NSLog(@"Cookie: %d", cookie);
    // Returns an integer representation for this HID value reference.
    CFIndex nIndex = IOHIDValueGetIntegerValue(inIOHIDValueRef);
    
    // return the collection type:
    //  kIOHIDElementTypeInput_Misc         = 1 = JD1-Wheel,
    //  kIOHIDElementTypeInput_Button       = 2 = all Buttons of JD-1,
    IOHIDElementType tType = IOHIDElementGetType(elementRef);
    
    if(tType == kIOHIDElementTypeInput_Button)
    {
        // index:
        // 1 = pressed
        // 0 = released
        
        if( 1 == nIndex )
        {
            // a button of JD1 is pressed
            [jd1.delegate onJD1ButtonClicked:buttonEnum];
        }
        else
        {
            //tCFIndex = 0;
            // a button if JD1 is released
            //printf("Button released(cookie: %d, element: %p)\n", cookie, elementRef);
        }
    }
    else if(tType == kIOHIDElementTypeInput_Misc)
    {
        // wheel index:
        // 1  = CW
        // -1 = CCW
        
        [jd1.delegate onJD1WheelTurned:(1 == nIndex)];
    }
    
    // the HID element name
    //CFStringRef name = IOHIDElementGetName(elementRef); // not valid at JD-1
    
    // Returns the timestamp value associated with this HID value reference.
    //uint64_t timestamp = IOHIDValueGetTimeStamp(inIOHIDValueRef);
}


@implementation Jd1

// index = 0 (000) -> All leds off
// index = 1 (001) -> Deck LED
// index = 2 (010) -> Jog LED
// index = 4 (100)-> Shuttle LED
- (void)SetLED_State:(CFIndex) tCFIndex // the HID device
{
    if( NULL != inIOHIDDeviceRef )
    {
        CFDictionaryRef matchingCFDictRef = hu_CreateMatchingDictionaryUsagePageUsage( FALSE, kHIDPage_VendorDefinedStart, 0 );
        // copy all the elements
        CFArrayRef elementCFArrayRef = IOHIDDeviceCopyMatchingElements(inIOHIDDeviceRef,
                                                                       matchingCFDictRef,
                                                                       kIOHIDOptionsTypeNone );
        if ( matchingCFDictRef )
        {
            CFRelease( matchingCFDictRef );
        }
        
        if( NULL != elementCFArrayRef )
        {
            // iterate over all the elements
            CFIndex elementIndex, elementCount = CFArrayGetCount( elementCFArrayRef );
            for ( elementIndex = 0; elementIndex < elementCount; elementIndex++ )
            {
                IOHIDElementRef tIOHIDElementRef = ( IOHIDElementRef ) CFArrayGetValueAtIndex( elementCFArrayRef, elementIndex );
                
                uint64_t timestamp = 0; // create the IO HID Value to be sent to this LED element
                IOHIDValueRef tIOHIDValueRef = IOHIDValueCreateWithIntegerValue( kCFAllocatorDefault, tIOHIDElementRef, timestamp, tCFIndex );
                if ( tIOHIDValueRef )
                {
                    // now set it on the device
                    IOHIDDeviceSetValue( inIOHIDDeviceRef, tIOHIDElementRef, tIOHIDValueRef );
                    CFRelease( tIOHIDValueRef );
                }
            }
        }
    }
}

- (void)onDeviceRemoved:(IOHIDDeviceRef) deviceRef
{
    NSLog(@"Device removed: %p\n", deviceRef);
    
    if( deviceRef == inIOHIDDeviceRef )
    {
        inIOHIDDeviceRef = NULL;
    }
}

- (void)onDeviceMatched:(IOHIDDeviceRef) deviceRef
{
    NSLog(@"Device added: %p\n", deviceRef);
    inIOHIDDeviceRef = deviceRef;
}


- (void)initializeJd1
{
    // Insert code here to initialize your application
    IOHIDManagerRef gIOHIDManagerRef = IOHIDManagerCreate( kCFAllocatorDefault, kIOHIDOptionsTypeNone );
    if (CFGetTypeID(gIOHIDManagerRef) != IOHIDManagerGetTypeID())
    {
        // this is not a valid HID Manager reference!
        return;
    }
    
    // Create a device matching dictionary
    CFDictionaryRef matchingDictionary = hu_CreateMatchingDictionary();
    if( NULL == matchingDictionary )
    {
        return;
    }
    
    // set the HID device matching dictionary
    // (single matching criteria (dictionary) for device enumeration)
    IOHIDManagerSetDeviceMatching( gIOHIDManagerRef, matchingDictionary );
    
    if ( matchingDictionary )
    {
        CFRelease( matchingDictionary );
    }
    
    // There is no special function to unregister HID callback routines.
    // You can unregistered by calling the appropriate registration function and passing NULL for the pointer to the callback routine.
    
    // This routine will be called when a new (matching) device is connected.
    IOHIDManagerRegisterDeviceMatchingCallback(gIOHIDManagerRef, Handle_DeviceMatchingCallback, (__bridge void *)(self));
    // This routine will be called when a (matching) device is disconnected.
    IOHIDManagerRegisterDeviceRemovalCallback(gIOHIDManagerRef, Handle_RemovalCallback, (__bridge void *)(self));
    
    IOHIDManagerRegisterInputValueCallback(gIOHIDManagerRef, Handle_IOHIDInputValueCallback, (__bridge void *)(self));
    
    // Schedule HID Manager with run loop
    IOHIDManagerScheduleWithRunLoop(gIOHIDManagerRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    
    // Now open the IO HID Manager reference
    // TODO: Once a HID Manager reference has been opened it may be closed by using the IOHIDManagerClose function
    // kIOHIDOptionsTypeSeizeDevice forces exclusive access for all matching devices
    IOReturn tIOReturn = IOHIDManagerOpen( gIOHIDManagerRef, kIOHIDOptionsTypeSeizeDevice );
    if( kIOReturnSuccess != tIOReturn )
    {
        return;
    }
}

@end
