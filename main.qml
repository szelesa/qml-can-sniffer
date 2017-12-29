import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Window {
    id: window
    visible: true
    width: 800
    height: 480
    title: qsTr("Hello World")
    Item {
        id:__root
        anchors.bottom: inputPanel.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottomMargin: 0

        function hexDecode (text){
            var j;
            var hexes = text.match(/.{1,2}/g) || [];
            var back = "";
            for(j = 0; j<hexes.length; j++) {
                back += String.fromCharCode(parseInt(hexes[j], 16));
            }

            return back;
        }

        Item {
            id: controls
            height: 50
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            CheckBox {
                id: scrollToBottom
                text: qsTr("Scroll to Bottom")
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                checked:true
            }
            CheckBox {
                id: capture
                text: qsTr("Capture")
                anchors.left: scrollToBottom.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                checked: canController.capturing
                Binding {
                    target: canController
                    property: "capturing"
                    value: capture.checked
                }
            }
            CheckBox {
                id: isString
                text: qsTr("Payload as string")
                anchors.left: capture.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
            }

            Button {
                id: button
                text: qsTr("Clear")
                anchors.left: isString.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                onClicked: canController.clear()
            }
        }
        Item {
            id: multiControls
            height: 50
            anchors.top: controls.bottom
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0

            CheckBox {
                id: captureMulti
                text: qsTr("Only display payloads with more than ")
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                checked: canController.filter
                Binding {
                    target: canController
                    property: "filter"
                    value: captureMulti.checked
                }
            }

            SpinBox {
                id: spinBox
                to: 10
                from: 2
                anchors.left: captureMulti.right
                anchors.leftMargin: 6
                anchors.verticalCenterOffset: 0
                anchors.verticalCenter: parent.verticalCenter
                value: canController.occurrenceLimit
                Binding {
                    target: canController
                    property: "occurrenceLimit"
                    value: spinBox.value
                }
            }

            Text {
                id: text1
                text: qsTr("occurrences")
                anchors.left: spinBox.right
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Item {
            id: messageList
            width: parent.width /2
            anchors.top: multiControls.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: 0
            Item{
                id: listHead
                height: 20
                width:parent.width
                Text{
                    id: idHead
                    width: 60
                    text: "ID"
                    clip: false
                }
                Text{
                    text: "Payload"
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.left: idHead.right
                    anchors.leftMargin: 8
                }
            }
            ListView{
                property int oldIndex: 0
                clip: true
                anchors.top: listHead.bottom
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.topMargin: 8
                model:canController.messages
                delegate: Item{
                    id: item1
                    height: 20
                    width:parent.width
                    property var message: modelData.split('#')
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: {
                            payload.text = modelData
                            tagDialog.open()
                        }
                    }

                    Text{
                        id: id
                        width: 60
                        text:message[0]
                        clip: false
                    }

                    Text{
                        text:isString.checked?__root.hexDecode(message[1]):message[1]
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.left: id.right
                        anchors.leftMargin: 8
                    }

                }
                onCountChanged: {
                    if(scrollToBottom.checked){
                        //var newIndex = count - 1 // last index
                        positionViewAtEnd()
                        //currentIndex = newIndex
                    }
                }
                ScrollBar.vertical: ScrollBar {
                    active: true
                    policy:ScrollBar.AlwaysOn
                }
            }

        }
        Item {
            id: tagList
            width: parent.width /2
            anchors.leftMargin: 0
            anchors.top: multiControls.bottom
            anchors.bottom: parent.bottom
            anchors.left: messageList.right
            anchors.topMargin: 0
            Item{
                id: tagListHead
                height: 20
                width:parent.width
                Text{
                    id: tagIdHead
                    width: 60
                    text: "ID"
                    clip: false
                }
                Text{
                    id: tagPayloadHead
                    width: 150
                    text: "Payload"
                    anchors.left: tagIdHead.right
                    anchors.leftMargin: 8
                }

                Text {
                    id: tagNameHead
                    text: qsTr("Tag Name")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: tagPayloadHead.right
                    anchors.leftMargin: 8
                }
            }
            ListView{
                property int oldIndex: 0
                clip: true
                anchors.top: tagListHead.bottom
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.topMargin: 8
                model:ListModel{
                    id:tagListModel
                }

                delegate: Item{
                    height: 20
                    width:parent.width
                    property var message: payload.split('#')

                    Text{
                        id: tagId
                        width: 60
                        text:message[0]
                        clip: false
                    }

                    Text{
                        id: tagPayloadLabel
                        text:isString.checked?__root.hexDecode(message[1]):message[1]
                        anchors.left: tagId.right
                        anchors.leftMargin: 8
                        width: 150
                    }
                    Text {
                        text: tagName
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: tagPayloadLabel.right
                        anchors.leftMargin: 8
                    }

                }
                onCountChanged: {
                    if(scrollToBottom.checked){
                        //var newIndex = count - 1 // last index
                        positionViewAtEnd()
                        //currentIndex = newIndex
                    }
                }
                ScrollBar.vertical: ScrollBar {
                    active: true
                    policy:ScrollBar.AlwaysOn
                }
            }

        }
        Popup {
            id: tagDialog
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            z: 20
            width:parent.width*0.5
            height:parent.height*0.5
            visible: false
            dim: false
            modal: false
            focus: true
            closePolicy: Popup.NoAutoClose

            Text {
                id: payload
                anchors.bottom: tagName.top
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                color: "navy"
            }
            TextField {
                id: tagName
                placeholderText : "Payload Tag"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Button {
                id: tagAddButton
                text: qsTr("Add")
                anchors.horizontalCenterOffset: -width/2 - 4
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: tagName.bottom
                anchors.topMargin: 8
                onClicked: {
                    tagDialog.close();
                    tagListModel.append({
                                            "payload":payload.text,
                                            "tagName":tagName.text
                                        })
                    tagName.text = ""
                }
            }
            Button {
                id: tagCloseButton
                text: qsTr("Cancel")
                anchors.horizontalCenterOffset: width/2 + 4
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: tagName.bottom
                anchors.topMargin: 8
                onClicked: {
                    tagName.text = ""
                    tagDialog.close();
                }
            }
        }
    }
    InputPanel {
        id: inputPanel
        z: 99
        x: 0
        y: window.height
        width: window.width

        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: window.height - inputPanel.height
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
