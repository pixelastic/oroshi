# shellcheck disable=SC2088
# Display config for the most common projects.
# Colors and icons will be used in tmux and for short path in zsh
declare -A PROJECTS
PROJECTS=()
PROJECTS[aberlaas:background]="YELLOW_7"
PROJECTS[aberlaas:foreground]="GRAY_9"
PROJECTS[aberlaas:icon]=" "
PROJECTS[aberlaas:path]="~/local/www/projects/aberlaas/"
PROJECTS[algolia-indexing:background]="BLUE_7"
PROJECTS[algolia-indexing:foreground]="GRAY_2"
PROJECTS[algolia-indexing:icon]=" "
PROJECTS[algolia-indexing:path]="~/local/www/projects/algolia-indexing/"
PROJECTS[algolia:background]="BLUE_7"
PROJECTS[algolia:foreground]="GRAY_2"
PROJECTS[algolia:icon]=" "
PROJECTS[alme:background]="PINK_8"
PROJECTS[alme:foreground]="GRAY_3"
PROJECTS[alme:icon]="(.) "
PROJECTS[alme:path]="~/local/www/projects/alme/"
PROJECTS[aoinan:background]="ORANGE_8"
PROJECTS[aoinan:foreground]="GRAY_3"
PROJECTS[aoinan:icon]="<> "
PROJECTS[aoinan:path]="~/local/www/projects/aoinan/"
PROJECTS[api-cloudflare:background]="ORANGE"
PROJECTS[api-cloudflare:foreground]="WHITE"
PROJECTS[api-cloudflare:icon]="  "
PROJECTS[api-cloudflare:path]="~/local/www/pixelastic.com/api.pixelastic.com/cloudflare/"
PROJECTS[api-fly:background]="PURPLE"
PROJECTS[api-fly:foreground]="WHITE"
PROJECTS[api-fly:icon]="  "
PROJECTS[api-fly:path]="~/local/www/pixelastic.com/api.pixelastic.com/fly/"
PROJECTS[api-netlify:background]="TEAL_6"
PROJECTS[api-netlify:foreground]="WHITE"
PROJECTS[api-netlify:icon]="  "
PROJECTS[api-netlify:path]="~/local/www/pixelastic.com/api.pixelastic.com/netlify/"
PROJECTS[armory:background]="GRAY"
PROJECTS[armory:foreground]="YELLOW_5"
PROJECTS[armory:icon]=" "
PROJECTS[armory:path]="~/local/www/pixelastic.com/gamemaster/armory/"
PROJECTS[bg:background]="ORANGE"
PROJECTS[bg:foreground]="WHITE"
PROJECTS[bg:icon]="力"
PROJECTS[blog:background]="GREEN"
PROJECTS[blog:foreground]="WHITE"
PROJECTS[blog:icon]="  "
PROJECTS[blog:path]="~/local/www/pixelastic.com/blog.pixelastic.com/"
PROJECTS[books:icon]=" "
PROJECTS[callirhoe:background]="TEAL_9"
PROJECTS[callirhoe:foreground]="GRAY_2"
PROJECTS[callirhoe:icon]=" "
PROJECTS[callirhoe:path]="~/local/www/projects/callirhoe/"
PROJECTS[comics:icon]="X"
PROJECTS[contentsquare:background]="WHITE"
PROJECTS[contentsquare:foreground]="BLUE_8"
PROJECTS[contentsquare:icon]=" "
PROJECTS[contentsquare:path]="~/local/www/contentsquare/"
PROJECTS[crafting:background]="YELLOW_9"
PROJECTS[crafting:icon]=" "
PROJECTS[dashboards:background]="BLUE_3"
PROJECTS[devrel:background]="TEAL_6"
PROJECTS[devrel:foreground]="GRAY_3"
PROJECTS[devrel:icon]=" "
PROJECTS[dropbox:icon]=" "
PROJECTS[dungeons-pages:background]="YELLOW_6"
PROJECTS[dungeons-pages:foreground]="BLACK"
PROJECTS[dungeons-pages:icon]="  "
PROJECTS[dungeons-pages:path]="~/local/www/pixelastic.com/gamemaster/dungeons/dungeons-pages/"
PROJECTS[dungeons-pictures:background]="YELLOW_5"
PROJECTS[dungeons-pictures:foreground]="BLACK"
PROJECTS[dungeons-pictures:icon]="  "
PROJECTS[dungeons-pictures:path]="~/local/www/pixelastic.com/gamemaster/dungeons/dungeons-pictures/"
PROJECTS[dungeons:background]="YELLOW_7"
PROJECTS[dungeons:foreground]="BLACK"
PROJECTS[dungeons:icon]=" "
PROJECTS[dungeons:path]="~/local/www/pixelastic.com/gamemaster/dungeons/dungeons/"
PROJECTS[ensureUrlTrailingSlash:background]="BLUE_9"
PROJECTS[ensureUrlTrailingSlash:foreground]="GRAY_2"
PROJECTS[ensureUrlTrailingSlash:icon]=" "
PROJECTS[ensureUrlTrailingSlash:path]="~/local/www/projects/ensure-url-trailing-slash/"
PROJECTS[esmify:background]="YELLOW"
PROJECTS[esmify:foreground]="BLACK"
PROJECTS[esmify:icon]=" "
PROJECTS[esmify:path]="~/local/www/projects/esmify/"
PROJECTS[firost:background]="GREEN"
PROJECTS[firost:foreground]="GRAY_2"
PROJECTS[firost:icon]="❯ "
PROJECTS[firost:path]="~/local/www/projects/firost/"
PROJECTS[gamemaster:background]="PURPLE_8"
PROJECTS[gamemaster:foreground]="WHITE"
PROJECTS[gamemaster:icon]="  "
PROJECTS[gamemaster:path]="~/local/www/pixelastic.com/gamemaster/gamemaster.pixelastic.com/"
PROJECTS[gdrive:background]="YELLOW"
PROJECTS[gdrive:foreground]="DARK_YELLOW"
PROJECTS[gdrive:icon]="  "
PROJECTS[gdrive:path]="~/local/mount/gdrive/"
PROJECTS[gilmore:background]="PURPLE_7"
PROJECTS[gilmore:foreground]="YELLOW_1"
PROJECTS[gilmore:icon]="✨ "
PROJECTS[gilmore:path]="~/local/www/projects/gilmore/"
PROJECTS[gitinx:background]="GRAY_3"
PROJECTS[gitinx:foreground]="BLUE"
PROJECTS[gitinx:icon]=" "
PROJECTS[gitinx:path]="~/local/www/projects/gitinx/"
PROJECTS[golgoth:background]="ORANGE"
PROJECTS[golgoth:foreground]="ORANGE_1"
PROJECTS[golgoth:icon]=" "
PROJECTS[golgoth:path]="~/local/www/projects/golgoth/"
PROJECTS[home:background]="GREEN"
PROJECTS[home:foreground]="GREEN_1"
PROJECTS[home:hideNameInPrompt]=1
PROJECTS[home:icon]=""
PROJECTS[home:path]="~/"
PROJECTS[imoen:background]="PINK_9"
PROJECTS[imoen:foreground]="GRAY_2"
PROJECTS[imoen:icon]="  "
PROJECTS[imoen:path]="~/local/www/projects/imoen/"
PROJECTS[indexing:background]="BLUE_3"
PROJECTS[indexing:icon]=" "
PROJECTS[irori:background]="TEAL"
PROJECTS[irori:foreground]="WHITE"
PROJECTS[irori:icon]=" "
PROJECTS[irori:path]="~/local/www/projects/irori/"
PROJECTS[items-data:background]="ORANGE_8"
PROJECTS[items-data:foreground]="WHITE"
PROJECTS[items-data:icon]="ﰤ "
PROJECTS[items-data:path]="~/local/www/pixelastic.com/gamemaster/items/items-data/"
PROJECTS[items:background]="ORANGE_9"
PROJECTS[items:foreground]="WHITE"
PROJECTS[items:icon]="ﰤ "
PROJECTS[items:path]="~/local/www/pixelastic.com/gamemaster/items/items/"
PROJECTS[jekyll:background]="BLUE_5"
PROJECTS[jekyll:foreground]="WHITE"
PROJECTS[jekyll:icon]=" "
PROJECTS[jekyll:path]="~/local/www/algolia/jekyll-algolia/"
PROJECTS[kindle:background]="BLUE_9"
PROJECTS[kindle:foreground]="BLUE_2"
PROJECTS[kindle:icon]="   "
PROJECTS[kindle:path]="/media/tim/Kindle/"
PROJECTS[landscapes-data:background]="BLUE_8"
PROJECTS[landscapes-data:foreground]="WHITE"
PROJECTS[landscapes-data:icon]="  "
PROJECTS[landscapes-data:path]="~/local/www/projects/landscapes/landscapes-data/"
PROJECTS[landscapes:background]="BLUE_9"
PROJECTS[landscapes:foreground]="WHITE"
PROJECTS[landscapes:icon]="  "
PROJECTS[landscapes:path]="~/local/www/projects/landscapes/landscapes/"
PROJECTS[magic:background]="RED_8"
PROJECTS[magic:foreground]="BLACK"
PROJECTS[magic:icon]=" "
PROJECTS[magic:path]="~/local/www/pixelastic.com/projects/magic/"
PROJECTS[maps-data:background]="BLUE_9"
PROJECTS[maps-data:foreground]="GRAY_2"
PROJECTS[maps-data:icon]="  "
PROJECTS[maps-data:path]="~/local/www/pixelastic.com/gamemaster/maps/maps-data/"
PROJECTS[maps:background]="BLUE_6"
PROJECTS[maps:foreground]="GRAY_2"
PROJECTS[maps:icon]="  "
PROJECTS[maps:path]="~/local/www/pixelastic.com/gamemaster/maps/maps/"
PROJECTS[media:background]="GRAY"
PROJECTS[media:foreground]="WHITE"
PROJECTS[media:hideNameInPrompt]=0
PROJECTS[media:icon]="  "
PROJECTS[media:path]="/media"
PROJECTS[meetups:background]="RED_9"
PROJECTS[meetups:foreground]="WHITE"
PROJECTS[meetups:icon]="  "
PROJECTS[meetups:path]="~/local/www/pixelastic.com/meetups.pixelastic.com/"
PROJECTS[megadungeon:background]="YELLOW_8"
PROJECTS[megadungeon:foreground]="GRAY_1"
PROJECTS[megadungeon:icon]=" "
PROJECTS[megadungeon:path]="~/local/www/pixelastic.com/gamemaster/megadungeon/"
PROJECTS[monorepoify:background]="GRAY"
PROJECTS[monorepoify:foreground]="WHITE"
PROJECTS[monorepoify:icon]="  "
PROJECTS[monorepoify:path]="~/local/www/projects/monorepoify/"
PROJECTS[monsters-pages:background]="YELLOW"
PROJECTS[monsters-pages:foreground]="GRAY_8"
PROJECTS[monsters-pages:icon]="  "
PROJECTS[monsters-pages:path]="~/local/www/pixelastic.com/gamemaster/monsters/monsters-pages/"
PROJECTS[monsters-pictures:background]="GRAY_8"
PROJECTS[monsters-pictures:foreground]="GREEN"
PROJECTS[monsters-pictures:icon]="  "
PROJECTS[monsters-pictures:path]="~/local/www/pixelastic.com/gamemaster/monsters/monsters-pictures/"
PROJECTS[monsters:background]="GRAY_8"
PROJECTS[monsters:foreground]="RED_8"
PROJECTS[monsters:icon]=" "
PROJECTS[monsters:path]="~/local/www/pixelastic.com/gamemaster/monsters/monsters/"
PROJECTS[movies:icon]=" "
PROJECTS[music:icon]=" "
PROJECTS[netlify-minutes:background]="GREEN_8"
PROJECTS[netlify-minutes:foreground]="WHITE"
PROJECTS[netlify-minutes:icon]="神"
PROJECTS[netlify-minutes:path]="~/local/www/projects/netlify-minutes/"
PROJECTS[norska:background]="BLUE_3"
PROJECTS[norska:foreground]="GRAY_8"
PROJECTS[norska:icon]="煮"
PROJECTS[norska:path]="~/local/www/projects/norska/norska/"
PROJECTS[npm-search:background]="SKY_6"
PROJECTS[npm-search:foreground]="WHITE"
PROJECTS[npm-search:icon]="  "
PROJECTS[npm-search:path]="~/local/www/algolia/npm-search/"
PROJECTS[on-circle:background]="RED_3"
PROJECTS[on-circle:foreground]="GRAY_9"
PROJECTS[on-circle:icon]="⬤ "
PROJECTS[on-circle:path]="~/local/www/projects/on-circle/"
PROJECTS[oroshi:background]="GREEN"
PROJECTS[oroshi:foreground]="WHITE"
PROJECTS[oroshi:icon]="x "
PROJECTS[oroshi:path]="~/.oroshi/"
PROJECTS[painting:background]="GRAY_4"
PROJECTS[painting:foreground]="BLACK"
PROJECTS[painting:icon]=" "
PROJECTS[painting:path]="~/local/www/pixelastic.com/painting.pixelastic.com/"
PROJECTS[pantheon:background]="PURPLE_6"
PROJECTS[pantheon:foreground]="GRAY_4"
PROJECTS[pantheon:icon]="  "
PROJECTS[pantheon:path]="~/local/www/pixelastic.com/gamemaster/pantheon/"
PROJECTS[perso:background]="PURPLE"
PROJECTS[perso:foreground]="WHITE"
PROJECTS[perso:icon]=" "
PROJECTS[pictures:icon]=""
PROJECTS[pietro:background]="BLUE_7"
PROJECTS[pietro:foreground]="YELLOW_4"
PROJECTS[pietro:icon]=" "
PROJECTS[pietro:path]="~/local/www/projects/pietro/"
PROJECTS[projects:background]="GREEN"
PROJECTS[projects:foreground]="GRAY_2"
PROJECTS[projects:icon]=" "
PROJECTS[prst:background]="BLUE_8"
PROJECTS[prst:foreground]="GRAY_2"
PROJECTS[prst:icon]=" "
PROJECTS[prst:path]="~/local/www/projects/prst/"
PROJECTS[reddinx:background]="ORANGE_6"
PROJECTS[reddinx:foreground]="GRAY_1"
PROJECTS[reddinx:icon]=" "
PROJECTS[reddinx:path]="~/local/www/projects/reddinx/"
PROJECTS[renovate:background]="BLUE_4"
PROJECTS[renovate:foreground]="GRAY_9"
PROJECTS[renovate:icon]=" "
PROJECTS[renovate:path]="~/local/www/projects/renovate-config-aberlaas/"
PROJECTS[roleplay:background]="GREEN_9"
PROJECTS[roleplay:foreground]="WHITE"
PROJECTS[roleplay:icon]=" "
PROJECTS[roleplay:path]="~/local/www/pixelastic.com/roleplay.pixelastic.com/"
PROJECTS[s3-meetups:background]="GREEN_5"
PROJECTS[s3-meetups:foreground]="DARK_GREEN"
PROJECTS[s3-meetups:icon]="  "
PROJECTS[s3-meetups:path]="~/local/mount/s3/algolia-meetups-recording-98ecae72-ef0c-4c09-ad3f-7e7f56964204/"
PROJECTS[s3:background]="GREEN"
PROJECTS[s3:foreground]="DARK_GREEN"
PROJECTS[s3:icon]="  "
PROJECTS[s3:path]="~/local/mount/s3/"
PROJECTS[shar-teel:background]="PURPLE_9"
PROJECTS[shar-teel:foreground]="ORANGE_4"
PROJECTS[shar-teel:icon]=" "
PROJECTS[shar-teel:path]="~/local/www/projects/shar-teel/"
PROJECTS[society-data:background]="RED_9"
PROJECTS[society-data:foreground]="YELLOW_5"
PROJECTS[society-data:icon]="  "
PROJECTS[society-data:path]="~/local/www/pixelastic.com/gamemaster/society/society-data/"
PROJECTS[society-pdfs:background]="RED_9"
PROJECTS[society-pdfs:foreground]="YELLOW_5"
PROJECTS[society-pdfs:icon]="  "
PROJECTS[society-pdfs:path]="~/local/www/pixelastic.com/gamemaster/society/society-pdfs/"
PROJECTS[society:background]="RED_9"
PROJECTS[society:foreground]="YELLOW_5"
PROJECTS[society:icon]=" "
PROJECTS[society:path]="~/local/www/pixelastic.com/gamemaster/society/society/"
PROJECTS[sov:icon]="蠟"
PROJECTS[speaker-program:background]="TEAL_6"
PROJECTS[speaker-program:foreground]="GRAY_3"
PROJECTS[speaker-program:icon]=" "
PROJECTS[speaker-program:path]="~/local/www/talks/speaker-program/"
PROJECTS[spells:background]="BLUE_8"
PROJECTS[spells:foreground]="WHITE"
PROJECTS[spells:icon]=" "
PROJECTS[spells:path]="~/local/www/pixelastic.com/gamemaster/spells/spells/"
PROJECTS[talks:background]="GREEN_8"
PROJECTS[talks:foreground]="WHITE"
PROJECTS[talks:icon]="  "
PROJECTS[talk-blog:background]="GREEN"
PROJECTS[talk-blog:foreground]="WHITE"
PROJECTS[talk-blog:icon]="  "
PROJECTS[talk-blog:path]="~/local/www/talks/talk-blog/"
PROJECTS[terrainbuilding-data:background]="GREEN_8"
PROJECTS[terrainbuilding-data:foreground]="YELLOW_6"
PROJECTS[terrainbuilding-data:icon]=" "
PROJECTS[terrainbuilding-data:path]="~/local/www/pixelastic.com/gamemaster/terrainbuilding/terrainbuilding-data/"
PROJECTS[terrainbuilding:background]="GREEN_9"
PROJECTS[terrainbuilding:foreground]="YELLOW_5"
PROJECTS[terrainbuilding:icon]=" "
PROJECTS[terrainbuilding:path]="~/local/www/pixelastic.com/gamemaster/terrainbuilding/terrainbuilding/"
PROJECTS[theme-docs:background]="BLUE_3"
PROJECTS[theme-docs:foreground]="GRAY_8"
PROJECTS[theme-docs:icon]=" "
PROJECTS[theme-docs:path]="~/local/www/projects/norska-theme-docs/"
PROJECTS[theme-search-infinite:background]="BLUE_3"
PROJECTS[theme-search-infinite:foreground]="GRAY_8"
PROJECTS[theme-search-infinite:icon]=" "
PROJECTS[theme-search-infinite:path]="~/local/www/projects/norska-theme-search-infinite/"
PROJECTS[theme-search:background]="BLUE_5"
PROJECTS[theme-search:foreground]="WHITE"
PROJECTS[theme-search:icon]=" "
PROJECTS[theme-search:path]="~/local/www/projects/norska-theme-search/"
PROJECTS[theme-slides:background]="GREEN_8"
PROJECTS[theme-slides:foreground]="WHITE"
PROJECTS[theme-slides:icon]=" "
PROJECTS[theme-slides:path]="~/local/www/projects/norska-theme-slides/"
PROJECTS[tmp:background]="GRAY"
PROJECTS[tmp:icon]=" "
PROJECTS[transparentify:background]="WHITE"
PROJECTS[transparentify:foreground]="GRAY"
PROJECTS[transparentify:icon]="頋"
PROJECTS[transparentify:path]="~/local/www/projects/transparentify/"
PROJECTS[twitter:icon]=" "
PROJECTS[ubuntu:background]="ORANGE_7"
PROJECTS[ubuntu:foreground]="ORANGE_2"
PROJECTS[ubuntu:hideNameInPrompt]=0
PROJECTS[ubuntu:icon]=" "
PROJECTS[ubuntu:path]="/"
PROJECTS[videogames-helper:background]="BLUE_8"
PROJECTS[videogames-helper:icon]="  "
PROJECTS[videogames:background]="BLUE_8"
PROJECTS[videogames:foreground]="GRAY_2"
PROJECTS[videogames:icon]="  "
PROJECTS[videogames:path]="~/local/www/pixelastic.com/videogames/videogames.pixelastic.com/"
PROJECTS[videos:icon]=" "
PROJECTS[vim:icon]=" "
PROJECTS[websites:background]="YELLOW"
PROJECTS[websites:foreground]="WHITE"
PROJECTS[websites:icon]="  "
PROJECTS[wikinx:background]="WHITE"
PROJECTS[wikinx:foreground]="BLACK"
PROJECTS[wikinx:icon]="  "
PROJECTS[wikinx:path]="~/local/www/projects/wikinx/"
PROJECTS[www:background]="GREEN"
PROJECTS[www:foreground]="GRAY_2"
PROJECTS[www:icon]=" "
PROJECTS[www:path]="~/local/www/pixelastic.com/www.pixelastic.com/"
PROJECTS[youtinx:background]="GRAY_4"
PROJECTS[youtinx:foreground]="RED_8"
PROJECTS[youtinx:icon]=" "
PROJECTS[youtinx:path]="~/local/www/projects/youtinx/"
PROJECTS[zsh:icon]=" "
