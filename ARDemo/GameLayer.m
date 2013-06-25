//
//  GameLayer.m
//  ARDemo
//
//  Created by jeans on 13-6-23.
//  Copyright floatpoint 2013年. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#include <stdlib.h>
#import "SimpleAudioEngine.h"

#pragma mark - GameLayer

// GameLayer implementation
@implementation GameLayer

@synthesize motionManager;
@synthesize enemyCount;
#define kXPositionMultiplier 15
#define kTimeToLive 100



// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        NSLog(@"size:%fX%f", size.width, size.height);
	
//		yawLabel = [CCLabelTTF labelWithString:@"Yaw:" fontName:@"Marker Felt" fontSize:12];
//        posIn360Label = [CCLabelTTF labelWithString:@"360Pos:" fontName:@"Marker Felt" fontSize:12];
//		yawLabel.position = ccp(50, 240);
//        posIn360Label.position = ccp(50, 300);
//        [self addChild:yawLabel];
//        [self addChild:posIn360Label];
        score = 0;
        scoreLabel = [CCLabelTTF labelWithString:@"分数:0" fontName:@"Marker Felt" fontSize:24];
        scoreLabel.position = ccp(50, 300);
        [self addChild:scoreLabel];

		
		//启动陀螺仪
        self.motionManager = [[[CMMotionManager alloc] init] autorelease];
        //更新间隔设置为每秒60次
        motionManager.deviceMotionUpdateInterval = 1.0/60.0;
        if (motionManager.isDeviceMotionAvailable) {
            [motionManager startDeviceMotionUpdates];
        }
        
        
        //scope = [CCSprite spriteWithFile:@"scope.png" rect:CGRectMake(240, 160, 75, 75)];
        scope = [CCSprite spriteWithFile:@"scope.png"];
        scope.position = ccp(240, 160);
        [self addChild:scope z:15];
        //[self registerWithTouchDispatcher];
        [self setTouchEnabled:YES];
        self.touchMode = kCCTouchesOneByOne;
        // 把标准的touch打开
        //self.isTouchEnabled = YES;
        // 注册cocos2d特有的事件方法
        //[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
//        [[[CCDirector sharedDirector] touchDispatcher] addStandardDelegate:self priority:0];
//        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
        
        
        [self scheduleUpdate];
        
        batchNode = [CCSpriteBatchNode batchNodeWithFile:@"Sprites.pvr.ccz"];
        [self addChild:batchNode];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Sprites.plist"];

        
        enemySprites = [[NSMutableArray alloc] init];
        for(int i = 0; i < 50; ++i) {
            EnemyShip *enemyShip = [self addEnemyShip:i];
            [enemySprites addObject:enemyShip];
            enemyCount += 1;
        }
        
        //背景音乐
        //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"SpaceGame.caf" loop:YES];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"explosion_large.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"laser_ship.caf"];
        
      
	}
	return self;
}

-(void)update:(ccTime)delta {
    CMDeviceMotion *currentDeviceMotion = motionManager.deviceMotion;
    CMAttitude *currentAttitude = currentDeviceMotion.attitude;
    
    //Yaw值代表往左或往右移动。motion manager获取的值是弧度。我们需要使用内置的函数CC_RADIANS_TO_DEGREES来把弧度转换成角度
    float yaw = roundf((float)(CC_RADIANS_TO_DEGREES(currentAttitude.yaw)));
//    [yawLabel setString:[NSString stringWithFormat:@"Yaw:%.0f", yaw]];
    
    //如果yaw值是正的，那么我们什么也不做。如果是负的，那么就减去360.（加上一个负值和减去一个正值是一样的）
    int positionIn360 = yaw;
    if (positionIn360 < 0) {
        positionIn360 = 360 + positionIn360;
    }
//    [posIn360Label setString:[NSString stringWithFormat:@"360Pos:%d", positionIn360]];
    
    for (EnemyShip *enemyShip in enemySprites) {
        [self checkEnemyShipPosition:enemyShip withYaw:yaw];
    }
    
    //添加一些基本的AI吧,随着时间的推移，我们会改变一下飞船的位置
    for (EnemyShip *enemyShip in enemySprites) {
        enemyShip.timeToLive--;
        if (enemyShip.timeToLive == 0) {
            int x = arc4random() % 360;
            int y = arc4random() % 160;
            [enemyShip setPosition:ccp(5000, y)];
            enemyShip.yawPosition = x;
            enemyShip.timeToLive = kTimeToLive;
        }
    }
}

//创建新的敌人太空飞船
//接收一个整数值作为tag，并且返回一个EnemyShip CCSprite。下面一行代码，我们从精灵表单中创建一个EnemyShip精灵。接着，我们使用arc4random方法来得到一个0~360的随机 数。最后，我们设置了飞船的位置，并把timeToLive的值设置为100，把飞船添加到batchNode里面，最后返回飞船精灵对象
- (EnemyShip *)addEnemyShip:(int)shipTag {
    //随机选择飞船图片
    NSArray *sheets = @[@"enemy_spaceship.png",@"SpaceFlier_lg_1.png",@"SpaceFlier_lg_2.png",@"SpaceFlier_med_1.png",@"SpaceFlier_sm_1.png",@"SpaceFlier_sm_2.png",@"powerup.png"];
    int index = arc4random() % sheets.count;
    EnemyShip *enemyShip = [EnemyShip spriteWithSpriteFrameName:[sheets objectAtIndex:index]];
    
    int x = arc4random() % 360;
    enemyShip.yawPosition = x;
    
   // int y = arc4random() % 320;
    
    //设置在屏幕外面
    [enemyShip setPosition:ccp(3000, 160)];
    enemyShip.timeToLive = kTimeToLive;
    enemyShip.visible = true;
    
    [batchNode addChild:enemyShip z:3 tag:shipTag];
    return enemyShip;
}

- (void)checkEnemyShipPosition:(EnemyShip *)enemyShip withYaw:(float)yawPostion {
    //检查设置的yaw坐标址（positionIn360)，然后把此值限制在0~360之间
    int positionIn360 = yawPostion;
    if (positionIn360 < 0) {
        positionIn360 = 360 + positionIn360;
    }
    
    //两端范围都是0~360，所以需要检查一下设置的positionIn360具体属于哪一端。我们使用一个任意数23来代表将在屏幕一半处显示的度数。
    BOOL checkAlternateRange = false;
    int rangeMin = positionIn360 - 23;
    if (rangeMin < 0) {
        rangeMin = 360 + rangeMin;
        checkAlternateRange = true;
    }
    
    int rangeMax = positionIn360 + 23;
    if (rangeMax > 360) {
        rangeMax = rangeMax - 360;
        checkAlternateRange = true;
    }
    
    if (checkAlternateRange) {
        if ((enemyShip.yawPosition < rangeMax || enemyShip.yawPosition > rangeMin ) || (enemyShip.yawPosition > rangeMin || enemyShip.yawPosition < rangeMax)) {
            [self updateEnemyShipPosition:positionIn360 withEnemy:enemyShip];
        }
    } else {
        if (enemyShip.yawPosition > rangeMin && enemyShip.yawPosition < rangeMax) {
            [self updateEnemyShipPosition:positionIn360 withEnemy:enemyShip];
        }
    }
}


-(void)updateEnemyShipPosition:(int)positionIn360 withEnemy:(EnemyShip *)enemyShip {
    int difference = 0;
    if (positionIn360 < 23) {
        // Run 1
        if (enemyShip.yawPosition > 337) {
            difference = (360 - enemyShip.yawPosition) + positionIn360;
            int xPosition = 240 + (difference * kXPositionMultiplier);
            [enemyShip setPosition:ccp(xPosition, enemyShip.position.y)];
        } else {
            // Run Standard Position Check
            [self runStandardPositionCheck:positionIn360 withDiff:difference withEnemy:enemyShip];
        }
    } else if(positionIn360 > 337) {
        // Run 2
        if (enemyShip.yawPosition < 23) {
            difference = enemyShip.yawPosition + (360 - positionIn360);
            int xPosition = 240 - (difference * kXPositionMultiplier);
            [enemyShip setPosition:ccp(xPosition, enemyShip.position.y)];
        } else {
            // Run Standard Position Check
            [self runStandardPositionCheck:positionIn360 withDiff:difference withEnemy:enemyShip];
        }
    } else {
        // Run Standard Position Check
        [self runStandardPositionCheck:positionIn360 withDiff:difference withEnemy:enemyShip];
    }
}
-(void)runStandardPositionCheck:(int)positionIn360 withDiff:(int)difference withEnemy:(EnemyShip *)enemyShip {
    if (enemyShip.yawPosition > positionIn360) {
        difference = enemyShip.yawPosition - positionIn360;
        int xPosition = 240 - (difference * kXPositionMultiplier);
        [enemyShip setPosition:ccp(xPosition, enemyShip.position.y)];
    } else {
        difference = positionIn360 - enemyShip.yawPosition;
        int xPosition = 240 + (difference * kXPositionMultiplier);
        [enemyShip setPosition:ccp(xPosition, enemyShip.position.y)];
    }
}

- (BOOL) circle:(CGPoint) circlePoint withRadius:(float) radius collisionWithCircle:(CGPoint) circlePointTwo collisionCircleRadius:(float) radiusTwo {
    //检测是否两个点的半径有交集。输入的参数是敌方飞船位置和屏幕的中心点位置
    //我们计算两个点X和Y值的差。接下来计算两点的距离。这个在高中就学过的，叫勾股定理
    float xdif = circlePoint.x - circlePointTwo.x;
    float ydif = circlePoint.y - circlePointTwo.y;
    
    float distance = sqrt(xdif*xdif+ydif*ydif);
    if(distance <= radius+radiusTwo) return YES;
    
    return NO;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [[SimpleAudioEngine sharedEngine] playEffect:@"laser_ship.caf"];
    CGPoint location = [self convertTouchToNodeSpace:touch];
   // NSLog(@"touch location:%.0f*%.0f",location.x,location.y);
    scope.position = location;
    
    CGPoint locationScope = scope.position;
    
    // 1碰撞检测，用来测试是否飞船在瞄准器范围之内,如果其中一个飞船被击中了，我们就飞船的属性来隐藏它，同时把 enemyCount计数减1.
    for (EnemyShip *enemyShip in enemySprites) {
        if (enemyShip.timeToLive > 0) {
            // Check to see if yaw position is in range
            BOOL wasTouched = [self circle:locationScope withRadius:50 collisionWithCircle:enemyShip.position collisionCircleRadius:50];
            
            if (wasTouched) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"explosion_large.caf"]; 
                enemyShip.timeToLive = 0;
                enemyShip.visible = false;
                enemyCount -= 1;
                
                //加分数
                score++;
                [scoreLabel setString:[NSString stringWithFormat:@"分数:%d", score]];
            }
        }
    }
    
    // 2往屏幕中心添加了一个爆炸粒子系统
    CCParticleSystemQuad *particle = [CCParticleSystemQuad particleWithFile:@"bow.plist"];
    particle.position = scope.position;
    [self addChild:particle z:200];
    particle.autoRemoveOnFinish = YES;
    
    // 3检查enemyCount是 否为0，如果是的话，就显示一个label，告知玩家游戏结束了
    if (enemyCount == 0) {
        // Show end game
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"You win!" fntFile:@"Arial.fnt"];
        label.scale = 2.0;
        label.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:label z:30];
    }
    
    return NO;
}




// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    [enemySprites release]; 
	[super dealloc];
}

@end
