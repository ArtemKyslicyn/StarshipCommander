//
//  GameManager.h
//  StarshipComander
//
//  Created by Arcilite on 21.09.14.
//  Copyright (c) 2014 Ramotion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "GameSprite.h"
#import <GLKit/GLKit.h>
typedef NS_ENUM(NSInteger, GameState) {
    GameStateNone = 0,
    GameStateLose,
    GameStateWon
};


@interface GameManager : NSObject

@property (strong, nonatomic) GameSprite *starShip;

@property (strong, nonatomic,readonly) NSMutableArray *fireRockets;

@property (strong, nonatomic,readonly) NSMutableArray *asteroids;
@property (strong, nonatomic,readonly) NSMutableArray *smallAsteroids;

@property (strong, nonatomic) GLKTextureInfo *bgTextureInfo;

@property (strong, nonatomic) GameSprite * background;

@property (assign) GameState gameState;
@property (assign) BOOL isGameRunning;

-(id)initWithEffect:(GLKBaseEffect*)effect;

- (void)startGame;

-(void)operationsToNotUsedObjectsInBouds:(CGRect)bounds;

-(void)processFireRocketAndAsteroidCollision;
-(void)asteroidWithSpaceShipCollision;
-(void)spaceShipFire;

@end