

#if !TARGET_OS_IPHONE
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#endif

@import CoreLocation;

#define NOTAPPLICAPLE @"--"

#define NET NetworkHelpers


@interface Locale : NSObject

+ (instancetype) localeOfIP:(NSString*)ip;

+ (NSDictionary*) flags;

@property (readonly) NSImage *flag;

@property (copy) NSString * city,
                          * region_code,
                          * region_name,
                          * postal_code,
                          * country_code,

                          * latitude,
                          * longitude,
                          * time_zone,
                          * zip_code,
                          * metro_code,
                          * country_name, *ip,

                          * country_code3,
                          * country,
                          * continent_code,
                          * dma_code,
                          * area_code,
                          * asn,
                          * isp,
                          * timezone,
                          * message,
                          * code;

@end

@interface Interface : NSObject

@property (readonly,copy) NSString *speed, *name, *ip, *externalIP, *ISP, *FQDN, *prettySpeed;
@property (readonly)          BOOL isPrivate, isPrimary;
@property (readonly)        Locale *locale;
//@property (readonly) NSUInteger speed;
@end

@interface Locator : NSObject <CLLocationManagerDelegate>

+ (instancetype) locate:(void(^)(NSString*))notfier;

@end

@interface NetworkHelpers : NSObject

+ (BOOL) isPrivate:(NSString*)ip;

+ (NSString*) curl:x;

+ (NSString*) externalIPOf:x;



+ (NSString*)  ISP;
+ (NSString*)  ISPof:(NSString*)ip;
//+ (NSString*)  ISPon:(Interface*)__ ___
+ (NSString*)  ISPon:(NSString*)extip;

+ (NSString*) FQDNof:(NSString*)ip; // [NetworkHelpers FQDNof:@"70.208.76.172"] = 172.sub-70-208-76.myvzw.com

/*!
 @abstract		IPv4 address of the primary network interface.
 @discussion	This property automatically determines which interface is the primary interface and returns its IPv4 address.
 refresh is called if the shared instance have not retrieved network information yet.
 */
+ (NSString*) primaryIPv4Address;

+ (NSString*) externalIP; // ie. 24.193.96.236


///  { en0 = "10.0.1.100"; en2 = "10.0.1.101"; lo0 = "127.0.0.1"; vmnet1 = "172.16.21.1"; vmnet8 = "192.168.136.1"; }
+ (NSDictionary *)       localhosts;
+ (NSArray*)       interfaces;

+   (NSData*)               JSONify:__ ;
+      (BOOL)    connectedToNetwork;
+      (BOOL)         hostAvailable:(NSString*)theHost;
+ (NSString*)            mimeForExt:(NSString*)ext; // MIMEHelper
+ (NSString*)       hostAddyForPort:(int)chosenPort;

// Return the iPhone's IP address
+ (NSString*) localIPAddressForPort:(int)p;
+ (NSString*)   localAddressForPort:(int)p;

+ (NSString*)           prettyBytes:(CGFloat)bytes;
+ (NSString*)                  FQDN;
+ (NSString*)     createindexForDir:(NSString*)cwd;


@end

typedef NS_ENUM(NSUInteger, tNetworkReachabilityFlags)
{
    tInternetIsReachable  = 1 << 1,
    tLANIsReachable       = 1 << 2
};

void      * InAddrStruct(struct sockaddr *sa);

NSString  * AddressString(struct sockaddr *sa);

NSArray   * NetworkInterfaces();

NSString  * NetworkOfIPv4Address(NSString *address, NSString *mask);

typedef NS_ENUM(int, HTTPMethod)
{
  // Requests a representation of the specified resource. Requests using GET should only retrieve data and should have no other effect. (This is also true of some other HTTP methods.)[1] The W3C has published guidance principles on this distinction, saying, "Web application design should be informed by the above principles, but also by the relevant limitations."[11] See safe methods below.
  HTTPGET,

  //  Asks for the response identical to the one that would correspond to a GET request, but without the response body. This is useful for retrieving meta-information written in response headers, without having to transport the entire content.
  HTTPHEAD,

  // Requests that the server accept the entity enclosed in the request as a new subordinate of the web resource identified by the URI. The data POSTed might be, as examples, an annotation for existing resources; a message for a bulletin board, newsgroup, mailing list, or comment thread; a block of data that is the result of submitting a web form to a data-handling process; or an item to add to a database.[12]
  HTTPPOST,

  // Requests that the enclosed entity be stored under the supplied URI. If the URI refers to an already existing resource, it is modified; if the URI does not point to an existing resource, then the server can create the resource with that URI.[13]
  HTTPPUT,

  // Deletes the specified resource.
  HTTPDELETE,

  // Echoes back the received request so that a client can see what (if any) changes or additions have been made by intermediate servers.
  HTTPTRACE,

  // Returns the HTTP methods that the server supports for the specified URL. This can be used to check the functionality of a web server by requesting '*' instead of a specific resource.
  HTTPOPTIONS,

  // Converts the request connection to a transparent TCP/IP tunnel, usually to facilitate SSL-encrypted communication (HTTPS) through an unencrypted HTTP proxy.[14][15] See HTTP CONNECT Tunneling.
  HTTPCONNECT,

  // Is used to apply partial modifications to a resource.[
  HTTPPATCH
};

NS_INLINE HTTPMethod HTTPMethodFromString(NSString*s) {  s = s.uppercaseString;

  return [s rangeOfString:@"GET"]     .location != NSNotFound ? HTTPGET :
         [s rangeOfString:@"HEAD"]    .location != NSNotFound ? HTTPHEAD :
         [s rangeOfString:@"POST"]    .location != NSNotFound ? HTTPPOST :
         [s rangeOfString:@"PUT"]     .location != NSNotFound ? HTTPPUT :
         [s rangeOfString:@"DELETE"]  .location != NSNotFound ? HTTPDELETE :
         [s rangeOfString:@"TRACE"]   .location != NSNotFound ? HTTPTRACE :
         [s rangeOfString:@"OPTIONS"] .location != NSNotFound ? HTTPOPTIONS :
         [s rangeOfString:@"CONNECT"] .location != NSNotFound ? HTTPCONNECT : HTTPPATCH;
}

NS_INLINE NSString* StringFromHTTPMethod(HTTPMethod m) {  return

  m == HTTPGET      ? @"GET"      : m == HTTPHEAD     ? @"HEAD"       : m == HTTPPOST   ? @"POST" :
  m == HTTPPUT      ? @"PUT"      : m == HTTPDELETE   ? @"DELETE"     : m == HTTPTRACE  ? @"TRACE" :
  m == HTTPOPTIONS  ? @"OPTIONS"  : m ==HTTPCONNECT   ? @"CONNECT"                      : @"PATCH";
}


NS_INLINE NSString * StringWithTrailingSlash (NSString*s) {
  return [s hasSuffix:@"/"] ? s : [s stringByAppendingString:@"/"];
}
NS_INLINE NSUInteger RandomPort() { return arc4random_uniform(9000) + 3000; }


#define tIPv4 @"IPv4"
#define tIPv6 @"IPv6"
#define HTTP_BONJOUR_TYPE @"_http._tcp."


#define LEGAL @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

#define DOCUMENTS_FOLDER	[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define TMP_FOLDER        [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]



//#define RREQ RouteRequest
//#define RRES RouteResponse
//#define RREQRRESP RREQ *req, RRES *resp
#define GPS_LOG		@"gps.txt"
#define WIFI_LOG	@"wifi.txt"
#define GSM_LOG		@"gsm.txt"
#define	LOGS_LOG	@"logs.txt"
#define	POINTS_LOG	@"points.txt"
#define SCAN_TAG	999
#define SHARE_TAG	998
#define FINDME_TAG	997
#define INFO_TAG	996
#define LOGS_TAG	995
#define FTPSETTINGS_TAG	994

//+      (void)                notify:(NSString*)aMessage,...;

//#define CGRectZero	CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)

//#define SCAN_DELAY	7.0f


//+ (NSString*)        ipForInterface:(NSString*)iface;

//
//#define ALERT_UTILITY_TAG	2111
//#define OPTIONS_ALERT_TAG	5111
//#define    TEXT_ALERT_TAG		5112
//#define      LOG_VIEW_TAG		5113
#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>

@interface SpeedTester : NSObject

+ (void)     start:(NSString*)key;
+ (void)       lap:(NSString*)key WithComment:(NSString*)comment;
+ (void) lapAndEnd:(NSString*)key WithComment:(NSString*)comment;
+ (void) clearAll;

@end

