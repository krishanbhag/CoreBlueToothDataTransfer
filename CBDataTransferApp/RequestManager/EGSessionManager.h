#import <AFNetworking/AFNetworking.h>


typedef void(^EGSessionManagerCompletionBlock)(NSURLResponse *response, id responseObject, NSError *error);
typedef void(^EGGeneralManagerCompletionBlock)(id responseObject, NSError *error);

@interface EGSessionManager : AFHTTPSessionManager {
    
}
+ (instancetype)sharedManager;
- (NSMutableURLRequest *)requestWithHTTPMethod:(NSString *)HTTPMethod URLPath:(NSString *)URLPath parameters:(id)parameters headers:(NSDictionary *)headers;
- (NSMutableURLRequest *)imageUploadRequestWithHTTPMethod:(NSString *)HTTPMethod URLPath:(NSString *)URLPath forImageUploadData:(NSData *)imageData headers:(NSDictionary *)headers;

- (BOOL)isNetworkAvailable;

@end
