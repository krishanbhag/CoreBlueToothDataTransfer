#import "EGSessionManager.h"

@implementation EGSessionManager

+ (instancetype)sharedManager
{
    static EGSessionManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self manager];
        
    });
    
    return sharedManager;
}

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    if (!(self = [super initWithBaseURL:nil sessionConfiguration:configuration]))
    {
        return nil;
    }
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    return self;
}

- (void)dealloc
{
}

- (NSURL *)baseURL
{
    return [NSURL URLWithString:@""];

}


- (NSMutableURLRequest *)requestWithHTTPMethod:(NSString *)HTTPMethod URLPath:(NSString *)URLPath parameters:(id)parameters headers:(NSDictionary *)headers
{
    NSString *URLString = [[self.baseURL URLByAppendingPathComponent:URLPath ?: @""] absoluteString];
    NSLog(@"\n Request URL:%@ \nParameters : %@ \n headers:%@",URLPath,[parameters description],[headers description]);

    NSMutableURLRequest *request = [[self.requestSerializer requestWithMethod:HTTPMethod URLString:URLString parameters:parameters error:nil] mutableCopy];
    request.timeoutInterval = 10;
//    [request setValue:[NSString stringWithFormat:@"Bearer %@", [Utility requestToken]] forHTTPHeaderField:@"Authorization"];
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    return request;
}
- (NSMutableURLRequest *)imageUploadRequestWithHTTPMethod:(NSString *)HTTPMethod URLPath:(NSString *)URLPath forImageUploadData:(NSData *)imageData headers:(NSDictionary *)headers
{
    NSString *URLString = [[self.baseURL URLByAppendingPathComponent:URLPath ?: @""] absoluteString];
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:HTTPMethod URLString:URLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"file.png" mimeType:@"image/jpeg"];
        
    } error:nil];
    request.timeoutInterval = 10;
//    [request setValue:[NSString stringWithFormat:@"Bearer %@", [Utility requestToken]] forHTTPHeaderField:@"Authorization"];
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    return request;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{    
    return [super dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        NSLog(@"\n Request URL:%@ \n%@ \n Error:%@",[request.URL absoluteString],responseObject,error);
        
        if (error)
        {
            [self.responseSerializer validateResponse:(NSHTTPURLResponse *)response data:responseObject error:&error];
        }
        if (completionHandler)
        {
            completionHandler(response, responseObject, error);
        }
    }];
}
- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request
                                                 progress:(NSProgress * __autoreleasing *)progress
                                        completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {


    return [super uploadTaskWithStreamedRequest:request progress:progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        NSLog(@"\n Request URL:%@ \n%@ \n Error:%@",[request.URL absoluteString],responseObject,error);
        
        if (error)
        {
            [self.responseSerializer validateResponse:(NSHTTPURLResponse *)response data:responseObject error:&error];
        }
        if (completionHandler)
        {
            completionHandler(response, responseObject, error);
        }

        
    }];
}

- (BOOL)isNetworkAvailable {
  return [AFNetworkReachabilityManager sharedManager].reachable;
}

@end
