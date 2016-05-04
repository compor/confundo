# qmake file


# general options

MOC_DIR = .objs
OBJECTS_DIR = .objs


# project-specific options

# using a fake non-existent make dependent module
FAKE_MAKEFILE = Makefile.fake

# using postgres db as an example
DBP_HDR_DIR = 
DBP_LIB_DIR =


# determine target architecture

# either from env variable or the qmake.conf target
# here we use the environment

ENV_CROSS_COMPILE_PREFIX = $$(CROSS_COMPILE)
message(cross compile set: $${ENV_CROSS_COMPILE_PREFIX} )

ARCH = intel
equals(ENV_CROSS_COMPILE_PREFIX,arm-fsl-linux-gnueabi-):ARCH = arm

message(build target architecture: $${ARCH})


# determine qt version

isEmpty(QT_MAJOR_VERSION) {
    # probably using qt version 3, otherwise wtf?

    QT_VER = 3
} else {
    QT_VER = $${QT_MAJOR_VERSION}
}

message(qt version: $${QT_VER})


# determine files and dirs

equals(ARCH, arm) {
    # arm

    TMP_DIR = /usr/local/arm/rootfs/usr/local/pgsql/include
    exists($${TMP_DIR}):DBP_HDR_DIR = $${TMP_DIR}

    TMP_DIR = /usr/local/arm/rootfs/usr/local/pgsql/lib
    exists($${TMP_DIR}):DBP_LIB_DIR = $${TMP_DIR}
} else {
    # intel

    TMP_DIR = /usr/local/pgsql/include
    exists($${TMP_DIR}):DBP_HDR_DIR = $${TMP_DIR}

    TMP_DIR = /usr/include/postgresql
    exists($${TMP_DIR}):DBP_HDR_DIR = $${TMP_DIR}

    TMP_DIR = /usr/lib
    exists($${TMP_DIR}):DBP_LIB_DIR = $${TMP_DIR}
}


# compilation flags

equals(ARCH, arm):QMAKE_CFLAGS += -march=armv7-a -mfpu=neon -mfloat-abi=softfp
equals(ARCH, arm):QMAKE_CXXFLAGS += -march=armv7-a -mfpu=neon -mfloat-abi=softfp


# defines

DEFINES += QT_VER=$${QT_VER}


# includes

equals(ARCH, arm):INCLUDEPATH += \
    /usr/local/arm/include \
    /usr/local/arm/rootfs/include


# libs

equals(ARCH, arm):LIBS += \
    -L/usr/local/arm/lib

equals(ARCH, arm):LIBS += \
    -L/usr/local/arm/rootfs/lib \
    -L/usr/local/arm/rootfs/usr/lib


# other


