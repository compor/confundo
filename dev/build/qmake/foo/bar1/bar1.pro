# qmake file


include(../project-pre0.pri)


LIB_DIR = ../libs
HDR_DIR = .

CONFIG -= release
CONFIG += debug
CONFIG += warn_on
CONFIG += plugin

QT -= core gui

TEMPLATE = lib
DESTDIR = $${LIB_DIR}
TARGET = bar1


QMAKE_CXXFLAGS += -DQT_VER=$${QT_MAJOR_VERSION}
QMAKE_CXXFLAGS += -Wall


SOURCES = \
    bar1.cpp


HEADERS = \
    bar1.hpp


INCLUDEPATH += \
    $${HDR_DIR}


include(../project-post0.pri)


