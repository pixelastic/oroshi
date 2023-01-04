# FILETYPE_GROUPS {{{
# - patterns starting with a dot (as in .md) are checked against the end of
#   the filename
# - patterns not starting with a dot are checked against the whole filename
declare -gA FILETYPE_GROUPS
FILETYPE_GROUPS=()
declare -gA FILETYPES
FILETYPES=()

# FILETYPE_GROUPS {{{
# Text files
FILETYPE_GROUPS[text,patterns]="\
  CODEOWNERS \
  LICENSE \
  MAINTAINERS \
  .md \
  .txt \
"
FILETYPE_GROUPS[text,color]="orange5"
FILETYPE_GROUPS[text,icon]=" "

# Script files
FILETYPE_GROUPS[script,patterns]="\
  .au3 \
  .bats \
  .cfg \
  .conf \
  .css \
  .eot \
  .gemspec \
  .html \
  .ini \
  .json \
  .js \
  .ps1 \
  .pug \
  .py \
  .rb \
  .ru \
  .sass \
  .scss \
  .sh \
  .svg \
  .theme \
  .toml \
  .tsx \
  .ts \
  .ttf \
  .vim \
  .woff \
  .xml \
  .yaml \
  .yml \
  .zsh \
  Dockerfile \
  Gemfile \
  Guardfile \
  Rakefile \
  Vagrantfile \
"
FILETYPE_GROUPS[script,color]="purple5"
FILETYPE_GROUPS[script,icon]=" "

# Image files
FILETYPE_GROUPS[image,patterns]="\
  .gif \
  .ico \
  .jpg \
  .png \
"
FILETYPE_GROUPS[image,color]="yellow5"
FILETYPE_GROUPS[image,icon]=" "

# Audio files
FILETYPE_GROUPS[audio,patterns]="\
  .mp3 \
  .wav \
"
FILETYPE_GROUPS[audio,color]="blue4"
FILETYPE_GROUPS[audio,icon]=" "

# Video files
FILETYPE_GROUPS[video,patterns]="\
  .avi \
  .mkv \
  .mp4 \
  .mpg \
"
FILETYPE_GROUPS[video,color]="blue"
FILETYPE_GROUPS[video,icon]=" "
FILETYPE_GROUPS[video,bold]="1"

# Archive files
FILETYPE_GROUPS[archive,patterns]="\
  .cbr \
  .cbz \
  .deb \
  .gz \
  .rar \
  .tar.gz \
  .tgz \
  .zip \
"
FILETYPE_GROUPS[archive,color]="green"
FILETYPE_GROUPS[archive,icon]=" "
FILETYPE_GROUPS[archive,bold]="1"

# Documents files
FILETYPE_GROUPS[document,patterns]="\
  .epub \
  .pdf \
"
FILETYPE_GROUPS[document,color]="yellow7"
FILETYPE_GROUPS[document,icon]=" "

# Binary files
FILETYPE_GROUPS[binary,patterns]=".exe"
FILETYPE_GROUPS[binary,color]="blue"
FILETYPE_GROUPS[binary,icon]=" "
FILETYPE_GROUPS[binary,bold]="1"

# Minor files files
FILETYPE_GROUPS[minor,patterns]="\
  .js.map \
  .lock \
  .log \
  .min.css \
  .min.js \
  .part \
  .pid \
  _algolia_api_key \
"
FILETYPE_GROUPS[minor,color]="gray7"
FILETYPE_GROUPS[minor,icon]=" "
# }}}

# FILETYPES {{{
FILETYPES[.pdf,bold]="1"
# }}}


