//
//  NodeTooltipViewController.m
//  InternetMap
//
//  Created by Alexander on 21.12.12.
//  Copyright (c) 2012 Peer1. All rights reserved.
//

#import "NodeTooltipViewController.h"
#import "NodeWrapper.h"


@interface NodeTooltipViewController ()
@end

@implementation NodeTooltipViewController

- (id)initWithNode:(NodeWrapper*)node
{
    self = [super init];
    if (self) {
        self.node = node;
        self.contentSizeForViewInPopover = CGSizeMake(320, 44);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.contentSizeForViewInPopover.width-10, 26)];
    label.centerY = self.contentSizeForViewInPopover.height/2;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:22];
    if ([HelperMethods isStringEmptyOrNil:self.node.textDescription]) {
        label.text = [NSString stringWithFormat:@"AS%@", self.node.asn];
    }else {
        
        NSMutableString* textDescription = [self.node.textDescription mutableCopy];
        NSArray* components = [textDescription componentsSeparatedByString:@" "];
        if ([components count] > 1) {
            NSString* firstWord = components[0];
            if ([firstWord rangeOfString:@"-"].location != NSNotFound || [firstWord isEqualToString:components[1]]) {
                textDescription = [NSMutableString string];
                for (int i = 1; i<[components count]-1; i++) {
                    [textDescription appendFormat:@"%@ ", components[i]];
                }
                textDescription = [[textDescription capitalizedString] mutableCopy];
            }
        }
        
        label.text = textDescription;
    }
    [self.view addSubview:label];
}

@end
