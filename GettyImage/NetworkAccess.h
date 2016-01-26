//
//  NetworkAccess.h
//  GettyImage
//
//  Created by Justin Lee on 1/26/16.
//  Copyright © 2016 Justin Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface NetworkAccess : NSObject

+ (void) accessServer:(NSString *)acronym success:(void (^)(NSURLSessionTask *task, NSArray * responseObject))success failure:(void (^)(NSURLSessionTask *operation, NSError *error))failure;

@end
