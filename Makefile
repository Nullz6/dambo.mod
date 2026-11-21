TARGET = iphone:clang:latest:16.0
ARCHS = arm64
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DAMBO
DAMBO_FILES = DAMBO.mm
DAMBO_CFLAGS = -fobjc-arc -std=c++17
DAMBO_FRAMEWORKS = UIKit Foundation QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk