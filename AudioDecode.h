//
//  AudioDecode.h
//  ffmpeg
//
//  Created by Apple on 2018/10/27.
//  Copyright © 2018年 XC. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "avformat.h"
#include "avcodec.h"
#include "imgutils.h"
#include "swscale.h"
#include "swresample.h"
#include "frame.h"

@interface AudioDecode : NSObject

+(void)ffmpegAudioDecode:(NSString*)inFilePath outFilePath:(NSString*)outFilePath;

@end
