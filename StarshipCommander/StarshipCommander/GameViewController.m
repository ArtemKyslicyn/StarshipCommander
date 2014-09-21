//
//  GameViewController.m
//  StarshipCommander
//
//  Created by Arcilite on 21.09.14.
//  Copyright (c) 2014 Ramotion. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#import "GameManager.h"
#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};



@interface GameViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) GameManager *gameManager;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    [self setupGL];
    
    [self setupGesturesRecognition];
    
    [self setupGameManager];
}




- (void)setupGL
{
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, [[UIScreen mainScreen] bounds].size.width, 0, [[UIScreen mainScreen] bounds].size.height, -1024, 1024);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    
}

-(void)setupGesturesRecognition{
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureFrom:)];
    [self.view addGestureRecognizer:panRecognizer];
    [self.view addGestureRecognizer:tapRecognizer];
    
}

-(void)setupGameManager{
    _gameManager = [[GameManager alloc] initWithEffect:self.effect];
    
}


#pragma mark - GLKView and GLKViewController delegate methods

- (void)update{
    
    [self.gameManager.background update:self.timeSinceLastUpdate];
    [self.gameManager operationsToNotUsedObjectsInBouds:  [[UIScreen mainScreen] bounds]];
    [self.gameManager processFireRocketAndAsteroidCollision];
    [self.gameManager asteroidWithSpaceShipCollision];
    [self.gameManager.starShip update:self.timeSinceLastUpdate];
    
    for (GameSprite *asteroid in self.gameManager.asteroids){
        [asteroid update:self.timeSinceLastUpdate];
    }
    
    for (GameSprite *asteroid in self.gameManager.smallAsteroids){
        [asteroid update:self.timeSinceLastUpdate];
    }
    
    for (GameSprite *fireRocket in self.gameManager.fireRockets){
        [fireRocket update:self.timeSinceLastUpdate];
    }
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    glClearColor(0.f, 0.f, 0.f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    [self.gameManager.background render];
    [self.gameManager.starShip render];
    
    for (GameSprite *asteroid in self.gameManager.asteroids){
        [asteroid render];
    }
    
    for (GameSprite *asteroid in self.gameManager.smallAsteroids){
        [asteroid render];
    }
    
    for (GameSprite *fireRocket in self.gameManager.fireRockets){
        [fireRocket render];
    }
}


#pragma mark - gesture Actions
- (void)handleTapGestureFrom:(UITapGestureRecognizer *)recognizer{
    
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    if (self.gameManager.isGameRunning)
    {
        GLKVector2 target = GLKVector2Make(touchLocation.x, self.gameManager.starShip.position.y);
        self.gameManager.starShip.position = target;
        [self.gameManager spaceShipFire];
    }
    else {
        [self.gameManager startGame];
    }
}

- (void)handlePanGesture:(UIGestureRecognizer *)gestureRecognizer{
    
    CGPoint touchLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (self.gameManager.isGameRunning)
    {
        GLKVector2 target = GLKVector2Make(touchLocation.x, self.gameManager.starShip.position.y);
        self.gameManager.starShip.position = target;
        
    }
}


- (void)dealloc{
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    
    // Dispose of any resources that can be recreated.
}

- (void)tearDownGL{
    
    [EAGLContext setCurrentContext:self.context];
    self.effect = nil;
}


@end
