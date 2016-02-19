//
//  ViewController.m
//  CybersourceSample
//
//  Created by hirauchi.shinichi on 2016/02/18.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonHMAC.h>


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

    NSString *API_KEY = @"{put your api key here}";
    NSString *SHARED_SECRET = @"{put your shared secret here}";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)tapButton:(id)sender {

    NSString *baseUri = @"cybersource/";
    NSString *resourcePath = @"payments/v1/authorizations";
    NSString *url = [NSString stringWithFormat:@"https://sandbox.api.visa.com/%@%@?apikey=%@",baseUri,resourcePath,API_KEY];
    NSString *body = @"{\"amount\": \"0\", \"currency\": \"USD\", \"payment\": { \"cardNumber\": \"4111111111111111\", \"cardExpirationMonth\": \"10\", \"cardExpirationYear\": \"2016\" }}";
    NSString *xPayToken = [self getXPayToken:resourcePath queryString:[NSString stringWithFormat:@"apikey=%@",API_KEY] requestBody:body];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    [request addValue:xPayToken forHTTPHeaderField: @"x-pay-token"];
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody];

    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest: request  completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (response && ! error) {
            NSString *responseString = [[NSString alloc] initWithData: data  encoding: NSUTF8StringEncoding];
            NSLog(responseString);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.textView.text = responseString;
            });

        }
        else {
            NSLog(@"ERROR: %@",error);
        }

    }] resume];
}

- (NSString *)getXPayToken:(NSString *)apiNameURI queryString:(NSString *)queryString requestBody:(NSString *)requestBody
{
    NSString *timestamp = [self getTimestamp];
    NSString *sourceString = [NSString stringWithFormat:@"%@%@%@%@%@",SHARED_SECRET,timestamp,apiNameURI,queryString,requestBody];;
    NSString *hash = [self getDigest:sourceString];
    NSString *token = [NSString stringWithFormat:@"x:%@:%@",timestamp,hash];
    return token;
}

- (NSString *)getTimestamp
{
    long timeStamp = (long)[[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat : @"%ld", timeStamp];
}

- (NSString *)getDigest:(NSString *)date
{
    NSData *d = [date dataUsingEncoding:NSASCIIStringEncoding];
    uint8_t bytes[64];
    CC_SHA256(d.bytes, d.length, bytes);
    NSMutableString* digest = [NSMutableString stringWithCapacity:64];
    for(int i = 0; i < 32; i++) {
        [digest appendFormat:@"%02x", bytes[i]];
    }
    return digest;
}

@end

