#include "canbuscontroller.h"

CanBusController::CanBusController(QObject *parent) : QObject(parent)
{
    if (QCanBus::instance()->plugins().contains(QStringLiteral("socketcan"))) {
        QString errorString;
        const QList<QCanBusDeviceInfo> devices = QCanBus::instance()->availableDevices(
                    QStringLiteral("socketcan"), &errorString);

        if (!errorString.isEmpty()){
            qDebug() << errorString;
        } else {
            if(devices.length() > 0){
                m_device = QCanBus::instance()->createDevice(QStringLiteral("socketcan"), devices.at(0).name());
                setCapturing(true);
            }
        }
    }
}
void CanBusController::frameReceived(){
    for(int i=0; i < m_device->framesAvailable(); i++){
        QCanBusFrame frame = m_device->readFrame();
        if(frame.frameType() == QCanBusFrame::DataFrame){
            QString tmp = QString::number(frame.frameId(), 16).toUpper() + "#" + frame.payload().toHex().toUpper();
            if(m_filter){
                messageCount.insert(tmp,messageCount.value(tmp, 0)+1);
                if(messageCount.value(tmp, 0) == m_occurrenceLimit){
                    m_messages.append(tmp);
                }
            } else {
                m_messages.append(tmp);
            }
        }
    }
    emit messageListChanged();
}
void CanBusController::setCapturing(bool capture){
    if(capture){
        m_device->connectDevice();
        connect(m_device,&QCanBusDevice::framesReceived,this,&CanBusController::frameReceived);
    } else {
        disconnect(m_device, 0, 0, 0);
        m_device->disconnectDevice();
    }
    m_capturing = capture;
    emit capturingChanged();
}
