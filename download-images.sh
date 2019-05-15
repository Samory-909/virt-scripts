#!/bin/bash
# Download kvm images builded with https://github.com/goffinet/packer-kvm from http://get.goffinet.org/kvm/

#imagename="debian7 debian8 centos7 centos7.5 ubuntu1604 ubuntu1804 metasploitable kali arch"
which curl > /dev/null || ( echo "Please install curl" && exit )
imagename=($(curl -qs https://get.goffinet.org/kvm/imagename))
image="$1"
url=http://get.goffinet.org/kvm/
destination=/var/lib/libvirt/images/
parameters=$#
wd=$PWD
force="$2"

question () {
echo "WARN : Do you want anyway download this file ${image}.qcow2 ?"
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

download_image () {
if [ "${force}" != "--force" ] ; then
  question
fi
curl ${url}${image}.qcow2 -o ${destination}${image}.qcow2
curl ${url}${image}.qcow2.sha1 -o ${destination}${image}.qcow2.sha1
cd ${destination}
sha1sum -c ${image}.qcow2.sha1
rm -rf ${image}.qcow2.sha1
cd ${wd}
}

usage () {
  echo "------------------------------------------------------------------------"
  echo "This script download automatically KVM images from get.goffinet.org/kvm."
  echo "The option \"--force\" does not ask any confirmation"
  echo "Usage:"
  echo "$0 image_name [--force]"
  echo "where \"image_name\" can be:"
  echo ${imagename[*]}
  echo "Examples:"
  echo "$0 ${imagename[0]} --force"
  echo "$0 ${imagename[1]}"
  echo "------------------------------------------------------------------------"
}

if [ ${parameters} -lt 1 ] ; then
  usage
  echo "ERROR: Please provide an image name."
  exit
fi
if grep -qvw "${image}" <<< "${imagename[*]}" ; then
  usage
  echo "ERROR: Please provide a valid image name."
  exit
fi
if [ ${parameters} -gt 2 ] ; then
  usage
  echo "ERROR: Too much args."
  exit
fi
if [ -f ${destination}${image}.qcow2  ] ; then
  echo "WARN: The image ${destination}${image}.qcow2 already exists."
  cd ${destination}
  remote_sha1="$(curl -s ${url}${image}.qcow2.sha1)"
  cd ${destination}
  local_sha1="$(sha1sum ${image}.qcow2)"
  cd ${wd}
    if [ "${remote_sha1}" = "${local_sha1}" ] ; then
      echo "WARN: The local image is exactly the same than the remote image."
      download_image
    else
      echo "WARN: The local image differs from the remote image."
      download_image
fi
else
  echo "WARN: The image ${destination}${image}.qcow2 does not exist."
  download_image
fi
