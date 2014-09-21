//
//  GameManager.m
//  StarshipComander
//
//  Created by Arcilite on 20.09.14.
//  Copyright (c) 2014 Ramotion. All rights reserved.
//

#import "GameManager.h"
#import  "Helper.h"

static  NSString * const spaceShipImage = @"Rocket";
static  NSString * const backGroundImage = @"Space";
static  NSString * const gameOverImage = @"Game_Over";
static  NSString * const asteroidImage = @"AsteroidTop";
static  NSString * const smallAsteroidImage = @"ASTEROID";
static  NSString * const rocketImage = @"fire-roket";

#define GAME_OVER_POSITION GLKVector2Make(160, 235)
#define STARSHIP_POSITION GLKVector2Make(160, 35)

const float kStartOffsetAsteroids = 50.0f;
const float kOffsetAsteroids = 15.0f;

const int kCountAsteroids = 6;
const int kRowsAsteroids = 2;


const float kYDistanceBetweenAsteroids = 72.f;
const float kXDistanceBetweenAsteroids = 60.0f;
const float kDefaultScreenHeight =  680.f;  // i know it's not got I fix it later

const float kAsteroidSpeed = -90.f;
const float kSmallAsteroidSpeed = -90.f;
const float kLaunchRocketSpeed = 950.f;
const float kSmallAsteroidAngle = 15.f;
const float kBigAsteroidRotationSpeed =180.f;
const float kBigAsteroidAfterCrashRotationSpeed =360.f;
const float kSmallAsteroidRotationSpeed =780.f;

const float rocketLaunchYPositon = 80;

@interface GameManager()
@property (strong, nonatomic) GLKBaseEffect *effect;
@end

@implementation GameManager

-(id)initWithEffect:(GLKBaseEffect*)effect{
    
    self = [super init];
    
    if (self) {
        _effect = effect;
        self.background = [[GameSprite alloc] initWithImage:[UIImage imageNamed:backGroundImage] effect:self.effect];
        self.gameOver =  [[GameSprite alloc] initWithImage:[UIImage imageNamed:gameOverImage] effect:self.effect];
        self.gameOver.position = GAME_OVER_POSITION;
    }
    
    return self;
}


-(GameSprite*)starShip{
    
    if (!_starShip) {
        
        _starShip = [[GameSprite alloc] initWithImage:[UIImage imageNamed:spaceShipImage] effect:self.effect];
        _starShip.position = STARSHIP_POSITION;
        
    }
    
    return _starShip;
}


- (void)startGame{

    [self createAsteroidSprites];
    
    _fireRockets = [NSMutableArray array];
   _smallAsteroids = [NSMutableArray array];
    self.isGameRunning = YES;
    self.gameState = GameStateNone;
    

}

-(void)operationsToNotUsedObjectsInBouds:(CGRect)bounds{
    
    
    for (GameSprite *asteroid in self.asteroids) {
        if (asteroid.boundingRect.origin.y <= bounds.origin.y-kStartOffsetAsteroids){
           
            float randomY = [Helper getYesOrNo]?[Helper randomInt]: -[Helper randomInt];
            float y = bounds.size.height  - kOffsetAsteroids+ randomY;
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
    
    UIImage *brickImage = [UIImage imageNamed:asteroidImage];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:brickImage.CGImage options:options error:&error];
    
    for (int i = 0; i < kRowsAsteroids; i++){
        
        for (int j = 0; j < kCountAsteroids; j++)
        {
            GameSprite *brickSprite = [[GameSprite alloc] initWithTexture:textureInfo effect:self.effect];
            float randomX = [Helper getYesOrNo]?[Helper randomInt]: -[Helper randomInt];
            float randomY = [Helper getYesOrNo]?[Helper randomInt]: -[Helper randomInt];
            float x = (j + 1) * kYDistanceBetweenAsteroids - 15.f + randomX;
            float y = kDefaultScreenHeight - (i+ 1) * kXDistanceBetweenAsteroids - kOffsetAsteroids+ randomY;
            
            brickSprite.position = GLKVector2Make(x, y);
            brickSprite.rotationVelocity  = kBigAsteroidRotationSpeed;
            brickSprite.moveVelocity = GLKVector2Make(0, kAsteroidSpeed);
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
            float y = kDefaultScreenHeight -  kXDistanceBetweenAsteroids - kOffsetAsteroids+ randomY;
            
            brickSprite.position = GLKVector2Make(brickSprite.position.x, y);
            brickSprite.rotationVelocity  = kBigAsteroidAfterCrashRotationSpeed;
            [loadedAsteroids addObject:brickSprite];
        }
    
    
   return  loadedAsteroids;
    
}


-(void)createSmallsAsteroidsFromAsteroid:(GameSprite*)asteroid counOfsmalAsteroids:(int)count{
    
    for (int i =0; i< count; i++) {
        GameSprite*smallAsteroid = [[GameSprite alloc] initWithImage:[UIImage imageNamed:smallAsteroidImage] effect:self.effect];
        smallAsteroid.position = asteroid.position;
        smallAsteroid.rotationVelocity = kSmallAsteroidRotationSpeed;
        float angle = i%2?-kSmallAsteroidAngle:kSmallAsteroidAngle;

        smallAsteroid.moveVelocity = GLKVector2Make(angle, kSmallAsteroidSpeed);
        
        [self.smallAsteroids addObject:smallAsteroid];
    }
    
}

-(void)spaceShipFire{
    
    GameSprite*fireRocket = [[GameSprite alloc] initWithImage:[UIImage imageNamed:rocketImage] effect:self.effect];
    fireRocket.position = GLKVector2Make(self.starShip.position.x, rocketLaunchYPositon);
    fireRocket.rotation = 0;
    fireRocket.moveVelocity = GLKVector2Make(0,kLaunchRocketSpeed);
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
