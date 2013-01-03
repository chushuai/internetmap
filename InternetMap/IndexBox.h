//
//  IndexBox.h
//  InternetMap
//
//  Created by Alexander on 11.12.12.
//  Copyright (c) 2012 Peer1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

static const float IndexBoxMinX = -8;
static const float IndexBoxMaxX = 8;
static const float IndexBoxMinY = -2;
static const float IndexBoxMaxY = 2;
static const float IndexBoxMinZ = -2;
static const float IndexBoxMaxZ = 2;
static const float lengthX = -IndexBoxMinX + IndexBoxMaxX;
static const float lengthY = -IndexBoxMinY + IndexBoxMaxY;
static const float lengthZ = -IndexBoxMinZ + IndexBoxMaxZ;

static const int numberOfCellsX = 32;
static const int numberOfCellsY = 4;
static const int numberOfCellsZ = 4;
static const float boxSizeXWithoutOverlap = lengthX/numberOfCellsX;
static const float boxSizeYWithoutOverlap = lengthY/numberOfCellsY;
static const float boxSizeZWithoutOverlap = lengthZ/numberOfCellsZ;

@interface IndexBox : NSObject {
    GLKVector3 parameters[2];
}

    @property (nonatomic, assign) GLKVector3 center;
    @property (nonatomic, assign) GLKVector3 minCorner;
    @property (nonatomic, assign) GLKVector3 maxCorner;
    @property (nonatomic, strong) NSMutableIndexSet* indices;

- (BOOL)isPointInside:(GLKVector3)point;
- (BOOL)doesLineIntersectOptimized:(GLKVector3)origin invertedDirection:(GLKVector3)invertedDirection sign:(int *)sign;

@end
