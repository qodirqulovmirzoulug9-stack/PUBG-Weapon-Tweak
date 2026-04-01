ARCHS = arm64
TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = ShadowTrackerExtra

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PUBGWeaponTweak
PUBGWeaponTweak_FILES = Tweak.x
PUBGWeaponTweak_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable

include $(THEOS_MAKE_PATH)/tweak.mk
