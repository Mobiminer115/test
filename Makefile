TARGET := iphone:clang:16.5:12.0
ARCHS := arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := CW3UnitEditor
CW3UnitEditor_FILES := Tweak.xm
CW3UnitEditor_CFLAGS := -fobjc-arc
CW3UnitEditor_FRAMEWORKS := UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
