# qmake files


include(./project-pre0.pri)


TEMPLATE = subdirs


SUBDIRS = \
    bar1 \
    bar2 



# fake target
# not used, just for doc purposes

fake.commands = make -C $${FAKE_MAKEFILE} depend && make -C $${FAKE_MAKEFILE};

QMAKE_EXTRA_TARGETS += fake


# setup sub-project inter-dependencies

bar2.depends = bar1


