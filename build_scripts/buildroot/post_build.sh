#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../env.sh
source $BASE_DIR/.mod_env

create_version()
{
    pushd $1 > /dev/null
    version="$(git describe --tags)-GuppyMod-$(date +%Y%m%d)"
    popd  > /dev/null
    echo $version
}

# paths
TARGET_ROOT="$TARGET_DIR"

# move unwantend initscripts to init.o (optional)
mkdir -p $TARGET_ROOT/etc/init.o
mv $TARGET_ROOT/etc/init.d/S35iptables $TARGET_ROOT/etc/init.o/ || true

# clean up root, if containing old build artefacts
rm -rf $TARGET_ROOT/root/setup
rm -rf $TARGET_ROOT/root/printer_data
rm -rf $TARGET_ROOT/root/printer_software/klipper
rm -rf $TARGET_ROOT/root/printer_software/KlipperScreen
rm -rf $TARGET_ROOT/root/printer_software/moonraker
rm -rf $TARGET_ROOT/root/printer_software/web
rm -rf $TARGET_ROOT/root/printer_software/guppyflo
# save build time for fake-hwclock
date -u '+%Y-%m-%d %H:%M:%S' > $TARGET_ROOT/etc/fake-hwclock.data

# update os-release
pushd $GIT_ROOT
KLIPPER_MOD_VERSION=$(git describe --tags)
popd

cat << EOF > $TARGET_ROOT/etc/os-release
NAME=Buildroot-GuppyMod
VERSION=-$KLIPPER_MOD_VERSION
ID=buildroot
VERSION_ID=$KLIPPER_MOD_VERSION
PRETTY_NAME="Klipper Mod $KLIPPER_MOD_VERSION"
EOF

##############################
# install klipper
##############################

log_info "Install Klipper"
mkdir -p $TARGET_ROOT/root/printer_software/klipper/

# copy prebuilt env or wheels
if [ -f $GIT_ROOT/prebuilt/klippy-env.tar.xz ]
then
  tar -xf $GIT_ROOT/prebuilt/klippy-env.tar.xz -C $TARGET_ROOT/root/printer_software/klipper/
else
  mkdir -p $TARGET_ROOT/root/setup/
  cp -r $GIT_ROOT/prebuilt/wheels/klipper_wheels $TARGET_ROOT/root/setup/
  cp -r $GIT_ROOT/submodules/klipper/scripts/klippy-requirements.txt $TARGET_ROOT/root/setup/klipper_wheels/requirements.txt
fi

# install klippy pyhton sources
pushd $GIT_ROOT/submodules/klipper/

pushd klippy/chelper
cp $BUILD_SCRIPTS/components/klipper/Makefile .
make
rm Makefile

popd
cp $BUILD_SCRIPTS/components/klipper/k1-klipper.patch .
if patch -r - -b -N -p1 < k1-klipper.patch;
then
    log_info "Skipping patch, already applied"
else
    log_info "Patch applied"
fi
cp -r klippy docs config README.md COPYING $TARGET_ROOT/root/printer_software/klipper/
rm k1-klipper.patch

create_version ./ > $TARGET_ROOT/root/printer_software/klipper/klippy/.version
popd

# install g-code shell extension
cp $GIT_ROOT/build_scripts/components/klipper/gcode_shell_command.py $TARGET_ROOT/root/printer_software/klipper/klippy/extras/

##############################
# install moonraker
##############################

log_info "Install Moonraker"
mkdir -p $TARGET_ROOT/root/printer_software/moonraker

# copy prebuilt env or wheels
if [ -f $GIT_ROOT/prebuilt/moonraker-env.tar.xz ]
then
  tar -xf $GIT_ROOT/prebuilt/moonraker-env.tar.xz -C $TARGET_ROOT/root/printer_software/moonraker/
else
  mkdir -p $TARGET_ROOT/root/setup/
  cp -r $GIT_ROOT/prebuilt/wheels/moonraker_wheels $TARGET_ROOT/root/setup/
  cat $GIT_ROOT/submodules/moonraker/scripts/moonraker-requirements.txt > $TARGET_ROOT/root/setup/moonraker_wheels/requirements.txt
  cat $GIT_ROOT/submodules/moonraker/scripts/moonraker-speedups.txt >> $TARGET_ROOT/root/setup/moonraker_wheels/requirements.txt
fi

# install moonraker python sources
pushd $GIT_ROOT/submodules/moonraker/
cp -r moonraker docs LICENSE README.md $TARGET_ROOT/root/printer_software/moonraker/
create_version ./ > $TARGET_ROOT/root/printer_software/moonraker/moonraker/.version
popd

# install moonraker timelapse plugin (from git)
cp $GIT_ROOT/prebuilt/moonraker-plugins/timelapse/timelapse.py "$TARGET_ROOT/root/printer_software/moonraker/moonraker/components/timelapse.py"

##############################
# install mainsail
##############################

log_info "Install Mainsail"
if [ ! -f $GIT_ROOT/prebuilt/mainsail.zip ]
then
  wget -P $GIT_ROOT/prebuilt/ https://github.com/mainsail-crew/mainsail/releases/download/v2.11.1/mainsail.zip
fi
mkdir -p $TARGET_ROOT/root/printer_software/web/mainsail
unzip $GIT_ROOT/prebuilt/mainsail.zip -d $TARGET_ROOT/root/printer_software/web/mainsail
# set moonraker port
sed -i 's\"port": null\"port": 7125\g' $TARGET_ROOT/root/printer_software/web/mainsail/config.json

##############################
# install fluidd
##############################

log_info "Install Fluidd"
if [ ! -f $GIT_ROOT/prebuilt/fluidd.zip ]
then
  wget -P $GIT_ROOT/prebuilt/ https://github.com/fluidd-core/fluidd/releases/download/v1.30.0/fluidd.zip
fi
mkdir -p $TARGET_ROOT/root/printer_software/web/fluidd
unzip $GIT_ROOT/prebuilt/fluidd.zip -d $TARGET_ROOT/root/printer_software/web/fluidd


##############################
# install printer configs
##############################

log_info "Install printer configs"
mkdir -p $TARGET_ROOT/root/printer_data/config
mkdir -p $TARGET_ROOT/root/printer_data/logs
cp -r $GIT_ROOT/printer_configs/* $TARGET_ROOT/root/printer_data/config/

##############################
# install guppyscreen
##############################

curl -L https://github.com/ballaswag/guppyflo/releases/latest/download/guppyflo_mipsle.zip -o $GIT_ROOT/prebuilt/guppyflo.zip
mkdir -p $TARGET_ROOT/root/printer_software/guppyflo
unzip $GIT_ROOT/prebuilt/guppyflo.zip -d $TARGET_ROOT/root/printer_software/guppyflo
mv $TARGET_ROOT/root/printer_software/guppyflo/guppyflo $TARGET_ROOT/root/printer_software/guppyflo/guppyflo.disabled
ln -sf /root/printer_data/config/guppytunnel.json $TARGET_ROOT/root/printer_software/guppyflo/guppytunnel.json


###############################
# Fix dbus user if not present
###############################
if ! grep dbus $TARGET_ROOT/etc/group;
then
    echo "dbus:x:101:dbus" >> $TARGET_ROOT/etc/group
fi
if ! grep dbus $TARGET_ROOT/etc/passwd;
then
    echo "dbus:x:100:101:DBus messagebus user:/run/dbus:/bin/false" >> $TARGET_ROOT/etc/passwd
fi
if ! grep dbus $TARGET_ROOT/etc/shadow;
then
    echo "dbus:*:::::::" >> $TARGET_ROOT/etc/shadow
fi

if [ "$MOD_VARIANT" == "guppyscreen" ]
then
    # files are in the overlay
    log_info "Installing guppyscreen"

    # config symlink
    ln -sf /root/printer_data/config/guppyconfig.json $TARGET_ROOT/root/printer_software/guppyscreen/guppyconfig.json
    mkdir -p $TARGET_ROOT/root/printer_data/config/GuppyScreen/scripts

    GUPPYOUT=$BUILDROOT_OUT/variant-guppyscreen/build/guppyscreen-origin_main/

    cp -r $GUPPYOUT/themes $TARGET_ROOT/root/printer_software/guppyscreen/
    cp $GUPPYOUT/k1/scripts/*.py $TARGET_DIR/root/printer_data/config/GuppyScreen/scripts/
    cp $GUPPYOUT/k1/scripts/guppy_cmd.cfg $TARGET_DIR/root/printer_data/config/GuppyScreen/
    cp $GUPPYOUT/k1/k1_mods/*.py $TARGET_DIR/root/printer_software/klipper/klippy/extras/

    sed -i "s|/usr/data/|/root/|g" $TARGET_DIR/root/printer_data/config/GuppyScreen/guppy_cmd.cfg
fi
