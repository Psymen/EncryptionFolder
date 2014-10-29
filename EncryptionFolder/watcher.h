//
//  watcher.h
//  EncryptionFolder
//
/*
 
 File:       Watcher.c
 Abstract:   A simple demonstration of the FSEvents API.
 Version: <1.3>
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc.
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied,
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2007 Apple Inc. All Rights Reserved.
 
 are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 */
//

#ifndef EncryptionFolder_watcher_h
#define EncryptionFolder_watcher_h

#include "watcher.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <sys/mount.h>
#include <sys/event.h>
#include <dirent.h>
#include <assert.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <pthread.h>




typedef struct _settings_t {
    dev_t                dev;
    FSEventStreamEventId since_when;
    CFAbsoluteTime       latency;
    const char          *fullpath;
    const char          *desktop;
    const char          *password;
    const char          *encryptScript;
    const char          *decryptScript;
    CFUUIDRef            dev_uuid;
    char                 mount_point[MAXPATHLEN];
} settings_t;



typedef struct dir_item {
    char       *dirname;
    short int   depth;
    short int   state;
    off_t       size;
} dir_item;




void  scan_directory(const char *path, int add, int recursive, int depth);
int   save_dir_items(const char *name);
int   load_dir_items(const char *name);
void  discard_all_dir_items(void);
int   remove_dir_and_children(const char *name);
int   check_children_of_dir(const char *dirname);
off_t get_total_size(void);

void  save_stream_info(uint64_t last_id, CFUUIDRef dev_uuid);
int   load_stream_info(uint64_t *since_when, CFUUIDRef *uuid_ref_ptr);

int   setup_run_loop_signal_handler(CFRunLoopRef loop);
void  cleanup_run_loop_signal_handler(CFRunLoopRef loop);

int   get_dev_info(settings_t *settings);
CFMutableArrayRef create_cfarray_from_path(const char *path);


void initialize_folder_monitoring(char * encryptionFolder, char * desktopFolder, char *encryptionPassword, id param, char * encryptionScript, char * decryptionScript);
void handleEncryption(settings_t *settings);



#endif
