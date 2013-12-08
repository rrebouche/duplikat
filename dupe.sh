#!/bin/sh


# A very crude script that uses a single arg to determine dump location, then dumps all it sees into an ELF-format core dump for later examination. As Anubis matures this will grow into a much more complex and capable beast, probably written at least partly in Python and/or C


# Load variables
source mnemosyne.cfg


make_folder()
{

touch $targetF/test.empty
    if [ $? != 0 ]; then

        echo "Making folder for memory capture..."
        mkdir -p $targetF
        if [ $? == 0 ]; then
            return 0
            
        else
        echo "Making capture directory failed..."
        exit 21
    
        fi
    fi

}


capmem()
{

echo "Beginning memory capture... (This will take some time)"

#    Guess what this does
dd bs=1M count=$memcap if=/dev/mem of=$memdump
return $?

}

hash_dump()
{
#    Set up hash file
echo "Hashes of uncompressed image:" >> $targetF/hashes.txt
echo "Hashing uncompressed image, this could take some time..."

#    Hash memory image...
echo "Begin MD5 hash, see $targetF/hashes.txt"
md5sum $memdump | tee -a $targetF/hashes.txt
error $?
echo "Begin SHA1 hash, see $targetF/hashes.txt"
sha1sum $memdump | tee -a $targetF/hashes.txt
error $?
}


error()
{

if [ $1 != 0 ]; then
    echo "Last command failed, examine kernel messages and logfile"
    exit 1
fi    

}

main()
{

make_folder

error $?

capmem

error $?

hash_dump

error $?

echo "Fin! Check $targetF for your image and hashes!"
}


main

#    Compression can be added
