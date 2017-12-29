#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlEngine>
#include "canbuscontroller.h"

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

#if defined(Q_OS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine *engine = new QQmlApplicationEngine;

    CanBusController *canController = new CanBusController();

    engine->rootContext()->setContextProperty("canController", canController);
    engine->load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine->rootObjects().isEmpty())
        return -1;

    return app.exec();
}
