import QtQuick 2.12
import QtQuick.Controls 2.0
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.12
import MySQL 1.0
import 'JavaScript.js' as JS

Item {

    property double startTime: 0
    property double logoutTime: 0

    property var taskType: null
    property var taskKind: null
    property bool warningTriggered: false
    property bool loggedOff: false
    property var card: null

    onTaskKindChanged: Qt.callLater(JS.statusDisplay)
    onTaskTypeChanged: Qt.callLater(JS.statusDisplay)
    onWarningTriggeredChanged: Qt.callLater(JS.statusDisplay)
    //onLoggedOffChanged: Qt.callLater(JS.statusDisplay)
    onCardChanged: { Qt.callLater(JS.statusDisplay); }

    property var cardTemporar2: cardTemporar
    onCardTemporar2Changed: { Qt.callLater(JS.cardAssign) }

    // MAIN Rectangle
    Rectangle {
        anchors.fill: parent
        color: "transparent"

        // TOP Rectangle
        Rectangle {
            id: mainRectTop
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: buttonHeight
            color: "transparent"

            Canvas {
                id: wideCanvasTop
                anchors.fill: parent

                onPaint: {
                    var context = getContext("2d");

                    // Shape
                    context.moveTo(mainWindow.width / 100, parent.height / 2);
                    context.lineTo(mainWindow.width / 25, parent.height / 20);
                    context.lineTo(mainWindow.width - (mainWindow.width / 25), parent.height / 20);
                    context.lineTo(mainWindow.width - (mainWindow.width / 100), parent.height / 2);
                    context.lineTo(mainWindow.width - (mainWindow.width / 25), parent.height - (parent.height / 20));
                    context.lineTo(mainWindow.width / 25, parent.height - (parent.height / 20));
                    context.lineTo(mainWindow.width / 100, parent.height / 2);

                    // Line
                    context.lineWidth = parent.height / 20;
                    context.strokeStyle = colors['unchoseStroke'];
                    context.stroke();

                    // Color
                    var grad = context.createLinearGradient(0, mainWindow.height/2, mainWindow.width, mainWindow.height/2);
                    grad.addColorStop(0, '#303030');
                    grad.addColorStop(0.35, '#151515');
                    grad.addColorStop(0.65, '#151515');
                    grad.addColorStop(1, '#303030');
                    context.fillStyle = grad;
                    context.fill();
                }
            }

            AnimatedImage  {
                id: icon
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: mainWindow.width/17.4
                height: mainWindow.height/10
                fillMode: Image.PreserveAspectFit
                source: { JS.imgSource(); }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        JS.viewModeChange();
                    }
                }
            }

            Label {
                id: datetimeDate
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height/2
                font.pixelSize: parent.height/3
                font.bold: true
                color: colors['dateTime']
                text: JS.currentDate()
            }
            Label {
                id: datetimeTime
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: parent.height/2
                font.pixelSize: parent.height/3
                font.bold: true
                color: colors['dateTime']
                text: JS.currentTime()

                MouseArea { // SHOKARTA - zmenit na kdyz se prilozi karta
                    anchors.fill: parent
                    onClicked: { JS.login("bla"); }
                }
            }

            Label {
                id: database
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: mainWindow.width/17.4
                font.pixelSize: parent.height/4
                font.bold: true
                color: dbOnline===true ? 'Lime' : 'Red'
                text: dbOnline===true ? 'ONLINE' : 'OFFLINE'

                MouseArea {
                    anchors.fill: parent
                    onClicked: { dbRefresh.restart(); }
                }
            }
        }

        // TOP MIDDLE
        Rectangle {
            id: mainRectMiddle
            anchors.top: mainRectTop.bottom
            anchors.bottom: mainRectBottom.top
            anchors.left: parent.left
            anchors.right: parent.right
            color: "transparent"

            // TOP-LEFT Rectangle
            Rectangle {
                id: midRectLeft
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: buttonWidth
                color: "transparent"
                visible: viewMode==='common' ? true : false

                Rectangle {
                    id: leftRect1
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: (parent.height/3.7)-(buttonHeight/2)
                    height: buttonHeight
                    color: "transparent"

                    Canvas {
                        id: leftCanvas1
                        anchors.fill: parent

                        onPaint: {
                            var context = getContext("2d");

                            // Shape
                            context.moveTo(mainWindow.width / 100, parent.height / 2);
                            context.lineTo(mainWindow.width / 25, parent.height / 20);
                            context.lineTo(parent.width - (mainWindow.width / 100), parent.height / 20);
                            context.lineTo(parent.width - (mainWindow.width / 100), parent.height - (parent.height / 20));
                            context.lineTo(mainWindow.width / 25, parent.height - (parent.height / 20));
                            context.lineTo(mainWindow.width / 100, parent.height / 2);

                            // Line
                            context.lineWidth = parent.height / 20;
                            taskKind==='startTask' ? context.strokeStyle = colors['chosenStroke'] : context.strokeStyle = colors['unchoseStroke'];
                            context.stroke();

                            // Color
                            var grad = context.createLinearGradient(0, mainWindow.height/2, mainWindow.width, mainWindow.height/2);
                            grad.addColorStop(0, '#303030');
                            grad.addColorStop(0.35, '#151515');
                            grad.addColorStop(0.65, '#151515');
                            grad.addColorStop(1, '#303030');
                            context.fillStyle = grad;
                            context.fill();
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if(card!==null) {
                                    taskKind==='startTask' ? taskKind=null : taskKind='startTask'
                                    startTime=0;
                                    resetTerminal.restart();
                                }
                                else { JS.alertDisplay(); }
                            }
                        }
                    }

                    Label {
                        id: startTask
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: mainWindow.width/42.5
                        font.pixelSize: parent.height/4
                        font.bold: true
                        color: card===null ? colors['naCanvasText'] : (taskKind==='startTask' ? colors['chosenCanvasText'] : colors['unchosenCanvasText'])
                        text: qsTr("Začátek")
                    }
                }

                Rectangle {
                    id: leftRect2
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: (parent.height/3.7)-(buttonHeight/2)
                    height: buttonHeight
                    color: "transparent"

                    Canvas {
                        id: leftCanvas2
                        anchors.fill: parent

                        onPaint: {
                            var context = getContext("2d");

                            // Shape
                            context.moveTo(mainWindow.width / 100, parent.height / 2);
                            context.lineTo(mainWindow.width / 25, parent.height / 20);
                            context.lineTo(parent.width - (mainWindow.width / 100), parent.height / 20);
                            context.lineTo(parent.width - (mainWindow.width / 100), parent.height - (parent.height / 20));
                            context.lineTo(mainWindow.width / 25, parent.height - (parent.height / 20));
                            context.lineTo(mainWindow.width / 100, parent.height / 2);

                            // Line
                            context.lineWidth = parent.height / 20;
                            taskKind==='stopTask' ? context.strokeStyle = colors['chosenStroke'] : context.strokeStyle = colors['unchoseStroke']
                            context.stroke();

                            // Color
                            var grad = context.createLinearGradient(0, mainWindow.height/2, mainWindow.width, mainWindow.height/2);
                            grad.addColorStop(0, '#303030');
                            grad.addColorStop(0.35, '#151515');
                            grad.addColorStop(0.65, '#151515');
                            grad.addColorStop(1, '#303030');
                            context.fillStyle = grad;
                            context.fill();
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if(card!==null) {
                                    taskKind==='stopTask' ? taskKind=null : taskKind='stopTask'
                                    startTime=0;
                                    resetTerminal.restart();
                                }
                                else { JS.alertDisplay(); }
                                JS.refreshCanvas();
                            }
                        }
                    }

                    Label {
                        id: stopTask
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: mainWindow.width/42.5
                        font.pixelSize: parent.height/4
                        font.bold: true
                        color: card===null ? colors['naCanvasText'] : (taskKind==='stopTask' ? colors['chosenCanvasText'] : colors['unchosenCanvasText'])
                        text: qsTr("Konec")
                    }
                }
            }

            // TOP-CENTER Rectangle
            Rectangle {
                id: midRectCenter
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                color: "transparent"


                // APL CHANGE
                Rectangle {
                    id: settingsRect
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.verticalCenter
                    width: parent.width/2
                    height: parent.height/4
                    color: "transparent"
                    visible: viewMode==='settings' ? true : false

                    Rectangle {
                        id: aplIcon
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        width: parent.height
                        color: "transparent"

                        AnimatedImage  {
                            id: aplnimatedIcon
                            anchors.centerIn: parent
                            width: parent.width * 0.8
                            height: parent.height * 0.8
                            fillMode: Image.PreserveAspectFit
                            source: "sources/images/apl.gif"

                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.viewModeChange("aplChange"); }
                            }
                        }
                    }
                    Rectangle {
                        id: aplLabel2
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: aplIcon.right
                        anchors.right: parent.right
                        color: "transparent"

                        Label {
                            id: aplLabelLabel
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/20
                            font.pixelSize: parent.height/2.5
                            font.bold: false
                            color: colors['labelLabel']
                            text: "ZMĚNIT PRACOVIŠTĚ"
                        }
                    }
                }

                // SHUTDOWN
                Rectangle {
                    id: settingsRect2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.verticalCenter
                    width: parent.width/2
                    height: parent.height/4
                    color: "transparent"
                    visible: viewMode==='settings' ? true : false

                    Rectangle {
                        id: shutdownIcon
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        width: parent.height
                        color: "transparent"

                        AnimatedImage  {
                            id: shutdownAnimatedIcon
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height
                            fillMode: Image.PreserveAspectFit
                            source: "sources/images/shutdown.gif"

                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.viewModeChange("confirmShutdown"); }
                            }
                        }
                    }
                    Rectangle {
                        id: shutdownLabel
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: shutdownIcon.right
                        anchors.right: parent.right
                        color: "transparent"

                        Label {
                            id: shutdownLabelLabel
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/20
                            font.pixelSize: parent.height/2.5
                            font.bold: false
                            color: colors['labelLabel']
                            text: "UKONČIT APLIKACI"
                        }
                    }
                }

                Rectangle {
                    id: passRect
                    anchors.centerIn: parent
                    color: "transparent"
                    height: parent.height * 0.95
                    width: parent.width * 0.35
                    visible: viewMode==='checkPass' ? true : false

                    Label {
                        id: passwordLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        font.pixelSize: parent.height/10
                        font.bold: false
                        color: colors['labelLabel']
                        text: "Vložte heslo"
                    }

                    Rectangle {
                        id: passTyped
                        anchors.top: passwordLabel.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: mainWindow.width / 4.5
                        height: mainWindow.height / 14
                        color: "transparent"

                        Rectangle {
                            id: passTyped1
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            color: passTypedValue.length<1 ? 'transparent' : '#303030'
                            border.color: colors['unchoseStroke']
                            border.width: passTyped1.width/15
                            radius: passTyped1.width/2
                            height: passTyped.height
                            width: passTyped.height
                        }
                        Rectangle {
                            id: passTyped2
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/3 - passTyped2.width/3
                            color: passTypedValue.length<2 ? 'transparent' : '#303030'
                            border.color: colors['unchoseStroke']
                            border.width: passTyped2.width/15
                            radius: passTyped2.width/2
                            height: passTyped.height
                            width: passTyped.height
                        }
                        Rectangle {
                            id: passTyped3
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width/3 - passTyped3.width/3
                            color: passTypedValue.length<3 ? 'transparent' : '#303030'
                            border.color: colors['unchoseStroke']
                            border.width: passTyped3.width/15
                            radius: passTyped3.width/2
                            height: passTyped.height
                            width: passTyped.height
                        }
                        Rectangle {
                            id: passTyped4
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            color: passTypedValue.length<4 ? 'transparent' : '#303030'
                            border.color: colors['unchoseStroke']
                            border.width: passTyped4.width/15
                            radius: passTyped4.width/2
                            height: passTyped.height
                            width: passTyped.height
                        }
                    }

                    Rectangle {
                        id: keyboard
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: parent.height*0.67
                        color: "transparent"

                        // KEY 1
                        Rectangle {
                            id: key1
                            anchors.left: parent.left
                            anchors.top: parent.top
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: labelKey1
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "1"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.passKeyPressed("1"); }
                            }
                        }
                        // KEY 2
                        Rectangle {
                            id: key2
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: labelKey2
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "2"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.passKeyPressed("2"); }
                            }
                        }
                        // KEY 3
                        Rectangle {
                            id: key3
                            anchors.right: parent.right
                            anchors.top: parent.top
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: labelKey3
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "3"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.passKeyPressed("3"); }
                            }
                        }
                        // KEY 4
                        Rectangle {
                            id: key4
                            anchors.left: key1.left
                            anchors.top: key1.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: labelKey4
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "4"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.passKeyPressed("4"); }
                            }
                        }
                        // KEY 5
                        Rectangle {
                            id: key5
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: key2.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: labelKey5
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "5"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.passKeyPressed("5"); }
                            }
                        }
                        // KEY 6
                        Rectangle {
                            id: key6
                            anchors.right: parent.right
                            anchors.top: key3.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: labelKey6
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "6"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.passKeyPressed("6"); }
                            }
                        }
                        // KEY 7
                        Rectangle {
                            id: key7
                            anchors.left: parent.left
                            anchors.top: key4.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: labelKey7
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "7"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.passKeyPressed("7"); }
                            }
                        }
                        // KEY 8
                        Rectangle {
                            id: key8
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: key5.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: labelKey8
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "8"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.passKeyPressed("8"); }
                            }
                        }
                        // KEY 9
                        Rectangle {
                            id: key9
                            anchors.right: parent.right
                            anchors.top: key6.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: labelKey9
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "9"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.passKeyPressed("9"); }
                            }
                        }
                        // KEY CLS
                        Rectangle {
                            id: keyCLS
                            anchors.left: parent.left
                            anchors.top: key7.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: labelKeyCLS
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "x"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.passKeyPressed("C"); }
                            }
                        }
                        // KEY 0
                        Rectangle {
                            id: key0
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: key8.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: labelKey0
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "0"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.passKeyPressed("0"); }
                            }
                        }
                        // KEY BACKSPACE
                        Rectangle {
                            id: keyB
                            anchors.right: parent.right
                            anchors.top: key9.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: labelKeyB
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "⇦"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.passKeyPressed("B"); }
                            }
                        }
                    }
                }

                Rectangle {
                    id: aplRect
                    anchors.centerIn: parent
                    color: "transparent"
                    height: parent.height * 0.95
                    width: parent.width * 0.35
                    visible: viewMode==='aplChange' ? true : false

                    Label {
                        id: aplLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        font.pixelSize: parent.height/10
                        font.bold: false
                        color: colors['labelLabel']
                        text: "Vložte pracoviště"
                    }

                    Rectangle {
                        id: aplTyped
                        anchors.top: aplLabel.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: mainWindow.width / 4.5
                        height: mainWindow.height / 14
                        color: "transparent"

                        Label {
                            id: aplTypedK
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            height: aplTyped.height
                            color: "yellow"
                            font.pixelSize: parent.height/1.25
                            text: "K"
                        }
                        Label {
                            id: aplTyped1
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width/5 + aplTyped1.width/2
                            height: aplTyped.height
                            color: "white"
                            font.pixelSize: parent.height/1.25
                            text: aplTypedValue.length<1 ? "_" : aplTypedValue.substr(0, 1)
                        }
                        Label {
                            id: aplTyped2
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            height: aplTyped.height
                            color: "white"
                            font.pixelSize: parent.height/1.25
                            text: aplTypedValue.length<2 ? "_" : aplTypedValue.substr(1, 1)
                        }
                        Label {
                            id: aplTyped3
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width/5 + aplTyped3.width/2
                            height: aplTyped.height
                            color: "white"
                            font.pixelSize: parent.height/1.25
                            text: aplTypedValue.length<3 ? "_" : aplTypedValue.substr(2, 1)
                        }
                        Label {
                            id: aplTyped4
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            height: aplTyped.height
                            color: "white"
                            font.pixelSize: parent.height/1.25
                            text: aplTypedValue.length<4 ? "_" : aplTypedValue.substr(3, 1)
                        }
                    }

                    Rectangle {
                        id: aplKeyboard
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: parent.height*0.67
                        color: "transparent"

                        // KEY 1
                        Rectangle {
                            id: aplKey1
                            anchors.left: parent.left
                            anchors.top: parent.top
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: aplLabelKey1
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "1"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.aplKeyPressed("1"); }
                            }
                        }
                        // KEY 2
                        Rectangle {
                            id: aplKey2
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: aplLabelKey2
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "2"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.aplKeyPressed("2"); }
                            }
                        }
                        // KEY 3
                        Rectangle {
                            id: aplKey3
                            anchors.right: parent.right
                            anchors.top: parent.top
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: aplLabelKey3
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "3"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.aplKeyPressed("3"); }
                            }
                        }
                        // KEY 4
                        Rectangle {
                            id: aplKey4
                            anchors.left: aplKey1.left
                            anchors.top: aplKey1.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: aplLabelKey4
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "4"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.aplKeyPressed("4"); }
                            }
                        }
                        // KEY 5
                        Rectangle {
                            id: aplKey5
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: aplKey2.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: aplLabelKey5
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "5"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.aplKeyPressed("5"); }
                            }
                        }
                        // KEY 6
                        Rectangle {
                            id: aplKey6
                            anchors.right: parent.right
                            anchors.top: aplKey3.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: aplLabelKey6
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "6"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.aplKeyPressed("6"); }
                            }
                        }
                        // KEY 7
                        Rectangle {
                            id: aplKey7
                            anchors.left: parent.left
                            anchors.top: aplKey4.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: aplLabelKey7
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "7"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.aplKeyPressed("7"); }
                            }
                        }
                        // KEY 8
                        Rectangle {
                            id: aplKey8
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: aplKey5.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: aplLabelKey8
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "8"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.aplKeyPressed("8"); }
                            }
                        }
                        // KEY 9
                        Rectangle {
                            id: aplKey9
                            anchors.right: parent.right
                            anchors.top: aplKey6.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: aplLabelKey9
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "9"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.aplKeyPressed("9"); }
                            }
                        }
                        // KEY CLS
                        Rectangle {
                            id: aplKeyCLS
                            anchors.left: parent.left
                            anchors.top: aplKey7.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: aplLabelKeyCLS
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "x"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.aplKeyPressed("C"); }
                            }
                        }
                        // KEY 0
                        Rectangle {
                            id: aplKey0
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: aplKey8.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: aplLabelKey0
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "0"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.aplKeyPressed("0"); }
                            }
                        }
                        // KEY BACKSPACE
                        Rectangle {
                            id: aplKeyB
                            anchors.right: parent.right
                            anchors.top: aplKey9.bottom
                            width: parent.width/3
                            height: parent.height/4
                            border.color: colors['unchoseStroke']
                            border.width: mainWindow.height/215
                            radius: mainWindow.height/35
                            gradient: Gradient {
                                GradientStop { position: 0.00; color: '#303030' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 0.50; color: '#151515' }
                                GradientStop { position: 1.00; color: '#303030' }
                            }
                            Label {
                                id: aplLabelKeyB
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: parent.height / 2
                                text: "⇦"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { JS.aplKeyPressed("B"); }
                            }
                        }
                    }
                }


                Rectangle {
                    id: midRectCenterWorkplace
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: mainWindow.width-(buttonWidth*2)
                    height: parent.height/2
                    color: "transparent"
                    visible: viewMode==='common' ? true : false

                    Label {
                        id: workplaceLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: parent.height/3-workplaceLabel.height
                        font.pixelSize: parent.height/10
                        font.bold: false
                        color: colors['labelLabel']
                        text: qsTr("Pracoviště")
                    }
                    Label {
                        id: workplaceValue
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: workplaceLabel.bottom
                        font.pixelSize: parent.height/10
                        font.bold: true
                        color: colors['labelValue']
                        text: apl
                    }

                    Label {
                        id: statusLabelMain
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: parent.height/3-statusLabel.height/2
                        font.pixelSize: parent.height/10
                        font.bold: false
                        color: colors['cardAwate']
                        text: "Čeká na přihlášení..."
                        visible: card===null ? true : false
                    }
                    Label {
                        id: statusLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: parent.height/3//-statusLabel.height
                        font.pixelSize: parent.height/10
                        font.bold: false
                        color: colors['labelLabel']
                        text: JS.cardInfo(card)
                        visible: card===null ? false : true
                    }
                    Label {
                        id: statusValue
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: statusLabel.bottom
                        font.pixelSize: parent.height/10
                        font.bold: true
                        color: colors['logout']
                        text: "Odhlásit"
                        visible: card===null ? false : true

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                JS.logout();
                            }
                        }
                    }


                    // ProgressBar
                    Rectangle {
                        id: progressBar
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: parent.height/6
                        width: (mainWindow.width-(buttonWidth*2))*0.75
                        height: parent.height/25
                        color: "transparent"
                        border.color: colors['unchoseStroke']
                        border.width: 1
                        visible: card===null ? false : true

                        Rectangle {
                            id: progressBarValue1
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: progressBarValue2.left
                            color: "green"
                        }
                        Rectangle {
                            id: progressBarValue2
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            width: ((logoutTime-startTime)/resetTerminal.interval)*parent.width
                            color: "transparent"
                        }
                    }

                }
            }

            // TOP-RIGHT Rectangle
            Rectangle {
                id: midRectRight
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: buttonWidth
                color: "transparent"
                visible: viewMode==='common' ? true : false

                Rectangle {
                    id: rightRect1
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: (parent.height/3.7)-(buttonHeight/2)
                    height: buttonHeight
                    color: "transparent"

                    Canvas {
                        id: rightCanvas1
                        anchors.fill: parent

                        onPaint: {
                            var context = getContext("2d");

                            // Shape
                            context.moveTo(parent.width - (mainWindow.width / 100), parent.height / 2);
                            context.lineTo(parent.width - (mainWindow.width / 25), parent.height / 20);
                            context.lineTo(mainWindow.width / 100, parent.height / 20);
                            context.lineTo(mainWindow.width / 100, parent.height - (parent.height / 20));
                            context.lineTo(parent.width - (mainWindow.width / 25), parent.height - (parent.height / 20));
                            context.lineTo(parent.width - (mainWindow.width / 100), parent.height / 2);

                            // Line
                            context.lineWidth = parent.height / 20;
                            taskType==='productionTask' ? context.strokeStyle = colors['chosenStroke'] : context.strokeStyle = colors['unchoseStroke']
                            context.stroke();

                            // Color
                            var grad = context.createLinearGradient(0, mainWindow.height/2, mainWindow.width, mainWindow.height/2);
                            grad.addColorStop(0, '#303030');
                            grad.addColorStop(0.35, '#151515');
                            grad.addColorStop(0.65, '#151515');
                            grad.addColorStop(1, '#303030');
                            context.fillStyle = grad;
                            context.fill();
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if(card!==null) {
                                    taskType==='productionTask' ? taskType=null : taskType='productionTask'
                                    startTime=0;
                                    resetTerminal.restart();
                                }
                                else { JS.alertDisplay(); }
                                JS.refreshCanvas();
                            }
                        }
                    }

                    Label {
                        id: productionTask
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: mainWindow.width/42.5
                        font.pixelSize: parent.height/4
                        font.bold: true
                        color: card===null ? colors['naCanvasText'] : (taskType==='productionTask' ? colors['chosenCanvasText'] : colors['unchosenCanvasText'])
                        text: qsTr("Výroba")
                    }
                }

                Rectangle {
                    id: rightRect2
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: (parent.height/3.7)-(buttonHeight/2)
                    height: buttonHeight
                    color: "transparent"

                    Canvas {
                        id: rightCanvas2
                        anchors.fill: parent

                        onPaint: {
                            var context = getContext("2d");

                            // Shape
                            context.moveTo(parent.width - (mainWindow.width / 100), parent.height / 2);
                            context.lineTo(parent.width - (mainWindow.width / 25), parent.height / 20);
                            context.lineTo(mainWindow.width / 100, parent.height / 20);
                            context.lineTo(mainWindow.width / 100, parent.height - (parent.height / 20));
                            context.lineTo(parent.width - (mainWindow.width / 25), parent.height - (parent.height / 20));
                            context.lineTo(parent.width - (mainWindow.width / 100), parent.height / 2);

                            // Line
                            context.lineWidth = parent.height / 20;
                            taskType==='maintenanceTask' ? context.strokeStyle = colors['chosenStroke'] : context.strokeStyle = colors['unchoseStroke']
                            context.stroke();

                            // Color
                            var grad = context.createLinearGradient(0, mainWindow.height/2, mainWindow.width, mainWindow.height/2);
                            grad.addColorStop(0, '#303030');
                            grad.addColorStop(0.35, '#151515');
                            grad.addColorStop(0.65, '#151515');
                            grad.addColorStop(1, '#303030');
                            context.fillStyle = grad;
                            context.fill();
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if(card!==null) {
                                    taskType==='maintenanceTask' ? taskType=null : taskType='maintenanceTask'
                                    startTime=0;
                                    resetTerminal.restart();
                                }
                                else { JS.alertDisplay(); }
                                JS.refreshCanvas();
                            }
                        }
                    }

                    Label {
                        id: maintenanceTask
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: mainWindow.width/42.5
                        font.pixelSize: parent.height/4
                        font.bold: true
                        color: card===null ? colors['naCanvasText'] : (taskType==='maintenanceTask' ? colors['chosenCanvasText'] : colors['unchosenCanvasText'])
                        text: qsTr("Údržba")
                    }
                }
            }
        }

        // BOTTOM Rectangle
        Rectangle {
            id: mainRectBottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: buttonHeight
            color: "transparent"


            Canvas {
                id: wideCanvasBottom
                anchors.fill: parent

                onPaint: {
                    var context = getContext("2d");

                    // Shape
                    context.moveTo(mainWindow.width / 100, parent.height / 2);
                    context.lineTo(mainWindow.width / 25, parent.height / 20);
                    context.lineTo(mainWindow.width - (mainWindow.width / 25), parent.height / 20);
                    context.lineTo(mainWindow.width - (mainWindow.width / 100), parent.height / 2);
                    context.lineTo(mainWindow.width - (mainWindow.width / 25), parent.height - (parent.height / 20));
                    context.lineTo(mainWindow.width / 25, parent.height - (parent.height / 20));
                    context.lineTo(mainWindow.width / 100, parent.height / 2);

                    // Line
                    context.lineWidth = parent.height / 20;
                    context.strokeStyle = colors['unchoseStroke'];
                    context.stroke();

                    // Color
                    var grad = context.createLinearGradient(0, mainWindow.height/2, mainWindow.width, mainWindow.height/2);
                    grad.addColorStop(0, '#303030');
                    grad.addColorStop(0.35, '#151515');
                    grad.addColorStop(0.65, '#151515');
                    grad.addColorStop(1, '#303030');
                    context.fillStyle = grad;
                    context.fill();
                }

                Label {
                    id: status
                    anchors.centerIn: parent
                    font.pixelSize: parent.height/2.5
                    font.bold: false
                    color: colors['initialStatus']
                    //text: JS.statusDisplay()

                    Component.onCompleted: JS.statusDisplay()
                }
            }
        }
    }

    Timer {
        id: dateTimer
        interval: 50
        running: true
        repeat: true
        onTriggered: {
            datetimeDate.text = JS.currentDate(); datetimeTime.text = JS.currentTime();
            if (resetTerminal.running===true) { logoutTime = new Date().getTime(); }
        }
    }
    Timer {
        id: statusWarning
        interval: 3000
        running: false
        repeat: false
        triggeredOnStart: true
        onTriggered: {
            if(warningTriggered===false) {
                status.text = "Přiložte kartu";
                status.color = colors['warningStatus'];
                warningTriggered = true;
            }
            else {
                JS.statusDisplay();
                warningTriggered = false;
            }
            if(loggedOff===true) { loggedOff=false; } else { taskKind=null; taskType=null; }
        }
    }
    Timer {
        id: resetTerminal
        interval: 3000
        running: false
        repeat: false
        triggeredOnStart: true
        onTriggered: {
            if (startTime>0) {
                card=null; taskType=null; taskKind=null; startTime=0; cardTemporar=undefined;
            }
            else {
                startTime = new Date().getTime();
            }
            JS.refreshCanvas();
        }
    }
}
