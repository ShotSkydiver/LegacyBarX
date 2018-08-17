include $(THEOS)/makefiles/common.mk

DEBUG = 1
SDKVERSION = 11.2
TARGET = iphone:clang:11.2:10.3
ARCHS = arm64

TWEAK_NAME = LegacyBarX
LegacyBarX_PRIVATE_FRAMEWORKS = AppSupport
LegacyBarX_FILES = Tweak.xm
LegacyBarX_FRAMEWORKS = UIKit CoreGraphics
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
