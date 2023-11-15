python -c "import zipfile; zipfile.ZipFile('/mnt/data/lib.zip').extractall('/mnt/data')"
python -c "import zipfile; zipfile.ZipFile('/mnt/data/bin.zip').extractall('/mnt/data')"

chmod 777 /mnt/data/bin/*
ln -s /mnt/data/bin/* /home/sandbox/.local/bin/

LD_LIBRARY_PATH=/mnt/data/lib:$LD_LIBRARY_PATH /mnt/data/bin/strace /bin/ls > /mnt/data/lstrace.txt
