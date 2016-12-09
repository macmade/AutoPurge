/*******************************************************************************
 * Copyright (c) 2011, Jean-David Gadina <macmade@eosgarden.com>
 * All rights reserved
 ******************************************************************************/
 
/* $Id$ */

/*!
 * @header      ...
 * @copyright   eosgarden 2011 - Jean-David Gadina <macmade@eosgarden.com>
 * @abstract    ...
 */

FOUNDATION_EXPORT NSString * const PreferencesChangedNotification;

@interface PreferencesController: NSWindowController
{
@protected
    
    NSButton    * _loginCheckbox;
    NSButton    * _autoPurgeCheckbox;
    NSButton    * _idleCheckbox;
    NSSlider    * _autoPurgeSlider;
    NSSlider    * _idleSlider;
    NSTextField * _autoPurgeText;
    NSTextField * _idleText;
    
@private
    
    id _PreferencesController_Reserved[ 5 ] __attribute__( ( unused ) );
}

@property( nonatomic, retain ) IBOutlet NSButton    * loginCheckbox;
@property( nonatomic, retain ) IBOutlet NSButton    * autoPurgeCheckbox;
@property( nonatomic, retain ) IBOutlet NSButton    * idleCheckbox;
@property( nonatomic, retain ) IBOutlet NSSlider    * autoPurgeSlider;
@property( nonatomic, retain ) IBOutlet NSSlider    * idleSlider;
@property( nonatomic, retain ) IBOutlet NSTextField * autoPurgeText;
@property( nonatomic, retain ) IBOutlet NSTextField * idleText;

- ( IBAction )cancel: ( id )sender;
- ( IBAction )save: ( id )sender;
- ( IBAction )toggleAutoPurgeSlider: ( id )sender;
- ( IBAction )toggleIdleSlider: ( id )sender;

@end
