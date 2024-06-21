#!/bin/sh
set -ex

# workdir contains our update files
cd "$(dirname "$0")"
WORK_DIR="$(pwd)"
MACHINE=$1
PID=$2

# error handling
error_handler() {
  # xzcat $WORK_DIR/img/install_fail_error.img.xz > /dev/fb0
  sync
  # always exit without error, to prevent immediate boot of flashforge software
  exit 0
}
trap '[ $? -eq 0 ] && exit 0 || error_handler' EXIT

do_setup()
{
    # # safety check, only install on supported printer
    # if ([ "$MACHINE" != "Adventurer5M" ] && [ "$MACHINE" != "Adventurer5MPro" ]) || \
    #    ([ "$PID" != "0023" ] && [ "$PID" != "0024" ]) || \
    #     [ "$(uname -m)" != "armv7l" ]
    #  then
    #     echo "Update file does not match machine type."
    #     xzcat $WORK_DIR/img/install_fail_vers.img.xz > /dev/fb0
    #     exit 0
    # fi

    # # saftey check, only install on supported versions
    # FF_VERSION="$(cat /root/version)"
    # if [ "$FF_VERSION" != "2.4.5" ]
    # then
    #     echo "Printer software version not supported."
    #     xzcat $WORK_DIR/img/install_fail_vers.img.xz > /dev/fb0
    #     exit 0
    # fi

    MOD_INIT_FILE="/etc/init.d/S00klipper_mod"
    MOD_INIT_FILE_OLD="/etc/init.d/S90klipper_mod"
    MOD_DIR="/usr/data/.klipper_mod"
    # chroot is replaced on mod upate or reinstall
    # other data in .klipper_mod is kept, unless uninstalled
    CHROOT_DIR="${MOD_DIR}/chroot"

    # update start image
    # xzcat $WORK_DIR/img/install_start.img.xz > /dev/fb0
    # --------------------------------

    # uninstall previous mod version if present - keep other data in .klipper_mod
    rm -f $MOD_INIT_FILE
    rm -f $MOD_INIT_FILE_OLD
    rm -rf $CHROOT_DIR

    # check free space, we require 512MB before installation for saftey reasons
    FREE_SPACE=$(df /usr/data | tail -1 | tr -s ' ' | cut -d' ' -f4)
    MIN_SPACE="524228"
    if [ "$FREE_SPACE" -lt "$MIN_SPACE" ]
    then
        echo "Not enough free space on data partition. 512MB required!";
        # xzcat $WORK_DIR/img/install_fail_mem.img.xz > /dev/fb0
        exit 0
    fi

    # calculate checksums to be printed in the log
    if ls /mnt/K1*; then
      md5sum /mnt/K1*
    fi
    md5sum $WORK_DIR/chroot.tar.xz

    # unpack chroot environment
    mkdir -p $CHROOT_DIR
    xz -dc $WORK_DIR/chroot.tar.xz | tar -xf - -C $CHROOT_DIR
    sync

    ##############################
    # which k1 are you?
    ##############################

    PRINTER_CONF_DIR="${CHROOT_DIR}//root/printer_data/config"
    machine_info=$(tr -d '\0' </dev/mmcblk0p2)
    if [[ $machine_info == *"CR-K1;CR4CU220812S12;;;;;"* ]]; then
	echo "Identified machine as K1. Configuring printer.cfg for a K1."
	cp $PRINTER_CONF_DIR/k1/*.cfg $PRINTER_CONF_DIR/
	rm $PRINTER_CONF_DIR/printer_k1c.cfg $PRINTER_CONF_DIR/printer_variant1.cfg

    elif [[ $machine_info == *"CR-K1;CR4CU220812S12;;;1;;"* ]]; then
	echo "Identified machine as K1 New Variant. Configuring printer.cfg for a K1 New Variant."
	cp $PRINTER_CONF_DIR/k1/*.cfg $PRINTER_CONF_DIR/
	mv $PRINTER_CONF_DIR/printer_variant1.cfg $PRINTER_CONF_DIR/printer.cfg
	rm $PRINTER_CONF_DIR/printer_k1c.cfg

    elif [[ $machine_info == *"CR-K1 Max;CR4CU220812S12;;;;;"* ]]; then
	echo "Identified machine as K1 Max. Configuring printer.cfg for a K1 Max."
	cp $PRINTER_CONF_DIR/k1max/*.cfg $PRINTER_CONF_DIR/
	rm $PRINTER_CONF_DIR/printer_variant1.cfg

    elif [[ $machine_info == *"CR-K1 Max;CR4CU220812S12;;;1;;"* ]]; then
	echo "Identified machine as K1 Max New Variant. Configuring printer.cfg for a K1 Max New Variant."
	cp $PRINTER_CONF_DIR/k1max/*.cfg $PRINTER_CONF_DIR/
	mv $PRINTER_CONF_DIR/printer_variant1.cfg  $PRINTER_CONF_DIR/printer.cfg

    elif [[ $machine_info == *"K1C;CR4CU220812S12;;;;;"* ]]; then
	echo "Identified machine as K1C. Configuring printer.cfg for a K1C."
	cp $PRINTER_CONF_DIR/k1/*.cfg $PRINTER_CONF_DIR/
	mv $PRINTER_CONF_DIR/printer_k1c.cfg $PRINTER_CONF_DIR/printer.cfg
	rm $PRINTER_CONF_DIR/printer_variant1.cfg

    else
	echo "Failed to idenity K1 model. Exiting.."
	exit 1
    fi


    # do intial setup
    $CHROOT_DIR/etc/init/S00klipper_mod setup
    sync

    # install initfile
    cp $CHROOT_DIR/etc/init/S00klipper_mod /etc/init.d/
    sync

    # update end image
    # --------------------------------
    # xzcat $WORK_DIR/img/install_ok.img.xz > /dev/fb0
}

# write log (if mount point is found)
if grep "^/dev/sd[ab12]* /mnt " /proc/mounts; then
  do_setup &> /mnt/klipper_mod_install.log
  sync
else
  do_setup
fi

exit 0
