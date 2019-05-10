#!/bin/bash
# Download kvm images builded with https://github.com/goffinet/packer-kvm from http://get.goffinet.org/kvm/

#imagename="debian7 debian8 centos7 centos7.5 ubuntu1604 ubuntu1804 metasploitable kali arch"
which curl > /dev/null || ( echo "Please install curl" && exit )
imagename="$(curl -qs https://get.goffinet.org/kvm/imagename)"
image="$1.qcow2"
url=http://get.goffinet.org/kvm/
destination=/var/lib/libvirt/images/
parameters=$#
wd=$PWD

download_image () {
if [ "${2}" != "--force" ] ; then
  question
fi
curl ${url}${image} -o ${destination}${image}
curl ${url}${image}.sha1 -o ${destination}${image}.sha1
cd ${destination}
sha1sum -c ${image}.sha1
rm -rf ${image}.sha1
cd ${wd}
}

question () {
echo "Do you want anyway download this file ${image}"
read -r -p "Are you sure? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
        sleep 1
        ;;
    *)
        exit
        ;;
esac
}

if [ ${parameters} -ne 1 ] ; then
echo "Please provide the image name : "
echo ${imagename}
exit
fi
if [ -f ${destination}${image}  ] ; then
echo "The image ${destination}${image} already exists."
cd ${destination}
remote_sha1="$(curl -s ${url}${image}.sha1)"
cd ${destination}
local_sha1="$(sha1sum ${image})"
cd ${wd}
if [ "${remote_sha1}" = "${local_sha1}" ] ; then
echo "The local image is exactly the same than the remote"
download_image
else
echo "The local image is not the same than the remote"
download_image
fi
else
echo "The image ${destination}${image} does not exist."
download_image
fi
