#!/bin/sh

error()
{

if [ $? != 0 ]; then
    echo "Last command failed, check logs and kernel mesgs"
    exit 1

else continue

fi

}

main()
{



./mount_dumpfs.sh

error $?

./memcap.sh

error $?

echo "Memory dump finished!"

}

main
