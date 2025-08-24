#!/bin/bash
exit 0

# input file
file="Groundhog Day [День сурка] (1993) 1920x1040 BDRip RusEngSubsChpt.mkv"

# print list of channels
ffprobe $file 2>&1 >/dev/null | grep 'Stream.\*Audio'

# output example:
#  Stream #0:1(rus): Audio: ac3, 48000 Hz, 5.1(side), fltp, 448 kb/s (default)
#  Stream #0:2(rus): Audio: ac3, 48000 Hz, 5.1(side), fltp, 448 kb/s
#  Stream #0:3(rus): Audio: ac3, 48000 Hz, stereo, fltp, 192 kb/s
#  Stream #0:4(rus): Audio: ac3, 48000 Hz, stereo, fltp, 192 kb/s
#  Stream #0:5(rus): Audio: dts (dca) (DTS), 48000 Hz, 5.1(side), fltp, 1536 kb/s
#  Stream #0:6(rus): Audio: ac3, 48000 Hz, stereo, fltp, 192 kb/s
#  Stream #0:7(rus): Audio: ac3, 48000 Hz, stereo, fltp, 192 kb/s
#  Stream #0:8(rus): Audio: ac3, 48000 Hz, stereo, fltp, 192 kb/s
#  Stream #0:9(rus): Audio: ac3, 48000 Hz, stereo, fltp, 192 kb/s
#  Stream #0:10(eng): Audio: dts (dca) (DTS), 48000 Hz, 5.1(side), fltp, 1536 kb/s
#  Stream #0:11(eng): Audio: ac3, 48000 Hz, stereo, fltp, 192 kb/s

# extract audio
ffmpeg -i $file -map 0:1 -acodec copy ru.ac3
ffmpeg -i $file -map 0:10 -acodec copy en.dts

# verify we have correct tracks - play it
mpv --term-osd-bar --term-osd-bar-chars="█▓▒░ " ru.ac3
mpv --term-osd-bar --term-osd-bar-chars="█▓▒░ " en.dts

# extract only front_center channel from 5.1 - speach
ffmpeg -i ru.ac3 -filter_complex "channelsplit=channel_layout=5.1:channels=FC[center]" -map "[center]" ru_front_center.wav
ffmpeg -i en.dts -filter_complex "channelsplit=channel_layout=5.1:channels=FC[center]" -map "[center]" en_front_center.wav

# join to 5.1
ffmpeg -i ru_front_center.wav -i en_front_center.wav -filter_complex "[0:a][0:a][0:a][0:a][1:a][1:a]join=inputs=6:channel_layout=5.1[a]" -map "[a]" ru_en_5_1.wav
