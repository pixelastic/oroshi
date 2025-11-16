# FILETYPE_GROUPS {{{
# This file will be read by env-generate-filetypes to generate the list of ENV
# variables used to color files in ls (and other places)
#
# - by default, patterns will be treated as extensions
# - patterns wrapped in [] will be treated as exact match
declare -A FILETYPE_GROUPS
FILETYPE_GROUPS=()
declare -A FILETYPES
FILETYPES=()

# FILETYPE_GROUPS {{{
# Text files
FILETYPE_GROUPS[text:color]="AMBER"
FILETYPE_GROUPS[text:icon]=" "
FILETYPE_GROUPS[text:patterns]="\
  [CODEOWNERS] \
  [LICENSE] \
  [MAINTAINERS] \
  [README] \
  md \
  txt \
  vtt \
"

# Script files
FILETYPE_GROUPS[script:color]="VIOLET"
FILETYPE_GROUPS[script:icon]=" "
FILETYPE_GROUPS[script:patterns]="\
  au3 \
  bats \
  cjs \
  css \
  eot \
  gemspec \
  html \
  jsonl \
  json \
  js \
  jsx \
  kbd \
  lua \
  mjs \
  ps1 \
  pug \
  py \
  rb \
  ru \
  sass \
  scss \
  sh \
  svg \
  theme \
  tmTheme \
  toml \
  tsx \
  ts \
  ttf \
  vim \
  vue \
  woff \
  xml \
  yaml \
  yml \
  zsh \
  [Dockerfile] \
  [Gemfile] \
  [Guardfile] \
  [Rakefile] \
  [Vagrantfile] \
"

# Config files
FILETYPE_GROUPS[config:color]="YELLOW"
FILETYPE_GROUPS[config:icon]=" "
FILETYPE_GROUPS[config:patterns]="\
  cfg \
  conf \
  csv \
  desktop \
  ini \
  opt \
  rmp \
  service \
  [.envrc] \
  [.fdignore] \
  [.eslintignore] \
  [.gitattributes] \
  [.gitignore] \
  [.gitmodules] \
  [.nvmrc] \
  [.prettierignore] \
  [.stylelintignore] \
  [.yarnrc] \
"

# Image files
FILETYPE_GROUPS[image:color]="YELLOW_6"
FILETYPE_GROUPS[image:icon]=" "
FILETYPE_GROUPS[image:patterns]="\
  avif \
  bmp \
  gif \
  ico \
  jpeg \
  jpg \
  png \
"

# Audio files
FILETYPE_GROUPS[audio:color]="BLUE_5"
FILETYPE_GROUPS[audio:icon]=" "
FILETYPE_GROUPS[audio:bold]="1"
FILETYPE_GROUPS[audio:patterns]="\
  m4a \
  mp3 \
  ogg \
  wav \
"

# Video files
FILETYPE_GROUPS[video:color]="BLUE"
FILETYPE_GROUPS[video:icon]=" "
FILETYPE_GROUPS[video:bold]="1"
FILETYPE_GROUPS[video:patterns]="\
  avi \
  mkv \
  mp4 \
  mpg \
"

# Archive files
FILETYPE_GROUPS[archive:color]="GREEN"
FILETYPE_GROUPS[archive:icon]=" "
FILETYPE_GROUPS[archive:bold]="1"
FILETYPE_GROUPS[archive:patterns]="\
  7z \
  cbr \
  cbz \
  deb \
  gz \
  rar \
  tar.gz \
  tar.xz \
  tgz \
  txz \
  xz \
  zip \
"

# Documents files
FILETYPE_GROUPS[document:color]="YELLOW_6"
FILETYPE_GROUPS[document:icon]=" "
FILETYPE_GROUPS[document:bold]="1"
FILETYPE_GROUPS[document:patterns]="\
  pdf \
"

FILETYPE_GROUPS[ebook:color]="YELLOW_7"
FILETYPE_GROUPS[ebook:icon]=" "
FILETYPE_GROUPS[ebook:bold]="1"
FILETYPE_GROUPS[ebook:patterns]="\
  epub \
  mobi \
"

# Binary files
FILETYPE_GROUPS[binary:color]="BLUE"
FILETYPE_GROUPS[binary:icon]=" "
FILETYPE_GROUPS[binary:bold]="1"
FILETYPE_GROUPS[binary:patterns]="exe"

# Minor files files
FILETYPE_GROUPS[minor:color]="NEUTRAL"
FILETYPE_GROUPS[minor:icon]=" "
FILETYPE_GROUPS[minor:patterns]="\
  js.map \
  lock \
  log \
  min.css \
  min.js \
  part \
  pid \
  session \
  [_algolia_api_key] \
"

# Unknown filetypes
FILETYPE_GROUPS[unknown:color]="RED_4"
FILETYPE_GROUPS[unknown:icon]=" "
FILETYPE_GROUPS[unknown:patterns]="\
  [__UNKNOWN__] \
"
# }}}

# FILETYPES OVERRIDES{{{
FILETYPES[MOBI:bold]="0"
FILETYPES[VIM:icon]=" "
FILETYPES[MD:icon]=" "
FILETYPES[MKD:icon]=" "
FILETYPES[JS:icon]=" "
FILETYPES[JS:color]="YELLOW"
# }}}
