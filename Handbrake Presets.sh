 /Applications/HandBrakeCLI  -i /Users/fcpuser/Desktop/JTDA_OPEN.mov  -o /Users/fcpuser/Desktop/houtput.mp4 -b 5000 --vfr -x264 --x264-preset slow
 <fast>
/*  fast version  */
 /Applications/HandBrakeCLI -i /Users/fcpuser/Desktop/ -o /Users/fcpuser/Desktop/OUTPUT.mp4 -m -E copy --audio-copy-mask ac3,dts,dtshd --audio-fallback ffac3 -e x264 -q 20 -x level=4.1:ref=4:b-adapt=2:direct=auto:me=umh:subq=8:rc-lookahead=50:psy-rd=1.0,0.15:deblock=-1,-1:vbv-bufsize=30000:vbv-maxrate=40000:slices=4
 
 /*  Quality Setting  */
 
 /Applications/HandBrakeCLI  -i /Users/fcpuser/Desktop/input.mov  -o /Users/fcpuser/Desktop/output.mp4 -m -E copy --audio-copy-mask ac3,dts,dtshd --audio-fallback ffac3 -e x264 -q 20 -x level=4.1:ref=4:b-adapt=2:direct=auto:me=umh:subq=8:rc-lookahead=50:psy-rd=1.0,0.15:deblock=-1,-1:vbv-bufsize=3000:vbv-maxrate=50000:slices=4