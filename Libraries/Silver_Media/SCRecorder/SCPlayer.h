//
//  SCVideoPlayer.h
//  SCAudioVideoRecorder
//
//  Created by Simon CORSIN on 8/30/13.
//  Copyright (c) 2013 rFlex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SCFilterGroup.h"
#import "SCImageView.h"

@class SCPlayer;

@protocol SCPlayerDelegate <NSObject>

@optional

- (void)videoPlayer:(SCPlayer*)videoPlayer didPlay:(Float64)secondsElapsed loopsCount:(NSInteger)loopsCount;
- (void)videoPlayer:(SCPlayer *)videoPlayer didChangeItem:(AVPlayerItem*)item;
- (void)player:(SCPlayer *)player didReachEndForItem:(AVPlayerItem *)item;

@end

@interface SCPlayer : AVPlayer<GLKViewDelegate>

@property (weak, nonatomic) id<SCPlayerDelegate> delegate;
@property (assign, nonatomic) CMTime minimumBufferedTimeBeforePlaying;
@property (assign, nonatomic) BOOL shouldLoop;
@property (strong, nonatomic) SCFilterGroup *filterGroup;
@property (weak, nonatomic) UIView *outputView;
@property (readonly, nonatomic) BOOL isSendingPlayMessages;
@property (assign, nonatomic) BOOL shouldPlayConcurrently;
// If true, the player will figure out an affine transform so the video best fits the screen. The resulting
// video may not be in the correct device orientation though.
@property (assign, nonatomic) BOOL autoRotate;

// If true, the player will always use a SCImageView for rendering the video (may be slower)
@property (assign, nonatomic) BOOL useCoreImageView;
// The SCImageView to use for displaying the buffers if useCoreImageView is enabled
// This will be autogenerated if no SCImageView is provided
@property (strong, nonatomic) SCImageView *SCImageView;

// If useCoreImageView is true and no SCImageView has been set,
// setting this property to true will make the SCPlayer to create one
// automatically. Set this to false if you are eventually going to provide
// one to the player (if you use SCFilterSwitcherView for example)
@property (assign, nonatomic) BOOL autoCreateSCImageView;

+ (SCPlayer *)player;
+ (void)pauseCurrentPlayer;
+ (SCPlayer *)currentPlayer;

// Ask the SCPlayer to send didPlay messages during the playback
// endSendingPlayMessages must be called, otherwise the SCPlayer will never
// be deallocated
- (void)beginSendingPlayMessages;
// Ask the SCPlayer to stop sending didPlay messages during the playback
- (void)endSendingPlayMessages;

- (void)resizePlayerLayerToFitOutputView;
- (void)resizePlayerLayer:(CGSize)size;

- (void)setItemByStringPath:(NSString*)stringPath;
- (void)setItemByUrl:(NSURL*)url;
- (void)setItemByAsset:(AVAsset*)asset;
- (void)setItem:(AVPlayerItem*)item;

// These methods allow the player to add the same item "loopCount" time
// in order to have a smooth loop. The loop system provided by Apple
// has an unvoidable hiccup. Using these methods will avoid the hiccup for "loopCount" time

- (void)setSmoothLoopItemByStringPath:(NSString*)stringPath smoothLoopCount:(NSUInteger)loopCount;
- (void)setSmoothLoopItemByUrl:(NSURL*)url smoothLoopCount:(NSUInteger)loopCount;
- (void)setSmoothLoopItemByAsset:(AVAsset*)asset smoothLoopCount:(NSUInteger)loopCount;

- (CMTime)itemDuration;
- (CMTime)playableDuration;
- (BOOL)isPlaying;

@end
