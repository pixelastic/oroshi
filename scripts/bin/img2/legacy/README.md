# img

This repository holds a bunch of command line scripts I use to manipulate images
(jpg, png and gif).

## ⚠ Work in progress ⚠

## Dependencies

- ImageMagick (`convert`, `mogrify`, `identify`)
- giflossy ([Gifsicle](https://github.com/pornel/giflossy/releases) fork)
- gifify
- jpegoptim
- ffmpeg
- exiftool
- pngquant
- dssim

## Available scripts

### Conversion

#### jpg2png
  Will convert any number of JPG images into their JPG versions

#### png2jpg
  Will convert any number of PNG images into their JPG versions

#### png2ico
  Will convert any number of PNG images into their ICO versions

#### gif2png
  Will convert any number of GIF images into their PNG versions. Note that if
  the GIF is animated, the first frame will be extracted instead.

### Modification

#### resize
  Will resize the input files to the specified dimensions. Image ratio will be
  kept if possible. Pass `-f` to force the dimensions.

#### gifmin
  Losslessly compress GIF files

### Information

#### gif-is-animated
  Check if the input file is an animated GIF or not

#### width
  Return the width of the specified files

#### height
  Return the height of the specified files

#### dimensions
  Return the width x height of the specified files

## Contributing

Run `./scripts/test` to run the tests
