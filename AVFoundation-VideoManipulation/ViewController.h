//
//  ViewController.h
//  AVFoundation-VideoManipulation
//
//  Created by Abdul Azeem Khan on 4/2/12.
//  Copyright (c) 2012 DataInvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMTime.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVVideoComposition.h>
@class AVPlayerDemoPlaybackView;
@class AVPlayer;
@interface ViewController : UIViewController{
    AVPlayer* mPlayer;
    IBOutlet AVPlayerDemoPlaybackView  *mPlaybackView;
}

@property (readwrite, retain) AVPlayer* mPlayer;
@property (nonatomic, retain) IBOutlet AVPlayerDemoPlaybackView *mPlaybackView;
- (void) mergeVideos;
- (void)exportDidFinish:(AVAssetExportSession*)session;
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
@end

