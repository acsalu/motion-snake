//
//  HelloWorldLayer.m
//  MotionSnake
//
//  Created by Acsa Lu on 4/30/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "AppDelegate.h"

#define MAX_COLS 11
#define MAX_ROWS 10
#define GRID_SIZE 40

#pragma mark - HelloWorldLayer

@implementation HelloWorldLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init
{
	if( (self=[super init]) ) {
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        _label = [CCLabelTTF labelWithString:@"Hello World!" fontName:@"Marker Felt" fontSize:20];
        _label.position = ccp(size.width / 2, size.height - 40);
        
        [self addChild:_label];
        
        _ball = [CCSprite spriteWithFile:@"Icon.png"];
        [self addChild:_ball];
        
        _volecityX = 0.0f;
        _volecityY = 0.0f;
        
        
        CGFloat startX = 20;
        CGFloat startY = size.height - 80;
        _map = [NSMutableArray arrayWithCapacity:MAX_ROWS];
        for (int i = 0; i < MAX_ROWS; ++i) {
            _map[i] = [NSMutableArray arrayWithCapacity:MAX_COLS];
            for (int j = 0; j < MAX_COLS; ++j) {
                _map[i][j] = [NSValue valueWithCGPoint:ccp(startX + j * GRID_SIZE, startY - i * GRID_SIZE)];
            }
        }
        
        _currentCol = 5;
        _currentRow = 5;
        [self updateSnakePosition];
        
        _currentSpeed = 1;
        _currentDirection = UP;
        
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 30.0 / 60.0;
        
        if (_motionManager.isDeviceMotionAvailable)
            [_motionManager startDeviceMotionUpdates];
        
        [self schedule:@selector(update:) interval:0.5f repeat:kCCRepeatForever delay:0.0f];
	}
	return self;
}


- (void)update:(ccTime)delta
{
    CMDeviceMotion *currentDeviceMotion = _motionManager.deviceMotion;
    CMAttitude *currentAttitude = currentDeviceMotion.attitude;
    
    float roll = currentAttitude.roll;
    float pitch = currentAttitude.pitch;
    float yaw = currentAttitude.yaw;
    
    [_label setString:[NSString stringWithFormat:@"roll:%.2f  pitch:%.2f  yaw:%.2f",
                       CC_RADIANS_TO_DEGREES(roll), CC_RADIANS_TO_DEGREES(pitch), CC_RADIANS_TO_DEGREES(yaw)]];

    
    _volecityX = CC_RADIANS_TO_DEGREES(roll) * 20;
    _volecityY = - CC_RADIANS_TO_DEGREES(pitch) * 20;
    
    
//
//    CGSize size = [[CCDirector sharedDirector] winSize];
//    
//    CGFloat newX = _ball.position.x + _volecityX * delta;
//    CGFloat newY = _ball.position.y + _volecityY * delta;
//    
//    if (newX > size.width) newX = size.width;
//    else if (newX < 0) newX = 0;
//    
//    if (newY > size.height) newY = size.height;
//    else if (newY < 0) newY = 0;
//    
//    
//    _ball.position = ccp(newX, newY);
    if (abs(_volecityX) > abs(_volecityY)) {
        if (_volecityX > 0) _currentDirection = RIGHT;
        else _currentDirection = LEFT;
    } else {
        if (_volecityY > 0) _currentDirection = UP;
        else _currentDirection = DOWN;
    }
    
    switch (_currentDirection) {
        case UP:
            if (_currentRow > 0) --_currentRow;
            break;
        case DOWN:
            if (_currentRow < MAX_ROWS - 1) ++ _currentRow;
            break;
        case LEFT:
            if (_currentCol > 0) --_currentCol;
            break;
        case RIGHT:
            if (_currentCol < MAX_COLS - 1) ++_currentCol;
            break;
    }
    [self updateSnakePosition];
}

- (void)updateSnakePosition
{
    CGPoint position = [((NSValue *) _map[_currentRow][_currentCol]) CGPointValue];
    CCLOG(@"update snake position to (%.0f, %.0f)", position.x, position.y);
    _ball.position = position;
}


@end
