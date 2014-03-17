#!/bin/bash
#
# transcode-video.sh
#
# Copyright (c) 2013 Don Melton
#
# This script is a wrapper for `HandBrakeCLI` (see: <http://handbrake.fr/>).
# The purpose of this script is to transcode a video file into a format and
# size similar to a video available for download from the iTunes Store.
#
# While this script works best with a Blu-ray Disc or DVD rip extracted using
# `MakeMKV` (see: <http://www.makemkv.com/>), it will work with any reasonable
# video file as input.
#
# The goal of this script is NOT to make an exact pixel-for-pixel,
# wave-for-wave copy of the input. That's not practical. Instead, the goal is
# to create a portable version of that input as quickly as possible at a
# reasonable quality --- something that can be enjoyed without prejudice on
# both a small tablet computer and a large, wide-screen home entertainment
# system with 5.1 surround sound.
#
# Also, it should be possible for the output of this script to be served by
# media management systems like Plex (see: <http://www.plexapp.com/>) without
# further dynamic transcoding. In other words, transcode a video file with
# this script and never have to explicitly or implicitly transcode it again.
#
# By default this script will try to create an MP4 format file with dual audio
# tracks (like iTunes video), but it can also output Matroska format (i.e.
# MKV) with a single audio track.
#
# For Blu-ray Disc input, this script will transcode the video with an average
# bitrate of 5000 kbps, varying 500-600 kbps either way. Again, this is like
# iTunes video.
#
# Please note that this script does NOT use the default x264 single-pass
# average bitrate (ABR) mode. Instead, it modifies that mode using the x264
# `ratetol=inf` option. This causes ABR mode to behave more like constant rate
# factor (CRF) mode, varying the bitrate to maintain quality.
#
# However, while CRF mode can create wildly different output bitrates and file
# sizes depending on input, the modified ABR mode used here is much more
# predictable. And for some input, can create better output quality than, for
# example, using CRF mode with a quality setting of `20`.
#
# Also note that this modified ABR mode requires usage by this script of the
# x264 video buffer verifier (VBV) system. Otherwise the output video might
# not play on some output devices.
#
# For DVD input, this script will transcode the video with an average bitrate
# of 1800 kbps for PAL format discs and 1500 kbps for NTSC format.
#
# For all other video input, this script will choose an output average bitrate
# based on the input width, height and bitrate. That chosen output bitrate
# will never be greater that 80% of the input, nor will it exceed targets for
# similarly-dimensioned Blu-rays and DVDs.
#
# If faster transcoding time or a smaller output file size is desired for
# Blu-ray Disc and other 1080p video input, this script can scale that input
# to fit within a 1280x720 pixel bounds, targeting an average output bitrate
# of 4000 kbps. Again, much like 720p iTunes video.
#
# By default this script uses the x264 `fast` preset to transcode all video.
# This is done to achieve both the performance AND quality goals. Transcoding
# with the `fast` preset still results in high-quality output.
#
# However, if even higher quality video is desired, access to both the
# `medium` and `slow` x264 presets are available. Please note that using these
# other presets does NOT guarantee higher-quality output. Also, even though
# x264 has still more presets, faster settings are undesirable and slower ones
# are unnecessary.
#
# For input with multi-channel audio, two audio tracks will be created for MP4
# file format output. The first track will be stereo AAC audio and the second
# track will be multi-channel AC-3 audio. For MKV file format output, only the
# AC-3 surround track will be created.
#
# For stereo or mono audio input, only a single AAC audio track is created for
# both MP4 and MKV file formats.
#
# Multi-channel audio is transcoded at 384 kbps, stereo at 160 kbps and mono
# at 80 kbps.
#
# For input with Blu-ray- or DVD-compatible subtitles (PGS or VobSub formats),
# this script will automatically burn the first subtitle into the video if
# that subtitle has its forced flag set.
#
# For other subtitle manipulation, it's best to use another program on this
# script's output after transcoding is complete.
#
# Some of this script's various behaviors can be changed or disabled via
# command line options.
#
# This script does NOT facilitate the automatic cropping behavior of
# HandBrakeCLI due to reliability problems with that feature. Instead,
# cropping bounds must be passed explicitly at the command line. Use the
# `detect-crop.sh` script to aid in determining these parameters.
#
# WARNING: This script was designed to work on OS X. There's no guarantee it
# will work on a different operating system.
#

about() {
    cat <<EOF
$program 1.1 of November 29, 2013
Copyright (c) 2013 Don Melton
EOF
    exit 0
}

usage() {
    cat <<EOF
Transcode video file (works best with Blu-ray or DVD rip) into MP4
(or optionally Matroska) format, with configuration and at bitrate
similar to popluar online downloads.

Usage: $program [OPTION]... [FILE]

    --mkv           output Matroska format with single audio track
    --preset NAME   use x264 fast|medium|slow preset (default: fast)
    --resize        resize video to fit within 1280x720 pixel bounds
    --rate FPS      force video frame rate (default: based on input)
    --no-surround   don't output multi-channel AC-3 audio
    --crop T:B:L:R  set video croping bounds (default: 0:0:0:0)
    --no-auto-burn  don't automatically burn first "forced" subtitle

    --help          display this help and exit
    --version       output version information and exit

Requires \`HandBrakeCLI\` and \`mediainfo\` executables in \$PATH.
Output and log file are written to current working directory.
EOF
    exit 0
}

syntax_error() {
    echo "$program: $1" >&2
    echo "Try \`$program --help\` for more information." >&2
    exit 1
}

die() {
    echo "$program: $1" >&2
    exit ${2:-1}
}

readonly program="$(basename "$0")"

case $1 in
    --help)
        usage
        ;;
    --version)
        about
        ;;
esac

container_format='mp4'
container_format_options='--large-file --optimize'
preset_options='--x264-preset fast'
reference_frames_option=''
resize=''
frame_rate_options=''
surround='yes'
crop='0:0:0:0'
size_options='--strict-anamorphic'
auto_burn='yes'

while [ "$1" ]; do
    case $1 in
        --mkv)
            container_format='mkv'
            container_format_options=''
            ;;
        --preset)
            preset="$2"
            shift

            case $preset in
                fast|slow)
                    preset_options="--x264-preset $preset"
                    ;;
                medium)
                    preset_options=''
                    ;;
                *)
                    syntax_error "unsupported preset: $preset"
                    ;;
            esac
            ;;
        --resize)
            resize='yes'
            ;;
        --rate)
            frame_rate_options="--rate $2"
            shift
            ;;
        --no-surround)
            surround=''
            ;;
        --crop)
            crop="$2"
            shift
            ;;
        --no-auto-burn)
            auto_burn=''
            ;;
        -*)
            syntax_error "unrecognized option: $1"
            ;;
        *)
            break
            ;;
    esac
    shift
done

readonly input="$1"

if [ ! "$input" ]; then
    syntax_error 'too few arguments'
fi

if [ ! -f "$input" ]; then
    die "input file not found: $input"
fi

readonly output="$(basename "$input" | sed 's/\.[^.]*$//').$container_format"

if [ -e "$output" ]; then
    die "output file already exists: $output"
fi

if ! $(which HandBrakeCLI >/dev/null); then
    die 'executable not in $PATH: HandBrakeCLI'
fi

if ! $(which mediainfo >/dev/null); then
    die 'executable not in $PATH: mediainfo'
fi

# Determine maximum output video bitrate based on input size:
#   5000 kbps for Blu-ray or other content larger than 1280x720 pixels.
#   4000 kbps for resized or other content larger than 720x576 pixels.
#   1800 kbps for PAL DVD or other content taller than 480 pixels.
#   1500 kbps for NTSC DVD or other content.

# Limit output video bitrate to 80% of input video bitrate.

# Set `x264` video buffer verifier (VBV) size and maximum rate to values
# appropriate for H.264 level with High profile:
#   25000 for level 4.0 (e.g. Blu-ray input)
#   17500 for level 3.1 (e.g. 720p input)
#   12500 for level 3.0 (e.g. DVD input)

# When using `slow` preset for output larger than 1280x720 pixels, limit
# reference frames to 4 to maintain compatibility with H.264 level 4.0.

readonly width="$(mediainfo --Inform='Video;%Width%' "$input")"
readonly height="$(mediainfo --Inform='Video;%Height%' "$input")"

if (($width > 1280)) || (($height > 720)); then

    if [ ! "$resize" ]; then
        vbv_value='25000'
        max_bitrate='5000'

        if [ "$preset" == 'slow' ]; then
            reference_frames_option='ref=4:'
        fi
    else
        vbv_value='17500'
        max_bitrate='4000'
        size_options='--maxWidth 1280 --maxHeight 720 --loose-anamorphic'
    fi

elif (($width > 720)) || (($height > 576)); then
    vbv_value='17500'
    max_bitrate='4000'
else
    vbv_value='12500'

    if (($height > 480)); then
        max_bitrate='1800'
    else
        max_bitrate='1500'
    fi
fi

readonly min_bitrate="$((max_bitrate / 2))"

bitrate="$(mediainfo --Inform='Video;%BitRate%' "$input")"

if [ ! "$bitrate" ]; then
    bitrate="$(mediainfo --Inform='General;%OverallBitRate%' "$input")"
    bitrate="$(((bitrate / 10) * 9))"
fi

if [ "$bitrate" ]; then
    bitrate="$(((bitrate / 5) * 4))"
    bitrate="$((bitrate / 1000))"
    bitrate="$(((bitrate / 100) * 100))"

    if (($bitrate > $max_bitrate)); then
        bitrate="$max_bitrate"

    elif (($bitrate < $min_bitrate)); then
        bitrate="$min_bitrate"
    fi
else
    bitrate="$min_bitrate"
fi

# Set peak video frame rate to 30 fps so `HandBrakeCLI` can dynamically
# determine output frame rate, but force output frame rate of `23.976` if
# input frame rate is exactly `29.970`, or if user has indicated a specific
# output frame rate.

frame_rate="$(mediainfo --Inform='Video;%FrameRate_Original%' "$input")"

if [ ! "$frame_rate" ]; then
    frame_rate="$(mediainfo --Inform='Video;%FrameRate%' "$input")"
fi

if [ ! "$frame_rate_options" ]; then

    if [ "$frame_rate" == '29.970' ]; then
        frame_rate_options='--rate 23.976'
    else
        frame_rate_options='--rate 30 --pfr'
    fi
fi

# Transcode multi-channel audio at 384 kbps in Dolby Digital (AC-3) format.
# Use existing audio if it's already in that format and at or below that
# bitrate.

# Transcode stereo or mono audio using `HandBrakeCLI` default behavior,
# Advanced Audio Coding (AAC) format at 160 or 80 kbps. Use existing audio if
# it's already in that format.

# For MP4 output, transcode multi-channel audio input first in stereo AAC
# format and then add a second audio track in multi-channel AC-3 format.

# Allow user to decide whether to output multi-channel AC-3 audio.

readonly audio_channels="$(mediainfo --Inform='Audio;%Channels%' "$input" | sed 's/^\([0-9]\).*$/\1/')"
readonly audio_format="$(mediainfo --Inform='General;%Audio_Format_List%' "$input" | sed 's| /.*||')"

if [ "$surround" ] && (($audio_channels > 2)); then
    readonly audio_bitrate="$(mediainfo --Inform='Audio;%BitRate%' "$input")"

    if [ "$audio_format" == 'AC-3' ] && (($audio_bitrate <= 384000)); then

        if [ "$container_format" == 'mp4' ]; then
            audio_options='--aencoder ca_aac,copy:ac3'
        else
            audio_options='--aencoder copy:ac3'
        fi

    elif [ "$container_format" == 'mp4' ]; then
        audio_options='--aencoder ca_aac,ac3 --ab ,384'
    else
        audio_options='--aencoder ac3 --ab 384'
    fi

elif [ "$audio_format" == 'AAC' ]; then
    audio_options='--aencoder copy:aac'
else
    audio_options=''
fi

# Detelecine video if input frame rate is exactly `29.970` fps. This forces
# consistent output frame rate for NTSC DVD input, smoothing playback.

if [ "$frame_rate" == '29.970' ]; then
    filter_options='--detelecine'
else
    filter_options=''
fi

# Automatically burn first subtitle into video output if that subtitle has its
# forced flag set and it's a supported format for burning. But allow user to
# disable this behavior.

readonly subtitle_forced="$(mediainfo --Inform='Text;%Forced%' "$input" | sed 's/^\(Yes\).*$/\1/')"
readonly subtitle_format="$(mediainfo --Inform='Text;%Format%' "$input" | sed 's/^\(PGS\).*$/\1/;s/^\(VobSub\).*$/\1/')"

if [ "$auto_burn" ] && [ "$subtitle_forced" == 'Yes' ] && ( [ "$subtitle_format" == 'PGS' ] || [ "$subtitle_format" == 'VobSub' ] ); then
    subtitle_options='--subtitle 1 --subtitle-burned'
else
    subtitle_options=''
fi

echo "Transcoding: $input" >&2

# Transcode video in single-pass average bitrate (ABR) mode, but set rate
# tolerance to maximum (using `ratetol=inf` option) so behavior is more like
# constant rate factor (CRF) mode.

time HandBrakeCLI \
    --markers \
    $container_format_options \
    --encoder x264 \
    $preset_options \
    --encopts ${reference_frames_option}vbv-maxrate=$vbv_value:vbv-bufsize=$vbv_value:ratetol=inf \
    --vb $bitrate \
    $frame_rate_options \
    $audio_options \
    --crop $crop \
    $size_options \
    $filter_options \
    $subtitle_options \
    --input "$input" \
    --output "$output" \
    2>&1 | tee -a "${output}.log"