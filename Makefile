ARCHS = arm64
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PUBGWeaponTweak
PUBGWeaponTweak_FILES = Tweak.x
PUBGWeaponTweak_CFLAGS = -fobjc-arc -w

include $(THEOS_MAKE_PATH)/tweak.mk
