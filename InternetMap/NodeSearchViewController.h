//
//  NodeSearchViewController.h
//  InternetMap
//
//  Created by Angelina Fabbro on 12-12-03.
//  Copyright (c) 2012 Peer1. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Node;

@protocol NodeSearchDelegate

-(void)nodeSearchDelegateDone;
-(void)nodeSelected:(Node*)node;
-(void)selectNodeByHostLookup:(NSString*)host;

@end

@interface NodeSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) id delegate;
@property (copy, nonatomic) NSMutableArray* allItems;
@property (strong, nonatomic) UITableView* tableView;

@end
