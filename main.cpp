#include <QtCore>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtSql>
#include <QtDebug>
#include "mysql.h"


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<MySQL>("MySQL", 1, 0, "MySQL");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    // Sets path for SQLite
    engine.setOfflineStoragePath("C:\\Terminal");

    return app.exec();
}
