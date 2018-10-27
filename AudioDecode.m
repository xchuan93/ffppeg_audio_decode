//
//  AudioDecode.m
//  ffmpeg
//
//  Created by Apple on 2018/10/27.
//  Copyright © 2018年 XC. All rights reserved.
//

#import "AudioDecode.h"

@implementation AudioDecode
+(void)ffmpegAudioDecode:(NSString*)inFilePath outFilePath:(NSString*)outFilePath{
    av_register_all();
    const char *in_url = [inFilePath UTF8String];
    AVFormatContext *av_ctx = avformat_alloc_context();
    if (avformat_open_input(&av_ctx, in_url, NULL, NULL) != 0) {
        NSLog(@"打开文件失败");
        return ;
    }
    if (avformat_find_stream_info(av_ctx, NULL) < 0) {
        NSLog(@"查找失败");
        return ;
    }
    int audio_index = av_find_best_stream(av_ctx, AVMEDIA_TYPE_AUDIO, -1, -1, NULL, 0);
    if (audio_index == -1) {
        NSLog(@"没有找到音频流Index");
        return ;
    }
    AVCodecContext *avcodec_ctx = avcodec_alloc_context3(NULL);
    if (avcodec_parameters_to_context(avcodec_ctx, av_ctx->streams[audio_index]->codecpar) < 0) {
        NSLog(@"初始化解码器上下文失败");
        return ;
    }
    AVCodec *avcodec = avcodec_find_decoder(avcodec_ctx->codec_id);
    if (avcodec_open2(avcodec_ctx, avcodec, NULL) != 0) {
        NSLog(@"打开解码器失败");
        return ;
    }
    //初始化一帧压缩数据
    AVPacket *avpacket = (AVPacket *)malloc(sizeof(avpacket));
    //初始化一帧数据采样数据
    AVFrame *avframe = av_frame_alloc();
    //初始化音频采样数据上下文
    SwrContext *swr_ctx = swr_alloc();
    //获取输入音道布局
    int64_t in_ch_layout = av_get_default_channel_layout(avcodec_ctx->channels);
    //设置音频默认参数
    swr_alloc_set_opts(swr_ctx, AV_CH_LAYOUT_STEREO, AV_SAMPLE_FMT_S16, avcodec_ctx->sample_rate, in_ch_layout, avcodec_ctx->sample_fmt, avcodec_ctx->sample_rate, 0, NULL);
    swr_init(swr_ctx);
    //统一输出音频采样数据格式->pcm
    int MAX_Audio_Size = 44100 * 2;
    uint8_t *outBuffer = (uint8_t *)av_malloc(MAX_Audio_Size);
    //获取缓冲区实际大小
    int out_bn_channel = av_get_channel_layout_nb_channels(AV_CH_LAYOUT_STEREO);
    const char *out_url = [outFilePath UTF8String];
    FILE *file_pcm = fopen(out_url, "wb+");
    if (file_pcm == NULL) {
        NSLog(@"打开文件失败");
        return ;
    }
    int current_index = 0;
    while (av_read_frame(av_ctx, avpacket)) {
        if (avpacket->stream_index == audio_index) {
            avcodec_send_packet(avcodec_ctx, avpacket);
            int ret = avcodec_receive_frame(avcodec_ctx, avframe);
            if (ret == 0) {
                swr_convert(swr_ctx, &outBuffer, MAX_Audio_Size, (const uint8_t **)avframe->data, avframe->nb_samples);
                //获取缓冲区大小
                int buffer_size = av_samples_get_buffer_size(NULL, out_bn_channel, avframe->nb_samples, avcodec_ctx->sample_fmt, 1);
                fwrite(outBuffer, 1, buffer_size, file_pcm);
                current_index ++;
                NSLog(@"解码第几帧 %d",current_index);
            }
        }
    }
    av_packet_free(&avpacket);
    fclose(file_pcm);
    av_frame_free(&avframe);
    free(outBuffer);
    avcodec_close(avcodec_ctx);
    avformat_free_context(av_ctx);
}
@end
