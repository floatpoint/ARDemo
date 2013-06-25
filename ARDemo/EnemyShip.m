//
//  EnemyShip.m
//  ARDemo
//
//  Created by jeans on 13-6-24.
//  Copyright (c) 2013年 floatpoint. All rights reserved.
//

#import "EnemyShip.h"

@implementation EnemyShip

- (id)init {
    self = [super init];
    if (self) {
        self.yawPosition = 0;
        self.timeToLive = 0;
    }
    return self;
}

@end
