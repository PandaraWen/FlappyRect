//
//  MainScene.m
//  FlappyRect
//
//  Created by Pandara on 14-10-1.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

#import "MainScene.h"
#import "RestartView.h"

#define HERO_SIZE CGSizeMake(40, 30)
#define WALL_WIDTH 40

#define NODENAME_HERO @"heronode"
#define NODENAME_BRICK @"brick"
#define NODENAME_WALL @"wall"
#define NODENAME_HOLE @"hole"
#define NODENAME_DUST @"dust"

#define ACTIONKEY_ADDWALL @"addwall"
#define ACTIONKEY_MOVEWALL @"movewall"
#define ACTIONKEY_FLY @"fly"
#define ACTIONKEY_ADDDUST @"adddust"
#define ACTIONKEY_MOVEHEAD @"movehead"

#define GROUND_HEIGHT 20.0f

#define TIMEINTERVAL_ADDWALL 2.0f
#define TIMEINTERVAL_MOVEWALL 4.0f

#define DUST_WIDTH 20.0f
#define DUST_HEIGHT 1.0f
#define DUSTWIDTH_MIN 2
#define DUSTWIDTH_MAX 5

#define COLOR_HERO color(244, 118, 148, 1)
#define COLOR_BG [UIColor whiteColor]
#define COLOR_WALL color(34, 166, 159, 1)
#define COLOR_LABEL color(17, 39, 57, 1)

static const uint32_t heroCategory = 0x1 << 0;
static const uint32_t wallCategory = 0x1 << 1;
static const uint32_t holeCategory = 0x1 << 2;
static const uint32_t groundCategory = 0x1 << 3;
static const uint32_t edgeCategory = 0x1 << 4;

@interface MainScene() <SKPhysicsContactDelegate, RestartViewDelegate>

@property (strong, nonatomic) SKSpriteNode *hero;

@property (strong, nonatomic) SKAction *moveWallAction;
@property (strong, nonatomic) SKAction *moveHeadAction;

@property (strong, nonatomic) SKSpriteNode *ground;

@property (strong, nonatomic) SKLabelNode *labelNode;

@property BOOL isGameOver;
@property BOOL isGameStart;

@end

@implementation MainScene

- (void)initalize
{
    [super initalize];
    
    //self
    self.backgroundColor = COLOR_BG;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = edgeCategory;
    self.physicsWorld.contactDelegate = self;
    
    self.moveWallAction = [SKAction moveToX:-WALL_WIDTH duration:TIMEINTERVAL_MOVEWALL];
    
    SKAction *upHeadAction = [SKAction rotateToAngle:M_PI / 6 duration:0.2f];
    upHeadAction.timingMode = SKActionTimingEaseOut;
    SKAction *downHeadAction = [SKAction rotateToAngle:-M_PI / 2 duration:0.8f];
    downHeadAction.timingMode = SKActionTimingEaseOut;
    self.moveHeadAction = [SKAction sequence:@[upHeadAction, downHeadAction,]];
    
    //ground
    [self addGroundNode];
    
    //hero
    [self addHeroNode];
    
    //label
    [self addResultLabelNode];

    //dust
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[
                                                                       [SKAction performSelector:@selector(addDust) onTarget:self],
                                                                       [SKAction waitForDuration:0.3f],
                                                                       ]]] withKey:ACTIONKEY_ADDDUST];
}

#pragma mark - method
- (void)addResultLabelNode
{
    self.labelNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    _labelNode.text = @"0";
    _labelNode.fontSize = 30.0f;
    _labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    _labelNode.position = CGPointMake(10, self.frame.size.height - 20);
    _labelNode.fontColor = COLOR_LABEL;
    [self addChild:_labelNode];
}

- (SKAction *)getFlyAction
{
    SKAction *flyUp = [SKAction moveToY:_hero.position.y + 10 duration:0.3f];
    flyUp.timingMode = SKActionTimingEaseOut;
    SKAction *flyDown = [SKAction moveToY:_hero.position.y - 10 duration:0.3f];
    flyDown.timingMode = SKActionTimingEaseOut;
    SKAction *fly = [SKAction sequence:@[flyUp, flyDown]];
    return fly;
}

- (void)addHeroNode
{
    self.hero = [SKSpriteNode spriteNodeWithColor:COLOR_HERO size:HERO_SIZE];
    _hero.anchorPoint = CGPointMake(0.5, 0.5);
    _hero.position = CGPointMake(self.frame.size.width / 3, CGRectGetMidY(self.frame));
    _hero.name = NODENAME_HERO;
    _hero.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_hero.size center:CGPointMake(0, 0)];
    _hero.physicsBody.categoryBitMask = heroCategory;
    _hero.physicsBody.collisionBitMask = wallCategory | groundCategory;
    _hero.physicsBody.contactTestBitMask = holeCategory | wallCategory | groundCategory;
    _hero.physicsBody.dynamic = YES;
    _hero.physicsBody.affectedByGravity = NO;
    _hero.physicsBody.allowsRotation = YES;
    _hero.physicsBody.restitution = 0;
    _hero.physicsBody.usesPreciseCollisionDetection = YES;
    [self addChild:_hero];
    
    [_hero runAction:[SKAction repeatActionForever:[self getFlyAction]]
             withKey:ACTIONKEY_FLY];
}

- (void)addGroundNode
{
    self.ground = [SKSpriteNode spriteNodeWithColor:COLOR_WALL size:CGSizeMake(self.frame.size.width, GROUND_HEIGHT)];
    _ground.anchorPoint = CGPointMake(0, 0);
    _ground.position = CGPointMake(0, 0);
    _ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_ground.size center:CGPointMake(_ground.size.width / 2.0f, _ground.size.height / 2.0f)];
    _ground.physicsBody.categoryBitMask = groundCategory;
    _ground.physicsBody.dynamic = NO;
    [self addChild:_ground];
}

- (void)addDust
{
    CGFloat dustWidth = (arc4random() % (DUSTWIDTH_MAX - DUSTWIDTH_MIN + 1) + DUSTWIDTH_MIN) * DUST_WIDTH;
    SKSpriteNode *dustNode = [SKSpriteNode spriteNodeWithColor:color(230, 230, 230, 1) size:CGSizeMake(dustWidth, DUST_HEIGHT)];
    dustNode.anchorPoint = CGPointMake(0, 0);
    dustNode.name = NODENAME_DUST;
    dustNode.position = CGPointMake(self.frame.size.width, arc4random() % (int)(self.frame.size.height / 3) + self.frame.size.height / 3);
    [dustNode runAction:[SKAction moveToX:-dustWidth duration:1.0f]];
    [self addChild:dustNode];
}

- (void)addWall
{
    CGFloat spaceHeigh = self.frame.size.height - GROUND_HEIGHT;
    
    CGFloat holeLength = HERO_SIZE.height * 5;
    int holePosition = arc4random() % (int)((spaceHeigh - holeLength) / HERO_SIZE.height);
    
    CGFloat x = self.frame.size.width;
    
    //上部分
    CGFloat upHeight = holePosition * HERO_SIZE.height;
    if (upHeight > 0) {
        SKSpriteNode *upWall = [SKSpriteNode spriteNodeWithColor:COLOR_WALL size:CGSizeMake(WALL_WIDTH, upHeight)];
        upWall.anchorPoint = CGPointMake(0, 0);
        upWall.position = CGPointMake(x, self.frame.size.height - upHeight);
        upWall.name = NODENAME_WALL;
        
        upWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:upWall.size center:CGPointMake(upWall.size.width / 2.0f, upWall.size.height / 2.0f)];
        upWall.physicsBody.categoryBitMask = wallCategory;
        upWall.physicsBody.dynamic = NO;
        upWall.physicsBody.friction = 0;
        
        [upWall runAction:_moveWallAction withKey:ACTIONKEY_MOVEWALL];
        
        [self addChild:upWall];
    }
    
    //下部分
    CGFloat downHeight = spaceHeigh - upHeight - holeLength;
    if (downHeight > 0) {
        SKSpriteNode *downWall = [SKSpriteNode spriteNodeWithColor:COLOR_WALL size:CGSizeMake(WALL_WIDTH, downHeight)];
        downWall.anchorPoint = CGPointMake(0, 0);
        downWall.position = CGPointMake(x, GROUND_HEIGHT);
        downWall.name = NODENAME_WALL;
        
        downWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:downWall.size center:CGPointMake(downWall.size.width / 2.0f, downWall.size.height / 2.0f)];
        downWall.physicsBody.categoryBitMask = wallCategory;
        downWall.physicsBody.dynamic = NO;
        downWall.physicsBody.friction = 0;
        
        [downWall runAction:_moveWallAction withKey:ACTIONKEY_MOVEWALL];
        
        [self addChild:downWall];
    }
    
    //中空部分
    SKSpriteNode *hole = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(WALL_WIDTH, holeLength)];
    hole.anchorPoint = CGPointMake(0, 0);
    hole.position = CGPointMake(x, self.frame.size.height - upHeight - holeLength);
    hole.name = NODENAME_HOLE;
    
    hole.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hole.size center:CGPointMake(hole.size.width / 2.0f, hole.size.height / 2.0f)];
    hole.physicsBody.categoryBitMask = holeCategory;
    hole.physicsBody.dynamic = NO;
    
    [hole runAction:_moveWallAction withKey:ACTIONKEY_MOVEWALL];
    
    [self addChild:hole];
}

- (void)update:(NSTimeInterval)currentTime
{
    __block int wallCount = 0;
    [self enumerateChildNodesWithName:NODENAME_WALL usingBlock:^(SKNode *node, BOOL *stop) {
        if (wallCount >= 2) {
            *stop = YES;
            return;
        }
        
        if (node.position.x <= -WALL_WIDTH) {
            wallCount++;
            [node removeFromParent];
        }
    }];
    
    [self enumerateChildNodesWithName:NODENAME_HOLE usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x <= -WALL_WIDTH) {
            [node removeFromParent];
            *stop = YES;
        }
    }];
    
    [self enumerateChildNodesWithName:NODENAME_DUST usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x <= -node.frame.size.width) {
            [node removeFromParent];
        }
    }];
}

- (void)startGame
{
    self.isGameStart = YES;
    [self removeActionForKey:ACTIONKEY_ADDDUST];
    
    //hero
    _hero.physicsBody.affectedByGravity = YES;
    [_hero removeActionForKey:ACTIONKEY_FLY];
    
    //add wall
    SKAction *addWall = [SKAction sequence:@[
                                             [SKAction performSelector:@selector(addWall) onTarget:self],
                                             [SKAction waitForDuration:TIMEINTERVAL_ADDWALL],
                                             ]];
    
    [self runAction:[SKAction repeatActionForever:addWall] withKey:ACTIONKEY_ADDWALL];
}

- (void)gameOver
{
    self.isGameOver = YES;
    
    [_hero removeActionForKey:ACTIONKEY_MOVEHEAD];
    
    [self removeActionForKey:ACTIONKEY_ADDWALL];
    
    [self enumerateChildNodesWithName:NODENAME_WALL usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeActionForKey:ACTIONKEY_MOVEWALL];
    }];
    [self enumerateChildNodesWithName:NODENAME_HOLE usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeActionForKey:ACTIONKEY_MOVEWALL];
    }];
    
    RestartView *restartView = [RestartView getInstanceWithSize:self.size];
    restartView.delegate = self;
    [restartView showInScene:self];
}

- (void)restart
{
    //label
    self.labelNode.text = @"0";
    
    //remove all wall and hole
    [self enumerateChildNodesWithName:NODENAME_HOLE usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    
    [self enumerateChildNodesWithName:NODENAME_WALL usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    
    //reset hero
    [_hero removeFromParent];
    self.hero = nil;
    [self addHeroNode];
    
    //dust
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[
                                                                       [SKAction performSelector:@selector(addDust) onTarget:self],
                                                                       [SKAction waitForDuration:0.3f],
                                                                       ]]] withKey:ACTIONKEY_ADDDUST];
    
    //flag
    self.isGameStart = NO;
    self.isGameOver = NO;
}

- (void)playSoundWithName:(NSString *)fileName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self runAction:[SKAction playSoundFileNamed:fileName waitForCompletion:YES]];
    });
}

#pragma mark - TouchEvent
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isGameOver) {
        return;
    }
    if (!_isGameStart) {
        [self startGame];
    }
    
    _hero.physicsBody.velocity = CGVectorMake(0, 400);
    [_hero runAction:_moveHeadAction withKey:ACTIONKEY_MOVEHEAD];
    [self playSoundWithName:@"sfx_wing.caf"];
}

#pragma mark - SKPhysicsContactDelegate
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if (_isGameOver) {
        return;
    }
    
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & heroCategory) && (secondBody.categoryBitMask & holeCategory)) {
        int currentPoint = [_labelNode.text intValue];
        _labelNode.text = [NSString stringWithFormat:@"%d", currentPoint + 1];
        [self playSoundWithName:@"sfx_point.caf"];
    } else {
        [self playSoundWithName:@"sfx_hit.caf"];
        [self gameOver];
    }
}

#pragma mark - RestartViewDelegate
- (void)restartView:(RestartView *)restartView didPressRestartButton:(SKSpriteNode *)restartButton
{
    [restartView dismiss];
    [self restart];
}
@end






