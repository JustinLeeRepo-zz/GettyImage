//
//  NetworkAccess.m
//  GettyImage
//
//  Created by Justin Lee on 1/26/16.
//  Copyright © 2016 Justin Lee. All rights reserved.
//

#import "NetworkAccess.h"

@interface NetworkAccess()

@end

@implementation NetworkAccess

+ (void) accessServer:(NSString *)search success:(void (^)(NSURLSessionTask *task, NSArray * responseObject))success failure:(void (^)(NSURLSessionTask *operation, NSError *error))failure
{
	NSString *baseUrl = @"https://api.gettyimages.com/v3/search/images?fields=id,title,thumb,comp,preview,referral_destinations&sort_order=best&phrase=";
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@", baseUrl, search];
	
	AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//	manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
	manager.responseSerializer = [AFJSONResponseSerializer serializer];
	manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
	[manager.requestSerializer setValue:@"yy7dmvpg6jeutfhntdk8ywrp" forHTTPHeaderField:@"Api-Key"];
//	NSDictionary *parameters = @{@"Api-Key":@"yy7dmvpg6jeutfhntdk8ywrp"};
	[manager GET:urlString parameters:nil progress:nil success:success failure:failure];
}



@end
