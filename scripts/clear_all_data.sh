#!/usr/bin/env bash
# This script removes all data that has been collected. It is tantamount to
# starting all data-collection from scratch. Only run this if you are sure
# you are okay will losing all the data that you've collected and processed
# so far.
source /etc/birdnet/birdnet.conf
HOME=/home/pi
USER=pi
my_dir=${HOME}/BirdNET-Pi/scripts
echo "Stopping services"
sudo systemctl stop birdnet_recording.service
echo "Removing all data . . . "
sudo rm -drf "${RECS_DIR}"
sudo rm -f $(dirname ${my_dir})/BirdDB.txt
echo "Creating necessary directories"
[ -d ${EXTRACTED} ] || sudo -u ${USER} mkdir -p ${EXTRACTED}
[ -d ${EXTRACTED}/By_Date ] || sudo -u ${USER} mkdir -p ${EXTRACTED}/By_Date
[ -d ${EXTRACTED}/Charts ] || sudo -u ${USER} mkdir -p ${EXTRACTED}/Charts
[ -d ${PROCESSED} ] || sudo -u ${USER} mkdir -p ${PROCESSED}

sudo -u ${USER} ln -fs $(dirname ${my_dir})/homepage/* ${EXTRACTED}
sudo -u ${USER} ln -fs $(dirname ${my_dir})/model/labels.txt ${my_dir}/
sudo -u ${USER} ln -fs $(dirname ${my_dir})/scripts ${EXTRACTED}
sudo -u ${USER} ln -fs $(dirname ${my_dir})/scripts/spectrogram.php ${EXTRACTED}
sudo -u ${USER} ln -fs $(dirname ${my_dir})/scripts/viewday.php ${EXTRACTED}
sudo -u ${USER} ln -fs $(dirname ${my_dir})/scripts/overview.php ${EXTRACTED}
sudo -u ${USER} ln -fs $(dirname ${my_dir})/scripts/stats.php ${EXTRACTED}
sudo -u ${USER} ln -fs $(dirname ${my_dir})/scripts/viewdb.php ${EXTRACTED}
sudo -u ${USER} ln -fs $(dirname ${my_dir})/scripts/history.php ${EXTRACTED}
sudo -u ${USER} ln -fs $(dirname ${my_dir})/scripts/play.php ${EXTRACTED}
sudo -u ${USER} ln -fs $(dirname ${my_dir})/scripts/play.css ${EXTRACTED}
sudo -u ${USER} ln -fs $(dirname ${my_dir})/homepage/images/favicon.ico ${EXTRACTED}
sudo -u ${USER} ln -fs ${HOME}/phpsysinfo ${EXTRACTED}
sudo -u ${USER} cp -f $(dirname ${my_dir})/templates/phpsysinfo.ini ${HOME}/phpsysinfo/
sudo -u ${USER} cp -f $(dirname ${my_dir})/templates/green_bootstrap.css ${HOME}/phpsysinfo/templates/
sudo -u ${USER} cp -f $(dirname ${my_dir})/templates/index_bootstrap.html ${HOME}/phpsysinfo/templates/html

sudo chmod -R g+rw $(dirname ${my_dir})
sudo chmod -R g+rw ${RECS_DIR}

echo "Generating BirdDB.txt"
if ! [ -f $(dirname ${my_dir})/BirdDB.txt ];then
  sudo -u ${USER} touch $(dirname ${my_dir})/BirdDB.txt
  echo "Date;Time;Sci_Name;Com_Name;Confidence;Lat;Lon;Cutoff;Week;Sens;Overlap" | sudo -u ${USER} tee -a $(dirname ${my_dir})/BirdDB.txt
elif ! grep Date $(dirname ${my_dir})/BirdDB.txt;then
  sudo -u ${USER} sed -i '1 i\Date;Time;Sci_Name;Com_Name;Confidence;Lat;Lon;Cutoff;Week;Sens;Overlap' $(dirname ${my_dir})/BirdDB.txt
fi
ln -sf $(dirname ${my_dir})/BirdDB.txt ${my_dir}/BirdDB.txt &&
sudo chown pi:pi ${my_dir}/BirdDB.txt && sudo chmod g+rw ${my_dir}/BirdDB.txt


echo "Dropping and re-creating database"
sudo /home/pi/BirdNET-Pi/scripts/createdb.sh
echo "Restarting services"
sudo systemctl start birdnet_recording.service
