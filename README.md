# ffppeg_audio_decode
### 1 ：初始化AVFormatContext
### 2 ：使用avformat_find_stream_info将文件和AVFormatContext关联起来
### 3 ：使用av_find_best_stream查找音视频id （4.3之后）
### 4 ：4.3之后使用avcodec_parameters_to_context初始化AVCodecContext
### 5 ： avcodec_find_decoder初始化AVCodec
### 6 ：avcodec_open2打开编解码器
### 7 ： swr_alloc_set_opts设置音频默认参数
### 8 ： avcodec_send_packet，avcodec_receive_frame 视频数据解码（4.3之后）
### 9 ： 便利AVFrame数据得到bufferData
