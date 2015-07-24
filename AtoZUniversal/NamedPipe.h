
#import <Foundation/Foundation.h>

@interface NSFileHandle (NamedPipe)

+ (instancetype) read:(NSString*)path toBlock:(BOOL(^)(NSData*))b;

//_VD destroyPipe; // Automatically invoked if an NSPipe is dealloc-ed

@end