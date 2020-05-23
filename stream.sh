#!/bin/bash
# SOURCE: source file
# RTMPSERVER: destination server hostname/ip
# STARTDELAY: delay until clients start streaming
# STREAMNAME: what to title the stream
set +euxo pipefail

USAGE="Usage: $0 SOURCE RTMPSERVER [STARTDELAY] [STREAMNAME]"
SOURCE=${1:?$USAGE}
SERVER=${2:?$USAGE}
STARTDELAY=${3:-"10"}
NAME=${4:-"stream"}

function get_time {
    curl -s "http://time.akamai.com"
}

START=$(($(get_time) + STARTDELAY))
echo "Stream link: http://${SERVER}/tv/${NAME}?start=${START}"

# by default stream is available at http://${SERVER}/tv
# otherwise at http://${SERVER}/tv/${NAME}

# stream specifiers 'a': audio, 'v': video
# -re               read input at native frame rate, for livestreaming \
# -i                video file as input
# -loop -1          don't loop the stream
# -vcodec copy      don't change the video codec, just read/write the bitstream
# -codec:a aac      encode audio stream as aac
# -codec:v libx254  encode video stream as libx254
# -b:a 160k         set audio bitrate
# -ar 44100         set audio sampling frequency (CD quality)
# -ac 1             one audio channel in output
# -f flv            set container type (required for rtmp)
ffmpeg -hide_banner -stats -loglevel warning \
    -re \
    -i "${SOURCE}" \
    -s 1280x720 \
    -vcodec copy \
    -loop -1 \
    -codec:a aac \
    -codec:v libx264 \
    -preset fast \
    -pix_fmt yuv420p \
    -threads 0 \
    -ac 1 \
    -strict experimental \
    -f flv \
    "rtmp:${SERVER}/live/${NAME}"
    #-ar 44100 \
    #-b:a 128k \
    #-codec:a aac \
