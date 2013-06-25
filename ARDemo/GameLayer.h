//
//  GameLayer.h
//  ARDemo
//
//  Created by jeans on 13-6-23.
//  Copyright floatpoint 2013年. All rights reserved.
//


#import <CoreMotion/CoreMotion.h>
#import <CoreFoundation/CoreFoundation.h>
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "EnemyShip.h"

// GameLayer
@interface GameLayer : CCLayer {
    CMMotionManager *motionManager;
//    CCLabelTTF *yawLabel;
//    CCLabelTTF *posIn360Label;
    CCLabelTTF *scoreLabel;
    int score;
    
    NSMutableArray *enemySprites;
    int enemyCount;
    CCSpriteBatchNode *batchNode;
    
    CCSprite *scope;
}

@property (nonatomic, retain) CMMotionManager *motionManager;
@property (readwrite) int enemyCount;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

- (EnemyShip *)addEnemyShip:(int)shipTag;
- (void)checkEnemyShipPosition:(EnemyShip *)enemyShip withYaw:(float)yawPostion;
-(void)updateEnemyShipPosition:(int)positionIn360 withEnemy:(EnemyShip *)enemyShip;
-(void)runStandardPositionCheck:(int)positionIn360 withDiff:(int)difference withEnemy:(EnemyShip *)enemyShip;

//判断玩家的开火区域是否击中了飞船
- (BOOL) circle:(CGPoint) circlePoint withRadius:(float) radius collisionWithCircle:(CGPoint) circlePointTwo collisionCircleRadius:(float) radiusTwo; 

@end
