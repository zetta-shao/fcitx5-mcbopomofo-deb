#!/bin/bash
PWD=$(pwd)
TGT='fcitx5-mcbopomofo'
ARCH="amd64"
GITTGT=${PWD}"/"${TGT}

if [ "${1}" = "clean" ]; then rm -rf build DEBIAN ${GITTGT}; exit; fi

if ! [ -r ${GITTGT} ]; then
source ./debpkh.sh
git clone https://github.com/openvanilla/fcitx5-mcbopomofo.git ${GITTGT};
fi

cd ${GITTGT}
git pull
GITVER=$(git describe --long --always)
#GITVER=$(git describe)
TITLE=${TGT}"-"${GITVER}
echo "source:"${TITLE}

#sudo rm -rf ${PWD}/build/
if ! [ -r ${PWD}"/build" ]; then
sudo mkdir -p build deb
sudo cmake -B build -DCMAKE_INSTALL_PREFIX=${PWD}/deb/usr -DCMAKE_BUILD_TYPE=Release
sudo cmake --build build -j$(nproc)
sudo cmake --install build
fi

PKGVER=$(cat build/src/mcbopomofo-addon.conf|awk -F'=' '/Version/ {print $2}')
PKGNAME=$(cat build/src/mcbopomofo-addon.conf|awk -F'=' '/Name\[en\]/ {print $2}')
PKGCMT=$(cat build/src/mcbopomofo-addon.conf|awk -F'=' '/Comment\[en\]/ {print $2}')
TITLE=${TGT}"-"${GITVER}"-"${ARCH}
echo "build deb for "${TITLE}
DEBMTGT="/tmp/"${TITLE}
DEBTGT=${DEBMTGT}"/DEBIAN"
sudo rm -rf ${DEBMTGT}
mkdir -p ${DEBTGT}
sudo cp -a ${GITTGT}/deb/* ${DEBMTGT}/
sudo mkdir -p ${DEBMTGT}/usr/lib/x86_64-linux-gnu
sudo mv ${DEBMTGT}/usr/lib/fcitx5 ${DEBMTGT}/usr/lib/x86_64-linux-gnu/

cd ..

DEBCTL=${DEBTGT}'/control'
DEBPIN=${DEBTGT}'/postinst'
DEBPRM=${DEBTGT}'/postrm'

sudo rm -rf ${DEBCTL} ${DEBPIN} ${DEBPRM}

echo "Package: fcitx5-mcbopomofo" > ${DEBCTL}
echo "Maintainer: openvanilla https://github.com/openvanilla" >> ${DEBCTL}
echo "Architecture: amd64" >> ${DEBCTL}
echo "Version: "${GITVER} >> ${DEBCTL}
echo "Depends: fcitx5, libfmt9" >> ${DEBCTL}
echo "Description: "${PKGCMT} >> ${DEBCTL}

echo "sudo update-icon-caches /usr/share/icons/*" ${DEBPIN}
echo "sudo update-icon-caches /usr/share/icons/*" ${DEBPRM}
chmod a+x ${DEBPIN} 2>/dev/null
chmod a+x ${DEBPRM} 2>/dev/null
chown 0:0 -R ${DEBTGT}/ 2>/dev/null


sudo dpkg-deb -z9 -Zgzip --build ${DEBMTGT}
sudo chown 1000:1000 ${DEBMTGT}.deb; sudo mv ${DEBMTGT}.deb ./
sudo rm -rf ${DEBMTGT}
