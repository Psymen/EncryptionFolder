//
//  AppDelegate.h
//  EncryptionFolder
//
//  Created by lancashi on 7/7/13.
//  Copyright (c) 2013 Language Systems Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
    IBOutlet NSMenu *statusMenu;
    
    NSStatusItem    *statusItem;
    NSImage         *statusImage;
    NSImage         *statusImageHighlight;

    NSString        *homeDir;
    NSString        *encryptionDir;
    NSString        *encryptionDirPasswordFile;
    NSString        *hiddenEncryptionDir;
    NSString        *hiddenEncryptionDirPasswordFile;
    NSString        *libraryDir;
    NSString        *libraryDirFolderEncryptionFile;
    NSString        *libraryDirFolderDecryptionFile;
    NSString        *desktopPath;
    NSString        *encryptionPassword;
    NSString        *passwordConfirm;
    
}
-(IBAction)configureApplication:(id)sender;
-(IBAction)terminateApplication:(id)sender;
-(int)fetchPassword:(id)sender;
-(void)applyIconToEncryptionFolder;


@property (assign) IBOutlet NSWindow *window;

@end
