/*
 * Copyright (c) 2009 Jonathan K. Bullard
 */

@import Darwin;

#import "AtoZUniversal.h"

@implementation  NSFileHandle (NamedPipe)

  CLANG_IGNORE(-Wobjc-designated-initializers)

- initAndRead:(NSString *)inPath toBlock:(BOOL(^)(NSData*))readMaybeCancel {

  CLANG_POP

  NSParameterAssert(readMaybeCancel && inPath);

  if ((mkfifo(inPath.UTF8String, 0666) == -1) && (errno != EEXIST)) // Create the pipe

    return NSLog(@"Unable to create named pipe %@", inPath), nil;   // Bail on fail.

  /*!

  We "open()" to get a file descriptor, then get a fileHandle from the returned file descriptor.

  If we try to get a fileHandle directly via "[NSFileHandle fileHandleForReadingAtPath:]" the process is blocked. Calling "open()" and then getting the fileHandle from the returned file descriptor avoids that blocking.

  Similarly, if we get a file handle via "[NSFileHandle fileHandleForUpdatingAtPath:]", the process blocks when we do a "[fileHandle release]" or a "[fileHandle closeFile]"
  
  Using "initWithFileDescriptor: closeOnDealloc:NO" causes the file NOT to be closed when the fileDescriptor is
   released. See the comment in "destroyPipe", below.
   
   We can't open with the "O_NONBLOCK" option because that causes "readInBackgroundAndNotify" to send continuous notifications that there is data of length zero. That eats up 100% of the CPU (at a low priority, but still...)

*/

  int fileDescriptor = open(inPath.UTF8String, O_RDWR); // Get a file descriptor for reading the pipe without blocking

  if (fileDescriptor == -1) return NSLog(@"Unable to get file descriptor for named pipe %@", inPath), nil;

  self = [NSFileHandle.alloc initWithFileDescriptor:fileDescriptor closeOnDealloc:NO];

  if (!self) return NSLog(@"Unable to get file handle for named pipe %@", inPath), nil;

  [self observeName:NSFileHandleReadCompletionNotification usingBlock:^(NSNotification *note) {

    NSData *data = note.userInfo[NSFileHandleNotificationDataItem];

    if (data.length) readMaybeCancel(data);

    [self readInBackgroundAndNotify]; // Keep getting more data unless the pipe has been destroyed

  }];

  return [self readInBackgroundAndNotify], self;
}

+ (instancetype) read:(NSString*)path toBlock:(BOOL(^)(NSData*))readMaybeCancel {

  return [self.alloc initAndRead:path toBlock:readMaybeCancel];
}
@end

/*

- (void)dealloc {
  [self destroyPipe];  // In case pipe wasn't already destroyed
}

- (void)destroyPipe {

 Destroy the pipe and delete it from the filesystem destroyPipe works even if it is called for an already-destroyed pipe

  [NSNotificationCenter.defaultCenter removeObserver:self];
   We DON'T close the file with "close()" or "[fileHandleForReading
   closeFile];" because that blocks the process.
   "close()" even blocks if we call "fnctl()" with O_NONBLOCK) first. So we
   never really close
   the file descriptor.
   Also, see the comment in "initPipeReadingFromPath: sendingDataTo:
   whichIsIn:", above.

  fileHandleForReading = nil;
  if (inPath) { [NSFileManager.defaultManager removeFileAtPath:inPath handler:nil];
      inPath = nil;
  }
     inTarget = nil;
}
@end
      addObserver:self
         selector:@selector(pipeDataReady:)
             name:NSFileHandleReadCompletionNotification
           object:fileHandleForReading];

- initPipeReadingFromPath:(NSString *)path
            sendingDataTo:(SEL)method
                whichIsIn:(id)target { SUPERINIT;

  if (![target respondsToSelector:method])
    return NSLog(@"Unable to create NamedPipe with path %@ because %@ does not "
                 @"respond to %@",
                 path, target, method), nil;
  fileHandleForReading = nil;
  inPath = path;
  inMethod = method;
  inTarget = target;
  return [self makeFIFO] ? self : nil;

}
*/
