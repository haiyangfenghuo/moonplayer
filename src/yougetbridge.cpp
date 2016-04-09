#include "yougetbridge.h"
#include "danmakudelaygetter.h"
#include "downloader.h"
#include "playlist.h"
#include "settings_network.h"
#include "settings_plugins.h"
#include "webvideo.h"
#include <QDir>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QMessageBox>
#include <QProcess>

YouGetBridge you_get_bridge;

YouGetBridge::YouGetBridge(QObject *parent) : QObject(parent)
{
    process = new QProcess(this);
    connect(process, SIGNAL(finished(int)),this, SLOT(onFinished()));
}

void YouGetBridge::parse(const QString &url, bool download, const QString &danmaku)
{
    if (process->state() == QProcess::Running)
    {
        QMessageBox::warning(NULL, "Error", tr("Another file is being parsed."));
        return;
    }
    qDebug("Use you-get.");
    this->download = download;
    this->danmaku = danmaku;
    QStringList args;
    if (!Settings::proxy.isEmpty())
        args << "--http-proxy" << (Settings::proxy + ':' + QString::number(Settings::port));
    args << "--json" << url;
    process->start("you-get", args, QProcess::ReadOnly);
}

void YouGetBridge::onFinished()
{
    QJsonParseError json_error;
    QJsonObject obj = QJsonDocument::fromJson(process->readAllStandardOutput(), &json_error).object();
    if (json_error.error == QJsonParseError::NoError)
    {
        if (obj.contains("streams"))
        {
            QString title = obj["title"].toString();
            QJsonObject streams = obj["streams"].toObject();
            QJsonObject::const_iterator i;
            for (i = streams.constBegin(); i != streams.constEnd(); i++)
            {
                QJsonObject item = i.value().toObject();
                if (item.contains("src"))
                {
                    QString container = item["container"].toString();
                    QJsonArray json_urls = item["src"].toArray();
                    QStringList names, urls;

                    for (int i = 0; i < json_urls.size(); i++)
                    {
                        names << QString("%1_%2.%3").arg(title, QString::number(i), container);
                        urls << json_urls[i].toString();
                    }

                    if (!danmaku.isEmpty() && !download && urls.size() > 1)
                        new DanmakuDelayGetter(names, urls, danmaku);

                    else if (download)
                    {
                        QDir dir = QDir(Settings::downloadDir);
                        QString dirname = title + '.' + container;
                        if (urls.size() > 1)
                        {
                            if (!dir.cd(dirname))
                            {
                                dir.mkdir(dirname);
                                dir.cd(dirname);
                            }
                        }
                        for (int i = 0; i < urls.size(); i++)
                            downloader->addTask(urls[i].toUtf8(), dir.filePath(names[i]), urls.size() > 1);
                        QMessageBox::information(NULL, "Message", tr("Add download task successfully!"));
                    }
                    else
                    {
                        playlist->addFileAndPlay(names[0], urls[0], danmaku);
                        for (int i = 1; i < urls.size(); i++)
                            playlist->addFile(names[i], urls[i]);
                        if (Settings::autoCloseWindow)
                            webvideo->close();
                    }

                    return;
                }
            }
        }
    }
    QMessageBox::warning(NULL, "Error", " Parse failed!\n" + QString::fromUtf8(process->readAllStandardError()));
}
