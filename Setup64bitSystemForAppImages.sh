#!/bin/sh
# Author : Ismael Barros² <ismael@barros2.org>
# License : BSD http://en.wikipedia.org/wiki/BSD_license

sudo apt-get update
sudo apt-get install libc6-i386 libglib2.0-0:i386 libgl1-mesa-glx-lts-quantal:i386
sudo apt-get install libpulse0:i386 libvorbisfile3:i386
sudo apt-get install libglu1-mesa:i386 libxcursor1:i386
#sudo apt-get install ia32-libs

libfuse="/lib32/libfuse.so.2"
if [ -f "$libfuse" ]; then
        echo "Fuse support already installed"
else
	pushd /tmp/
	wget http://archive.ubuntu.com/ubuntu/pool/main/f/fuse/libfuse2_2.8.1-1.1ubuntu2_i386.deb
	ar x libfuse2_2.8.1-1.1ubuntu2_i386.deb data.tar.gz
	tar -xhf data.tar.gz ./lib/libfuse.so.2.8.1
	sudo install -o root lib/libfuse.so.2.8.1 /lib32/libfuse.so.2
	rm lib/libfuse.so.2.8.1 data.tar.gz libfuse2_2.8.1-1.1ubuntu2_i386.deb
	rmdir lib
	sudo ldconfig
	popd
fi
