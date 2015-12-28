#!/bin/bash
echo $1 > fifo
./play.sh&
/usr/bin/omxplayer -o local "$1" < fifo&
