#!/bin/sh


# This script:
#    - Loads variables from mnemosyne.cfg (because DIE)
#    - Auto-mounts a partition named whatever $memcatch is set to in mnemosyne.cfg found, if not..
#    - Checks visible filesystems for free space
#    - Displays a list of live ext3+ or NTFS filesystems
#    - Logs activity to $logfile in mnemosyne.cfg


source mnemosyne.cfg



mount_menu()
{

# Determine free space required
# This can't come into play until we've selected a dump target
# Free space determined by memcap variable set in anubis.cfg


# Echo menu commands
echo "Type device string of the target partition, then press enter"
echo "Use the whole string, such as \"/dev/sdb2\" (without the quotes)"
echo
echo "A folder will be made after the partition is mounted"
echo "in the partition's root called 'dump'. It will be mounted"
echo "at \$mnemosyne_root/dumptrg"
echo
echo "Please ensure the target has more than $memcap MB in free space"
echo "and at least 11MB more for logfiles and hashes, and ensure if"
echo "the memory is over 2GB, an NTFS, HFS+ or ext3/4 target is selected"
echo
echo "This cannot be checked before mount, but it *will* be checked"
echo "after mounting to ensure data integrity"
echo



lsblk -alf | grep -v -e loop | awk -F " " '{printf "%-8s %-6s %s \n", $1, $2, $3}'
echo

# Read device string if not already set (planning for future scripting
read devstring

#fi


mount "$devstring" $dump_target | tee -a $logfile



# We need to check if enough free space is present, using staticaly-linked df replacement

export freespace=`df -m | grep $devstring | grep [[:digit:]] | awk -F " " '{print $4}' | awk -F "." '{print $1}'`
if [ $freespace -gt $spacecheck ]; then

# Make folder in dumptrg to test if mounted and writable, and hold dumps

mkdir -p $targetF
touch $targetF/test.file
    if [ $? != 0 ]; then
        echo "Mount has failed, examine kernel mesg and logs" | tee -a $logfile
        exit 1

    else
#        clear
        echo "Mount successful!"
        return 0
    fi
    
else
echo "Insufficent free space on target, aborting..."
exit 1
fi

}


main()
{

mount_memcatch

mount_menu

return $?
}

main

return $?
