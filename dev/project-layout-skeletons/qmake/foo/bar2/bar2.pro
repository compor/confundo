# qmake file


include(../project-pre0.pri)


BIN_DIR = ../bins
LIB_DIR = ../libs
HDR_DIR = \
    . \
    ../bar1/
    

CONFIG -= release
CONFIG += debug
CONFIG += warn_on

QT -= core gui

TEMPLATE = app
DESTDIR = $${BIN_DIR}
TARGET = bar2


QMAKE_CXXFLAGS += -DQT_VER=$${QT_MAJOR_VERSION}
QMAKE_CXXFLAGS += -Wall


SOURCES = \
    bar2.cpp


HEADERS =


INCLUDEPATH += \
    $${HDR_DIR}


LIBS += \
    -L$${LIB_DIR}


LIBS += \
    -lbar1



include(../project-post0.pri)


