
/// MIMEHelper   Copyright 2008, Erica Sadun All rights are retained. This code remains the trade secret and intellectual property of Erica Sadun.

@import Darwin;       // Darwin.POSIX + Darwin.POSIX.net;
@import Foundation;
@import ObjectiveC;

#import "AtoZUniversal.h"
#import <ifaddrs.h>
#import <netinet/in.h>
#import <sys/socket.h>

NSString* runCommand          (NSString* c) {	NSString* outP = nil;	char buffer[BUFSIZ + 1];	size_t chars_read = 0;

  memset(buffer, '\0', sizeof(buffer));

  FILE *read_fp = NULL;

  if ((read_fp = popen(c.UTF8String, "r"))) {
    chars_read = fread(buffer, sizeof(char), BUFSIZ, read_fp);
	   if (chars_read > 0) outP = @(buffer);
    pclose(read_fp);
  }
  return outP;
}
NSString* stringBetweenString (NSString*str, NSString* start, NSString *end) {

  NSScanner* scanner = [NSScanner scannerWithString:str];
  [scanner setCharactersToBeSkipped:nil];
  [scanner scanUpToString:start intoString:NULL];
  NSString* result = nil;
  return [scanner scanString:start intoString:NULL] && [scanner scanUpToString:end intoString:&result], result;
}

//  NetUtils.m  from Tabi Created by Vyacheslav Zakovyrya on 1/22/10.

#import <arpa/inet.h>

_Void *             InAddrStruct(struct sockaddr *sa) {

  return AF_INET == sa->sa_family ? (void*)&(((struct sockaddr_in*)sa)->sin_addr) : &(((struct sockaddr_in6*)sa)->sin6_addr);
}
_Text              AddressString(struct sockaddr *sa) {
  void *if_in_addr = InAddrStruct(sa);
  char if_addr_buff[(sa->sa_family == AF_INET ? INET_ADDRSTRLEN : INET6_ADDRSTRLEN)];
  memset(if_addr_buff, 0, sizeof if_addr_buff);
  inet_ntop(sa->sa_family, if_in_addr, if_addr_buff, sizeof if_addr_buff);
  NSString *addressStr = @(if_addr_buff);

  return addressStr;
}
_IsIt      processInetPTONStatus(_UInt status,      _Text addressStr) {
  return !status ? NSLog(@"Address %@ is messed up", addressStr), NO :
    -1 == status ? NSLog(@"Could not PTON address %@: %s", addressStr, strerror(errno)), NO
                 : YES;
}
_Text       NetworkOfIPv4Address(_Text addressStr,  _Text maskStr)    {
  struct sockaddr_in addr;
  struct sockaddr_in mask;
  if (!processInetPTONStatus(inet_pton(AF_INET, [addressStr cStringUsingEncoding:NSUTF8StringEncoding], &(addr.sin_addr)), addressStr)) {
    return nil;
  }
  if (!processInetPTONStatus(inet_pton(AF_INET, [maskStr cStringUsingEncoding:NSUTF8StringEncoding], &(mask.sin_addr)), maskStr)) {
    return nil;
  }

  struct sockaddr_in masked_addr;
  memset(&masked_addr, 0, sizeof masked_addr);

  masked_addr.sin_family = AF_INET;
  masked_addr.sin_len = sizeof masked_addr;

  uint8_t addr_buff[sizeof addr.sin_addr.s_addr];
  memcpy(addr_buff, &(addr.sin_addr.s_addr), sizeof addr_buff);
  uint8_t mask_buff[sizeof addr_buff];
  memcpy(mask_buff, &(mask.sin_addr.s_addr), sizeof mask_buff);

  uint8_t masked_addr_buff[sizeof addr_buff];
  for (int i = 0; i < sizeof masked_addr_buff; i++) {
    masked_addr_buff[i] = addr_buff[i] & mask_buff[i];
  }
  memcpy(&(masked_addr.sin_addr.s_addr), masked_addr_buff, sizeof masked_addr_buff);
  memset(masked_addr.sin_zero, 0, sizeof masked_addr.sin_zero);

  return AddressString((struct sockaddr *)&masked_addr);
}
_List          NetworkInterfaces(){
  struct ifaddrs *if_addrs;
  int status = getifaddrs(&if_addrs);
  if (0 != status) {
    NSLog(@"Could not get network interfaces: %s", strerror(errno));
    return nil;
  }

  NSMutableArray *interfaces = [NSMutableArray array];

  for (struct ifaddrs *if_addrs_cursor = if_addrs; NULL != if_addrs_cursor; if_addrs_cursor = if_addrs_cursor->ifa_next) {
    NSString *name = @(if_addrs_cursor->ifa_name);
    NSMutableDictionary *interfaceDict = [NSMutableDictionary dictionaryWithObject:name forKey:@"name"];
    if (NULL != if_addrs_cursor->ifa_addr) {
      struct sockaddr *if_addr = if_addrs_cursor->ifa_addr;
      NSString *addressStr = AddressString(if_addr);
      [interfaceDict setValue:addressStr forKey:@"address"];

      NSString *addressFamily = nil;
      if (AF_INET == if_addrs_cursor->ifa_addr->sa_family) {
        addressFamily = tIPv4;
      }
      else if (AF_INET6 == if_addrs_cursor->ifa_addr->sa_family) {
        addressFamily = tIPv6;
      }

      [interfaceDict setValue:addressFamily forKey:@"addressFamily"];

      if (NULL != if_addrs_cursor->ifa_dstaddr) {
        NSString *broadcastAddressStr = AddressString(if_addrs_cursor->ifa_dstaddr);
        [interfaceDict setValue:broadcastAddressStr forKey:@"broadcastAddress"];
      }
      if (NULL != if_addrs_cursor->ifa_netmask) {
        NSString *netMaskStr = AddressString(if_addrs_cursor->ifa_netmask);
        [interfaceDict setValue:netMaskStr forKey:@"netMask"];
      }
    }
    [interfaces addObject:interfaceDict];
  }
  
  freeifaddrs(if_addrs);
  return interfaces;
}

@implementation Interface

@synthesize  isPrimary = _isPrimary,
            externalIP = _externalIP,
                   ISP = _ISP,
                locale = _locale,
             isPrivate = _isPrivate;
             
#if MAC_ONLY

@synthesize speed = _speed, FQDN = _FQDN;

_TT speed {

  if (self.isPrivate) return _speed = NOTAPPLICAPLE;
  if (_speed && ![_speed isEqualToString:@"Testing"]) return _speed;

  __block __typeof(self) bSelf = self;

  static id testZIP;
  testZIP = testZIP ?: @"http://speedtest.wdc01.softlayer.com/downloads/test.zip";
  static NSOperationQueue * q; q = q ?: [NSOperationQueue new];

  if ([[q.operations valueForKey:@"name"] containsObject:self.name]) return _speed;

  __block id x;

  NSBlockOperation *blk = [NSBlockOperation blockOperationWithBlock:^{
    NSLog(@"Getting speed for %@", self.name);
      NSTask *task = NSTask.new;
      task.launchPath = @"/usr/bin/curl";
      task.arguments = @[@"-s", @"--interface",self.name, @"-w", @"%{time_total}", @"-o", @"/dev/null", testZIP];

      NSPipe *outputPipe = NSPipe.pipe;
      task.standardOutput = outputPipe;
      [task launch];
      [task waitUntilExit];
      NSData *outputData = outputPipe.fileHandleForReading.readDataToEndOfFile;
      NSString *stash = [NSString.alloc initWithData:outputData encoding:NSUTF8StringEncoding];

      x = stash ? [[NET prettyBytes:11536384/stash.floatValue]stringByAppendingString:@" / sec"] : @"ERR";

  //    id cmd = [NSString stringWithFormat:@"curl
  //    x = runCommand(cmd) ?: @"ERR"; // echo \"scale=2; `curl -i %@ -s -w %@ -o /dev/null` / 131072\" | bc | xargs -I {} echo {} mbps",
  }];

  [blk setName:bSelf.name];

  [blk setCompletionBlock:^{
    NSLog(@"Got speed %@ for %@", x, self.name);
//    [bSelf willChangeValueForKey:@"speed"];
//    bSelf->_speed = x;;
//    [bSelf didChangeValueForKey:@"speed"];
      [bSelf setValue:x forKey:@"speed"];
  }];


  [q addOperation:blk];


//  dispatch_queue_t table_download_queue = dispatch_queue_create([self.name UTF8String], NULL);
//  dispatch_async(table_download_queue, ^{

// fill your data source array from the data you fetch from web service API.
//   dispatch_async(dispatch_get_main_queue(), ^{

//                    [self setValue:x forKey:@"speed"];
//                    [reloadData];
//                });
//            });

//  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
  //Background Thread
//    id x = runCommand(@"echo \"scale=2; `curl -s -w \"%%{speed_download}\" http://speedtest.wdc01.softlayer.com/downloads/test10.zip -o /dev/null` / 131072\" | bc | xargs -I {} echo {} mbps") ?: @"N/A";
//    NSLog(@"Got speed %@ for %@", x, self.name);
//
//    dispatch_async(dispatch_get_main_queue(), ^(void){
//      self.speed = x;
//    });
//  });
  return _speed = @"Testing";
}

#endif
//  [NSOperationQueue.mainQueue addOperationWithBlock:^{
//    id x = runCommand(@"echo \"scale=2; `curl -s -w \"%%{speed_download}\" http://speedtest.wdc01.softlayer.com/downloads/test10.zip -o /dev/null` / 131072\" | bc | xargs -I {} echo {} mbps") ?: @"N/A";
//    self.speed = [x copy];
//  }];

- initWithName _ n ip _ ip { SUPERINIT ___

  _name       = n;
  _ip         = ip;
  _isPrimary  = [_ip isEqualToString:NET.primaryIPv4Address];
// _speed = () ? NOTAPPLICAPLE : nil; [NSOperationQueue.mainQueue addOperationWithBlock:^{ self.FQDN = [NET FQDNof:_ip]; }];
    return self;
}

_TT externalIP { // return self.isLoopback ? NOTAPPLICAPLE : [NET externalIPOf:self.name]; }

  return _externalIP ?: self.isPrivate ? _externalIP = NOTAPPLICAPLE : [NSOperationQueue.mainQueue addOperationWithBlock:^{
      id n = [NET externalIPOf:_name];
      [self setValue:n forKey:@"externalIP"];
    }], @"Pending";
}

_TT ISP             { return _ISP = _ISP ?: self.isPrivate ? NOTAPPLICAPLE : [NET ISPon:self.externalIP] ___ }
_TT description     { return [NSString.alloc initWithFormat:@"<%@> IP:%@ Ext:%@ ISP:%@ FQDN:%@", _name, _ip, _externalIP, _ISP, [self vFK:@"FQDN"]]; }
_IT isPrivate       { static dispatch_once_t onceToken; return dispatch_once(&onceToken, ^{ _isPrivate = [NET isPrivate:self.ip]; }), _isPrivate; }
- (Locale*) locale  { return _locale = _locale ?: ({ id x =  [Locale localeOfIP:self.externalIP];

NSLog(@"got locale:%@", [x country]); x; });
}

@end

#import <netinet/in.h>

@implementation NetworkHelpers


static struct {UInt32 mask __ value; } const kPrivateRanges[] = {

    {0xFF000000 __ 0x00000000} __       //         0.x.x.x  (hosts on "this" network)
    {0xFF000000 __ 0x0A000000} __       //        10.x.x.x  (private address range)
    {0xFF000000 __ 0x7F000000} __       //       127.x.x.x  (loopback)
    {0xFFFF0000 __ 0xA9FE0000} __       //     169.254.x.x  (link-local self-configured addresses)
    {0xFFF00000 __ 0xAC100000} __       // 172.(16-31).x.x  (private address range)
    {0xFFFF0000 __ 0xC0A80000} __       //     192.168.x.x  (private address range)
             {0 __ 0}

} ___ // Private IP address ranges. See RFC 3330.

+ (UInt32) IPv4FromDottedQuadString:(NSString*)str {

    UInt32 ipv4 = 0;
    NSScanner *scanner = [NSScanner scannerWithString: str];
    for( int i=0; i<4; i++ ) {
        if( i>0 && ! [scanner scanString: @"." intoString: nil] ) return 0;
        NSInteger octet;
        if( ! [scanner scanInteger: &octet] || octet<0 || octet>255 ) return 0;
        ipv4 = (ipv4<<8) | (UInt8)octet;
    }
    return ![scanner isAtEnd] ?: htonl(ipv4);
}

+ _IsIt_ isPrivate __Text_ ip {

  UInt32 address = ntohl([self.class IPv4FromDottedQuadString:ip]) ___
  for( int i=0; kPrivateRanges[i].mask; i++ ) if( (address & kPrivateRanges[i].mask) == kPrivateRanges[i].value ) return YES;
  return NO;
}

+ (NSString*) primaryIPv4Address {

#if MAC_ONLY
  char hostname[400] = "";

  @autoreleasepool {

    _Text primaryInterface;

    SCDynamicStoreContext context = { 0, (__bridge void *)self, NULL, NULL, NULL };

    SCDynamicStoreRef dynStore = SCDynamicStoreCreate( NULL,(__bridge CFStringRef)NSBundle.mainBundle.bundleIdentifier,nil,&context);

    _List allKeys = (__bridge _List)SCDynamicStoreCopyKeyList(dynStore, CFSTR("State:/Network/Global/IPv4"));

    for (int i = 0; i < allKeys.count; i++ ) {

      // NSLog(@"Current key: %@, value: %@", allKeys[i], [(NSString *)SCDynamicStoreCopyValue(dynStore, (CFStringRef)[allKeys objectAtIndex:i]) autorelease]);

      _Dict dict = (__bridge  NSDictionary *)SCDynamicStoreCopyValue(dynStore, (__bridge CFStringRef)allKeys[i]);

      //  NSLog(@"PrimaryInterface: %@ value is: %@", [allKeys objectAtIndex:i], [dict objectForKey:@"PrimaryInterface"]);

      primaryInterface = dict[@"PrimaryInterface"];
    }

    allKeys = (__bridge NSArray *)SCDynamicStoreCopyKeyList(dynStore, CFStringCreateWithFormat(kCFAllocatorDefault,
                                                                             NULL,
                                                                             CFSTR("State:/Network/Interface/%@/IPv4"),
                                                                             primaryInterface));
    for (int i = 0; i < allKeys.count; i++ ) {

      //NSLog(@"Current key: %@, value: %@", allKeys[i], [(NSString *)SCDynamicStoreCopyValue(dynStore, (CFStringRef)[allKeys objectAtIndex:i]) autorelease]);

      NSDictionary * dict = (__bridge NSDictionary*)SCDynamicStoreCopyValue(dynStore, (__bridge CFStringRef)allKeys[i]);

      //NSLog(@"IPv4 interface: %@ value is: %@", allKeys[i], dict[@"Addresses"]);

      strcpy(hostname, [dict[@"Addresses"][0] cString]);
    }
  }
  return [NSString.alloc initWithUTF8String:hostname];
  #else
  return @"N/A";
  #endif
}

+ _List_       interfaces {

  mList a = @[].mC;
  [self.localhosts enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [a addObject:[Interface.alloc initWithName:key ip:obj]];
  }];
  return a.copy;
}

+ (NSString*) externalIPOf:x {

#if MAC_ONLY
 NSTask *task = NSTask.new;
  task.launchPath = @"/usr/bin/curl";
  task.arguments = @[@"-L", @"-s",@"--interface", x, @"http://ip-api.com/line/?fields=query"];

  NSPipe *outputPipe = NSPipe.pipe;
  task.standardOutput = outputPipe;
  [task launch];
  [task waitUntilExit];
  NSData *outputData = outputPipe.fileHandleForReading.readDataToEndOfFile;
//  return stringBetweenString([NSString.alloc initWithData:outputData encoding:NSUTF8StringEncoding],@"our Internet Service Provider (ISP) is '",@"'");
//  return runCommand([NSString stringWithFormat:@"curl -L -s --interface %@ http://ip-api.com/line/?fields=query", x]);
  return [NSString.alloc initWithData:outputData encoding:NSUTF8StringEncoding];
#else 
  return runCommand($(@"/usr/bin/curl -L -s --interface %@ http://ip-api.com/line/?fields=query", x));
#endif
}

+ _Text_ externalIP {

  static NSURL *iPURL = nil; iPURL = iPURL ?: [NSURL URLWithString:@"http://ident.me"]; //www.dyndns.org/cgi-bin/check_ip.cgi"];

  NSUInteger  an_Integer;

  NSError       * error = nil;
  _Text externalIP = nil,
         theIpHtml = [NSString stringWithContentsOfURL:iPURL encoding:NSUTF8StringEncoding error:&error];

//  if (!error) {
//
//      NSString *text = nil;
//      NSScanner *theScanner = [NSScanner scannerWithString:theIpHtml];
//
//      while (!theScanner.isAtEnd) {
//
//        [theScanner scanUpToString:@"<" intoString:NULL] ; // find start of tag
//
//        [theScanner scanUpToString:@">" intoString:&text] ; // find end of tag
//
//        // replace the found tag with a space (you can filter multi-spaces out later if you wish)
//        theIpHtml = [theIpHtml stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@" "];
//        NSArray * ipItemsArray = [theIpHtml componentsSeparatedByString:@" "];
//        an_Integer = [ipItemsArray indexOfObject:@"Address:"];
//
//        externalIP = ipItemsArray[++an_Integer];
//
//      }
//    }
//    return externalIP ? externalIP
      return  theIpHtml ?: NSLog(@"Cannot get external IP error:%ld (%@)", error.code, error.localizedDescription), theIpHtml;
// externalIP;
}

+ (NSString*)  ISP {

  id x = objc_msgSend(self, NSSelectorFromString(@"curl:"), @"whoismyisp.org");
     x = objc_msgSend(x, NSSelectorFromString(@"substringAfter:"),@"Your Internet Service Provider (ISP) is '");
     x = objc_msgSend(x, NSSelectorFromString(@"substringBefore:"), @"'");
  return x;
}

//  return [self ISPof:self.externalIP]; }
//
//

+ (NSString*) curl:x {

  NSURL *url = x && [x isKindOfClass:NSURL.class] ? x : [NSURL URLWithString:([x hasPrefix:@"http://"] ? x : [@"http://" stringByAppendingString:x])];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10.0];

  [request setURL:url];
  [request setHTTPMethod:@"GET"];
  [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];

  NSError *error; NSURLResponse *response;
  NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
  return [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
}

static NSMutableDictionary *isps = nil;

+ (NSString*)  ISPon:(NSString*)extip {

#if MAC_ONLY
  if (!extip) return @"N/A";
  NSTask *task = NSTask.new;
  task.launchPath = @"/usr/bin/curl";
  task.arguments = @[@"-L", @"-s", [@"http://whoismyisp.org/ip/" stringByAppendingString:extip]];

  NSPipe *outputPipe = NSPipe.pipe;
  task.standardOutput = outputPipe;
  [task launch];
  [task waitUntilExit];
  NSData *outputData = outputPipe.fileHandleForReading.readDataToEndOfFile;
  NSString *stash = [NSString.alloc initWithData:outputData encoding:NSUTF8StringEncoding];
  return stash ? [stringBetweenString(stash,@"' is '",@"'")copy] : [@"" copy];
#else
  return @"N/A";
#endif
}

//  NSTask *task=[NSTask new];
//  [task setLaunchPath:@"curl -s --interface "username:PASSWD" https://api.github.com/users/username"];
//  [task launch];

//  return runCommand([NSString stringWithFormat:@"curl -s --interface %@ http://whoismyisp.org", ifacename]);


+ (NSString*)  ISPof:(NSString*)ip {

   isps = isps ?: @{}.mutableCopy;

  NSString *theISP = nil;
  if ((theISP = isps[ip])) return theISP;

  NSString *whois = runCommand([NSString stringWithFormat:@"whois %@", ip]);
  NSString *ispWithSpaces = stringBetweenString(whois, @"OrgName:", @"\n");
  NSInteger i = 0;

  while ((i < ispWithSpaces.length)
           && [NSCharacterSet.whitespaceCharacterSet characterIsMember:[ispWithSpaces characterAtIndex:i]])
        i++;

  isps[ip] = (theISP = [ispWithSpaces substringFromIndex:i]);
  return theISP;
}

+ (NSDictionary*) localhosts {  NSMutableDictionary* result = @{}.mutableCopy;

  // An autorelease pool stores objects that are sent a release message when the pool itself is drained.
  @autoreleasepool {

    struct ifaddrs* addrs;    // Creates an ifaddrs structure
    //function creates a linked list of structures describing the network interfaces of the local system, and stores the address of the first item of the list in *ifap.
    BOOL success = !getifaddrs(&addrs);

    if (success)		// If successful in getting the addresses
    {
      const struct ifaddrs* cursor = addrs;   			// Create a constant read only local attribute
      while (cursor != NULL)											// Loop through the struct while not NULL
      {
        NSMutableString* ip;										            // Creates a local attribute
        if (cursor->ifa_addr->sa_family == AF_INET)            // AF_INET is the address family for an internet socket
        {
          const struct sockaddr_in* dlAddr = (const struct sockaddr_in*)cursor->ifa_addr;	// Create a constant read only local attribute
          const uint8_t* base = (const uint8_t*)&dlAddr->sin_addr;                        // Create a constant read only local attribute
          ip = @"".mutableCopy;                                                           // Initializes and allocates memory for the new ip
          for (int i = 0; i < 4; i++)                                                     // Loops through the address and adds a period
          {
            if (i != 0) [ip appendFormat:@"."];
            [ip appendFormat:@"%d", base[i]];
          }
          result[[NSString stringWithFormat:@"%s", cursor->ifa_name]] = (NSString*)ip;
        }
        cursor = cursor->ifa_next;
      }
      // frees the address
      freeifaddrs(addrs);
    }
  }
  return result;
}

#if MAC_ONLY
//- (NSString*) FQDN { return _FQDN = _FQDN ?: [NET FQDNof:self.ip]; }

+ (NSString*) FQDNof:(NSString*)ip { return [NSHost hostWithAddress:ip].name; }

+ (NSString*) FQDN {  return NSHost.currentHost.name; }
#endif

// Return the hostname.local address for the iPhone
+ (NSString *) localAddressForPort: (int) chosenPort {
  char baseHostName[255];
  gethostname(baseHostName, 255);
  return [NSString stringWithFormat:@"http://%@%@:%d", @(baseHostName),
          [@(baseHostName) hasSuffix:@"local"] ? @"" : @".local",
          chosenPort];
}

#if MAC_ONLY
+ (BOOL) connectedToNetwork {

  // Create zero addy
  struct sockaddr_in zeroAddress;
  bzero(&zeroAddress, sizeof(zeroAddress));
  zeroAddress.sin_len = sizeof(zeroAddress);
  zeroAddress.sin_family = AF_INET;

  // Recover reachability flags
  SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
  SCNetworkReachabilityFlags flags;

  BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
  CFRelease(defaultRouteReachability);

  if (!didRetrieveFlags) return printf("Error. Could not recover network reachability flags\n"),  0;

  BOOL isReachable = flags & kSCNetworkFlagsReachable,
  needsConnection = flags & kSCNetworkFlagsConnectionRequired;
  return isReachable && !needsConnection;
}
#endif

// Return the iPhone's IP address
+ (NSString *) localIPAddressForPort: (int) chosenPort {
  char baseHostName[255];
  gethostname(baseHostName, 255);

  char hn[255];
  sprintf(hn, "%s.local", baseHostName);
  struct hostent *host = gethostbyname(hn);
  if (host == NULL)
  {
    herror("resolv");
    return NULL;
  }
  else {
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    return [NSString stringWithFormat:@"<br /><i>or</i><br />http://%@:%d", @(inet_ntoa(*list[0])), chosenPort];
  }

  return NULL;
}

// Return the full host address
+ (NSString *) hostAddyForPort: (int) chosenPort
{
  return [NSString stringWithFormat:@"http://%@:%d/", [self localIPAddressForPort:chosenPort], chosenPort];
}

/*
 + (void) notify: (NSString *) formatstring,...
 {
 #if TARGET_OS_IPHONE
	va_list arglist;
	if (formatstring)
 {
 va_start(arglist, formatstring);
 id outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];

 UIAlertView *baseAlert = [[UIAlertView alloc] initWithTitle:@"" message:outstring delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
 [baseAlert setTag:ALERT_UTILITY_TAG];
 [baseAlert show];
 va_end(arglist);
 [outstring release];
 }
 #endif
 }
 */
+ (NSString *) getIPAddressForHost: (NSString *) theHost
{
  struct hostent *host = gethostbyname([theHost UTF8String]);

  if (host == NULL) {
    herror("resolv");
    return NULL;
  }

  struct in_addr **list = (struct in_addr **)host->h_addr_list;
  NSString *addressString = @(inet_ntoa(*list[0]));
  return addressString;
}

// Direct from Apple. Thank you Apple
+ (BOOL)addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address
{
  if (!IPAddress || ![IPAddress length]) {
    return NO;
  }

  memset((char *) address, sizeof(struct sockaddr_in), 0);
  address->sin_family = AF_INET;
  address->sin_len = sizeof(struct sockaddr_in);

  int conversionResult = inet_aton([IPAddress UTF8String], &address->sin_addr);
  if (conversionResult == 0) {
    NSAssert1(conversionResult != 1, @"Failed to convert the IP address string into a sockaddr_in: %@", IPAddress);
    return NO;
  }

  return YES;
}
#if MAC_ONLY
+ (BOOL) hostAvailable: (NSString *) theHost
{

  NSString *addressString = [self getIPAddressForHost:theHost];
  if (!addressString)
  {
    printf("Error recovering IP address from host name\n");
    return NO;
  }

  struct sockaddr_in address;
  BOOL gotAddress = [self addressFromString:addressString address:&address];

  if (!gotAddress)
  {
    printf("Error recovering sockaddr address from %s\n", [addressString UTF8String]);
    return NO;
  }

  SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&address);
  SCNetworkReachabilityFlags flags;

  BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
  CFRelease(defaultRouteReachability);

  if (!didRetrieveFlags)
  {
    printf("Error. Could not recover network reachability flags\n");
    return NO;
  }

  BOOL isReachable = flags & kSCNetworkFlagsReachable;
  BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
  return (isReachable && !needsConnection) ? YES : NO;
}
#endif
+ (NSString *) mimeForExt:(NSString *)ext
{
  NSString *uc = [ext uppercaseString];
  if([uc caseInsensitiveCompare:@"3dm"] == NSOrderedSame) return @"x-world/x-3dmf";
  if([uc caseInsensitiveCompare:@"3dmf"] == NSOrderedSame) return @"x-world/x-3dmf";
  if([uc caseInsensitiveCompare:@"a"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"aab"] == NSOrderedSame) return @"application/x-authorware-bin";
  if([uc caseInsensitiveCompare:@"aam"] == NSOrderedSame) return @"application/x-authorware-map";
  if([uc caseInsensitiveCompare:@"aas"] == NSOrderedSame) return @"application/x-authorware-seg";
  if([uc caseInsensitiveCompare:@"abc"] == NSOrderedSame) return @"text/vnd.abc";
  if([uc caseInsensitiveCompare:@"acgi"] == NSOrderedSame) return @"text/html";
  if([uc caseInsensitiveCompare:@"afl"] == NSOrderedSame) return @"video/animaflex";
  if([uc caseInsensitiveCompare:@"ai"] == NSOrderedSame) return @"application/postscript";
  if([uc caseInsensitiveCompare:@"aif"] == NSOrderedSame) return @"audio/aiff";
  if([uc caseInsensitiveCompare:@"aif"] == NSOrderedSame) return @"audio/x-aiff";
  if([uc caseInsensitiveCompare:@"aifc"] == NSOrderedSame) return @"audio/aiff";
  if([uc caseInsensitiveCompare:@"aifc"] == NSOrderedSame) return @"audio/x-aiff";
  if([uc caseInsensitiveCompare:@"aiff"] == NSOrderedSame) return @"audio/aiff";
  if([uc caseInsensitiveCompare:@"aiff"] == NSOrderedSame) return @"audio/x-aiff";
  if([uc caseInsensitiveCompare:@"aim"] == NSOrderedSame) return @"application/x-aim";
  if([uc caseInsensitiveCompare:@"aip"] == NSOrderedSame) return @"text/x-audiosoft-intra";
  if([uc caseInsensitiveCompare:@"ani"] == NSOrderedSame) return @"application/x-navi-animation";
  if([uc caseInsensitiveCompare:@"aos"] == NSOrderedSame) return @"application/x-nokia-9000-communicator-add-on-software";
  if([uc caseInsensitiveCompare:@"aps"] == NSOrderedSame) return @"application/mime";
  if([uc caseInsensitiveCompare:@"arc"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"arj"] == NSOrderedSame) return @"application/arj";
  if([uc caseInsensitiveCompare:@"arj"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"art"] == NSOrderedSame) return @"image/x-jg";
  if([uc caseInsensitiveCompare:@"asf"] == NSOrderedSame) return @"video/x-ms-asf";
  if([uc caseInsensitiveCompare:@"asm"] == NSOrderedSame) return @"text/x-asm";
  if([uc caseInsensitiveCompare:@"asp"] == NSOrderedSame) return @"text/asp";
  if([uc caseInsensitiveCompare:@"asx"] == NSOrderedSame) return @"application/x-mplayer2";
  if([uc caseInsensitiveCompare:@"asx"] == NSOrderedSame) return @"video/x-ms-asf";
  if([uc caseInsensitiveCompare:@"asx"] == NSOrderedSame) return @"video/x-ms-asf-plugin";
  if([uc caseInsensitiveCompare:@"au"] == NSOrderedSame) return @"audio/basic";
  if([uc caseInsensitiveCompare:@"au"] == NSOrderedSame) return @"audio/x-au";
  if([uc caseInsensitiveCompare:@"avi"] == NSOrderedSame) return @"application/x-troff-msvideo";
  if([uc caseInsensitiveCompare:@"avi"] == NSOrderedSame) return @"video/avi";
  if([uc caseInsensitiveCompare:@"avi"] == NSOrderedSame) return @"video/msvideo";
  if([uc caseInsensitiveCompare:@"avi"] == NSOrderedSame) return @"video/x-msvideo";
  if([uc caseInsensitiveCompare:@"avs"] == NSOrderedSame) return @"video/avs-video";
  if([uc caseInsensitiveCompare:@"bcpio"] == NSOrderedSame) return @"application/x-bcpio";
  if([uc caseInsensitiveCompare:@"bin"] == NSOrderedSame) return @"application/mac-binary";
  if([uc caseInsensitiveCompare:@"bin"] == NSOrderedSame) return @"application/macbinary";
  if([uc caseInsensitiveCompare:@"bin"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"bin"] == NSOrderedSame) return @"application/x-binary";
  if([uc caseInsensitiveCompare:@"bin"] == NSOrderedSame) return @"application/x-macbinary";
  if([uc caseInsensitiveCompare:@"bm"] == NSOrderedSame) return @"image/bmp";
  if([uc caseInsensitiveCompare:@"bmp"] == NSOrderedSame) return @"image/bmp";
  if([uc caseInsensitiveCompare:@"bmp"] == NSOrderedSame) return @"image/x-windows-bmp";
  if([uc caseInsensitiveCompare:@"boo"] == NSOrderedSame) return @"application/book";
  if([uc caseInsensitiveCompare:@"book"] == NSOrderedSame) return @"application/book";
  if([uc caseInsensitiveCompare:@"boz"] == NSOrderedSame) return @"application/x-bzip2";
  if([uc caseInsensitiveCompare:@"bsh"] == NSOrderedSame) return @"application/x-bsh";
  if([uc caseInsensitiveCompare:@"bz"] == NSOrderedSame) return @"application/x-bzip";
  if([uc caseInsensitiveCompare:@"bz2"] == NSOrderedSame) return @"application/x-bzip2";
  if([uc caseInsensitiveCompare:@"c"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"c"] == NSOrderedSame) return @"text/x-c";
  if([uc caseInsensitiveCompare:@"c++"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"cat"] == NSOrderedSame) return @"application/vnd.ms-pki.seccat";
  if([uc caseInsensitiveCompare:@"cc"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"cc"] == NSOrderedSame) return @"text/x-c";
  if([uc caseInsensitiveCompare:@"ccad"] == NSOrderedSame) return @"application/clariscad";
  if([uc caseInsensitiveCompare:@"cco"] == NSOrderedSame) return @"application/x-cocoa";
  if([uc caseInsensitiveCompare:@"cdf"] == NSOrderedSame) return @"application/cdf";
  if([uc caseInsensitiveCompare:@"cdf"] == NSOrderedSame) return @"application/x-cdf";
  if([uc caseInsensitiveCompare:@"cdf"] == NSOrderedSame) return @"application/x-netcdf";
  if([uc caseInsensitiveCompare:@"cer"] == NSOrderedSame) return @"application/pkix-cert";
  if([uc caseInsensitiveCompare:@"cer"] == NSOrderedSame) return @"application/x-x509-ca-cert";
  if([uc caseInsensitiveCompare:@"cha"] == NSOrderedSame) return @"application/x-chat";
  if([uc caseInsensitiveCompare:@"chat"] == NSOrderedSame) return @"application/x-chat";
  if([uc caseInsensitiveCompare:@"class"] == NSOrderedSame) return @"application/java";
  if([uc caseInsensitiveCompare:@"class"] == NSOrderedSame) return @"application/java-byte-code";
  if([uc caseInsensitiveCompare:@"class"] == NSOrderedSame) return @"application/x-java-class";
  if([uc caseInsensitiveCompare:@"com"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"com"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"conf"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"cpio"] == NSOrderedSame) return @"application/x-cpio";
  if([uc caseInsensitiveCompare:@"cpp"] == NSOrderedSame) return @"text/x-c";
  if([uc caseInsensitiveCompare:@"cpt"] == NSOrderedSame) return @"application/mac-compactpro";
  if([uc caseInsensitiveCompare:@"cpt"] == NSOrderedSame) return @"application/x-compactpro";
  if([uc caseInsensitiveCompare:@"cpt"] == NSOrderedSame) return @"application/x-cpt";
  if([uc caseInsensitiveCompare:@"crl"] == NSOrderedSame) return @"application/pkcs-crl";
  if([uc caseInsensitiveCompare:@"crl"] == NSOrderedSame) return @"application/pkix-crl";
  if([uc caseInsensitiveCompare:@"crt"] == NSOrderedSame) return @"application/pkix-cert";
  if([uc caseInsensitiveCompare:@"crt"] == NSOrderedSame) return @"application/x-x509-ca-cert";
  if([uc caseInsensitiveCompare:@"crt"] == NSOrderedSame) return @"application/x-x509-user-cert";
  if([uc caseInsensitiveCompare:@"csh"] == NSOrderedSame) return @"application/x-csh";
  if([uc caseInsensitiveCompare:@"csh"] == NSOrderedSame) return @"text/x-script.csh";
  if([uc caseInsensitiveCompare:@"css"] == NSOrderedSame) return @"application/x-pointplus";
  if([uc caseInsensitiveCompare:@"css"] == NSOrderedSame) return @"text/css";
  if([uc caseInsensitiveCompare:@"cxx"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"dcr"] == NSOrderedSame) return @"application/x-director";
  if([uc caseInsensitiveCompare:@"deepv"] == NSOrderedSame) return @"application/x-deepv";
  if([uc caseInsensitiveCompare:@"def"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"der"] == NSOrderedSame) return @"application/x-x509-ca-cert";
  if([uc caseInsensitiveCompare:@"dif"] == NSOrderedSame) return @"video/x-dv";
  if([uc caseInsensitiveCompare:@"dir"] == NSOrderedSame) return @"application/x-director";
  if([uc caseInsensitiveCompare:@"dl"] == NSOrderedSame) return @"video/dl";
  if([uc caseInsensitiveCompare:@"dl"] == NSOrderedSame) return @"video/x-dl";
  if([uc caseInsensitiveCompare:@"doc"] == NSOrderedSame) return @"application/msword";
  if([uc caseInsensitiveCompare:@"dot"] == NSOrderedSame) return @"application/msword";
  if([uc caseInsensitiveCompare:@"dp"] == NSOrderedSame) return @"application/commonground";
  if([uc caseInsensitiveCompare:@"drw"] == NSOrderedSame) return @"application/drafting";
  if([uc caseInsensitiveCompare:@"dump"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"dv"] == NSOrderedSame) return @"video/x-dv";
  if([uc caseInsensitiveCompare:@"dvi"] == NSOrderedSame) return @"application/x-dvi";
  if([uc caseInsensitiveCompare:@"dwf"] == NSOrderedSame) return @"drawing/x-dwf (old)";
  if([uc caseInsensitiveCompare:@"dwf"] == NSOrderedSame) return @"model/vnd.dwf";
  if([uc caseInsensitiveCompare:@"dwg"] == NSOrderedSame) return @"application/acad";
  if([uc caseInsensitiveCompare:@"dwg"] == NSOrderedSame) return @"image/vnd.dwg";
  if([uc caseInsensitiveCompare:@"dwg"] == NSOrderedSame) return @"image/x-dwg";
  if([uc caseInsensitiveCompare:@"dxf"] == NSOrderedSame) return @"application/dxf";
  if([uc caseInsensitiveCompare:@"dxf"] == NSOrderedSame) return @"image/vnd.dwg";
  if([uc caseInsensitiveCompare:@"dxf"] == NSOrderedSame) return @"image/x-dwg";
  if([uc caseInsensitiveCompare:@"dxr"] == NSOrderedSame) return @"application/x-director";
  if([uc caseInsensitiveCompare:@"el"] == NSOrderedSame) return @"text/x-script.elisp";
  if([uc caseInsensitiveCompare:@"elc"] == NSOrderedSame) return @"application/x-bytecode.elisp (compiled elisp)";
  if([uc caseInsensitiveCompare:@"elc"] == NSOrderedSame) return @"application/x-elc";
  if([uc caseInsensitiveCompare:@"env"] == NSOrderedSame) return @"application/x-envoy";
  if([uc caseInsensitiveCompare:@"eps"] == NSOrderedSame) return @"application/postscript";
  if([uc caseInsensitiveCompare:@"es"] == NSOrderedSame) return @"application/x-esrehber";
  if([uc caseInsensitiveCompare:@"etx"] == NSOrderedSame) return @"text/x-setext";
  if([uc caseInsensitiveCompare:@"evy"] == NSOrderedSame) return @"application/envoy";
  if([uc caseInsensitiveCompare:@"evy"] == NSOrderedSame) return @"application/x-envoy";
  if([uc caseInsensitiveCompare:@"exe"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"f"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"f"] == NSOrderedSame) return @"text/x-fortran";
  if([uc caseInsensitiveCompare:@"f77"] == NSOrderedSame) return @"text/x-fortran";
  if([uc caseInsensitiveCompare:@"f90"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"f90"] == NSOrderedSame) return @"text/x-fortran";
  if([uc caseInsensitiveCompare:@"fdf"] == NSOrderedSame) return @"application/vnd.fdf";
  if([uc caseInsensitiveCompare:@"fif"] == NSOrderedSame) return @"application/fractals";
  if([uc caseInsensitiveCompare:@"fif"] == NSOrderedSame) return @"image/fif";
  if([uc caseInsensitiveCompare:@"fli"] == NSOrderedSame) return @"video/fli";
  if([uc caseInsensitiveCompare:@"fli"] == NSOrderedSame) return @"video/x-fli";
  if([uc caseInsensitiveCompare:@"flo"] == NSOrderedSame) return @"image/florian";
  if([uc caseInsensitiveCompare:@"flx"] == NSOrderedSame) return @"text/vnd.fmi.flexstor";
  if([uc caseInsensitiveCompare:@"fmf"] == NSOrderedSame) return @"video/x-atomic3d-feature";
  if([uc caseInsensitiveCompare:@"for"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"for"] == NSOrderedSame) return @"text/x-fortran";
  if([uc caseInsensitiveCompare:@"fpx"] == NSOrderedSame) return @"image/vnd.fpx";
  if([uc caseInsensitiveCompare:@"fpx"] == NSOrderedSame) return @"image/vnd.net-fpx";
  if([uc caseInsensitiveCompare:@"frl"] == NSOrderedSame) return @"application/freeloader";
  if([uc caseInsensitiveCompare:@"funk"] == NSOrderedSame) return @"audio/make";
  if([uc caseInsensitiveCompare:@"g"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"g3"] == NSOrderedSame) return @"image/g3fax";
  if([uc caseInsensitiveCompare:@"gif"] == NSOrderedSame) return @"image/gif";
  if([uc caseInsensitiveCompare:@"gl"] == NSOrderedSame) return @"video/gl";
  if([uc caseInsensitiveCompare:@"gl"] == NSOrderedSame) return @"video/x-gl";
  if([uc caseInsensitiveCompare:@"gsd"] == NSOrderedSame) return @"audio/x-gsm";
  if([uc caseInsensitiveCompare:@"gsm"] == NSOrderedSame) return @"audio/x-gsm";
  if([uc caseInsensitiveCompare:@"gsp"] == NSOrderedSame) return @"application/x-gsp";
  if([uc caseInsensitiveCompare:@"gss"] == NSOrderedSame) return @"application/x-gss";
  if([uc caseInsensitiveCompare:@"gtar"] == NSOrderedSame) return @"application/x-gtar";
  if([uc caseInsensitiveCompare:@"gz"] == NSOrderedSame) return @"application/x-compressed";
  if([uc caseInsensitiveCompare:@"gz"] == NSOrderedSame) return @"application/x-gzip";
  if([uc caseInsensitiveCompare:@"gzip"] == NSOrderedSame) return @"application/x-gzip";
  if([uc caseInsensitiveCompare:@"gzip"] == NSOrderedSame) return @"multipart/x-gzip";
  if([uc caseInsensitiveCompare:@"h"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"h"] == NSOrderedSame) return @"text/x-h";
  if([uc caseInsensitiveCompare:@"hdf"] == NSOrderedSame) return @"application/x-hdf";
  if([uc caseInsensitiveCompare:@"help"] == NSOrderedSame) return @"application/x-helpfile";
  if([uc caseInsensitiveCompare:@"hgl"] == NSOrderedSame) return @"application/vnd.hp-hpgl";
  if([uc caseInsensitiveCompare:@"hh"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"hh"] == NSOrderedSame) return @"text/x-h";
  if([uc caseInsensitiveCompare:@"hlb"] == NSOrderedSame) return @"text/x-script";
  if([uc caseInsensitiveCompare:@"hlp"] == NSOrderedSame) return @"application/hlp";
  if([uc caseInsensitiveCompare:@"hlp"] == NSOrderedSame) return @"application/x-helpfile";
  if([uc caseInsensitiveCompare:@"hlp"] == NSOrderedSame) return @"application/x-winhelp";
  if([uc caseInsensitiveCompare:@"hpg"] == NSOrderedSame) return @"application/vnd.hp-hpgl";
  if([uc caseInsensitiveCompare:@"hpgl"] == NSOrderedSame) return @"application/vnd.hp-hpgl";
  if([uc caseInsensitiveCompare:@"hqx"] == NSOrderedSame) return @"application/binhex";
  if([uc caseInsensitiveCompare:@"hqx"] == NSOrderedSame) return @"application/binhex4";
  if([uc caseInsensitiveCompare:@"hqx"] == NSOrderedSame) return @"application/mac-binhex";
  if([uc caseInsensitiveCompare:@"hqx"] == NSOrderedSame) return @"application/mac-binhex40";
  if([uc caseInsensitiveCompare:@"hqx"] == NSOrderedSame) return @"application/x-binhex40";
  if([uc caseInsensitiveCompare:@"hqx"] == NSOrderedSame) return @"application/x-mac-binhex40";
  if([uc caseInsensitiveCompare:@"hta"] == NSOrderedSame) return @"application/hta";
  if([uc caseInsensitiveCompare:@"htc"] == NSOrderedSame) return @"text/x-component";
  if([uc caseInsensitiveCompare:@"htm"] == NSOrderedSame) return @"text/html";
  if([uc caseInsensitiveCompare:@"html"] == NSOrderedSame) return @"text/html";
  if([uc caseInsensitiveCompare:@"htmls"] == NSOrderedSame) return @"text/html";
  if([uc caseInsensitiveCompare:@"htt"] == NSOrderedSame) return @"text/webviewhtml";
  if([uc caseInsensitiveCompare:@"htx"] == NSOrderedSame) return @"text/html";
  if([uc caseInsensitiveCompare:@"ice"] == NSOrderedSame) return @"x-conference/x-cooltalk";
  if([uc caseInsensitiveCompare:@"ico"] == NSOrderedSame) return @"image/x-icon";
  if([uc caseInsensitiveCompare:@"idc"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"ief"] == NSOrderedSame) return @"image/ief";
  if([uc caseInsensitiveCompare:@"iefs"] == NSOrderedSame) return @"image/ief";
  if([uc caseInsensitiveCompare:@"iges"] == NSOrderedSame) return @"application/iges";
  if([uc caseInsensitiveCompare:@"iges"] == NSOrderedSame) return @"model/iges";
  if([uc caseInsensitiveCompare:@"igs"] == NSOrderedSame) return @"application/iges";
  if([uc caseInsensitiveCompare:@"igs"] == NSOrderedSame) return @"model/iges";
  if([uc caseInsensitiveCompare:@"ima"] == NSOrderedSame) return @"application/x-ima";
  if([uc caseInsensitiveCompare:@"imap"] == NSOrderedSame) return @"application/x-httpd-imap";
  if([uc caseInsensitiveCompare:@"inf"] == NSOrderedSame) return @"application/inf";
  if([uc caseInsensitiveCompare:@"ins"] == NSOrderedSame) return @"application/x-internett-signup";
  if([uc caseInsensitiveCompare:@"ip"] == NSOrderedSame) return @"application/x-ip2";
  if([uc caseInsensitiveCompare:@"isu"] == NSOrderedSame) return @"video/x-isvideo";
  if([uc caseInsensitiveCompare:@"it"] == NSOrderedSame) return @"audio/it";
  if([uc caseInsensitiveCompare:@"iv"] == NSOrderedSame) return @"application/x-inventor";
  if([uc caseInsensitiveCompare:@"ivr"] == NSOrderedSame) return @"i-world/i-vrml";
  if([uc caseInsensitiveCompare:@"ivy"] == NSOrderedSame) return @"application/x-livescreen";
  if([uc caseInsensitiveCompare:@"jam"] == NSOrderedSame) return @"audio/x-jam";
  if([uc caseInsensitiveCompare:@"jav"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"jav"] == NSOrderedSame) return @"text/x-java-source";
  if([uc caseInsensitiveCompare:@"java"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"java"] == NSOrderedSame) return @"text/x-java-source";
  if([uc caseInsensitiveCompare:@"jcm"] == NSOrderedSame) return @"application/x-java-commerce";
  if([uc caseInsensitiveCompare:@"jfif"] == NSOrderedSame) return @"image/jpeg";
  if([uc caseInsensitiveCompare:@"jfif"] == NSOrderedSame) return @"image/pjpeg";
  if([uc caseInsensitiveCompare:@"jfif-tbnl"] == NSOrderedSame) return @"image/jpeg";
  if([uc caseInsensitiveCompare:@"jpe"] == NSOrderedSame) return @"image/jpeg";
  if([uc caseInsensitiveCompare:@"jpe"] == NSOrderedSame) return @"image/pjpeg";
  if([uc caseInsensitiveCompare:@"jpeg"] == NSOrderedSame) return @"image/jpeg";
  if([uc caseInsensitiveCompare:@"jpeg"] == NSOrderedSame) return @"image/pjpeg";
  if([uc caseInsensitiveCompare:@"jpg"] == NSOrderedSame) return @"image/jpeg";
  if([uc caseInsensitiveCompare:@"thm"] == NSOrderedSame) return @"image/jpeg";
  if([uc caseInsensitiveCompare:@"jpg"] == NSOrderedSame) return @"image/pjpeg";
  if([uc caseInsensitiveCompare:@"jps"] == NSOrderedSame) return @"image/x-jps";
  if([uc caseInsensitiveCompare:@"js"] == NSOrderedSame) return @"application/x-javascript";
  if([uc caseInsensitiveCompare:@"jut"] == NSOrderedSame) return @"image/jutvision";
  if([uc caseInsensitiveCompare:@"kar"] == NSOrderedSame) return @"audio/midi";
  if([uc caseInsensitiveCompare:@"kar"] == NSOrderedSame) return @"music/x-karaoke";
  if([uc caseInsensitiveCompare:@"ksh"] == NSOrderedSame) return @"application/x-ksh";
  if([uc caseInsensitiveCompare:@"ksh"] == NSOrderedSame) return @"text/x-script.ksh";
  if([uc caseInsensitiveCompare:@"la"] == NSOrderedSame) return @"audio/nspaudio";
  if([uc caseInsensitiveCompare:@"la"] == NSOrderedSame) return @"audio/x-nspaudio";
  if([uc caseInsensitiveCompare:@"lam"] == NSOrderedSame) return @"audio/x-liveaudio";
  if([uc caseInsensitiveCompare:@"latex"] == NSOrderedSame) return @"application/x-latex";
  if([uc caseInsensitiveCompare:@"lha"] == NSOrderedSame) return @"application/lha";
  if([uc caseInsensitiveCompare:@"lha"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"lha"] == NSOrderedSame) return @"application/x-lha";
  if([uc caseInsensitiveCompare:@"lhx"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"list"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"lma"] == NSOrderedSame) return @"audio/nspaudio";
  if([uc caseInsensitiveCompare:@"lma"] == NSOrderedSame) return @"audio/x-nspaudio";
  if([uc caseInsensitiveCompare:@"log"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"lsp"] == NSOrderedSame) return @"application/x-lisp";
  if([uc caseInsensitiveCompare:@"lsp"] == NSOrderedSame) return @"text/x-script.lisp";
  if([uc caseInsensitiveCompare:@"lst"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"lsx"] == NSOrderedSame) return @"text/x-la-asf";
  if([uc caseInsensitiveCompare:@"ltx"] == NSOrderedSame) return @"application/x-latex";
  if([uc caseInsensitiveCompare:@"lzh"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"lzh"] == NSOrderedSame) return @"application/x-lzh";
  if([uc caseInsensitiveCompare:@"lzx"] == NSOrderedSame) return @"application/lzx";
  if([uc caseInsensitiveCompare:@"lzx"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"lzx"] == NSOrderedSame) return @"application/x-lzx";
  if([uc caseInsensitiveCompare:@"m"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"m"] == NSOrderedSame) return @"text/x-m";
  if([uc caseInsensitiveCompare:@"m1v"] == NSOrderedSame) return @"video/mpeg";
  if([uc caseInsensitiveCompare:@"m2a"] == NSOrderedSame) return @"audio/mpeg";
  if([uc caseInsensitiveCompare:@"m2v"] == NSOrderedSame) return @"video/mpeg";
  if([uc caseInsensitiveCompare:@"m3u"] == NSOrderedSame) return @"audio/x-mpequrl";
  if([uc caseInsensitiveCompare:@"man"] == NSOrderedSame) return @"application/x-troff-man";
  if([uc caseInsensitiveCompare:@"map"] == NSOrderedSame) return @"application/x-navimap";
  if([uc caseInsensitiveCompare:@"mar"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"mbd"] == NSOrderedSame) return @"application/mbedlet";
  if([uc caseInsensitiveCompare:@"mc$"] == NSOrderedSame) return @"application/x-magic-cap-package-1.0";
  if([uc caseInsensitiveCompare:@"mcd"] == NSOrderedSame) return @"application/mcad";
  if([uc caseInsensitiveCompare:@"mcd"] == NSOrderedSame) return @"application/x-mathcad";
  if([uc caseInsensitiveCompare:@"mcf"] == NSOrderedSame) return @"image/vasa";
  if([uc caseInsensitiveCompare:@"mcf"] == NSOrderedSame) return @"text/mcf";
  if([uc caseInsensitiveCompare:@"mcp"] == NSOrderedSame) return @"application/netmc";
  if([uc caseInsensitiveCompare:@"me"] == NSOrderedSame) return @"application/x-troff-me";
  if([uc caseInsensitiveCompare:@"mht"] == NSOrderedSame) return @"message/rfc822";
  if([uc caseInsensitiveCompare:@"mhtml"] == NSOrderedSame) return @"message/rfc822";
  if([uc caseInsensitiveCompare:@"mid"] == NSOrderedSame) return @"application/x-midi";
  if([uc caseInsensitiveCompare:@"mid"] == NSOrderedSame) return @"audio/midi";
  if([uc caseInsensitiveCompare:@"mid"] == NSOrderedSame) return @"audio/x-mid";
  if([uc caseInsensitiveCompare:@"mid"] == NSOrderedSame) return @"audio/x-midi";
  if([uc caseInsensitiveCompare:@"mid"] == NSOrderedSame) return @"music/crescendo";
  if([uc caseInsensitiveCompare:@"mid"] == NSOrderedSame) return @"x-music/x-midi";
  if([uc caseInsensitiveCompare:@"midi"] == NSOrderedSame) return @"application/x-midi";
  if([uc caseInsensitiveCompare:@"midi"] == NSOrderedSame) return @"audio/midi";
  if([uc caseInsensitiveCompare:@"midi"] == NSOrderedSame) return @"audio/x-mid";
  if([uc caseInsensitiveCompare:@"midi"] == NSOrderedSame) return @"audio/x-midi";
  if([uc caseInsensitiveCompare:@"midi"] == NSOrderedSame) return @"music/crescendo";
  if([uc caseInsensitiveCompare:@"midi"] == NSOrderedSame) return @"x-music/x-midi";
  if([uc caseInsensitiveCompare:@"mif"] == NSOrderedSame) return @"application/x-frame";
  if([uc caseInsensitiveCompare:@"mif"] == NSOrderedSame) return @"application/x-mif";
  if([uc caseInsensitiveCompare:@"mime"] == NSOrderedSame) return @"message/rfc822";
  if([uc caseInsensitiveCompare:@"mime"] == NSOrderedSame) return @"www/mime";
  if([uc caseInsensitiveCompare:@"mjf"] == NSOrderedSame) return @"audio/x-vnd.audioexplosion.mjuicemediafile";
  if([uc caseInsensitiveCompare:@"mjpg"] == NSOrderedSame) return @"video/x-motion-jpeg";
  if([uc caseInsensitiveCompare:@"mm"] == NSOrderedSame) return @"application/base64";
  if([uc caseInsensitiveCompare:@"mm"] == NSOrderedSame) return @"application/x-meme";
  if([uc caseInsensitiveCompare:@"mme"] == NSOrderedSame) return @"application/base64";
  if([uc caseInsensitiveCompare:@"mod"] == NSOrderedSame) return @"audio/mod";
  if([uc caseInsensitiveCompare:@"mod"] == NSOrderedSame) return @"audio/x-mod";
  if([uc caseInsensitiveCompare:@"moov"] == NSOrderedSame) return @"video/quicktime";
  if([uc caseInsensitiveCompare:@"mov"] == NSOrderedSame) return @"video/quicktime";
  if([uc caseInsensitiveCompare:@"movie"] == NSOrderedSame) return @"video/x-sgi-movie";
  if([uc caseInsensitiveCompare:@"mp2"] == NSOrderedSame) return @"audio/mpeg";
  if([uc caseInsensitiveCompare:@"mp2"] == NSOrderedSame) return @"audio/x-mpeg";
  if([uc caseInsensitiveCompare:@"mp2"] == NSOrderedSame) return @"video/mpeg";
  if([uc caseInsensitiveCompare:@"mp2"] == NSOrderedSame) return @"video/x-mpeg";
  if([uc caseInsensitiveCompare:@"mp2"] == NSOrderedSame) return @"video/x-mpeq2a";
  if([uc caseInsensitiveCompare:@"mp3"] == NSOrderedSame) return @"audio/mpeg3";
  if([uc caseInsensitiveCompare:@"mp3"] == NSOrderedSame) return @"audio/x-mpeg-3";
  if([uc caseInsensitiveCompare:@"mp3"] == NSOrderedSame) return @"video/mpeg";
  if([uc caseInsensitiveCompare:@"mp3"] == NSOrderedSame) return @"video/x-mpeg";
  if([uc caseInsensitiveCompare:@"mpa"] == NSOrderedSame) return @"audio/mpeg";
  if([uc caseInsensitiveCompare:@"mpa"] == NSOrderedSame) return @"video/mpeg";
  if([uc caseInsensitiveCompare:@"mpc"] == NSOrderedSame) return @"application/x-project";
  if([uc caseInsensitiveCompare:@"mpe"] == NSOrderedSame) return @"video/mpeg";
  if([uc caseInsensitiveCompare:@"mpeg"] == NSOrderedSame) return @"video/mpeg";
  if([uc caseInsensitiveCompare:@"mpg"] == NSOrderedSame) return @"audio/mpeg";
  if([uc caseInsensitiveCompare:@"mpg"] == NSOrderedSame) return @"video/mpeg";
  if([uc caseInsensitiveCompare:@"mpga"] == NSOrderedSame) return @"audio/mpeg";
  if([uc caseInsensitiveCompare:@"mpp"] == NSOrderedSame) return @"application/vnd.ms-project";
  if([uc caseInsensitiveCompare:@"mpt"] == NSOrderedSame) return @"application/x-project";
  if([uc caseInsensitiveCompare:@"mpv"] == NSOrderedSame) return @"application/x-project";
  if([uc caseInsensitiveCompare:@"mpx"] == NSOrderedSame) return @"application/x-project";
  if([uc caseInsensitiveCompare:@"mrc"] == NSOrderedSame) return @"application/marc";
  if([uc caseInsensitiveCompare:@"ms"] == NSOrderedSame) return @"application/x-troff-ms";
  if([uc caseInsensitiveCompare:@"mv"] == NSOrderedSame) return @"video/x-sgi-movie";
  if([uc caseInsensitiveCompare:@"my"] == NSOrderedSame) return @"audio/make";
  if([uc caseInsensitiveCompare:@"mzz"] == NSOrderedSame) return @"application/x-vnd.audioexplosion.mzz";
  if([uc caseInsensitiveCompare:@"nap"] == NSOrderedSame) return @"image/naplps";
  if([uc caseInsensitiveCompare:@"naplps"] == NSOrderedSame) return @"image/naplps";
  if([uc caseInsensitiveCompare:@"nc"] == NSOrderedSame) return @"application/x-netcdf";
  if([uc caseInsensitiveCompare:@"ncm"] == NSOrderedSame) return @"application/vnd.nokia.configuration-message";
  if([uc caseInsensitiveCompare:@"nif"] == NSOrderedSame) return @"image/x-niff";
  if([uc caseInsensitiveCompare:@"niff"] == NSOrderedSame) return @"image/x-niff";
  if([uc caseInsensitiveCompare:@"nix"] == NSOrderedSame) return @"application/x-mix-transfer";
  if([uc caseInsensitiveCompare:@"nsc"] == NSOrderedSame) return @"application/x-conference";
  if([uc caseInsensitiveCompare:@"nvd"] == NSOrderedSame) return @"application/x-navidoc";
  if([uc caseInsensitiveCompare:@"o"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"oda"] == NSOrderedSame) return @"application/oda";
  if([uc caseInsensitiveCompare:@"omc"] == NSOrderedSame) return @"application/x-omc";
  if([uc caseInsensitiveCompare:@"omcd"] == NSOrderedSame) return @"application/x-omcdatamaker";
  if([uc caseInsensitiveCompare:@"omcr"] == NSOrderedSame) return @"application/x-omcregerator";
  if([uc caseInsensitiveCompare:@"p"] == NSOrderedSame) return @"text/x-pascal";
  if([uc caseInsensitiveCompare:@"p10"] == NSOrderedSame) return @"application/pkcs10";
  if([uc caseInsensitiveCompare:@"p10"] == NSOrderedSame) return @"application/x-pkcs10";
  if([uc caseInsensitiveCompare:@"p12"] == NSOrderedSame) return @"application/pkcs-12";
  if([uc caseInsensitiveCompare:@"p12"] == NSOrderedSame) return @"application/x-pkcs12";
  if([uc caseInsensitiveCompare:@"p7a"] == NSOrderedSame) return @"application/x-pkcs7-signature";
  if([uc caseInsensitiveCompare:@"p7c"] == NSOrderedSame) return @"application/pkcs7-mime";
  if([uc caseInsensitiveCompare:@"p7c"] == NSOrderedSame) return @"application/x-pkcs7-mime";
  if([uc caseInsensitiveCompare:@"p7m"] == NSOrderedSame) return @"application/pkcs7-mime";
  if([uc caseInsensitiveCompare:@"p7m"] == NSOrderedSame) return @"application/x-pkcs7-mime";
  if([uc caseInsensitiveCompare:@"p7r"] == NSOrderedSame) return @"application/x-pkcs7-certreqresp";
  if([uc caseInsensitiveCompare:@"p7s"] == NSOrderedSame) return @"application/pkcs7-signature";
  if([uc caseInsensitiveCompare:@"part"] == NSOrderedSame) return @"application/pro_eng";
  if([uc caseInsensitiveCompare:@"pas"] == NSOrderedSame) return @"text/pascal";
  if([uc caseInsensitiveCompare:@"pbm"] == NSOrderedSame) return @"image/x-portable-bitmap";
  if([uc caseInsensitiveCompare:@"pcl"] == NSOrderedSame) return @"application/vnd.hp-pcl";
  if([uc caseInsensitiveCompare:@"pcl"] == NSOrderedSame) return @"application/x-pcl";
  if([uc caseInsensitiveCompare:@"pct"] == NSOrderedSame) return @"image/x-pict";
  if([uc caseInsensitiveCompare:@"pcx"] == NSOrderedSame) return @"image/x-pcx";
  if([uc caseInsensitiveCompare:@"pdb"] == NSOrderedSame) return @"chemical/x-pdb";
  if([uc caseInsensitiveCompare:@"pdf"] == NSOrderedSame) return @"application/pdf";
  if([uc caseInsensitiveCompare:@"pfunk"] == NSOrderedSame) return @"audio/make";
  if([uc caseInsensitiveCompare:@"pfunk"] == NSOrderedSame) return @"audio/make.my.funk";
  if([uc caseInsensitiveCompare:@"pgm"] == NSOrderedSame) return @"image/x-portable-graymap";
  if([uc caseInsensitiveCompare:@"pgm"] == NSOrderedSame) return @"image/x-portable-greymap";
  if([uc caseInsensitiveCompare:@"pic"] == NSOrderedSame) return @"image/pict";
  if([uc caseInsensitiveCompare:@"pict"] == NSOrderedSame) return @"image/pict";
  if([uc caseInsensitiveCompare:@"pkg"] == NSOrderedSame) return @"application/x-newton-compatible-pkg";
  if([uc caseInsensitiveCompare:@"pko"] == NSOrderedSame) return @"application/vnd.ms-pki.pko";
  if([uc caseInsensitiveCompare:@"pl"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"pl"] == NSOrderedSame) return @"text/x-script.perl";
  if([uc caseInsensitiveCompare:@"plist"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"plx"] == NSOrderedSame) return @"application/x-pixclscript";
  if([uc caseInsensitiveCompare:@"pm"] == NSOrderedSame) return @"image/x-xpixmap";
  if([uc caseInsensitiveCompare:@"pm"] == NSOrderedSame) return @"text/x-script.perl-module";
  if([uc caseInsensitiveCompare:@"pm4"] == NSOrderedSame) return @"application/x-pagemaker";
  if([uc caseInsensitiveCompare:@"pm5"] == NSOrderedSame) return @"application/x-pagemaker";
  if([uc caseInsensitiveCompare:@"png"] == NSOrderedSame) return @"image/png";
  if([uc caseInsensitiveCompare:@"pnm"] == NSOrderedSame) return @"application/x-portable-anymap";
  if([uc caseInsensitiveCompare:@"pnm"] == NSOrderedSame) return @"image/x-portable-anymap";
  if([uc caseInsensitiveCompare:@"pot"] == NSOrderedSame) return @"application/mspowerpoint";
  if([uc caseInsensitiveCompare:@"pot"] == NSOrderedSame) return @"application/vnd.ms-powerpoint";
  if([uc caseInsensitiveCompare:@"pov"] == NSOrderedSame) return @"model/x-pov";
  if([uc caseInsensitiveCompare:@"ppa"] == NSOrderedSame) return @"application/vnd.ms-powerpoint";
  if([uc caseInsensitiveCompare:@"ppm"] == NSOrderedSame) return @"image/x-portable-pixmap";
  if([uc caseInsensitiveCompare:@"pps"] == NSOrderedSame) return @"application/mspowerpoint";
  if([uc caseInsensitiveCompare:@"pps"] == NSOrderedSame) return @"application/vnd.ms-powerpoint";
  if([uc caseInsensitiveCompare:@"ppt"] == NSOrderedSame) return @"application/mspowerpoint";
  if([uc caseInsensitiveCompare:@"ppt"] == NSOrderedSame) return @"application/powerpoint";
  if([uc caseInsensitiveCompare:@"ppt"] == NSOrderedSame) return @"application/vnd.ms-powerpoint";
  if([uc caseInsensitiveCompare:@"ppt"] == NSOrderedSame) return @"application/x-mspowerpoint";
  if([uc caseInsensitiveCompare:@"ppz"] == NSOrderedSame) return @"application/mspowerpoint";
  if([uc caseInsensitiveCompare:@"pre"] == NSOrderedSame) return @"application/x-freelance";
  if([uc caseInsensitiveCompare:@"prt"] == NSOrderedSame) return @"application/pro_eng";
  if([uc caseInsensitiveCompare:@"ps"] == NSOrderedSame) return @"application/postscript";
  if([uc caseInsensitiveCompare:@"psd"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"pvu"] == NSOrderedSame) return @"paleovu/x-pv";
  if([uc caseInsensitiveCompare:@"pwz"] == NSOrderedSame) return @"application/vnd.ms-powerpoint";
  if([uc caseInsensitiveCompare:@"py"] == NSOrderedSame) return @"text/x-script.phyton";
  if([uc caseInsensitiveCompare:@"pyc"] == NSOrderedSame) return @"applicaiton/x-bytecode.python";
  if([uc caseInsensitiveCompare:@"qcp"] == NSOrderedSame) return @"audio/vnd.qcelp";
  if([uc caseInsensitiveCompare:@"qd3"] == NSOrderedSame) return @"x-world/x-3dmf";
  if([uc caseInsensitiveCompare:@"qd3d"] == NSOrderedSame) return @"x-world/x-3dmf";
  if([uc caseInsensitiveCompare:@"qif"] == NSOrderedSame) return @"image/x-quicktime";
  if([uc caseInsensitiveCompare:@"qt"] == NSOrderedSame) return @"video/quicktime";
  if([uc caseInsensitiveCompare:@"qtc"] == NSOrderedSame) return @"video/x-qtc";
  if([uc caseInsensitiveCompare:@"qti"] == NSOrderedSame) return @"image/x-quicktime";
  if([uc caseInsensitiveCompare:@"qtif"] == NSOrderedSame) return @"image/x-quicktime";
  if([uc caseInsensitiveCompare:@"ra"] == NSOrderedSame) return @"audio/x-pn-realaudio";
  if([uc caseInsensitiveCompare:@"ra"] == NSOrderedSame) return @"audio/x-pn-realaudio-plugin";
  if([uc caseInsensitiveCompare:@"ra"] == NSOrderedSame) return @"audio/x-realaudio";
  if([uc caseInsensitiveCompare:@"ram"] == NSOrderedSame) return @"audio/x-pn-realaudio";
  if([uc caseInsensitiveCompare:@"ras"] == NSOrderedSame) return @"application/x-cmu-raster";
  if([uc caseInsensitiveCompare:@"ras"] == NSOrderedSame) return @"image/cmu-raster";
  if([uc caseInsensitiveCompare:@"ras"] == NSOrderedSame) return @"image/x-cmu-raster";
  if([uc caseInsensitiveCompare:@"rast"] == NSOrderedSame) return @"image/cmu-raster";
  if([uc caseInsensitiveCompare:@"rexx"] == NSOrderedSame) return @"text/x-script.rexx";
  if([uc caseInsensitiveCompare:@"rf"] == NSOrderedSame) return @"image/vnd.rn-realflash";
  if([uc caseInsensitiveCompare:@"rgb"] == NSOrderedSame) return @"image/x-rgb";
  if([uc caseInsensitiveCompare:@"rm"] == NSOrderedSame) return @"application/vnd.rn-realmedia";
  if([uc caseInsensitiveCompare:@"rm"] == NSOrderedSame) return @"audio/x-pn-realaudio";
  if([uc caseInsensitiveCompare:@"rmi"] == NSOrderedSame) return @"audio/mid";
  if([uc caseInsensitiveCompare:@"rmm"] == NSOrderedSame) return @"audio/x-pn-realaudio";
  if([uc caseInsensitiveCompare:@"rmp"] == NSOrderedSame) return @"audio/x-pn-realaudio";
  if([uc caseInsensitiveCompare:@"rmp"] == NSOrderedSame) return @"audio/x-pn-realaudio-plugin";
  if([uc caseInsensitiveCompare:@"rng"] == NSOrderedSame) return @"application/ringing-tones";
  if([uc caseInsensitiveCompare:@"rng"] == NSOrderedSame) return @"application/vnd.nokia.ringing-tone";
  if([uc caseInsensitiveCompare:@"rnx"] == NSOrderedSame) return @"application/vnd.rn-realplayer";
  if([uc caseInsensitiveCompare:@"roff"] == NSOrderedSame) return @"application/x-troff";
  if([uc caseInsensitiveCompare:@"rp"] == NSOrderedSame) return @"image/vnd.rn-realpix";
  if([uc caseInsensitiveCompare:@"rpm"] == NSOrderedSame) return @"audio/x-pn-realaudio-plugin";
  if([uc caseInsensitiveCompare:@"rt"] == NSOrderedSame) return @"text/richtext";
  if([uc caseInsensitiveCompare:@"rt"] == NSOrderedSame) return @"text/vnd.rn-realtext";
  if([uc caseInsensitiveCompare:@"rtf"] == NSOrderedSame) return @"application/rtf";
  if([uc caseInsensitiveCompare:@"rtf"] == NSOrderedSame) return @"application/x-rtf";
  if([uc caseInsensitiveCompare:@"rtf"] == NSOrderedSame) return @"text/richtext";
  if([uc caseInsensitiveCompare:@"rtx"] == NSOrderedSame) return @"application/rtf";
  if([uc caseInsensitiveCompare:@"rtx"] == NSOrderedSame) return @"text/richtext";
  if([uc caseInsensitiveCompare:@"rv"] == NSOrderedSame) return @"video/vnd.rn-realvideo";
  if([uc caseInsensitiveCompare:@"s"] == NSOrderedSame) return @"text/x-asm";
  if([uc caseInsensitiveCompare:@"s3m"] == NSOrderedSame) return @"audio/s3m";
  if([uc caseInsensitiveCompare:@"saveme"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"sbk"] == NSOrderedSame) return @"application/x-tbook";
  if([uc caseInsensitiveCompare:@"scm"] == NSOrderedSame) return @"application/x-lotusscreencam";
  if([uc caseInsensitiveCompare:@"scm"] == NSOrderedSame) return @"text/x-script.guile";
  if([uc caseInsensitiveCompare:@"scm"] == NSOrderedSame) return @"text/x-script.scheme";
  if([uc caseInsensitiveCompare:@"scm"] == NSOrderedSame) return @"video/x-scm";
  if([uc caseInsensitiveCompare:@"sdml"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"sdp"] == NSOrderedSame) return @"application/sdp";
  if([uc caseInsensitiveCompare:@"sdp"] == NSOrderedSame) return @"application/x-sdp";
  if([uc caseInsensitiveCompare:@"sdr"] == NSOrderedSame) return @"application/sounder";
  if([uc caseInsensitiveCompare:@"sea"] == NSOrderedSame) return @"application/sea";
  if([uc caseInsensitiveCompare:@"sea"] == NSOrderedSame) return @"application/x-sea";
  if([uc caseInsensitiveCompare:@"set"] == NSOrderedSame) return @"application/set";
  if([uc caseInsensitiveCompare:@"sgm"] == NSOrderedSame) return @"text/sgml";
  if([uc caseInsensitiveCompare:@"sgm"] == NSOrderedSame) return @"text/x-sgml";
  if([uc caseInsensitiveCompare:@"sgml"] == NSOrderedSame) return @"text/sgml";
  if([uc caseInsensitiveCompare:@"sgml"] == NSOrderedSame) return @"text/x-sgml";
  if([uc caseInsensitiveCompare:@"sh"] == NSOrderedSame) return @"application/x-bsh";
  if([uc caseInsensitiveCompare:@"sh"] == NSOrderedSame) return @"application/x-sh";
  if([uc caseInsensitiveCompare:@"sh"] == NSOrderedSame) return @"application/x-shar";
  if([uc caseInsensitiveCompare:@"sh"] == NSOrderedSame) return @"text/x-script.sh";
  if([uc caseInsensitiveCompare:@"shar"] == NSOrderedSame) return @"application/x-bsh";
  if([uc caseInsensitiveCompare:@"shar"] == NSOrderedSame) return @"application/x-shar";
  if([uc caseInsensitiveCompare:@"shtml"] == NSOrderedSame) return @"text/html";
  if([uc caseInsensitiveCompare:@"shtml"] == NSOrderedSame) return @"text/x-server-parsed-html";
  if([uc caseInsensitiveCompare:@"sid"] == NSOrderedSame) return @"audio/x-psid";
  if([uc caseInsensitiveCompare:@"sit"] == NSOrderedSame) return @"application/x-sit";
  if([uc caseInsensitiveCompare:@"sit"] == NSOrderedSame) return @"application/x-stuffit";
  if([uc caseInsensitiveCompare:@"skd"] == NSOrderedSame) return @"application/x-koan";
  if([uc caseInsensitiveCompare:@"skm"] == NSOrderedSame) return @"application/x-koan";
  if([uc caseInsensitiveCompare:@"skp"] == NSOrderedSame) return @"application/x-koan";
  if([uc caseInsensitiveCompare:@"skt"] == NSOrderedSame) return @"application/x-koan";
  if([uc caseInsensitiveCompare:@"sl"] == NSOrderedSame) return @"application/x-seelogo";
  if([uc caseInsensitiveCompare:@"smi"] == NSOrderedSame) return @"application/smil";
  if([uc caseInsensitiveCompare:@"smil"] == NSOrderedSame) return @"application/smil";
  if([uc caseInsensitiveCompare:@"snd"] == NSOrderedSame) return @"audio/basic";
  if([uc caseInsensitiveCompare:@"snd"] == NSOrderedSame) return @"audio/x-adpcm";
  if([uc caseInsensitiveCompare:@"sol"] == NSOrderedSame) return @"application/solids";
  if([uc caseInsensitiveCompare:@"spc"] == NSOrderedSame) return @"application/x-pkcs7-certificates";
  if([uc caseInsensitiveCompare:@"spc"] == NSOrderedSame) return @"text/x-speech";
  if([uc caseInsensitiveCompare:@"spl"] == NSOrderedSame) return @"application/futuresplash";
  if([uc caseInsensitiveCompare:@"spr"] == NSOrderedSame) return @"application/x-sprite";
  if([uc caseInsensitiveCompare:@"sprite"] == NSOrderedSame) return @"application/x-sprite";
  if([uc caseInsensitiveCompare:@"src"] == NSOrderedSame) return @"application/x-wais-source";
  if([uc caseInsensitiveCompare:@"ssi"] == NSOrderedSame) return @"text/x-server-parsed-html";
  if([uc caseInsensitiveCompare:@"ssm"] == NSOrderedSame) return @"application/streamingmedia";
  if([uc caseInsensitiveCompare:@"sst"] == NSOrderedSame) return @"application/vnd.ms-pki.certstore";
  if([uc caseInsensitiveCompare:@"step"] == NSOrderedSame) return @"application/step";
  if([uc caseInsensitiveCompare:@"stl"] == NSOrderedSame) return @"application/sla";
  if([uc caseInsensitiveCompare:@"stl"] == NSOrderedSame) return @"application/vnd.ms-pki.stl";
  if([uc caseInsensitiveCompare:@"stl"] == NSOrderedSame) return @"application/x-navistyle";
  if([uc caseInsensitiveCompare:@"stp"] == NSOrderedSame) return @"application/step";
  if([uc caseInsensitiveCompare:@"sv4cpio"] == NSOrderedSame) return @"application/x-sv4cpio";
  if([uc caseInsensitiveCompare:@"sv4crc"] == NSOrderedSame) return @"application/x-sv4crc";
  if([uc caseInsensitiveCompare:@"svf"] == NSOrderedSame) return @"image/vnd.dwg";
  if([uc caseInsensitiveCompare:@"svf"] == NSOrderedSame) return @"image/x-dwg";
  if([uc caseInsensitiveCompare:@"svr"] == NSOrderedSame) return @"application/x-world";
  if([uc caseInsensitiveCompare:@"svr"] == NSOrderedSame) return @"x-world/x-svr";
  if([uc caseInsensitiveCompare:@"swf"] == NSOrderedSame) return @"application/x-shockwave-flash";
  if([uc caseInsensitiveCompare:@"t"] == NSOrderedSame) return @"application/x-troff";
  if([uc caseInsensitiveCompare:@"talk"] == NSOrderedSame) return @"text/x-speech";
  if([uc caseInsensitiveCompare:@"tar"] == NSOrderedSame) return @"application/x-tar";
  if([uc caseInsensitiveCompare:@"tbk"] == NSOrderedSame) return @"application/toolbook";
  if([uc caseInsensitiveCompare:@"tbk"] == NSOrderedSame) return @"application/x-tbook";
  if([uc caseInsensitiveCompare:@"tcl"] == NSOrderedSame) return @"application/x-tcl";
  if([uc caseInsensitiveCompare:@"tcl"] == NSOrderedSame) return @"text/x-script.tcl";
  if([uc caseInsensitiveCompare:@"tcsh"] == NSOrderedSame) return @"text/x-script.tcsh";
  if([uc caseInsensitiveCompare:@"tex"] == NSOrderedSame) return @"application/x-tex";
  if([uc caseInsensitiveCompare:@"texi"] == NSOrderedSame) return @"application/x-texinfo";
  if([uc caseInsensitiveCompare:@"texinfo"] == NSOrderedSame) return @"application/x-texinfo";
  if([uc caseInsensitiveCompare:@"text"] == NSOrderedSame) return @"application/plain";
  if([uc caseInsensitiveCompare:@"text"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"tgz"] == NSOrderedSame) return @"application/gnutar";
  if([uc caseInsensitiveCompare:@"tgz"] == NSOrderedSame) return @"application/x-compressed";
  if([uc caseInsensitiveCompare:@"tif"] == NSOrderedSame) return @"image/tiff";
  if([uc caseInsensitiveCompare:@"tif"] == NSOrderedSame) return @"image/x-tiff";
  if([uc caseInsensitiveCompare:@"tiff"] == NSOrderedSame) return @"image/tiff";
  if([uc caseInsensitiveCompare:@"tiff"] == NSOrderedSame) return @"image/x-tiff";
  if([uc caseInsensitiveCompare:@"tr"] == NSOrderedSame) return @"application/x-troff";
  if([uc caseInsensitiveCompare:@"tsi"] == NSOrderedSame) return @"audio/tsp-audio";
  if([uc caseInsensitiveCompare:@"tsp"] == NSOrderedSame) return @"application/dsptype";
  if([uc caseInsensitiveCompare:@"tsp"] == NSOrderedSame) return @"audio/tsplayer";
  if([uc caseInsensitiveCompare:@"tsv"] == NSOrderedSame) return @"text/tab-separated-values";
  if([uc caseInsensitiveCompare:@"turbot"] == NSOrderedSame) return @"image/florian";
  if([uc caseInsensitiveCompare:@"txt"] == NSOrderedSame) return @"text/plain";
  if([uc caseInsensitiveCompare:@"uil"] == NSOrderedSame) return @"text/x-uil";
  if([uc caseInsensitiveCompare:@"uni"] == NSOrderedSame) return @"text/uri-list";
  if([uc caseInsensitiveCompare:@"unis"] == NSOrderedSame) return @"text/uri-list";
  if([uc caseInsensitiveCompare:@"unv"] == NSOrderedSame) return @"application/i-deas";
  if([uc caseInsensitiveCompare:@"uri"] == NSOrderedSame) return @"text/uri-list";
  if([uc caseInsensitiveCompare:@"uris"] == NSOrderedSame) return @"text/uri-list";
  if([uc caseInsensitiveCompare:@"ustar"] == NSOrderedSame) return @"application/x-ustar";
  if([uc caseInsensitiveCompare:@"ustar"] == NSOrderedSame) return @"multipart/x-ustar";
  if([uc caseInsensitiveCompare:@"uu"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"uu"] == NSOrderedSame) return @"text/x-uuencode";
  if([uc caseInsensitiveCompare:@"uue"] == NSOrderedSame) return @"text/x-uuencode";
  if([uc caseInsensitiveCompare:@"vcd"] == NSOrderedSame) return @"application/x-cdlink";
  if([uc caseInsensitiveCompare:@"vcs"] == NSOrderedSame) return @"text/x-vcalendar";
  if([uc caseInsensitiveCompare:@"vda"] == NSOrderedSame) return @"application/vda";
  if([uc caseInsensitiveCompare:@"vdo"] == NSOrderedSame) return @"video/vdo";
  if([uc caseInsensitiveCompare:@"vew"] == NSOrderedSame) return @"application/groupwise";
  if([uc caseInsensitiveCompare:@"viv"] == NSOrderedSame) return @"video/vivo";
  if([uc caseInsensitiveCompare:@"viv"] == NSOrderedSame) return @"video/vnd.vivo";
  if([uc caseInsensitiveCompare:@"vivo"] == NSOrderedSame) return @"video/vivo";
  if([uc caseInsensitiveCompare:@"vivo"] == NSOrderedSame) return @"video/vnd.vivo";
  if([uc caseInsensitiveCompare:@"vmd"] == NSOrderedSame) return @"application/vocaltec-media-desc";
  if([uc caseInsensitiveCompare:@"vmf"] == NSOrderedSame) return @"application/vocaltec-media-file";
  if([uc caseInsensitiveCompare:@"voc"] == NSOrderedSame) return @"audio/voc";
  if([uc caseInsensitiveCompare:@"voc"] == NSOrderedSame) return @"audio/x-voc";
  if([uc caseInsensitiveCompare:@"vos"] == NSOrderedSame) return @"video/vosaic";
  if([uc caseInsensitiveCompare:@"vox"] == NSOrderedSame) return @"audio/voxware";
  if([uc caseInsensitiveCompare:@"vqe"] == NSOrderedSame) return @"audio/x-twinvq-plugin";
  if([uc caseInsensitiveCompare:@"vqf"] == NSOrderedSame) return @"audio/x-twinvq";
  if([uc caseInsensitiveCompare:@"vql"] == NSOrderedSame) return @"audio/x-twinvq-plugin";
  if([uc caseInsensitiveCompare:@"vrml"] == NSOrderedSame) return @"application/x-vrml";
  if([uc caseInsensitiveCompare:@"vrml"] == NSOrderedSame) return @"model/vrml";
  if([uc caseInsensitiveCompare:@"vrml"] == NSOrderedSame) return @"x-world/x-vrml";
  if([uc caseInsensitiveCompare:@"vrt"] == NSOrderedSame) return @"x-world/x-vrt";
  if([uc caseInsensitiveCompare:@"vsd"] == NSOrderedSame) return @"application/x-visio";
  if([uc caseInsensitiveCompare:@"vst"] == NSOrderedSame) return @"application/x-visio";
  if([uc caseInsensitiveCompare:@"vsw"] == NSOrderedSame) return @"application/x-visio";
  if([uc caseInsensitiveCompare:@"w60"] == NSOrderedSame) return @"application/wordperfect6.0";
  if([uc caseInsensitiveCompare:@"w61"] == NSOrderedSame) return @"application/wordperfect6.1";
  if([uc caseInsensitiveCompare:@"w6w"] == NSOrderedSame) return @"application/msword";
  if([uc caseInsensitiveCompare:@"wav"] == NSOrderedSame) return @"audio/wav";
  if([uc caseInsensitiveCompare:@"wav"] == NSOrderedSame) return @"audio/x-wav";
  if([uc caseInsensitiveCompare:@"wb1"] == NSOrderedSame) return @"application/x-qpro";
  if([uc caseInsensitiveCompare:@"wbmp"] == NSOrderedSame) return @"image/vnd.wap.wbmp";
  if([uc caseInsensitiveCompare:@"web"] == NSOrderedSame) return @"application/vnd.xara";
  if([uc caseInsensitiveCompare:@"wiz"] == NSOrderedSame) return @"application/msword";
  if([uc caseInsensitiveCompare:@"wk1"] == NSOrderedSame) return @"application/x-123";
  if([uc caseInsensitiveCompare:@"wmf"] == NSOrderedSame) return @"windows/metafile";
  if([uc caseInsensitiveCompare:@"wml"] == NSOrderedSame) return @"text/vnd.wap.wml";
  if([uc caseInsensitiveCompare:@"wmlc"] == NSOrderedSame) return @"application/vnd.wap.wmlc";
  if([uc caseInsensitiveCompare:@"wmls"] == NSOrderedSame) return @"text/vnd.wap.wmlscript";
  if([uc caseInsensitiveCompare:@"wmlsc"] == NSOrderedSame) return @"application/vnd.wap.wmlscriptc";
  if([uc caseInsensitiveCompare:@"word"] == NSOrderedSame) return @"application/msword";
  if([uc caseInsensitiveCompare:@"wp"] == NSOrderedSame) return @"application/wordperfect";
  if([uc caseInsensitiveCompare:@"wp5"] == NSOrderedSame) return @"application/wordperfect";
  if([uc caseInsensitiveCompare:@"wp5"] == NSOrderedSame) return @"application/wordperfect6.0";
  if([uc caseInsensitiveCompare:@"wp6"] == NSOrderedSame) return @"application/wordperfect";
  if([uc caseInsensitiveCompare:@"wpd"] == NSOrderedSame) return @"application/wordperfect";
  if([uc caseInsensitiveCompare:@"wpd"] == NSOrderedSame) return @"application/x-wpwin";
  if([uc caseInsensitiveCompare:@"wq1"] == NSOrderedSame) return @"application/x-lotus";
  if([uc caseInsensitiveCompare:@"wri"] == NSOrderedSame) return @"application/mswrite";
  if([uc caseInsensitiveCompare:@"wri"] == NSOrderedSame) return @"application/x-wri";
  if([uc caseInsensitiveCompare:@"wrl"] == NSOrderedSame) return @"application/x-world";
  if([uc caseInsensitiveCompare:@"wrl"] == NSOrderedSame) return @"model/vrml";
  if([uc caseInsensitiveCompare:@"wrl"] == NSOrderedSame) return @"x-world/x-vrml";
  if([uc caseInsensitiveCompare:@"wrz"] == NSOrderedSame) return @"model/vrml";
  if([uc caseInsensitiveCompare:@"wrz"] == NSOrderedSame) return @"x-world/x-vrml";
  if([uc caseInsensitiveCompare:@"wsc"] == NSOrderedSame) return @"text/scriplet";
  if([uc caseInsensitiveCompare:@"wsrc"] == NSOrderedSame) return @"application/x-wais-source";
  if([uc caseInsensitiveCompare:@"wtk"] == NSOrderedSame) return @"application/x-wintalk";
  if([uc caseInsensitiveCompare:@"xbm"] == NSOrderedSame) return @"image/x-xbitmap";
  if([uc caseInsensitiveCompare:@"xbm"] == NSOrderedSame) return @"image/x-xbm";
  if([uc caseInsensitiveCompare:@"xbm"] == NSOrderedSame) return @"image/xbm";
  if([uc caseInsensitiveCompare:@"xdr"] == NSOrderedSame) return @"video/x-amt-demorun";
  if([uc caseInsensitiveCompare:@"xgz"] == NSOrderedSame) return @"xgl/drawing";
  if([uc caseInsensitiveCompare:@"xif"] == NSOrderedSame) return @"image/vnd.xiff";
  if([uc caseInsensitiveCompare:@"xl"] == NSOrderedSame) return @"application/excel";
  if([uc caseInsensitiveCompare:@"xla"] == NSOrderedSame) return @"application/excel";
  if([uc caseInsensitiveCompare:@"xla"] == NSOrderedSame) return @"application/x-excel";
  if([uc caseInsensitiveCompare:@"xla"] == NSOrderedSame) return @"application/x-msexcel";
  if([uc caseInsensitiveCompare:@"xlb"] == NSOrderedSame) return @"application/excel";
  if([uc caseInsensitiveCompare:@"xlb"] == NSOrderedSame) return @"application/vnd.ms-excel";
  if([uc caseInsensitiveCompare:@"xlb"] == NSOrderedSame) return @"application/x-excel";
  if([uc caseInsensitiveCompare:@"xlc"] == NSOrderedSame) return @"application/excel";
  if([uc caseInsensitiveCompare:@"xlc"] == NSOrderedSame) return @"application/vnd.ms-excel";
  if([uc caseInsensitiveCompare:@"xlc"] == NSOrderedSame) return @"application/x-excel";
  if([uc caseInsensitiveCompare:@"xld"] == NSOrderedSame) return @"application/excel";
  if([uc caseInsensitiveCompare:@"xld"] == NSOrderedSame) return @"application/x-excel";
  if([uc caseInsensitiveCompare:@"xlk"] == NSOrderedSame) return @"application/excel";
  if([uc caseInsensitiveCompare:@"xlk"] == NSOrderedSame) return @"application/x-excel";
  if([uc caseInsensitiveCompare:@"xll"] == NSOrderedSame) return @"application/excel";
  if([uc caseInsensitiveCompare:@"xll"] == NSOrderedSame) return @"application/vnd.ms-excel";
  if([uc caseInsensitiveCompare:@"xll"] == NSOrderedSame) return @"application/x-excel";
  if([uc caseInsensitiveCompare:@"xlm"] == NSOrderedSame) return @"application/excel";
  if([uc caseInsensitiveCompare:@"xlm"] == NSOrderedSame) return @"application/vnd.ms-excel";
  if([uc caseInsensitiveCompare:@"xlm"] == NSOrderedSame) return @"application/x-excel";
  if([uc caseInsensitiveCompare:@"xls"] == NSOrderedSame) return @"application/excel";
  if([uc caseInsensitiveCompare:@"xls"] == NSOrderedSame) return @"application/vnd.ms-excel";
  if([uc caseInsensitiveCompare:@"xls"] == NSOrderedSame) return @"application/x-excel";
  if([uc caseInsensitiveCompare:@"xls"] == NSOrderedSame) return @"application/x-msexcel";
  if([uc caseInsensitiveCompare:@"xlt"] == NSOrderedSame) return @"application/excel";
  if([uc caseInsensitiveCompare:@"xlt"] == NSOrderedSame) return @"application/x-excel";
  if([uc caseInsensitiveCompare:@"xlv"] == NSOrderedSame) return @"application/excel";
  if([uc caseInsensitiveCompare:@"xlv"] == NSOrderedSame) return @"application/x-excel";
  if([uc caseInsensitiveCompare:@"xlw"] == NSOrderedSame) return @"application/excel";
  if([uc caseInsensitiveCompare:@"xlw"] == NSOrderedSame) return @"application/vnd.ms-excel";
  if([uc caseInsensitiveCompare:@"xlw"] == NSOrderedSame) return @"application/x-excel";
  if([uc caseInsensitiveCompare:@"xlw"] == NSOrderedSame) return @"application/x-msexcel";
  if([uc caseInsensitiveCompare:@"xm"] == NSOrderedSame) return @"audio/xm";
  if([uc caseInsensitiveCompare:@"xml"] == NSOrderedSame) return @"application/xml";
  if([uc caseInsensitiveCompare:@"xml"] == NSOrderedSame) return @"text/xml";
  if([uc caseInsensitiveCompare:@"xmz"] == NSOrderedSame) return @"xgl/movie";
  if([uc caseInsensitiveCompare:@"xpix"] == NSOrderedSame) return @"application/x-vnd.ls-xpix";
  if([uc caseInsensitiveCompare:@"xpm"] == NSOrderedSame) return @"image/x-xpixmap";
  if([uc caseInsensitiveCompare:@"xpm"] == NSOrderedSame) return @"image/xpm";
  if([uc caseInsensitiveCompare:@"x-png"] == NSOrderedSame) return @"image/png";
  if([uc caseInsensitiveCompare:@"xsr"] == NSOrderedSame) return @"video/x-amt-showrun";
  if([uc caseInsensitiveCompare:@"xwd"] == NSOrderedSame) return @"image/x-xwd";
  if([uc caseInsensitiveCompare:@"xwd"] == NSOrderedSame) return @"image/x-xwindowdump";
  if([uc caseInsensitiveCompare:@"xyz"] == NSOrderedSame) return @"chemical/x-pdb";
  if([uc caseInsensitiveCompare:@"z"] == NSOrderedSame) return @"application/x-compress";
  if([uc caseInsensitiveCompare:@"z"] == NSOrderedSame) return @"application/x-compressed";
  if([uc caseInsensitiveCompare:@"zip"] == NSOrderedSame) return @"application/x-compressed";
  if([uc caseInsensitiveCompare:@"zip"] == NSOrderedSame) return @"application/x-zip-compressed";
  if([uc caseInsensitiveCompare:@"zip"] == NSOrderedSame) return @"application/zip";
  if([uc caseInsensitiveCompare:@"zip"] == NSOrderedSame) return @"multipart/x-zip";
  if([uc caseInsensitiveCompare:@"zoo"] == NSOrderedSame) return @"application/octet-stream";
  if([uc caseInsensitiveCompare:@"zsh"] == NSOrderedSame) return @"text/x-script.zsh";
  return @"unknown/unknown";
}


+ (NSString*) createindexForDir:(NSString*)cwd {

  NSMutableString *outdata = [NSMutableString stringWithFormat:@"\
                              <html>\n<head><title>%@</title>\n<meta name=\"viewport\" content=\"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\"/>\
                              <style>/* based on iui.css */ body {     margin: 0;     font-family: Helvetica;     background: #FFFFFF;     color: #000000;     overflow-x: hidden;     -webkit-user-select: none;     -webkit-text-size-adjust: none; }  body > *:not(.toolbar) {     display: none;     position: absolute;     margin: 0;     padding: 0;     left: 0;     top: 45px;     width: 100%%;     min-height: 372px; }  body > *[selected=\"true\"] {     display: block; }  a[selected], a:active {     background-color: #194fdb !important;     background-repeat: no-repeat, repeat-x;     background-position: right center, left top;     color: #FFFFFF !important; }  body > .toolbar {     box-sizing: border-box;     -moz-box-sizing: border-box;     -webkit-box-sizing: border-box;     border-bottom: 1px solid #2d3642;     border-top: 1px solid #6d84a2;     padding: 10px;     height: 45px;     background: #6d84a2 repeat-x; }  .toolbar > h1 {     position: absolute;     overflow: hidden;     font-size: 20px;     text-align: center;     font-weight: bold;     text-shadow: rgba(0, 0, 0, 0.4) 0px -1px 0;     text-overflow: ellipsis;     white-space: nowrap;     color: #FFFFFF;      margin: 1px 0 0 -120px;     left: 50%%;     width: 240px;     height: 45px; }  body > ul > li {     position: relative;     margin: 0;     border-bottom: 1px solid #E0E0E0;     padding: 8px 0 8px 10px;     font-size: 20px;     font-weight: bold;     list-style: none; }  body > ul > li > a {      margin: -8px 0 -8px -10px;     padding: 8px 32px 8px 10px;     text-decoration: none;     color: inherit; }  a[target=\"_replace\"] {     box-sizing: border-box;     -webkit-box-sizing: border-box;     padding-top: 25px;     padding-bottom: 25px;     font-size: 18px;     color: cornflowerblue;     background-color: #FFFFFF;     background-image: none; }  body > .dialog {     top: 0;     width: 100%%;     min-height: 417px;     z-index: 2;     background: rgba(0, 0, 0, 0.8);     padding: 0;     text-align: right; }  .dialog > fieldset {     box-sizing: border-box;     -webkit-box-sizing: border-box;     width: 100%%;     margin: 0;     border: none;     border-top: 1px solid #6d84a2;     padding: 10px 6px;     background: #7388a5 repeat-x; }  .dialog > fieldset > h1 {     margin: 0 10px 0 10px;     padding: 0;     font-size: 20px;     font-weight: bold;     color: #FFFFFF;     text-shadow: rgba(0, 0, 0, 0.4) 0px -1px 0;     text-align: center; }  .dialog > fieldset > label {     position: absolute;     margin: 16px 0 0 6px;     font-size: 14px;     color: #999999; }  p {     font-family: Helvetica;     background: #FFFFFF;     color: #000000;     padding:15px;     font-size: 20px;     margin-left: 15%%;     margin-right: 15%%;     text-align: center; }  </style>\
                              <script>\
                              window.onload = function() { setTimeout(function() {window.scrollTo(0,1);), 100); }\
                              </script>\
                              </head><body>\
                              <div class=\"toolbar\">	<h1 id=\"pageTitle\">%@</h1>	<a id=\"backButton\" class=\"button\" href=\"#\"></a>    </div>\
                              <ul id=\"home\" title=\"Files\" selected=\"true\">", cwd, [cwd lastPathComponent]];

  if (![cwd isEqualToString:@"/"]) {
    NSString *nwd = cwd.stringByDeletingLastPathComponent;
    [outdata appendFormat: ![nwd isEqualToString:@"/"] ? @"<li><a href=\"%@/\">Parent Directory/</a></li>\n" :
     @"<li><a href=\"%@\">Parent Directory/</a></li>\n", nwd];
  }

  // Read in the strings
  NSString *wd = cwd;
  for (NSString *fname in [FM directoryContentsAtPath:wd]) {
    BOOL isDir;
    NSString *cpath = [wd stringByAppendingPathComponent:fname];
    [FM fileExistsAtPath:cpath isDirectory:&isDir];
    [outdata appendFormat:@"<li><a href=\"%@%@\">%@%@</a>%@</li>\n", cpath, isDir ? @"/" : @"",
     fname, isDir ? @"/" : @"",  isDir ? [NSString stringWithFormat:@"<a href=\"zzzzip%@.zip\">[zip]</a>", cpath] : @"" ];
  }
  [outdata appendString:@"</ul>"];
  [outdata appendString:@"</body></html>\n"];
  return outdata;
}

_VD produceError: (NSString *) errorString forFD: (int) fd atPath:(NSString*)cwd {

  NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"];
  write (fd, outcontent.UTF8String, outcontent.length);

  NSMutableString *outdata = [[NSMutableString alloc] init];
  [outdata appendString:@"<html>"];
  [outdata appendString:@"<head><title>Error</title>\n"];
  [outdata appendString:@"<meta name=\"viewport\" content=\"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\"/>"];
  [outdata appendString:@"<style>/* based on iui.css (c) 2007 by iUI Project Members */ body {     margin: 0;     font-family: Helvetica;     background: #FFFFFF;     color: #000000;     overflow-x: hidden;     -webkit-user-select: none;     -webkit-text-size-adjust: none; }  body > *:not(.toolbar) {     display: none;     position: absolute;     margin: 0;     padding: 0;     left: 0;     top: 45px;     width: 100%;     min-height: 372px; }  body > *[selected=\"true\"] {     display: block; }  a[selected], a:active {     background-color: #194fdb !important;     background-repeat: no-repeat, repeat-x;     background-position: right center, left top;     color: #FFFFFF !important; }  body > .toolbar {     box-sizing: border-box;     -moz-box-sizing: border-box;     -webkit-box-sizing: border-box;     border-bottom: 1px solid #2d3642;     border-top: 1px solid #6d84a2;     padding: 10px;     height: 45px;     background: #6d84a2 repeat-x; }  .toolbar > h1 {     position: absolute;     overflow: hidden;     font-size: 20px;     text-align: center;     font-weight: bold;     text-shadow: rgba(0, 0, 0, 0.4) 0px -1px 0;     text-overflow: ellipsis;     white-space: nowrap;     color: #FFFFFF;      margin: 1px 0 0 -120px;     left: 50%;     width: 240px;     height: 45px; }  body > ul > li {     position: relative;     margin: 0;     border-bottom: 1px solid #E0E0E0;     padding: 8px 0 8px 10px;     font-size: 20px;     font-weight: bold;     list-style: none; }  body > ul > li > a {      margin: -8px 0 -8px -10px;     padding: 8px 32px 8px 10px;     text-decoration: none;     color: inherit; }  a[target=\"_replace\"] {     box-sizing: border-box;     -webkit-box-sizing: border-box;     padding-top: 25px;     padding-bottom: 25px;     font-size: 18px;     color: cornflowerblue;     background-color: #FFFFFF;     background-image: none; }  body > .dialog {     top: 0;     width: 100%;     min-height: 417px;     z-index: 2;     background: rgba(0, 0, 0, 0.8);     padding: 0;     text-align: right; }  .dialog > fieldset {     box-sizing: border-box;     -webkit-box-sizing: border-box;     width: 100%;     margin: 0;     border: none;     border-top: 1px solid #6d84a2;     padding: 10px 6px;     background: #7388a5 repeat-x; }  .dialog > fieldset > h1 {     margin: 0 10px 0 10px;     padding: 0;     font-size: 20px;     font-weight: bold;     color: #FFFFFF;     text-shadow: rgba(0, 0, 0, 0.4) 0px -1px 0;     text-align: center; }  .dialog > fieldset > label {     position: absolute;     margin: 16px 0 0 6px;     font-size: 14px;     color: #999999; }  p {     font-family: Helvetica;     background: #FFFFFF;     color: #000000;     padding:15px;     font-size: 20px;     margin-left: 15%;     margin-right: 15%;     text-align: center; }  </style>"];
  [outdata appendString:@"</head><body>"];
  [outdata appendString:@"<div class=\"toolbar\">	<h1 id=\"pageTitle\">Error</h1>	<a id=\"backButton\" class=\"button\" href=\"#\"></a>    </div>"];
  [outdata appendFormat:@"<p id=\"ErrorPara\" selected=\"true\"><br />%@<br /><br />Return to <a  href=\"upload.html\">upload page</a> or <a href=\"/\">Main browser</a></p>", errorString];
  [outdata appendString:@"</body></html>\n"];

  write (fd, outdata.UTF8String,outdata.length);
  close(fd);
}

#define BUFSIZE 8096

#define STATUS_OFFLINE	0
#define STATUS_ATTEMPT	1
#define STATUS_ONLINE   2

// Serve files to GET requests

_VD handleWebRequest:(int) fd {

  NSString *cwd;

  @autoreleasepool {
    static char buffer[BUFSIZE+1];

    int len = read(fd, buffer, BUFSIZE);
    buffer[len] = '\0';

    NSString *request = @(buffer);
    NSArray *reqs = [request componentsSeparatedByString:@"\n"];
    NSString *getreq = [reqs[0] substringFromIndex:4];
    NSRange range = [getreq rangeOfString:@"HTTP/"];
    if (range.location == NSNotFound) {
      printf("Error: GET request was improperly formed\n");  close(fd);  return;  }

    NSString *filereq = [[getreq substringToIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if ([filereq isEqualToString:@"/"])
    {
      cwd = filereq;
      NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"];
      write(fd, [outcontent UTF8String], [outcontent length]);

      NSString *outdata = [self.class createindexForDir:cwd];
      write(fd, [outdata UTF8String], [outdata length]);
      close(fd);
      return;
    }

    if ([filereq isEqualToString:@"/favicon.ico"])
    {
      NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: %@\r\n\r\n", @"image/vnd.microsoft.icon"];
      write (fd, [outcontent UTF8String], [outcontent length]);
      NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"favicon" ofType:@"ico"]];
      if (!data)
      {
        printf("Error: favicon.ico not found.\n");
        return;
      }
      write(fd, [data bytes], [data length]);
      close(fd);
      return;
    }

    filereq = [filereq stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    // Primary index.html
    if ([filereq hasSuffix:@"/"])
    {
      cwd = filereq;

      if (![[NSFileManager defaultManager] fileExistsAtPath:filereq])
      {
        printf("Error: folder not found.\n");
        [self produceError:@"Requested folder was not found." forFD:fd  atPath:cwd];
        return;
      }

      NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"];
      write(fd, [outcontent UTF8String], [outcontent length]);

      NSString *outdata = [self.class createindexForDir:cwd];
      write(fd, [outdata UTF8String], [outdata length]);
      close(fd);
      return;
    }

    NSString *mime = [self.class mimeForExt:[filereq pathExtension]];
    if (!mime)
    {
      printf("Error recovering mime type.\n");
      //      [self produceError:@"Sorry. This file type is not supported." forFD:fd];
      return;
    }

    NSRange r = [filereq rangeOfString:@"zzzzip"];
    if (r.location != NSNotFound)
    {
      NSString *path1 = [filereq substringFromIndex:r.location + 6];
      NSString *path = [path1 substringToIndex:[path1 length] - 4];
      printf("Zip request: %s\n", [path UTF8String]);

      NSString *zipRequest = @"zip -o archive.zip";
      NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:path];

      NSString *eachFile;
      while (eachFile = [direnum nextObject])
      {
        BOOL isDir;
        NSString *fpath = [path stringByAppendingPathComponent:eachFile];
        [[NSFileManager defaultManager] fileExistsAtPath:fpath isDirectory:&isDir];
        if (!isDir) zipRequest = [zipRequest stringByAppendingFormat:@" %@",
                                  [fpath stringByReplacingOccurrencesOfString:@" " withString: @"\\ "]];
      }

      // CFShow(zipRequest);
      chdir([DOCUMENTS_FOLDER UTF8String]);
      //      [NuZip zip:zipRequest];

      // Output the file
      NSString *outcontent = @"HTTP/1.0 200 OK\r\nContent-Type:application/x-compressed\r\n\r\n";
      write (fd, [outcontent UTF8String], [outcontent length]);
      NSData *data = [NSData dataWithContentsOfFile:@"archive.zip"];
      if (!data)
      {
        printf("Error: file not found.\n");
        //        [self produceError:@"File was not found. Please check the requested path and try again." forFD:fd];
        return;
      }
      printf("Writing %lu bytes from file\n", (unsigned long)[data length]);
      write(fd, [data bytes], [data length]);
      close(fd);

      return;
    }

    // Output the file
    NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: %@\r\n\r\n", mime];
    write (fd, [outcontent UTF8String], [outcontent length]);
    NSData *data = [NSData dataWithContentsOfFile:filereq];
    if (!data)
    {
      printf("Error: file not found.\n");
      //      [self produceError:@"File was not found. Please check the requested path and try again." forFD:fd];
      return;
    }
    printf("Writing %lu bytes from file\n", (unsigned long)[data length]);
    write(fd, [data bytes], [data length]);
    close(fd);
  }

}

+ _Dict_ ipsForInterfaces {

  struct ifaddrs *list, *cur; mDict d = @{}.mutableCopy;

  if(getifaddrs(&list) < 0) return perror("getifaddrs"), nil;

  for(cur = list; cur != NULL; cur = cur->ifa_next) {

    if ( cur->ifa_addr->sa_family != AF_INET ) continue;
    struct sockaddr_in *addrStruct = (struct sockaddr_in *)cur->ifa_addr;
               d[@(cur->ifa_name)] = @(inet_ntoa(addrStruct->sin_addr));
  }
  return freeifaddrs(list), d;
}

+ _Text_ prettyBytes __Flot_ bytes { _UInt unit = 0;	if(bytes < 1) return @"-";

  while (bytes > 1024) { bytes = bytes / 1024.0;	unit++; }

  return unit > 5 ? @"HUGE" : $(!unit ? @"%d %@" : @"%.2d %@", (int)bytes, @[@"Bytes", @"KB", @"MB", @"GB", @"TB", @"PB"][unit]);
}

+ _Data_ JSONify _ x  { x = ISA(x,Text) ? @{@"message": x} : x;

  return ISA(x,Dict) ? [Json dataWithJSONObject:x options:NSJSONWritingPrettyPrinted error:nil] : x;
}

@end

#define kFlagsDirectory @"/Library/Application Support/Apple/iChat Icons/Flags/"
#define service_url @"http://www.telize.com/geoip/" // @"http://freegeoip.net/json/"

@implementation Locale

+ _Kind_ localeOfIP __Text_ ip { if (!ip) return nil;

  static mDict locales; locales = locales ?: @{}.mutableCopy;

  Locale * l; if ((l = [locales objectForKey:ip])) return l;

  _Errr responseError = nil, parsingError = nil;

  _NRes response = nil;
  _Data data = [NCon sendSynchronousRequest:
                       [NReq requestWithURL:$URL([service_url withString:ip])]
                          returningResponse:&response error:&responseError];

  if (responseError)
    return NSLog(@"error: %@", [responseError localizedFailureReason]), (locales[ip] = NSNull.null);


  _Dict dict = [Json JSONObjectWithData:data options:0 error:&parsingError];

   [dict log];

  if (parsingError)
    return NSLog(@"JSON-parsing error: %@", [parsingError localizedFailureReason]), (locales[ip] = NSNull.null);

  return !dict ? (id) nil : ({ l = [self.class.new objectBySettingValuesWithDictionary:[dict dictionaryWithValuesForKeys:self.class.propertyNames]]; !l ? (id)nil : (locales[ip] = l); });
}

//- _Void_ setValue _ value forUndefinedKey __Text_ key  { }

- _Pict_ flag { id component = self.class.flags[self.country] ?: $(@"%@.png",self.country_code3);

  return !component ? nil : INIT_(Pict,WithContentsOfFile:[kFlagsDirectory withPath:component]);
}

+ _Dict_ flags { AZSTATIC_OBJ(Dict,f, [FM pathsForItemsInFolder:kFlagsDirectory withExtension:@"png"]); return f; }

//  static _Dict  f = nil; return f = f ?: ({ ;
//
//    mDict countries = @{}.mutableCopy;
//    NSDirectoryEnumerator *dirEnum = [NSFileManager.defaultManager enumeratorAtPath:];
//    for (_Text fileName in dirEnum) {
//      if (![fileName.pathExtension isEqualToString:@"png"]) continue;
//      countries[fileName.stringByDeletingPathExtension] = fileName;
//    }
//    countries.copy;
//  });
//}

@end


@implementation SpeedTester static NSMutableArray *keyArray;

+(void)start:(NSString*)key{
#ifdef DEBUG
    
    if(!keyArray){
        keyArray = [[NSMutableArray alloc] init];
    }
    
    NSDate *date = [[NSDate alloc] init];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:date forKey:key];
    [ud synchronize];
#endif
}

+(void)lap:(NSString*)key WithComment:(NSString*)comment{
#ifdef DEBUG
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDate *date = [ud objectForKey:key];
    NSLog(@"%@ - %@ : %f", key, comment, [date timeIntervalSinceNow]);
#endif
}

+(void)lapAndEnd:(NSString*)key WithComment:(NSString*)comment{
#ifdef DEBUG
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    NSString *cmt = [NSString stringWithFormat:@"%@%@", comment, @" / measure end"];
    [SpeedTester lap:key WithComment:cmt];
    [ud removeObjectForKey:key];
    [ud synchronize];
    if(keyArray) [keyArray removeObject:key];
#endif
}

+ (void) clearAll{
#ifdef DEBUG
    if(!keyArray) return;

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    for(NSString* key in keyArray){
        [ud removeObjectForKey:key];
        [keyArray removeObject:key];
        NSLog(@"key: [%@] removed", key);
   
    }
    [ud synchronize];

#endif
}
@end

@implementation Locator

{	CLLocationManager *locationManager; void(^_GotLocation)(NSString*); }

+ (instancetype)locate:(void (^)(NSString *))notfier
{
  Locator* x = self.class.new;
  x->_GotLocation = [notfier copy];
	(x->locationManager = CLLocationManager.new).delegate = x;
	[x->locationManager startUpdatingLocation];
  return x;
}

+ (double) latitudeRangeForLocation:(CLLocation *)aLocation {

	const double        M = 6367000.0,  // approximate average meridional radius of curvature of earth
       metersToLatitude = 1.0 / ((M_PI / 180.0) * M),
  accuracyToWindowScale = 2.0;
  return aLocation.horizontalAccuracy * metersToLatitude * accuracyToWindowScale;
}

+ (double) longitudeRangeForLocation:(CLLocation *)aLoc {

	return /* latitudeRange */ [self latitudeRangeForLocation:aLoc] * cos(aLoc.coordinate.latitude * M_PI / 180.0);
}


- (void)locationManager:(CLLocationManager*)lm	didUpdateToLocation:(CLLocation *)newL fromLocation:(CLLocation *)oldL {

	// Ignore updates where nothing we care about changed
	if (newL.coordinate.longitude == oldL.coordinate.longitude &&
		   newL.coordinate.latitude == oldL.coordinate.latitude  &&
        newL.horizontalAccuracy == oldL.horizontalAccuracy      ) return;

  if (_GotLocation) _GotLocation([self getAdrressFromLatLong:newL.coordinate.latitude lon:newL.coordinate.longitude]);
}

- (void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError *)error
{
  NSLog(@"Location manager failed with error: %@", [error localizedDescription]);
  if (_GotLocation) _GotLocation(@"N/A");
}

_VD dealloc {[locationManager stopUpdatingLocation]; }

- (NSString*) getAdrressFromLatLong : (CGFloat)lat lon:(CGFloat)lon {

 	NSURLResponse     * response = nil;
  NSError       * requestError = nil;
  NSMutableURLRequest *request = [NSMutableURLRequest.alloc initWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&amp;sensor=false",lat,lon] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&requestError];

  NSDictionary *d = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];

  NSString *address = nil;

	if (d.count) {
 
		if ([d[@"status"] isEqualToString:@"OK"] ) {

      NSLog(@"responseString %@",d[@"results"][0]);
      NSArray *components = d[@"results"][0][@"address_components"];
 
			address = !components.count ? address : components[1][@"long_name"]; // formatted_address"]; // use the address variable to access the ADDRESS :)
    }
  }
  return address ?: @"Location Unknown.";
}
@end

/*- copyWithZone:(NSZone *)zone
{
  NSLog(@"%@", NSStringFromSelector(_cmd));
    __typeof(self) copy = [self.class new];

    if (copy) { // Copy NSObject subclasses
        [copy setName:_name.copy];
        [copy setIp:_ip.copy];
        !_ISP         ?: [copy setISP:_ISP.copy];
        !_FQDN        ?: [copy setFQDN:_FQDN.copy];
        !_externalIP  ?: [copy setExternalIP:_externalIP.copy];
        [copy setIsLoopback:_isLoopback];
        [copy setIsPrimary:_isPrimary];
    }
    return copy;
}
- (void)encodeWithCoder:(NSCoder *)aCoder;
- initWithCoder:(NSCoder*)aDecoder {

}*/
//- init { return [NSException raise:@"poop" format:nil], (id)nil; }
