import QtQuick 2.12
import QtQuick.Controls 2.0
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.12
import MySQL 1.0
import 'JavaScript.js' as JS


ApplicationWindow {

    id: mainWindow
    visible: true
    //visibility: "FullScreen"
    width: 870
    height: 535
    title: qsTr("Team Bonus")
    color: "black"

    // DB Settings
    property string dbId: "offlineDatabase"
    property string dbVersion: "1.0"
    property string dbDescription: "Temporary records from terminal inputs"
    property int dbSize: 1000000
    property var db

    property bool dbOnline

    property real buttonWidth:  mainWindow.width / 5
    property real buttonHeight: mainWindow.height / 5

    property string apl

    property string passTypedValue
    property string goodPass: "2580"
    onPassTypedValueChanged: { if(passTypedValue.length===4) {if(passTypedValue===goodPass) {viewMode="settings";} passTypedValue="";} }

    property string aplTypedValue
    onAplTypedValueChanged: { if(aplTypedValue.length===4) { sql.aplModify("K"+aplTypedValue); apl=sql.aplUpdate(); viewMode="settings"; aplTypedValue=""; } }


    property var cardTemporar
    property string viewMode: "common"

    property bool blured: false

    property variant colors: {
        'initialStatus': 'white',           // Initial Status
        'chooseTask': '#FFFF80',            // Choose Task Type or Kind
        'recordSaved': 'lime',              // Record Saved
        'unchoseStroke': '#666666',         // Initial Canvas Border
        'chosenStroke': 'orange',           // Canvas Border of Choosen Type or Kind
        'dateTime': 'white',                // Date and Time
        'naCanvasText': 'white',            // Not Available Canvas Border
        'chosenCanvasText': 'orange',       // Choose Task Type and Kind Canvas Text
        'unchosenCanvasText': '#FFFF80',    // Unchosen Task Type and Kind Canvas Text
        'labelLabel': 'white',              // Label
        'labelValue': 'yellow',             // Label Value
        'logout': 'yellow',                 // Logout Button
        'cardAwate': 'lime',                // Waiting for card
        'warningStatus': 'red',             // Status Warning
        'cardDisplay': 'yellow',            // Displaying Card Number
        'nameDisplay': 'lime'               // Displaying Card Holder Name
    }

    MySQL {
        id: sql
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: initialScreen
    }

    Component {
        id: initialScreen
        InitialScreen {}
    }

    // Keyboard Handler
    Item {
        focus: true
        Keys.onPressed: { JS.keyboardListener(event.key); }
    }

    FastBlur {
        id: blur
        anchors.fill: parent
        source: stackView
        radius: viewMode==='confirmShutdown' ? 32 : 0
    }

    // SHUTDOWN
    Rectangle {
        z: 2
        id: confirmShutdownRect
        anchors.centerIn: parent
        width: parent.width/2
        height: parent.height/2
        visible: viewMode==='confirmShutdown' ? true : false
        border.color: colors['unchoseStroke']
        border.width: mainWindow.height/200
        radius: mainWindow.height/35
        gradient: Gradient {
            GradientStop { position: 0.00; color: '#303030' }
            GradientStop { position: 0.40; color: '#151515' }
            GradientStop { position: 0.60; color: '#151515' }
            GradientStop { position: 1.00; color: '#303030' }
        }

        Label {
            id: confirmShutdownLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height/10
            font.pixelSize: parent.height/9
            font.bold: false
            color: colors['labelLabel']
            text: "Opravdu ukončit aplikaci?"
        }

        Rectangle {
            id: confirmShutdownYes
            anchors.left: parent.left
            anchors.leftMargin: parent.width/5
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height/8
            radius: mainWindow.height/50
            border.color: colors['unchoseStroke']
            border.width: mainWindow.height/200
            width: parent.width/4
            height: parent.height/3.5
            gradient: Gradient {
                GradientStop { position: 0.00; color: '#303030' }
                GradientStop { position: 0.50; color: '#151515' }
                GradientStop { position: 0.50; color: '#151515' }
                GradientStop { position: 1.00; color: '#303030' }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: { Qt.quit(); }
            }
            Label {
                id: confirmShutdownYesLabel
                anchors.centerIn: parent
                color: colors['labelLabel']
                font.pixelSize: parent.height/4
                text: "ANO"
            }
        }
        Rectangle {
            id: confirmShutdownNo
            anchors.right: parent.right
            anchors.rightMargin: parent.width/5
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height/8
            radius: mainWindow.height/50
            border.color: colors['unchoseStroke']
            border.width: mainWindow.height/200
            width: parent.width/4
            height: parent.height/3.5
            gradient: Gradient {
                GradientStop { position: 0.00; color: '#303030' }
                GradientStop { position: 0.50; color: '#151515' }
                GradientStop { position: 0.50; color: '#151515' }
                GradientStop { position: 1.00; color: '#303030' }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: { viewMode="settings"; }
            }
            Label {
                id: confirmShutdownNoLabel
                anchors.centerIn: parent
                color: colors['labelLabel']
                font.pixelSize: parent.height/4
                text: "NE"
            }
        }
    }

    Timer {
        id: dbRefresh
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { JS.checkDB(); cardTemporar=""; apl=sql.aplUpdate(); if(dbOnline===true) {JS.updateOnlineDB();}}
    }
}
