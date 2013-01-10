//
//  DefaultVisualization.m
//  InternetMap
//

#import "DefaultVisualization.h"
#import "MapDisplay.h"
#import "Node.h"
#import "Lines.hpp"
#import "Connection.h"
#import "Nodes.hpp"

// Temp conversion function while note everything is converted TODO: remove

static Point3 GLKVec3ToPoint(const GLKVector3& in) {
    return Point3(in.x, in.y, in.z);
};

static Colour UIColorToColour(UIColor* color) {
    float r;
    float g;
    float b;
    float a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return Colour(r, g, b, a);
}


@implementation DefaultVisualization

-(GLKVector3)nodePosition:(Node*)node {
    return GLKVector3Make(log10f(node.importance) + 2.0f, node.positionX, node.positionY);
}

-(float)nodeSize:(Node*)node {
    return 0.005 + 0.70*powf(node.importance, .75);

}



-(void)updateDisplay:(MapDisplay*)display forNodes:(NSArray*)arrNodes {    
    //    UIColor* nodeColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
//    UIColor* t1Color = UIColorFromRGB(0x36a3e6);
//    UIColor* t2Color = UIColorFromRGB(0x2246a7);
//    UIColor* unknownColor = UIColorFromRGB(0x8e44bd);
//    UIColor* compColor = UIColorFromRGB(0x4490ce);
//    UIColor* eduColor = UIColorFromRGB(0xecb7fd);
//    UIColor* ixColor = UIColorFromRGB(0xb7fddc);
//    UIColor* nicColor = UIColorFromRGB(0xb0a2d3);
    
    UIColor* t1Color = UIColorFromRGB(0x548dff); // Changed to blue in style guide
    UIColor* t2Color = UIColorFromRGB(0x375ca6); // Slightly darker blue than in style guide
    UIColor* unknownColor = UIColorFromRGB(0x7ce346); // slightly brighter green than style guide
    UIColor* compColor = UIColorFromRGB(0x4490ce); //some other blue
    UIColor* eduColor = UIColorFromRGB(0x7200ff); //purpley
    UIColor* ixColor = UIColorFromRGB(0x75787b); //slate 
    UIColor* nicColor = UIColorFromRGB(0xffffff); //white, obvs



    
    display.nodes->beginUpdate();
    
    for(int i = 0; i < arrNodes.count; i++) {
        Node* node = arrNodes[i];
        
        UIColor* color;
        switch(node.type) {
            case AS_T1:
                color = t1Color;
                break;
            case AS_T2:
                color = t2Color;
                break;
            case AS_COMP:
                color = compColor;
                break;
            case AS_EDU:
                color = eduColor;
                break;
            case AS_IX:
                color = ixColor;
                break;
            case AS_NIC:
                color = nicColor;
                break;
            default:
                color = unknownColor;
                break;
        }
        
        display.nodes->updateNode(node.index, GLKVec3ToPoint([self nodePosition:node]), [self nodeSize:node], UIColorToColour(color)); // use index from node, not in array, so that partiual updates can work
        
    }
    
    display.nodes->endUpdate();
    
}

-(void)updateDisplay:(MapDisplay*)display forSelectedNodes:(NSArray*)arrNodes {
    display.selectedNodes->beginUpdate();
    for(int i = 0; i < arrNodes.count; i++) {
        Node* node = arrNodes[i];
        
        display.selectedNodes->updateNode(i, GLKVec3ToPoint([self nodePosition:node]), [self nodeSize:node], UIColorToColour(SELECTED_NODE_COLOR));
        
    }
    display.selectedNodes->endUpdate();
    
}

- (void)resetDisplay:(MapDisplay*)display forNodes:(NSArray*)arrNodes {
    if (display.nodes) {
        //TODO: get assert back
//        NSAssert(display.nodes->count == [arrNodes count], @"Display.nodes has already been allocated and you just tried to recreate it with a different count");
    }else {
        std::shared_ptr<Nodes> nodes(new Nodes([arrNodes count]));
        display.nodes = nodes;
    }

    
    [self updateDisplay:display forNodes:arrNodes];
}

- (void)resetDisplay:(MapDisplay *)display forSelectedNodes:(NSArray*)arrNodes {
    if (display.selectedNodes) {
        //TODO: get assert back
//        NSAssert([display.selectedNodes count] == [arrNodes count], @"Display.selectedNodes has already been allocated and you just tried to recreate it with a different count");
    }else {
        std::shared_ptr<Nodes> nodes(new Nodes([arrNodes count]));
        display.selectedNodes = nodes;
    }
    
    [self updateDisplay:display forSelectedNodes:arrNodes];
}

-(void)updateLineDisplay:(MapDisplay*)display forConnections:(NSArray*)connections {
    NSMutableArray* filteredConnections = [NSMutableArray new];
    
    // We are only drawing lines to nodes with > 0.01 importance, filter those out
    for(Connection* connection in connections) {
        if((connection.first.importance > 0.01) && (connection.second.importance > 0.01)) {
            [filteredConnections addObject:connection];
        }
    }
    
    int skipLines = 10;
    
    std::shared_ptr<Lines> lines(new Lines(filteredConnections.count / skipLines));
    
    lines->beginUpdate();
    
    int currentIndex = 0;
    int count = 0;
    for(Connection* connection in filteredConnections) {
        count++;
        
        if((count % skipLines) != 0) {
            continue;
        }
        
        Node* a = connection.first;
        Node* b = connection.second;
        
        float lineImportanceA = MAX(a.importance - 0.01f, 0.0f) * 1.5f;
        Colour lineColorA = Colour(lineImportanceA, lineImportanceA, lineImportanceA, 1.0);
        
        float lineImportanceB = MAX(b.importance - 0.01f, 0.0f) * 1.5f;
        Colour lineColorB = Colour(lineImportanceB, lineImportanceB, lineImportanceB, 1.0);
        
        lines->updateLine(currentIndex, GLKVec3ToPoint([self nodePosition:a]), lineColorA, GLKVec3ToPoint([self nodePosition:b]), lineColorB);
        currentIndex++;
    }
    
    lines->endUpdate();;
    
    display.visualizationLines = lines;
}

@end
