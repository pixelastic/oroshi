# Custom colors for this hostname
promptColor=(
	hostname	"071"
)

# Directories {{{
alias cdpaper="cd ~/Dropbox/perso/paperwork/"
alias cdbooks='cd ~/perso/books'
alias cdemu='cd ~/perso/emulation'
alias cdrp='cd ~/perso/roleplay/'
alias cdscenar='cd ~/perso/roleplay/scenarios/'
alias cdkiss="/var/www/java/kissihm/kissihm/src/main/webapp/resources/"
# }}}

# Synchronize stuff {{{
alias belette-sync-ebooks="ebook-sync ~/perso/books /media/tca/BELETTE/Books"
alias belette-sync-notes="update-dir ~/perso/notes /media/tca/BELETTE/notes"
alias belette-sync-roleplay="update-dir ~/perso/roleplay /media/tca/BELETTE/roleplay"
alias belette-sync-comics="update-dir /media/tca/armor/comics /media/tca/BELETTE/Comics"
alias doxie-extract="doxie-extract /media/tca/DOXIE/DCIM/ ~/perso/pictures/tmp/"
alias dingoo-sync="~/perso/emulation/devices/dingoo/tools/dingoo-sync /media/tca/dingoo"
alias gcw-sync="~/perso/emulation/devices/gcwzero/tools/gcw-sync gcwzero"
alias wii-sync="~/perso/emulation/devices/wii/tools/wii-sync /media/tca/WII"
alias galaxy-extract="camera-extract /media/tca/F101-14E2/DCIM ~/perso/pictures"
alias galaxy-sync-audio="update-dir ~/Dropbox/perso/config/audio /media/tca/F101-14E2/media/audio"
alias galaxy-sync-ebooks="ebook-sync ~/perso/books /media/tca/galaxy/books"
alias galaxy-sync-notes="update-dir ~/perso/notes/ /media/tca/galaxy/notes"
alias galaxy-sync-roleplay="update-dir ~/perso/roleplay /media/tca/galaxy/roleplay"
alias galaxy-backup-apps="update-dir /media/tca/galaxy/__backup__/titanium ~/Dropbox/perso/misc/backup/android/"
alias michel-extract="camera-extract /media/tca/MICHEL/ ~/perso/pictures"
alias sansa-sync-misc="music-sync ~/local/mnt/serenity/music/misc /media/tca/0123-4567 sansa"
alias sansa-sync-music="music-sync ~/local/mnt/serenity/music/music /media/tca/SANSA-SD sansa-sd"
alias sansa-sync-nature="music-sync ~/local/mnt/serenity/music/nature /media/tca/0123-4567 sansa"
alias sansa-sync-podcasts="music-sync ~/local/mnt/serenity/music/podcasts /media/tca/0123-4567 sansa"
alias sansa-sync-soundtracks="music-sync ~/local/mnt/serenity/music/soundtracks /media/tca/SANSA-SD sansa-sd"
alias serenity-sync-pictures="picture-sync ~/perso/pictures/ ~/local/mnt/serenity/perso/"
# }}}

function kb() {
	local initial_dir=`pwd`
	local tomcat_script=/etc/init.d/tomcat7
	local repo_dir=/var/www/java/kissihm
	local tomcat_directory=/var/lib/tomcat7

	# Stop server
	sudo $tomcat_script stop

	# Copy config file
	sudo mkdir -p ${tomcat_directory}/lib
	sudo cp ${repo_dir}/config/dev/environmentConfig.properties ${tomcat_directory}/lib
	sudo chown tomcat7:tomcat7 ${tomcat_directory}/lib/environmentConfig.properties

	# Build
	cd ${repo_dir}/kissihm
	mvn clean package

	# Clean tomcat and copy build
	sudo rm -drf ${tomcat_directory}/webapps/kiss
	sudo mv -f ./target/kiss*war ${tomcat_directory}/webapps/kiss.war	

	# Restart server
	sudo $tomcat_script start

	# Change owner of static files for easy re-deploy through rsync
	sudo chown -R tca:tca ${tomcat_directory}/webapps/kiss/resources/app/

	cd $initial_dir
}
function ku() {
	rsync -ra /var/www/java/kissihm/kissihm/src/main/webapp/resources/app/* /var/lib/tomcat7/webapps/kiss/resources/app/
}
