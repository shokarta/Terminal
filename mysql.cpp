#include "mysql.h"
#include <QtSql>
#include <QSqlQuery>
#include <QObject>
#include <QFile>
#include <QTextStream>

MySQL::MySQL(QObject *parent) :
    QObject(parent)
{
    // Sets Termianl Database
    terminal_db = QSqlDatabase::addDatabase("QMYSQL", "Terminal_DB_External");
    terminal_db.setHostName("localhost");
    terminal_db.setDatabaseName("terminals");
    terminal_db.setUserName("root");
    terminal_db.setPassword("");

    // Sets ANeT Database
    anet_db = QSqlDatabase::addDatabase("QMYSQL", "ANeT_DB");
    anet_db.setHostName("localhost");
    anet_db.setDatabaseName("terminals");
    anet_db.setUserName("root");
    anet_db.setPassword("");
}

bool MySQL::checkConnection()
{
    if(terminal_db.open()) { terminal_db.close(); return true; }
    else { qDebug() << "Terminal DB Error: " << terminal_db.lastError().text(); return false; }
}

bool MySQL::checkRecord(QString card, QString apl, QString taskType, QString taskKind, QString timestamp)
{
    if(!anet_db.open()) {
        qDebug() << "ANeT DB Error1: " << anet_db.lastError().text();
        return false;
    }
    else {
        QSqlQuery queryDatabaseAnet(anet_db);
        QString queryStringAnet("SELECT * FROM records WHERE (user='"+card+"' AND kst='"+apl+"' AND tasktype='"+taskType+"' AND taskkind='"+taskKind+"' AND timestamp='"+timestamp+"')");

        if(!queryDatabaseAnet.prepare(queryStringAnet)) {
            qDebug() << "ANeT DB Error2: " << anet_db.lastError().text();
            return false;
        }
        if(!queryDatabaseAnet.exec()) {
            qDebug() << "ANeT DB Error3: " << anet_db.lastError().text();
            return false;
        }
        else {
            int numRows;
            if(queryDatabaseAnet.driver()->hasFeature(QSqlDriver::QuerySize)) {
                numRows = queryDatabaseAnet.size();
            }
            else {
                queryDatabaseAnet.last();
                numRows = queryDatabaseAnet.at() + 1;
            }
            if(numRows<1) {
                // Nenalezeno ID Karty
                qDebug() << "ANeT DB Warning: Nenalezeno ID Karty";
                return false;
            }
            else {
                return true;
            }
        }
    }
}

bool MySQL::insertRecord(QString card, QString apl, QString taskType, QString taskKind, QString timestamp)
{
    if(!anet_db.open()) {
        qDebug() << "ANeT DB Error4: " << anet_db.lastError().text();
        return false;
    }
    else {
        QSqlQuery queryDatabaseAnet(anet_db);
        QString queryStringAnet("SELECT user_id FROM users WHERE card='"+card+"'");

        if(!queryDatabaseAnet.prepare(queryStringAnet)) {
            qDebug() << "ANeT DB Error5: " << anet_db.lastError().text();
            return false;
        }
        if(!queryDatabaseAnet.exec()) {
            qDebug() << "ANeT DB Error6: " << anet_db.lastError().text();
            return false;
        }
        else {
            int numRows;
            if(queryDatabaseAnet.driver()->hasFeature(QSqlDriver::QuerySize)) {
                numRows = queryDatabaseAnet.size();
            }
            else {
                queryDatabaseAnet.last();
                numRows = queryDatabaseAnet.at() + 1;
            }
            if(numRows<1) {
                // Nenalezeno ID Karty
                qDebug() << "ANeT DB Error: Nenalezeno ID Karty";
                return false;
            }

            // Nastavit user_id ke karte
            QString user_id;
            if(queryDatabaseAnet.next()) {
                user_id = queryDatabaseAnet.value("user_id").toString();
            }

            if(!terminal_db.open()) {
                qDebug() << "Terminal DB Error: " << terminal_db.lastError().text();
                return false;
            }
            else {
                QSqlQuery queryDatabase(terminal_db);
                QString queryString("INSERT INTO records (user, kst, tasktype, taskkind, timestamp) VALUES ('"+user_id+"', '"+apl+"', '"+taskType+"', '"+taskKind+"', '"+timestamp+"')");

                if(!queryDatabase.prepare(queryString)) {
                    qDebug() << "Terminal DB Error: " << terminal_db.lastError().text();
                    return false;
                }
                if(!queryDatabase.exec()) {
                    qDebug() << "Terminal DB Error: " << terminal_db.lastError().text();
                    return false;
                }
                else {
                    return true;
                }
            }
        }
    }
}

QString MySQL::selectName(QString card)
{
    if(!anet_db.open()) {
        qDebug() << "ANeT DB Error7: " << anet_db.lastError().text();
        return "NULL";
    }
    else {
        QSqlQuery queryDatabaseAnet(anet_db);
        QString queryStringAnet("SELECT CONCAT(fname, ' ', lname) AS name FROM users WHERE card='"+card+"'");

        if(!queryDatabaseAnet.prepare(queryStringAnet)) {
            qDebug() << "ANeT DB Error8: " << anet_db.lastError().text();
            return "NULL";
        }
        if(!queryDatabaseAnet.exec()) {
            qDebug() << "ANeT DB Error9: " << anet_db.lastError().text();
            return "NULL";
        }
        else {
            int numRows;
            if(queryDatabaseAnet.driver()->hasFeature(QSqlDriver::QuerySize)) {
                numRows = queryDatabaseAnet.size();
            }
            else {
                queryDatabaseAnet.last();
                numRows = queryDatabaseAnet.at() + 1;
            }
            if(numRows<1) {
                // Nenalezeno ID Karty
                qDebug() << "ANeT DB Error: Warning ID Karty";
                return "NULL";
            }

            // Nastavit user_id ke karte
            QString name;
            if(queryDatabaseAnet.next()) {
                name = queryDatabaseAnet.value("name").toString();
                return name;
            }
            else {
                return "NULL";
            }
        }
    }
}


QString MySQL::aplUpdate()
{
    QString fileName("C:\\Terminal\\Workplace.cfg");
    QFile file(fileName);
    QString data;
    if(QFileInfo::exists(fileName))
    {
        file.open(QIODevice::ReadWrite | QIODevice::Text);
        data = file.readAll();
        file.close();
        return data;
    }
    else
    {
        file.open(QIODevice::ReadWrite | QIODevice::Text);
        file.close();
        return "";
    }
}

void MySQL::aplModify(QString apl)
{
    QString fileName("C:\\Terminal\\Workplace.cfg");
    QFile file(fileName);

    file.open(QIODevice::ReadWrite | QIODevice::Text);
    QTextStream out(&file);
    out << apl;
    file.close();
}
