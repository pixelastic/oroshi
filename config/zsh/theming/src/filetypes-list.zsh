# FILETYPE_GROUPS {{{
# - patterns starting with a dot (as in .md) are checked against the end of
#   the filename
# - patterns not starting with a dot are checked against the whole filename
declare -A FILETYPE_GROUPS
FILETYPE_GROUPS=()
declare -A FILETYPES
FILETYPES=()

# FILETYPE_GROUPS {{{
# Text files
FILETYPE_GROUPS[text,color]="AMBER"
FILETYPE_GROUPS[text,icon]=" "
FILETYPE_GROUPS[text,patterns]="\
  CODEOWNERS \
  LICENSE \
  MAINTAINERS \
  .md \
  .txt \
"

# Script files
FILETYPE_GROUPS[script,color]="VIOLET"
FILETYPE_GROUPS[script,icon]=" "
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

# Image files
FILETYPE_GROUPS[image,color]="YELLOW_5"
FILETYPE_GROUPS[image,icon]=" "
FILETYPE_GROUPS[image,patterns]="\
  .gif \
  .ico \
  .jpg \
  .png \
"

# Audio files
FILETYPE_GROUPS[audio,color]="BLUE_4"
FILETYPE_GROUPS[audio,icon]=" "
FILETYPE_GROUPS[audio,patterns]="\
  .mp3 \
  .wav \
"

# Video files
FILETYPE_GROUPS[video,color]="BLUE"
FILETYPE_GROUPS[video,icon]=" "
FILETYPE_GROUPS[video,bold]="1"
FILETYPE_GROUPS[video,patterns]="\
  .avi \
  .mkv \
  .mp4 \
  .mpg \
"

# Archive files
FILETYPE_GROUPS[archive,color]="GREEN"
FILETYPE_GROUPS[archive,icon]=" "
FILETYPE_GROUPS[archive,bold]="1"
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

# Documents files
FILETYPE_GROUPS[document,color]="YELLOW_7"
FILETYPE_GROUPS[document,icon]=" "
FILETYPE_GROUPS[document,patterns]="\
  .epub \
  .pdf \
"

# Binary files
FILETYPE_GROUPS[binary,color]="BLUE"
FILETYPE_GROUPS[binary,icon]=" "
FILETYPE_GROUPS[binary,bold]="1"
FILETYPE_GROUPS[binary,patterns]=".exe"

# Minor files files
FILETYPE_GROUPS[minor,color]="GRAY_7"
FILETYPE_GROUPS[minor,icon]=" "
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
# }}}

# FILETYPES {{{
FILETYPES[.pdf,bold]="1"
FILETYPES[.vim,icon]=" "
FILETYPES[.js,icon]=" "
FILETYPES[.js,color]="YELLOW"
# }}}


