//
//  ViewController.m
//  AVFoundation-VideoManipulation
//
//  Created by Abdul Azeem Khan on 4/2/12.
//  Copyright (c) 2012 DataInvent. All rights reserved.
//

#import "ViewController.h"
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
@implementation ViewController
@synthesize mPlayer, mPlaybackView;

- (void)dealloc
{
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self mergeVideos3];
}
static  NSTimeInterval count  = 0;

- (void) mergeVideos3
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        count = [[NSDate date] timeIntervalSince1970];
        AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
        CMTime duration = kCMTimeZero;
        CMTime current = kCMTimeZero;
        
        NSError *compositionError = nil;
        for(int i = 0;i<9;i++) {
            NSArray * arrList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString * documentsPath = [arrList objectAtIndex:0];
            NSString * patch = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"1/%d.mp4",i]];
            NSURL * url = [NSURL fileURLWithPath:patch];
            AVURLAsset * asset  = [AVURLAsset URLAssetWithURL:url options:nil];
            if (i == 0) {
                duration = asset.duration;
            }
            
            
            BOOL result = [mixComposition insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration])
                                                  ofAsset:asset
                                                   atTime:current
                                                    error:&compositionError];
            if(!result) {
                if(compositionError) {
                    // manage the composition error case
                    NSLog(@"error ==%@",compositionError);
                }
            } else {
                current = CMTimeAdd(current, [asset duration]);
            }
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:@"mergeVideo8.mp4"];
        
        NSURL *url = [NSURL fileURLWithPath:myPathDocs];
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
        exporter.outputURL=url;
       // exporter.shouldOptimizeForNetworkUse = YES;
        // [exporter setVideoComposition:MainCompositionInst];
        //    exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.outputFileType = AVFileTypeMPEG4;
        
        [exporter exportAsynchronouslyWithCompletionHandler:^
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSTimeInterval second =  [[NSDate date] timeIntervalSince1970];
                 NSLog(@"timeOffset==%f",second- count);

             });

//             dispatch_async(dispatch_get_main_queue(), ^{
//                 [self exportDidFinish:exporter];
//             });
         }];

    });

    
}

- (void) mergeVideos2
{
   count = [[NSDate date] timeIntervalSince1970];
    NSMutableArray * testArr = [[NSMutableArray alloc] init];
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    CMTime duration = kCMTimeZero;
    for (int i = 0; i < 10; i ++) {
        
        AVURLAsset * asset  = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource: @"gizmo" ofType: @"mp4"]] options:nil];
        if (i == 0) {
            duration = asset.duration;
        }

        //Here we are creating the first AVMutableCompositionTrack.See how we are adding a new track to our AVMutableComposition.
        AVMutableCompositionTrack *track = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        //Now we set the length of the firstTrack equal to the length of the firstAsset and add the firstAsset to out newly created track at kCMTimeZero so video plays from the start of the track.
        [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];

        
        //We will be creating 2 AVMutableVideoCompositionLayerInstruction objects.Each for our 2 AVMutableCompositionTrack.here we are creating AVMutableVideoCompositionLayerInstruction for out first track.see how we make use of Affinetransform to move and scale our First Track.so it is displayed at the bottom of the screen in smaller size.(First track in the one that remains on top).
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:track];
        CGAffineTransform Scale = CGAffineTransformMakeScale(0.7f,0.7f);
        CGAffineTransform Move = CGAffineTransformMakeTranslation(230,230);
        [layerInstruction setTransform:CGAffineTransformConcat(Scale,Move) atTime:kCMTimeZero];
        
        [testArr addObject:layerInstruction];
    }
    
    
    //See how we are creating AVMutableVideoCompositionInstruction object.This object will contain the array of our AVMutableVideoCompositionLayerInstruction objects.You set the duration of the layer.You should add the lenght equal to the lingth of the longer asset in terms of duration.
    AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    [MainInstruction retain];
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, duration);
    MainInstruction.layerInstructions = testArr;
    
    //Now we add our 2 created AVMutableVideoCompositionLayerInstruction objects to our AVMutableVideoCompositionInstruction in form of an array.
    
    
    //Now we create AVMutableVideoComposition object.We can add mutiple AVMutableVideoCompositionInstruction to this object.We have only one AVMutableVideoCompositionInstruction object in our example.You can use multiple AVMutableVideoCompositionInstruction objects to add multiple layers of effects such as fade and transition but make sure that time ranges of the AVMutableVideoCompositionInstruction objects dont overlap.
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    [MainCompositionInst retain];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, 30);
    MainCompositionInst.renderSize = CGSizeMake(640, 480);
    
    //Finally just add the newly created AVMutableComposition with multiple tracks to an AVPlayerItem and play it using AVPlayer.
//    AVPlayerItem * newPlayerItem = [AVPlayerItem playerItemWithAsset:mixComposition];
//    [newPlayerItem retain];
//    newPlayerItem.videoComposition = MainCompositionInst;
//    self.mPlayer = [AVPlayer playerWithPlayerItem:newPlayerItem];
//    [mPlayer addObserver:self forKeyPath:@"status" options:0 context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    NSLog(@"搜书租===%d",[testArr count]);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentsDirectory = [paths objectAtIndex:0];
     NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:@"mergeVideo.mp4"];
     
     NSURL *url = [NSURL fileURLWithPath:myPathDocs];
     
     AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
     exporter.outputURL=url;
     [exporter setVideoComposition:MainCompositionInst];
     exporter.outputFileType = AVFileTypeQuickTimeMovie;
     
     [exporter exportAsynchronouslyWithCompletionHandler:^
     {
     dispatch_async(dispatch_get_main_queue(), ^{
     [self exportDidFinish:exporter];
     });
     }];

}
- (void) mergeVideos{
    
    //Here where load our movie Assets using AVURLAsset
    AVURLAsset* firstAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource: @"gizmo" ofType: @"mp4"]] options:nil];
    AVURLAsset * secondAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource: @"gizmo" ofType: @"mp4"]] options:nil];
    
    //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    
    //Here we are creating the first AVMutableCompositionTrack.See how we are adding a new track to our AVMutableComposition.
    AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    //Now we set the length of the firstTrack equal to the length of the firstAsset and add the firstAsset to out newly created track at kCMTimeZero so video plays from the start of the track.
    [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration) ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
     //Now we repeat the same process for the 2nd track as we did above for the first track.
    AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAsset.duration) ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //See how we are creating AVMutableVideoCompositionInstruction object.This object will contain the array of our AVMutableVideoCompositionLayerInstruction objects.You set the duration of the layer.You should add the lenght equal to the lingth of the longer asset in terms of duration.
    AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    [MainInstruction retain];
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(0, 300));
    
    //We will be creating 2 AVMutableVideoCompositionLayerInstruction objects.Each for our 2 AVMutableCompositionTrack.here we are creating AVMutableVideoCompositionLayerInstruction for out first track.see how we make use of Affinetransform to move and scale our First Track.so it is displayed at the bottom of the screen in smaller size.(First track in the one that remains on top).
    AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
//    CGAffineTransform Scale = CGAffineTransformMakeScale(0.7f,0.7f);
//    CGAffineTransform Move = CGAffineTransformMakeTranslation(230,230);
//    [FirstlayerInstruction setTransform:CGAffineTransformConcat(Scale,Move) atTime:kCMTimeZero];
   
    //Here we are creating AVMutableVideoCompositionLayerInstruction for out second track.see how we make use of Affinetransform to move and scale our second Track.
    AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
//    CGAffineTransform SecondScale = CGAffineTransformMakeScale(1.2f,1.5f);
//    CGAffineTransform SecondMove = CGAffineTransformMakeTranslation(0,0);
//    [SecondlayerInstruction setTransform:CGAffineTransformConcat(SecondScale,SecondMove) atTime:kCMTimeZero];
    
    //Now we add our 2 created AVMutableVideoCompositionLayerInstruction objects to our AVMutableVideoCompositionInstruction in form of an array.
    MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,nil];;
    
    //Now we create AVMutableVideoComposition object.We can add mutiple AVMutableVideoCompositionInstruction to this object.We have only one AVMutableVideoCompositionInstruction object in our example.You can use multiple AVMutableVideoCompositionInstruction objects to add multiple layers of effects such as fade and transition but make sure that time ranges of the AVMutableVideoCompositionInstruction objects dont overlap.
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    [MainCompositionInst retain];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, 30);
    MainCompositionInst.renderSize = CGSizeMake(640, 480);
    
    //Finally just add the newly created AVMutableComposition with multiple tracks to an AVPlayerItem and play it using AVPlayer. 
//    AVPlayerItem * newPlayerItem = [AVPlayerItem playerItemWithAsset:mixComposition];
//    [newPlayerItem retain];
//    newPlayerItem.videoComposition = MainCompositionInst;
//    self.mPlayer = [AVPlayer playerWithPlayerItem:newPlayerItem];
//    [mPlayer addObserver:self forKeyPath:@"status" options:0 context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];	
	NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:@"mergeVideo.mp4"];
    
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
	
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=url;
    [exporter setVideoComposition:MainCompositionInst];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
	
	[exporter exportAsynchronouslyWithCompletionHandler:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self exportDidFinish:exporter];
         });
     }];
}
- (void)exportDidFinish:(AVAssetExportSession*)session
{
	NSURL *outputURL = session.outputURL;
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:outputURL
									completionBlock:^(NSURL *assetURL, NSError *error){
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                           NSTimeInterval second =  [[NSDate date] timeIntervalSince1970];
                                            NSLog(@"timeOffset==%f",second- count);
											if (error) {
												NSLog(@"writeVideoToAssestsLibrary failed: %@", error);
											}else{
                                                NSLog(@"Writing3");
                                            }
											
										});
										
									}];
	}
	[library release];
}

- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if (mPlayer.status == AVPlayerStatusReadyToPlay) {
         [self.mPlaybackView setPlayer:self.mPlayer];
        [self.mPlayer play];
    }
}
@end
