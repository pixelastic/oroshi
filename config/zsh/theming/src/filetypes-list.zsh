# FILETYPE_GROUPS {{{
# This file will be read by env-generate-filetypes to generate the list of ENV
# variables used to color files in ls (and other places)
#
# - by default, patterns will be treated as extensions
# - patterns wrapped in [] will be treated as exact mac
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
  md \
  txt \
"

# Script files
FILETYPE_GROUPS[script:color]="VIOLET"
FILETYPE_GROUPS[script:icon]=" "
FILETYPE_GROUPS[script:patterns]="\
  au3 \
  bats \
  cfg \
  conf \
  css \
  eot \
  gemspec \
  html \
  ini \
  jsonl \
  json \
  js \
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
FILETYPE_GROUPS[image:color]="YELLOW_5"
FILETYPE_GROUPS[image:icon]=" "
FILETYPE_GROUPS[image:patterns]="\
  gif \
  ico \
  jpg \
  jpeg \
  png \
"

# Audio files
FILETYPE_GROUPS[audio:color]="BLUE_4"
FILETYPE_GROUPS[audio:icon]=" "
FILETYPE_GROUPS[audio:patterns]="\
  mp3 \
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
  cbr \
  cbz \
  deb \
  gz \
  rar \
  tar.gz \
  tar.xz \
  tgz \
  txz \
  zip \
"

# Documents files
FILETYPE_GROUPS[document:color]="YELLOW_6"
FILETYPE_GROUPS[document:icon]=" "
FILETYPE_GROUPS[document:bold]="1"
FILETYPE_GROUPS[document:patterns]="\
  epub \
  mobi \
  pdf \
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
  [_algolia_api_key] \
"
# }}}

# FILETYPES {{{
FILETYPES[pdf:bold]="1"
FILETYPES[vim:icon]=" "
FILETYPES[md:icon]=" "
FILETYPES[mkd:icon]=" "
FILETYPES[js:icon]=" "
FILETYPES[js:color]="YELLOW"
# }}}
