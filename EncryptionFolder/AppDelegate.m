//
//  AppDelegate.m
//  EncryptionFolder
//
//  Created by lancashi on 7/7/13.
//  Copyright (c) 2013 Language Systems Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "watcher.h"
#include <stdlib.h>
#include <pthread.h>
#include <dispatch/dispatch.h>




@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {


    printf("Testing 3");
    
    // Hide the Configuration Window
    self.window.isVisible = NO;
    

    
    
    printf("Testing 3");
    
    
    // setup initial directory paths
    homeDir = NSHomeDirectory();
    libraryDir = [homeDir stringByAppendingPathComponent:@"Library/EncryptionFolder"];
    libraryDirFolderEncryptionFile = [libraryDir stringByAppendingPathComponent:@"/encrypt"];
    libraryDirFolderDecryptionFile = [libraryDir stringByAppendingPathComponent:@"/decrypt"];
    hiddenEncryptionDir = [homeDir stringByAppendingPathComponent:@".Encryption"];
    hiddenEncryptionDirPasswordFile = [homeDir stringByAppendingPathComponent:@".Encryption/.password"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
    desktopPath = [paths objectAtIndex:0];
    encryptionDir = [desktopPath stringByAppendingPathComponent:@"Encryption"];
    encryptionDirPasswordFile = [desktopPath stringByAppendingPathComponent:@"Encryption/.password"];
    
    
    printf("Testing 3");
    
    
    
    // This block of code is triggered if the hidden encryption folder exists in the user home
    // directory. In this case, there is already a password set for the folder, and we only
    // need to prompt the user for a password and test for match.
    //
    // If the user cannot provide the necessary authentication information, then we should
    // quit the program. Users cannot change password information for folders once they have
    // been created.
    //
    BOOL doesDirectoryExist;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:hiddenEncryptionDir isDirectory:&doesDirectoryExist] || doesDirectoryExist) {
        
        
        printf("Hidden Encryption Dir already eixsts....");
        
        // Read password hash from hidden directory
        NSError *error = nil;
        NSString *encryptionPasswordHash = [NSString stringWithContentsOfFile:hiddenEncryptionDirPasswordFile encoding:NSUTF8StringEncoding error:&error];
        
        
        
        // Prompt User for Password
        NSAlert *alert = [NSAlert alertWithMessageText:@"Encryption Folder"
                                         defaultButton:@"Confirm"
                                       alternateButton:@"Cancel"
                                           otherButton:nil
                             informativeTextWithFormat:@"Confirm Encryption Folder password to launch:"];
        NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 24)];
        [alert setAccessoryView:input];
        NSInteger button = [alert runModal];
        if (button == NSAlertDefaultReturn) {
            encryptionPassword = [input stringValue];
        } else {
            //NSLog(@"Quitting!");
            exit(0);
        }
        

            
        
        // Now test our input password for the proper hash
        int doesHashMatch = 0;
        FILE *pipein_fp;
        int bufsize = 1024;
        char popcommand[bufsize];
        char readbuf[bufsize];
        sprintf(popcommand, "echo \"%s\" | openssl dgst -sha512", [encryptionPassword UTF8String]);
        //printf("\n\n %s \n\n", popcommand);
            
            
        // create pipe for reading data
        if (( pipein_fp = popen(popcommand, "r")) != NULL) {
                
            // read unencrypted files from butter
            while (fgets(readbuf, bufsize, pipein_fp)) {

                int order = strcmp(readbuf, [encryptionPasswordHash UTF8String]);
                if (order == 0) {
                    doesHashMatch = 1;
                }
            }
                
            // Close the pipes
            pclose(pipein_fp);
                
        }
            
          

        if (doesHashMatch == 0) {
            // password incorrect - simply exit
            exit(0);
        } else {
            // password correct -- copy Encryption Folder to Desktop
            NSString *copyCommand = [NSString stringWithFormat:@"mv \"%s\" \"%s\"", [hiddenEncryptionDir UTF8String], [encryptionDir UTF8String]];
            system([copyCommand UTF8String]);
        }
        
        
        
        
        
        
        
        
        
        
        
    // This block of code is triggered if the hidden encryption folder does not exist in the
    // user home directory. In this case, we may be setting up the software for the first time,
    // in which case we should prompt for a password, copy backend files and create the
    // encryption folder directly on the desktop
    } else {
        
        
        
        printf("Hidden Encryption Dir not exists... checking Desktop....");
        
        
        
        // assume encryption folder exists on the desktop and we just had a bad shutdown
        // in order to avoid overwriting everything.
        int folderAlreadyExists = 1;

        
        
        // create encryption folder on desktop
        if (![manager fileExistsAtPath:encryptionDir isDirectory:&doesDirectoryExist] || !doesDirectoryExist) {
            printf("Hidden Encryption Dir already exists on Desktop....");
            NSError *error = nil;
            [manager createDirectoryAtPath:encryptionDir withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                exit(1);
            } else {
                //NSLog(@"Created the encryption directory");
                folderAlreadyExists = 0;
            }
        } else {
            //NSLog(@"No need to create the encryption directory!");
            printf("Hidden Encryption Dir already exists on Desktop....");

        }
        
        
        
        
        
        // if the folder already exists on the desktop, we do not need to create an
        // Application Support Library as it will have already been created. But otherwise
        // we should create a folder to store our relevant / universal files.
        if (folderAlreadyExists == 0) {
    
            if (![manager fileExistsAtPath:libraryDir isDirectory:&doesDirectoryExist] || doesDirectoryExist) {
                NSError *error = nil;
                [manager createDirectoryAtPath:libraryDir withIntermediateDirectories:YES attributes:nil error:&error];
                if (error) {
                } else {
                }
            } else {
            }
            
            // copy encryption and decryption executables to Application Support Library
            NSString *encryptResourcePath =  [  [[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"encrypt"];
            NSString *decryptResourcePath =  [  [[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"decrypt"];
            
            NSString *copyCommand = [NSString stringWithFormat:@"cp \"%s\" \"%s\"", [encryptResourcePath UTF8String], [libraryDirFolderEncryptionFile UTF8String]];
            system([copyCommand UTF8String]);
            NSString *copyCommand2 = [NSString stringWithFormat:@"cp \"%s\" \"%s\"", [decryptResourcePath UTF8String], [libraryDirFolderDecryptionFile UTF8String]];
            system([copyCommand2 UTF8String]);
            
            // make encryption and decryption scripts executable by this user
            NSString *execCommand = [NSString stringWithFormat:@"chmod +x \"%s\"", [encryptResourcePath UTF8String]];
            system([execCommand UTF8String]);
            NSString *execCommand2 = [NSString stringWithFormat:@"chmod +x \"%s\"", [decryptResourcePath UTF8String]];
            system([execCommand2 UTF8String]);
            
        }

        
        
        
        // Now we have an encryption folder on the desktop, along with the supporting scripts
        // in the application support directory. In order to launch the program, we need to
        // ask the user for a password. If we have just created this directory, we need to
        // ask TWICE in order to avoid any problems. Otherwise, just prompt for the password
        // once and quit if it is not appropriate.
        if (folderAlreadyExists == 1) {
            
            // prompt for existing password
            NSAlert *alert = [NSAlert alertWithMessageText:@"Encryption Folder"
                                             defaultButton:@"Confirm"
                                           alternateButton:@"Cancel"
                                               otherButton:nil
                                 informativeTextWithFormat:@"Confirm Encryption Folder password to launch:"];
            NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 24)];
            [alert setAccessoryView:input];
            NSInteger button = [alert runModal];
            if (button == NSAlertDefaultReturn) {
                encryptionPassword = [input stringValue];
            } else {
                //NSLog(@"Quitting!");
                exit(0);
            }
            
        } else {
        
            // initialize a new folder
            NSAlert *alert = [NSAlert alertWithMessageText:@"Setup Encryption Folder"
                                         defaultButton:@"Set"
                                       alternateButton:@"Cancel"
                                           otherButton:nil
                             informativeTextWithFormat:@"Please provide a password for your Encryption Folder:"];
            NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 24)];
            [alert setAccessoryView:input];
            NSInteger button = [alert runModal];
            if (button == NSAlertDefaultReturn) {
                encryptionPassword = [input stringValue];
            } else {
                
                // abort installation - remove desktop encryption folder since password still unset
                NSString *delCommand = [NSString stringWithFormat:@"rmdir \"%s\"", [encryptionDir UTF8String]];
                system([delCommand UTF8String]);
                
                exit(0);
            }
        
            // confirm password
            alert = [NSAlert alertWithMessageText:@"Setup Encryption Folder"
                                defaultButton:@"Confirm"
                              alternateButton:@"Cancel"
                                  otherButton:nil
                    informativeTextWithFormat:@"Please confirm your Encryption Folder password:"];
            input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 24)];
            [alert setAccessoryView:input];
            button = [alert runModal];
            if (button == NSAlertDefaultReturn) {
                passwordConfirm = [input stringValue];
            } else {

                // abort installation - remove desktop encryption folder since password still unset
                NSString *delCommand = [NSString stringWithFormat:@"rmdir \"%s\"", [encryptionDir UTF8String]];
                system([delCommand UTF8String]);
                
                exit(0);
            }
        
        
        
        
            // while passwords do not match, keep asking until they do or the user quits
            while (![passwordConfirm isEqualToString:encryptionPassword]) {
            
                // fetch password
                alert = [NSAlert alertWithMessageText:@"Setup Encryption Folder"
                                    defaultButton:@"Set"
                                  alternateButton:@"Cancel"
                                      otherButton:nil
                        informativeTextWithFormat:@"Your passwords did not match. Re-enter password:"];
                input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 24)];
                [alert setAccessoryView:input];
                button = [alert runModal];
                if (button == NSAlertDefaultReturn) {
                    encryptionPassword = [input stringValue];
                } else {
                    exit(0);
                }
            
                // confirm password
                alert = [NSAlert alertWithMessageText:@"Setup Encryption Folder"
                                    defaultButton:@"Set"
                                  alternateButton:@"Cancel"
                                      otherButton:nil
                        informativeTextWithFormat:@"Please confirm re-entered password:"];
                input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 24)];
                [alert setAccessoryView:input];
                button = [alert runModal];
                if (button == NSAlertDefaultReturn) {
                    passwordConfirm = [input stringValue];
                } else {
                    exit(0);
                }
            
            }

            
            // Hash the new password and stuff it into our encryption folder for future reference
            FILE *pipein_fp;
            int bufsize = 1024;
            char popcommand[bufsize];
            char readbuf[bufsize];
            sprintf(popcommand, "echo \"%s\" | openssl dgst -sha512 > \"%s\"", [encryptionPassword UTF8String], [encryptionDirPasswordFile UTF8String]);
            system(popcommand);
            //printf("\n\n%s\n\n", popcommand);

        }
                
        
    
    }
    
    
    
    
    
    // tweak encryption folder icon
    [self applyIconToEncryptionFolder];

    
    
    
    
    
    // initialize monitoring the folder (kqueues, etc.)
    dispatch_queue_t myQueue = dispatch_queue_create("com.languagesystems.myqueue", 0);
    dispatch_async(myQueue, ^{
        //printf("this is a block!\n");
        initialize_folder_monitoring([encryptionDir UTF8String], [desktopPath UTF8String], [encryptionPassword UTF8String], self, [libraryDirFolderEncryptionFile UTF8String], [libraryDirFolderDecryptionFile UTF8String]);
        //printf("this is a block finished!\n");
    });

    
    
    
    
}


-(void)applicationDidBecomeActive:(NSNotification *)notification{

    return;
    
}

-(void)awakeFromNib{

    statusMenu = [[NSMenu alloc] init];

    printf("Testing");
    
    [statusMenu addItemWithTitle:@"Quit" action:@selector(terminateApplication:) keyEquivalent:@"q"];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setToolTip:@"Your Encryption Folder"];
    //[statusItem setTitle:@"Encrypt"];
    NSString *path32 = [[NSBundle mainBundle] pathForResource:@"lock_black" ofType:@"png"];
//    printf("Here: %s", [path32 UTF8String]);
    NSImage *statusImage = [[NSImage alloc] initWithContentsOfFile:path32];
    NSString *path33 = [[NSBundle mainBundle] pathForResource:@"lock_white" ofType:@"png"];
//    printf("Here: %s", [path33 UTF8String]);
    NSImage *statusImageHighlight = [[NSImage alloc] initWithContentsOfFile:path33];
    
    
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusImageHighlight];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:statusMenu];
    [statusItem setEnabled:YES];

    printf("Testing 2");

    
}

-(IBAction)terminateApplication:(id)sender {

    //NSLog(@"we are terminating the application!");
    
    
    
    // if hidden encryption folder exists on desktop, but not in hidden user folder, copy
    BOOL doesDirectoryExist;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:encryptionDir isDirectory:&doesDirectoryExist] || doesDirectoryExist) {

        if (![manager fileExistsAtPath:hiddenEncryptionDir isDirectory:&doesDirectoryExist] || !doesDirectoryExist) {

            //NSLog(@"Copying encryption folder back to hidden directory!");
            NSString *copyCommand = [NSString stringWithFormat:@"mv \"%s\" \"%s\"", [encryptionDir UTF8String], [hiddenEncryptionDir UTF8String]];
            system([copyCommand UTF8String]);

        } else {
        }
        
    } else {
        //NSLog(@"The hidden encryption directory does not exist!");
    }
    
    exit(0);
    
}
-(IBAction)configureApplication:(id)sender {
    self.window.isVisible = YES;
    //NSLog(@"we are configuring the application!");
}
-(void)applyIconToEncryptionFolder {
    
    // tweak the folder icon
    NSString *path22 = [[NSBundle mainBundle] pathForResource:@"folder_lock" ofType:@"png"];
    NSImage *iconImage = [[NSImage alloc] initWithContentsOfFile:path22];
    NSWorkspace * ws = [NSWorkspace sharedWorkspace];
    BOOL x = [ws setIcon:iconImage forFile:@"/Users/lancashire/Desktop/Encryption" options:0];
    
    return;
}



@end
