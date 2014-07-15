
#ifndef FOOBAROPERATIONS_H
#define FOOBAROPERATIONS_H

#include <QtCore/QObject>
#include <QtDBus/QtDBus>


class FoobarOperations : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.intralot.FoobarOperations");

public:
    FoobarOperations(QObject *parent = 0) : QObject(parent) { return; };
    ~FoobarOperations() { return; };


public Q_SLOTS:
    void Foo(qlonglong deviceId);

Q_SIGNALS:
    void Bar();
};



#endif //FOOBAROPERATIONS_H

