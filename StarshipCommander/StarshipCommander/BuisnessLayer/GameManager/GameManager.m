//
//  GameManager.m
//  StarshipComander
//
//  Created by Arcilite on 20.09.14.
//  Copyright (c) 2014 Ramotion. All rights reserved.
//

#import "GameManager.h"
#import  "Helper.h"
@interface GameManager()
@property (strong, nonatomic) GLKBaseEffect *effect;
@end

@implementation GameManager

-(id)initWithEffect:(GLKBaseEffect*)effect{
    
    self = [super init];
    
    if (self) {
        _effect = effect;
    }
    
    return self;
}


-(GameSprite*)starShip{
    
    if (!_starShip) {
        
        _starShip = [[GameSprite alloc] initWithImage:[UIImage imageNamed:@"Rocket"] effect:self.effect];
        _starShip.position = GLKVector2Make(160, 35);
        
    }
    
    return _starShip;
}


- (void)startGame{

    [self createAsteroidSprites];
    
    _fireRockets = [NSMutableArray array];
   _smallAsteroids = [NSMutableArray array];
    self.isGameRunning = YES;
    self.gameState = GameStateNone;
    
    self.background = [[GameSprite alloc] initWithImage:[UIImage imageNamed:@"Space"] effect:self.effect];
    //self.background.position = GLKVector2Make(160, 240);

}

-(void)operationsToNotUsedObjectsInBouds:(CGRect)bounds{
    
    
    for (GameSprite *asteroid in self.asteroids) {
        if (asteroid.boundingRect.origin.y <= bounds.origin.y-50){
           
            float randomY = [Helper getYesOrNo]?[Helper randomInt]: -[Helper randomInt];
            float y = 680.f  - 15.f+ randomY;
            asteroid.position = GLKVector2Make(asteroid.position.x, y);

        }
    }
    
    NSMutableArray * fireRocketsToRemove = [NSMutableArray array];
    
    for (GameSprite *fireRocket in self.fireRockets) {
        if (fireRocket.boundingRect.origin.y  >= bounds.size.height){
            [fireRocketsToRemove addObject:fireRocket];
        }
    }
    
    [self.fireRockets removeObjectsInArray:fireRocketsToRemove];
    
    NSMutableArray * smallAsteroidsToRemove = [NSMutableArray array];
    
    for (GameSprite *smallAsteroid in self.smallAsteroids) {
        if (smallAsteroid.boundingRect.origin.y  >= bounds.size.height){
            [smallAsteroidsToRemove addObject:smallAsteroid];
        }
    }
    
    [self.fireRockets removeObjectsInArray:smallAsteroidsToRemove];
    ///[self.smallAsteroids removeAllObjects];
    
    
}

-(void)asteroidWithSpaceShipCollision{
    for (GameSprite * asteroid in self.asteroids)
    {
        if (CGRectIntersectsRect(asteroid.boundingRect, self.starShip.boundingRect))
        {
            [self endGameWithWin:NO];
            
            return;
        }
    }
    
    for (GameSprite * asteroid in self.smallAsteroids)
    {
        if (CGRectIntersectsRect(asteroid.boundingRect, self.starShip.boundingRect))
        {
            [self endGameWithWin:NO];
            
            return;
        }
    }
    
}



-(void)processFireRocketAndAsteroidCollision{
   
    NSMutableArray *brokenAsteroids = [NSMutableArray array];
    NSMutableArray *desroyedRockets = [NSMutableArray array];
    NSMutableArray *destroyedAsteroids = [NSMutableArray array];
    
    for (GameSprite *fireRocket in self.fireRockets)
    {
        for (GameSprite *brick in self.asteroids)
        {
            
            if (CGRectIntersectsRect(fireRocket.boundingRect, brick.boundingRect))
            {
                [brokenAsteroids addObject: brick];
                [desroyedRockets addObject:fireRocket];
                [self createSmallsAsteroidsFromAsteroid:brick counOfsmalAsteroids:2];
                
            }
        }
        
        for (GameSprite *smallAsteroid in self.smallAsteroids)
        {
            
            if (CGRectIntersectsRect(fireRocket.boundingRect, smallAsteroid.boundingRect))
            {
                [destroyedAsteroids addObject: smallAsteroid];
                
            }
        }
        
    }
    
    [self.asteroids removeObjectsInArray: brokenAsteroids];
    [self.smallAsteroids removeObjectsInArray: destroyedAsteroids];
    [self.fireRockets removeObjectsInArray: desroyedRockets];
     NSArray * additionalAsteroids= [self createAditionalAsteroidFromBrokenArray:brokenAsteroids];
    [self.asteroids addObjectsFromArray:additionalAsteroids];
    // removing them
    
    
    
}

- (void)createAsteroidSprites{
    
    NSError *error;
    
    NSMutableArray *loadedAsteroids = [NSMutableArray array];
    
    UIImage *brickImage = [UIImage imageNamed:@"AsteroidTop"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:brickImage.CGImage options:options error:&error];
    
    for (int i = 0; i < 2; i++){
        
        for (int j = 0; j < 6; j++)
        {
            GameSprite *brickSprite = [[GameSprite alloc] initWithTexture:textureInfo effect:self.effect];
            float randomX = [Helper getYesOrNo]?[Helper randomInt]: -[Helper randomInt];
            float randomY = [Helper getYesOrNo]?[Helper randomInt]: -[Helper randomInt];
            float x = (j + 1) * 72.f - 15.f + randomX;
            float y = 680.f - (i+ 1) * 60.f - 15.f+ randomY;
            
            brickSprite.position = GLKVector2Make(x, y);
            brickSprite.rotationVelocity  = 180;
            brickSprite.moveVelocity = GLKVector2Make(0, -90);
            [loadedAsteroids addObject:brickSprite];
        }
        
    }
    
    _asteroids = loadedAsteroids;
    
}

- (NSMutableArray*)createAditionalAsteroidFromBrokenArray:(NSArray*)array{
    
    
    NSMutableArray *loadedAsteroids = [NSMutableArray array];


        for (int j = 0; j < array.count; j++)
        {
            GameSprite *brickSprite = [array objectAtIndex:j];
        
            float randomY = [Helper getYesOrNo]?[Helper randomInt]: -[Helper randomInt];
            float y = 680.f -  60.f - 15.f+ randomY;
            
            brickSprite.position = GLKVector2Make(brickSprite.position.x, y);
            brickSprite.rotationVelocity  = 360;
            [loadedAsteroids addObject:brickSprite];
        }
    
    
   return  loadedAsteroids;
    
}


-(void)createSmallsAsteroidsFromAsteroid:(GameSprite*)asteroid counOfsmalAsteroids:(int)count{
    
    for (int i =0; i< count; i++) {
        GameSprite*smallAsteroid = [[GameSprite alloc] initWithImage:[UIImage imageNamed:@"ASTEROID"] effect:self.effect];
        smallAsteroid.position = asteroid.position;
        smallAsteroid.rotationVelocity = 180.f;
        float angle = i%2?-15:15;

        smallAsteroid.moveVelocity = GLKVector2Make(angle, -90);
        
        [self.smallAsteroids addObject:smallAsteroid];
    }
    
}

-(void)spaceShipFire{
    
    GameSprite*fireRocket = [[GameSprite alloc] initWithImage:[UIImage imageNamed:@"fire-roket"] effect:self.effect];
    fireRocket.position = GLKVector2Make(self.starShip.position.x, 80);
    fireRocket.rotation = 0;
    fireRocket.moveVelocity = GLKVector2Make(0,940);
    [self.fireRockets addObject:fireRocket];
    
}

- (void)endGameWithWin:(BOOL)win{
    self.isGameRunning = NO;
    self.gameState = win ? GameStateWon : GameStateLose;
    
    [self.asteroids removeAllObjects];
    [self.smallAsteroids removeAllObjects];
    [self.fireRockets removeAllObjects];
}

@end
