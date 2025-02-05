#!/bin/bash
cd $(cat ~/.ofprojectgenerator/config)
git pull upstreamhttps master
cd $(cat ~/.ofprojectgenerator/config)/scripts/dev
lasthash=$(cat lasthash.txt)
currenthash=$(git rev-parse HEAD)
if [ "$currenthash" = "$lasthash" ]; then
    exit 0
fi

# delete packages older than 1 week ago
oneweeksago=$(date --date=@$[$(date +%s)-60*60*24*7] +%Y%m%d)
rm /var/www/versions/nightly/of_v${oneweeksago}*_nightly.*


lastversion=$(date +%Y%m%d)
echo $currenthash>lasthash.txt
./create_package.sh linux $lastversion master
./create_package.sh linux64 $lastversion master
./create_package.sh win_cb $lastversion master
./create_package.sh vs $lastversion master
./create_package.sh ios $lastversion master
./create_package.sh osx $lastversion master
./create_package.sh android $lastversion master
./create_package.sh linuxarmv6l $lastversion master
./create_package.sh linuxarmv7l $lastversion master

mv *.tar.gz /var/www/versions/nightly
mv *.zip /var/www/versions/nightly
rm /var/www/versions/nightly/of_latest_linux_release.tar.gz
rm /var/www/versions/nightly/of_latest_linux64_release.tar.gz
rm /var/www/versions/nightly/of_latest_win_cb_release.zip
rm /var/www/versions/nightly/of_latest_vs_release.zip
rm /var/www/versions/nightly/of_latest_ios_release.zip
rm /var/www/versions/nightly/of_latest_osx_release.zip
rm /var/www/versions/nightly/of_latest_android_release.tar.gz
rm /var/www/versions/nightly/of_latest_linuxarmv6l_release.tar.gz
rm /var/www/versions/nightly/of_latest_linuxarmv7l_release.tar.gz

rm /var/www/versions/nightly/of_latest_linux_nightly.tar.gz
rm /var/www/versions/nightly/of_latest_linux64_nightly.tar.gz
rm /var/www/versions/nightly/of_latest_win_cb_nightly.zip
rm /var/www/versions/nightly/of_latest_vs_nightly.zip
rm /var/www/versions/nightly/of_latest_ios_nightly.zip
rm /var/www/versions/nightly/of_latest_osx_nightly.zip
rm /var/www/versions/nightly/of_latest_android_nightly.tar.gz
rm /var/www/versions/nightly/of_latest_linuxarmv6l_nightly.tar.gz
rm /var/www/versions/nightly/of_latest_linuxarmv7l_nightly.tar.gz

mv /var/www/versions/nightly/of_v${lastversion}_linux_release.tar.gz /var/www/versions/nightly/of_v${lastversion}_linux_nightly.tar.gz
mv /var/www/versions/nightly/of_v${lastversion}_linux64_release.tar.gz /var/www/versions/nightly/of_v${lastversion}_linux64_nightly.tar.gz
mv /var/www/versions/nightly/of_v${lastversion}_win_cb_release.zip /var/www/versions/nightly/of_v${lastversion}_win_cb_nightly.zip
mv /var/www/versions/nightly/of_v${lastversion}_vs_release.zip /var/www/versions/nightly/of_v${lastversion}_vs_nightly.zip
mv /var/www/versions/nightly/of_v${lastversion}_ios_release.zip /var/www/versions/nightly/of_v${lastversion}_ios_nightly.zip
mv /var/www/versions/nightly/of_v${lastversion}_osx_release.zip /var/www/versions/nightly/of_v${lastversion}_osx_nightly.zip
mv /var/www/versions/nightly/of_v${lastversion}_android_release.tar.gz /var/www/versions/nightly/of_v${lastversion}_android_nightly.tar.gz
mv /var/www/versions/nightly/of_v${lastversion}_linuxarmv6l_release.tar.gz /var/www/versions/nightly/of_v${lastversion}_linuxarmv6l_nightly.tar.gz
mv /var/www/versions/nightly/of_v${lastversion}_linuxarmv7l_release.tar.gz /var/www/versions/nightly/of_v${lastversion}_linuxarmv7l_nightly.tar.gz

ln -s /var/www/versions/nightly/of_v${lastversion}_linux_nightly.tar.gz /var/www/versions/nightly/of_latest_linux_nightly.tar.gz
ln -s /var/www/versions/nightly/of_v${lastversion}_linux64_nightly.tar.gz /var/www/versions/nightly/of_latest_linux64_nightly.tar.gz
ln -s /var/www/versions/nightly/of_v${lastversion}_win_cb_nightly.zip /var/www/versions/nightly/of_latest_win_cb_nightly.zip
ln -s /var/www/versions/nightly/of_v${lastversion}_vs_nightly.zip /var/www/versions/nightly/of_latest_vs_nightly.zip
ln -s /var/www/versions/nightly/of_v${lastversion}_ios_nightly.zip /var/www/versions/nightly/of_latest_ios_nightly.zip
ln -s /var/www/versions/nightly/of_v${lastversion}_osx_nightly.zip /var/www/versions/nightly/of_latest_osx_nightly.zip
ln -s /var/www/versions/nightly/of_v${lastversion}_android_nightly.tar.gz /var/www/versions/nightly/of_latest_android_nightly.tar.gz
ln -s /var/www/versions/nightly/of_v${lastversion}_linuxarmv6l_nightly.tar.gz /var/www/versions/nightly/of_latest_linuxarmv6l_nightly.tar.gz
ln -s /var/www/versions/nightly/of_v${lastversion}_linuxarmv7l_nightly.tar.gz /var/www/versions/nightly/of_latest_linuxarmv7l_nightly.tar.gz

echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'> /var/www/nightlybuilds.html
echo '<html>' >> /var/www/nightlybuilds.html
echo '<head>' >> /var/www/nightlybuilds.html
cat head.template >> /var/www/nightlybuilds.html
echo '</head>' >> /var/www/nightlybuilds.html
echo '<body>' >> /var/www/nightlybuilds.html
echo '<div id="content">' >> /var/www/nightlybuilds.html
cat header_download.template >> /var/www/nightlybuilds.html

echo '<div id="body-wrap">' >> /var/www/nightlybuilds.html
echo '<div class="page-left-wide">' >> /var/www/nightlybuilds.html
cat nightlybuilds.template >> /var/www/nightlybuilds.html
echo '<p>This download corresponds to commit: <a href="https://github.com/openframeworks/openFrameworks/commit/'${currenthash}'">'${currenthash}'</a></p>' >> /var/www/nightlybuilds.html
echo '<br/>' >> /var/www/nightlybuilds.html
echo '<h2>Nightly</h2>' >> /var/www/nightlybuilds.html
prev_version=0
for pkg in $(ls -r /var/www/versions/nightly/ | grep -v latest); do
    version=$(echo $pkg | cut -c4-12)
    if [ "$version" != "$prev_version" ]; then
        echo '<br/><h3>'${version}'</h3>'  >> /var/www/nightlybuilds.html
    fi
    prev_version=$version
    echo '<a href="versions/nightly/'${pkg}'">'${pkg}'</a><br/>'  >> /var/www/nightlybuilds.html
done

echo '</div>' >> /var/www/nightlybuilds.html
echo '</div>' >> /var/www/nightlybuilds.html
echo '</div>' >> /var/www/nightlybuilds.html
echo '</body>' >> /var/www/nightlybuilds.html
echo '</html>' >> /var/www/nightlybuilds.html

wget http://openframeworks.cc/nightly_hook.php?version=${lastversion} -O /dev/null
