//
//  HelloWorldLayer.m
//  MotionSnake
//
//  Created by Acsa Lu on 4/30/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "AppDelegate.h"

#define MAX_COLS 10
#define MAX_ROWS 13
#define GRID_SIZE 30
#define BASE_UPDATE_INTERVAL 0.2
#define SNAKE_TAG_BASE 1000

#pragma mark - HelloWorldLayer

@implementation HelloWorldLayer

+ (CCScene *)scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	
	return scene;
}

- (id)init
{
	if( (self=[super initWithColor:ccc4(255, 255, 255, 255)]) ) {
        zOrder_ = -10;
        CGSize size = [[CCDirector sharedDirector] winSize];
        _label = [CCLabelTTF labelWithString:@"Hello World!" fontName:@"Helvetica" fontSize:20];
        
        _label.position = ccp(size.width / 2, size.height - 40);
        _label.color = ccc3(0, 0, 0);
        CCLOG(@"(w, h) = (%.0f, %.0f)", size.width, size.height);
        
        [self addChild:_label];
        
        _snakeHead = [CCSprite spriteWithFile:@"snake-head.png"];
        [self addChild:_snakeHead];
        _snakeHead.zOrder = 10;
        
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
        
        CGPoint vertices[4];
        vertices[0] = ccp(startX, startY);
        vertices[1] = ccp(startX + MAX_COLS * GRID_SIZE, startY);
        vertices[2] = ccp(startX + MAX_COLS * GRID_SIZE, startY - MAX_ROWS * GRID_SIZE);
        vertices[3] = ccp(startX, startY - MAX_ROWS * GRID_SIZE);
        
        ccDrawPoly(vertices, 4, YES);
        
        _currentCol = 5;
        _currentRow = 5;
        [self updateSnakePosition];
        
        _currentSpeed = 1;
        _currentDirection = UP;
        
        _snake = [NSMutableArray array];
        [_snake addObject:@[@(_currentRow), @(_currentCol)]];
        
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 30.0 / 60.0;
        
        if (_motionManager.isDeviceMotionAvailable)
            [_motionManager startDeviceMotionUpdates];
        
        [self schedule:@selector(update:) interval:BASE_UPDATE_INTERVAL / _currentSpeed repeat:kCCRepeatForever delay:0.0f];
        
        _target = [CCSprite spriteWithFile:@"target.png"];
        [self addChild:_target];
        
        [self genTarget];
	}
	return self;
}

- (void)setCurrentDirection:(Direction)currentDirection
{
    if (currentDirection != _currentDirection) {
        switch (currentDirection) {
            case UP:
                _snakeHead.rotation = 0;
                break;
            case DOWN:
                _snakeHead.rotation = 180;
                break;
            case RIGHT:
                _snakeHead.rotation = 90;
                break;
            case LEFT:
                _snakeHead.rotation = -90;
        }
        
        _currentDirection = currentDirection;
    }
}

- (void)genTarget
{
    int row, col;
    while (true) {
        row = arc4random() % MAX_ROWS;
        col = arc4random() % MAX_COLS;
        BOOL isOccupied = NO;
        
        for (NSArray *part in _snake) {
            int thisRow = [part[0] integerValue];
            int thisCol = [part[1] integerValue];
            if (row == thisRow && col == thisCol) {
                isOccupied = YES;
                break;
            }
        }
        if (!isOccupied) break;
    }
    CCLOG(@"put target on (%d, %d)", row, col);
    _targetCol = col;
    _targetRow = row;
    _target.position = [((NSValue *) _map[_targetRow][_targetCol]) CGPointValue];
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
    
    if (abs(_volecityX) > abs(_volecityY)) {
        if (_volecityX > 0) self.currentDirection = RIGHT;
        else self.currentDirection = LEFT;
    } else {
        if (_volecityY > 0) self.currentDirection = UP;
        else self.currentDirection = DOWN;
    }

    [self updateSnakePosition];
    [self checkTargetYummy];
}

- (void)updateSnakePosition
{
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
    CGPoint position = [((NSValue *) _map[_currentRow][_currentCol]) CGPointValue];
//    CCLOG(@"update snake position to (%d, %d)", _currentRow, _currentCol);
    
    for (int i = _snake.count - 1; i > 0; --i)
        _snake[i] = _snake[i - 1];
    _snake[0] = @[@(_currentRow), @(_currentCol)];
    _snakeHead.position = position;
    [self reformSnake];
}

- (void)reformSnake
{

    if (_snake.count > 1) {
        for (int i = 1; i < _snake.count; ++i) {
            CCSprite *body = (CCSprite *) [self getChildByTag:SNAKE_TAG_BASE + i];
            body.position = [self pointWithRow:[_snake[i][0] integerValue] andCol:[_snake[i][1] integerValue]];
        }
    }
}

- (void)checkTargetYummy
{
    if (_targetCol == _currentCol && _targetRow == _currentRow) {
        CCLOG(@"Yummy!");
        [self genTarget];
        switch (_currentDirection) {
            case UP:
                [_snake addObject:@[@(_currentRow + 1), @(_currentCol)]];
                break;
            case DOWN:
                [_snake addObject:@[@(_currentRow - 1), @(_currentCol)]];
                break;
            case LEFT:
                [_snake addObject:@[@(_currentRow), @(_currentCol + 1)]];
                break;
            case RIGHT:
                [_snake addObject:@[@(_currentRow), @(_currentCol - 1)]];
        }
        NSLog(@"last body:(%@, %@)", _snake[_snake.count - 1][0], _snake[_snake.count - 1][1]);
        CCSprite *body = [CCSprite spriteWithFile:@"snake-body.png"];
        body.tag = SNAKE_TAG_BASE + _snake.count;
        [self addChild:body];
        [self reformSnake];
    }
}

- (CGPoint)pointWithRow:(int)row andCol:(int)col
{
    return [((NSValue *) _map[row][col]) CGPointValue];
}



@end
