################################################################################
#
# klipper mcu flasher mkfile
#
################################################################################

KLIPPER_FLASHER_VERSION = origin/master
KLIPPER_FLASHER_SITE = https://github.com/Klipper3d/klipper.git
KLIPPER_FLASHER_SITE_METHOD = git
KLIPPER_FLASHER_LICENSE = GPL-3.0+
KLIPPER_FLASHER_LICENSE_FILES = COPYING
KLIPPER_FLASHER_DEPENDENCIES = libusb

define KLIPPER_FLASHER_BUILD_CMDS
$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/lib/rp2040_flash
endef

define KLIPPER_FLASHER_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/lib/rp2040_flash/rp2040_flash $(TARGET_DIR)/usr/bin/rp2040_flash
endef

$(eval $(generic-package))
