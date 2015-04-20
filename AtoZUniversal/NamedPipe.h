
#import <Foundation/Foundation.h>

@interface NSFileHandle (NamedPipe)

+ (instancetype) read:(NSString*)path toBlock:(BOOL(^)(NSData*))b;

//- (void) destroyPipe; // Automatically invoked if an NSPipe is dealloc-ed

@end