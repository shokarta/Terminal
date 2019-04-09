#ifndef MYSQL_H
#define MYSQL_H

#include <QObject>
#include <QtSql>


class MySQL : public QObject
{
    Q_OBJECT
public:
    explicit MySQL(QObject *parent = nullptr);
    Q_INVOKABLE bool checkConnection();
    Q_INVOKABLE bool checkRecord(QString card, QString apl, QString taskType, QString taskKind, QString timestamp);
    Q_INVOKABLE bool insertRecord(QString card, QString apl, QString taskType, QString taskKind, QString timestamp);
    Q_INVOKABLE QString selectName(QString card);
    Q_INVOKABLE QString aplUpdate();
    Q_INVOKABLE void aplModify(QString apl);

private:
    QSqlDatabase terminal_db;
    QSqlDatabase anet_db;

signals:

public slots:

};

#endif // MYSQL_H
