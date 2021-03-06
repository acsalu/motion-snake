//
//  HelloWorldLayer.h
//  MotionSnake
//
//  Created by Acsa Lu on 4/30/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>
#import <CoreMotion/CoreMotion.h>
#import "cocos2d.h"

typedef int Speed;

enum Direction {
    UP = 0, RIGHT, DOWN, LEFT
};
typedef enum Direction Direction;


@interface HelloWorldLayer : CCLayerColor

+(CCScene *) scene;

@property (nonatomic, strong) CCLabelTTF *label;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CCSprite *snakeHead;
@property (nonatomic) float volecityX;
@property (nonatomic) float volecityY;
@property (nonatomic) NSMutableArray *map;
@property (nonatomic) Speed currentSpeed;
@property (nonatomic) Direction currentDirection;
@property (nonatomic) int currentRow;
@property (nonatomic) int currentCol;

@property (nonatomic, strong) NSMutableArray *snake;
@property (nonatomic, strong) CCSprite *target;
@property (nonatomic) int targetRow;
@property (nonatomic) int targetCol;

@end
