//
//  EnemyShip.h
//  ARDemo
//
//  Created by jeans on 13-6-24.
//  Copyright (c) 2013年 floatpoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface EnemyShip : CCSprite {
    
}

@property (readwrite) int yawPosition;
@property (readwrite) int timeToLive;

@end
