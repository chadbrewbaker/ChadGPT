# wget -nc http://ubuntu.cs.utah.edu/ubuntu/pool/main/s/strace/strace_4.26-0.2ubuntu3_amd64.deb
# wget -nc http://security.ubuntu.com/ubuntu/pool/universe/libz/libzstd/zstd_1.4.4+dfsg-3ubuntu0.1_amd64.deb
# wget -nc http://security.ubuntu.com/ubuntu/pool/main/c/curl/curl_7.68.0-1ubuntu2.19_amd64.deb
# wget -nc https://github.com/ziglang/zig/releases/download/0.11.0/zig-bootstrap-0.11.0.tar.xz
# wget -nc http://ubuntu.cs.utah.edu/ubuntu/pool/universe/z/z3/z3_4.8.7-4build1_amd64.deb
# wget -nc https://github.com/uutils/coreutils/releases/download/0.0.21/coreutils_0.0.21_amd64.deb
# wget -nc http://ubuntu.cs.utah.edu/ubuntu/pool/main/g/gdb/gdb_9.1-0ubuntu1_amd64.deb
# https://packages.ubuntu.com/focal/amd64/libunwind8/download
wget -nc http://ubuntu.cs.utah.edu/ubuntu/pool/main/libu/libunwind/libunwind8_1.2.1-9build1_amd64.deb
wget -nc http://ubuntu.cs.utah.edu/ubuntu/pool/universe/n/nasm/nasm_2.14.02-1_amd64.deb
wget -nc http://security.ubuntu.com/ubuntu/pool/universe/b/busybox/busybox_1.30.1-4ubuntu6.4_amd64.deb
wget -nc http://ubuntu.cs.utah.edu/ubuntu/pool/main/b/babeltrace/libbabeltrace-dev_1.5.8-1build1_amd64.deb
wget -nc http://ubuntu.cs.utah.edu/ubuntu/pool/main/b/babeltrace/libbabeltrace1_1.5.8-1build1_amd64.deb

#pip download -d ./junk --only-binary=:all: --platform manylinux1_x86_64 --python-version 38 --implementation cp --abi cp38 z3-solver


mkdir -p junk
cd junk
# Loop through and print .deb files
for deb_file in ../*.deb; do
    echo "$deb_file"
    tar -xvf $deb_file
    tar -xvf data.tar.xz
    rm data.tar.xz
done
cd usr
pwd
zip -r   bin.zip ./bin
ls -la
pwd
du -h ./bin*
cd lib
pwd
mv ./x86_64-linux-gnu ./lib
zip -r   lib.zip ./lib
ls -la
cd ../../../
pwd
cp ./junk/usr/bin.zip .
cp ./junk/usr/lib/lib.zip .
