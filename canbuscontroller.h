#ifndef CANBUSCONTROLLER_H
#define CANBUSCONTROLLER_H

#include <QObject>
#include <QStringList>
#include <QDebug>
#include <QCanBus>
#include <QCanBusDevice>
class CanBusController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList messages READ messages NOTIFY messageListChanged)
    Q_PROPERTY(bool capturing READ capturing WRITE setCapturing NOTIFY capturingChanged)
    Q_PROPERTY(int occurrenceLimit READ occurrenceLimit WRITE setOccurrenceLimit NOTIFY occurrenceLimitChanged)
    Q_PROPERTY(bool filter READ filter WRITE setFilter NOTIFY filterChanged)
public:
    explicit CanBusController(QObject *parent = nullptr);
    QStringList messages(){
        return m_messages;
    }
    bool capturing(){
        return m_capturing;
    }
    int occurrenceLimit(){
        return m_occurrenceLimit;
    }
    bool filter(){
        return m_filter;
    }
    void setCapturing(bool);
    void setOccurrenceLimit(int occurrenceLimit){
        m_occurrenceLimit = occurrenceLimit;
        emit occurrenceLimitChanged();
        clear();
    }
    void setFilter(bool filter){
        m_filter = filter;
        emit filterChanged();
        clear();
    }
    Q_INVOKABLE void clear(){
        m_messages.clear();
        messageCount.clear();
        emit messageListChanged();
    }
signals:
    void messageListChanged();
    void capturingChanged();
    void occurrenceLimitChanged();
    void filterChanged();
public slots:
    void frameReceived();
private:
    QStringList m_messages;
    QMap<QString,int> messageCount;
    QCanBusDevice *m_device;
    bool m_capturing = false;
    int m_occurrenceLimit = 2;
    bool m_filter = false;
};

#endif // CANBUSCONTROLLER_H
