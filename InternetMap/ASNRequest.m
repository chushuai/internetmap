//
//  ASNRequest.m
//  InternetMap
//
//  Created by Alexander on 12.12.12.
//  Copyright (c) 2012 Peer1. All rights reserved.
//

#import "ASNRequest.h"
#import <dns_sd.h>
#import "ASIHTTPRequest.h"

@interface ASNRequest()

@property (nonatomic, readwrite) NSMutableArray* result;
@property (nonatomic, strong) ASNResponseBlock response;

- (void)finishedFetchingASN:(int)asn forIndex:(int)index;
- (void)failedFetchingASNForIndex:(int)index error:(NSString*)error;

@end

void callbackCurrent (
               DNSServiceRef sdRef,
               DNSServiceFlags flags,
               uint32_t interfaceIndex,
               DNSServiceErrorType errorCode,
               const char *fullname,
               uint16_t rrtype,
               uint16_t rrclass,
               uint16_t rdlen,
               const void *rdata,
               uint32_t ttl,
               void *context ) {
    
    NSData* data = [NSData dataWithBytes:rdata length:strlen(rdata)+1];
    NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    int value;
    NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    BOOL success = [[NSScanner scannerWithString:[string stringByTrimmingCharactersInSet:nonDigits]] scanInteger:&value];
    
    NSDictionary* dict = (__bridge NSDictionary*)context;
    
    ASNRequest* request = [dict objectForKey:@"request"];
    int index = [[dict objectForKey:@"index"] intValue];
    
    if (success) {
        [request finishedFetchingASN:value forIndex:index];
    }
    else {
        [request failedFetchingASNForIndex:index error: @"Couldn't resolve DNS."];
    }
}


@implementation ASNRequest

-(BOOL)isInvalidOrPrivate:(NSString*)ipAddress {
    NSArray* components = [ipAddress componentsSeparatedByString:@"."];
    
    if(components.count != 4) {
        return TRUE;
    }
    
    int a = [components[0] intValue];
    int b = [components[1] intValue];
    
    if (a == 10) {
        return TRUE;
    }
    
    if((a == 172) && ((b >= 16) && (b <= 31))) {
        return TRUE;
    }
    
    if((a == 192) && (b == 168)) {
        return TRUE;
    }
    
    return FALSE;
}

- (void)startFetchingASNsForIPs:(NSArray*)theIPs{
    self.result = [NSMutableArray arrayWithCapacity:theIPs.count];
    
    for (int i = 0; i < theIPs.count; i++) {
        [self.result addObject:[NSNull null]];
    }
    
    [[SCDispatchQueue defaultPriorityQueue] dispatchAsync:^{
        for (int i = 0; i < [theIPs count]; i++) {
            NSString* ip = [theIPs objectAtIndex:i];
            if (!ip || [self isInvalidOrPrivate:ip]) {
                [self failedFetchingASNForIndex:i error:@"Couldn't resolve DNS."];
            }else {
                [self fetchASNForIP:ip index:i];
            }
        }
        
        if (self.response) {
            [[SCDispatchQueue mainQueue] dispatchAsync:^{
                self.response(self.result);
            }];
        }
    }];

}

- (void)fetchASNForIP:(NSString*)ip index:(int)index{
    NSArray* ipComponents = [ip componentsSeparatedByString:@"."];
    NSString* dnsString = [NSString stringWithFormat:@"origin.asn.cymru.com"];
    for (NSString* component in ipComponents) {
        dnsString = [NSString stringWithFormat:@"%@.%@", component, dnsString];
    }
    DNSServiceRef sdRef;
    DNSServiceErrorType res;
    
    NSDictionary* context = @{@"request" : self, @"index" : [NSNumber numberWithInt:index]};
    
    res = DNSServiceQueryRecord(
                                &sdRef, 0, 0,
                                [dnsString cStringUsingEncoding:NSUTF8StringEncoding],
                                kDNSServiceType_TXT,
                                kDNSServiceClass_IN,
                                callbackCurrent,
                                (__bridge void *)context
                                );
    
    if (res != kDNSServiceErr_NoError) {
        [self failedFetchingASNForIndex:index error:@"Couldn't resolve DNS."];
    }
    
    DNSServiceProcessResult(sdRef);
    /*
     // trying to use select, so we have a timeout, just calling DNSServiceProcessREsult
     // can block forever, but doesn't work
    int dns_sd_fd = DNSServiceRefSockFD(sdRef);
    fd_set readfds;
    struct timeval tv;
    
    FD_ZERO(&readfds);
    FD_SET(dns_sd_fd, &readfds);
    tv.tv_sec = 10;
    tv.tv_usec = 0;
    int result = select(1, &readfds, (fd_set*)NULL, (fd_set*)NULL, &tv);
    if ((result > 0) && FD_ISSET(dns_sd_fd, &readfds)) {
         DNSServiceProcessResult(sdRef);
    }
    else {
        [self failedFetchingASNForIndex:index error:@"Couldn't resolve DNS."];
    }
     */
    
    DNSServiceRefDeallocate(sdRef);
}

- (void)finishedFetchingASN:(int)asn forIndex:(int)index {
    NSLog(@"ASN fetched for index %i: %i", index, asn);
    [self.result replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:asn]];
}

- (void)failedFetchingASNForIndex:(int)index error:(NSString*)error {
    NSLog(@"Failed for index: %i, error: %@", index, error);
}

+(void)fetchForAddresses:(NSArray*)addresses responseBlock:(ASNResponseBlock)response {
    ASNRequest* request = [ASNRequest new];
    request.response = response;
    [request startFetchingASNsForIPs:addresses];
}

+(void)fetchForASN:(int)asn responseBlock:(ASNResponseBlock)response {
    __weak ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://bgp.he.net/AS%i", asn]]];
    [request setCompletionBlock:^{
        NSRange range = [[request responseString] rangeOfString:@"/net/.*?/" options:NSRegularExpressionSearch];
        if(range.location != NSNotFound) {
            NSString* string = [[request responseString] substringWithRange:NSMakeRange(range.location+5, range.length-6)];
            response(@[string]);
        }else {
            response(@[[NSNull null]]);
        }

    }];
    [request startAsynchronous];
}

@end