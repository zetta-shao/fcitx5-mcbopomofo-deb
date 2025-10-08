#!/bin/bash
PASS='0'
TGT="pkg-config fcitx5 libfcitx5core-dev libfcitx5config-dev libfcitx5utils-dev fcitx5-modules-dev \
    cmake extra-cmake-modules gettext libfmt-dev libicu-dev libjson-c-dev"
for p in ${TGT}; do
MSG=$(dpkg -s ${p}|grep "Package");
if ! [ -z "${MSG}" ]; then continue;
else PASS='1'; break; fi;
done
if [ ${PASS} = '1' ]; then apt-get install ${TGT}; 
else echo "all installed"; fi
#sudo apt install ${TGT}
