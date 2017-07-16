#!/bin/sh

# requires imagemagik (brew install imagemagik)

sips -Z 1024 *.JPG
mogrify -format png -dither None -colors 64 *.JPG