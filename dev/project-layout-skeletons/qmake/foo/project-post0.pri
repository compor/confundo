# qmake file


equals(TEMPLATE, lib) {
    # install shared library in the same library target dir
    target.path = $${LIB_DIR}
    INSTALLS += target

    QMAKE_DISTCLEAN += $${DESTDIR}/lib$${TARGET}.so
}


equals(TEMPLATE, app) {
    # install binary in the same bin target dir
    target.path = $${BIN_DIR}
    INSTALLS += target

    QMAKE_DISTCLEAN += $${DESTDIR}/$${TARGET}
}




# strip debugging symbols, if release mode is on
release:QMAKE_POST_LINK += ${STRIP} -g $${DESTDIR}/$${TARGET};


