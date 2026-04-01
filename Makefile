include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PUBGWeaponTweak
PUBGWeaponTweak_FILES = Tweak.x
PUBGWeaponTweak_FRAMEWORKS = Foundation
PUBGWeaponTweak_LIBRARIES = substrate

include $(THEOS_MAKE_INSTANCE)/tweak.mk

# Agar sizda o'yinning bundle ID si bo'lsa, uni bu yerga kiriting.
# Masalan, PUBG Mobile uchun com.tencent.ig yoki com.pubg.mobile
# Bu tweakni faqat shu ilovaga yuklashni ta'minlaydi.
# PUBGWeaponTweak_BUNDLEID = com.tencent.ig
