$(call inherit-product, device/oneplus/oneplus2/base.mk)

PRODUCT_BRAND := oneplus

PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.extension_library=libqti-perfd-client.so \
    persist.radio.apm_sim_not_pwdn=1 \
    persist.radio.custom_ecc=1 \
    persist.radio.sib16_support=1 \
    persist.radio.multisim.config=dsds \
    persist.radio.VT_CAM_INTERFACE=1 \
    ro.frp.pst=/dev/block/bootdevice/by-name/config
