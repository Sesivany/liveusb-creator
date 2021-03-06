import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2

Item {
    id: root
    anchors.fill: parent

    signal stepForward

    Rectangle {
        z: 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: palette.window }
            GradientStop { position: 0.1; color: palette.window }
            GradientStop { position: 0.2; color: Qt.tint(palette.window, "transparent") }
            GradientStop { position: 1.0; color: "transparent" }
        }
        id: tools
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            leftMargin: mainWindow.margin
            rightMargin: anchors.leftMargin
        }
        height: $(64)
        BackButton {
            id: backButton
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                topMargin: $(16)
                bottomMargin: $(16)
            }
            onClicked: {
                canGoBack = false
                contentList.currentIndex--
            }
        }
        AdwaitaButton {
            text: qsTranslate("", "Create Live USB")
            color: "#628fcf"
            textColor: "white"
            onClicked: {
                dlDialog.visible = true
                liveUSBData.currentImage.get()
            }
            enabled: !liveUSBData.currentImage.isLocal || liveUSBData.currentImage.readyToWrite
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                topMargin: $(16)
                bottomMargin: $(16)
            }
        }
    }

    ScrollView {
        anchors {
            fill: parent
            leftMargin: anchors.rightMargin
        }
        contentItem: Item {
            y: $(72)
            x: mainWindow.margin
            width: root.width - 2 * mainWindow.margin
            height: childrenRect.height + $(64) + $(32)

            ColumnLayout {
                width: parent.width
                spacing: $(24)
                RowLayout {
                    z: 1 // so the popover stays over the text below
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: $(24)
                    Item {
                        Layout.preferredWidth: $(64) + $(16)
                        Layout.preferredHeight: $(64)
                        IndicatedImage {
                            x: $(12)
                            source: liveUSBData.currentImage.logo
                            fillMode: Image.PreserveAspectFit
                            sourceSize.width: parent.width
                            sourceSize.height: parent.height
                        }
                    }
                    ColumnLayout {
                        Layout.fillHeight: true
                        spacing: $(6)
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                Layout.fillWidth: true
                                anchors.left: parent.left
                                font.pixelSize: $(17)
                                text: liveUSBData.currentImage.name
                            }
                            Text {
                                anchors.right: parent.right
                                font.pixelSize: $(15)
                                property double size: liveUSBData.currentImage.size
                                text: size <= 0 ? "" :
                                      (size < 1024) ? (size + " B") :
                                      (size < (1024 * 1024)) ? ((size / 1024).toFixed(1) + " KB") :
                                      (size < (1024 * 1024 * 1024)) ? ((size / 1024 / 1024).toFixed(1) + " MB") :
                                      ((size / 1024 / 1024 / 1024).toFixed(1) + " GB")

                                color: "gray"
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                            height: childrenRect.height

                            ColumnLayout {
                                width: parent.width
                                spacing: $(6)
                                Text {
                                    font.pixelSize: $(13)
                                    color: "gray"
                                    visible: liveUSBData.currentImage.arch.length
                                    text: liveUSBData.releaseProxyModel.archFilter
                                }
                                Text {
                                    font.pixelSize: $(11)
                                    color: "gray"
                                    visible: liveUSBData.currentImage.arch.length
                                    text: liveUSBData.releaseProxyModel.archFilterDetailed
                                }
                                RowLayout {
                                    width: parent.width
                                    Text {
                                        // I'm sorry, everyone, I can't find a better way to determine if the date is valid
                                        text: liveUSBData.currentImage.version ? (qsTranslate("", "Version %1").arg(liveUSBData.currentImage.version) +
                                            (liveUSBData.currentImage.releaseDate.toLocaleDateString().length > 0 ? (qsTranslate("", ", released on %1").arg(liveUSBData.currentImage.releaseDate.toLocaleDateString())) : "")) : ""
                                        font.pixelSize: $(11)
                                        color: "gray"
                                    }
                                    Item {
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignRight
                                        visible: liveUSBData.currentImage.arch.length
                                        text: "Other architectures..."
                                        font.pixelSize: $(11)
                                        color: mouse.containsPress ? "#284875" : mouse.containsMouse ? "#447BC7" : "#315FA0"
                                        Behavior on color { ColorAnimation { duration: 100 } }
                                        MouseArea {
                                            id: mouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: popover.open = !popover.open
                                        }

                                        Rectangle {
                                            anchors {
                                                left: parent.left
                                                right: parent.right
                                                top: parent.bottom
                                                topMargin: $(1.5)
                                            }
                                            radius: height / 2
                                            color: parent.color
                                            height: $(1.2)
                                        }

                                        PopOver {
                                            id: popover
                                            anchors {
                                                horizontalCenter: parent.horizontalCenter
                                                top: parent.bottom
                                                topMargin: $(8) + opacity * $(24)
                                            }
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                id: localSelectionLayout
                                visible: liveUSBData.currentImage.isLocal
                                spacing: $(12)
                                AdwaitaButton {
                                    text: qsTranslate("", "Select Live ISO")
                                    onClicked: {
                                        fileDialog.visible = false // for some reason it got stuck in the closed state once in a while, so ensure it's actually closed
                                        fileDialog.visible = true
                                    }
                                }
                                Text {
                                    font.pixelSize: $(12)
                                    text: "<font color=\"gray\">" + qsTranslate("", "Selected:") + "</font> " + (liveUSBData.currentImage.path ? (((String)(liveUSBData.currentImage.path)).split("/").slice(-1)[0]) : ("<font color=\"gray\">" + qsTranslate("", "None") + "</font>"))
                                }
                            }
                        }
                    }
                }
                Text {
                    Layout.fillWidth: true
                    width: Layout.width
                    wrapMode: Text.WordWrap
                    text: liveUSBData.currentImage.description
                    textFormat: Text.RichText
                    font.pixelSize: $(12)
                }
                Repeater {
                    id: screenshotRepeater
                    model: liveUSBData.currentImage.screenshots
                    IndicatedImage {
                        cache: false
                        Layout.fillWidth: true
                        Layout.preferredHeight: width / sourceSize.width * sourceSize.height
                        fillMode: Image.PreserveAspectFit
                        source: modelData
                    }
                }
            }
        }
        style: ScrollViewStyle {
            incrementControl: Item {}
            decrementControl: Item {}
            corner: Item {
                implicitWidth: $(11)
                implicitHeight: $(11)
            }
            scrollBarBackground: Rectangle {
                color: "#dddddd"
                implicitWidth: $(11)
                implicitHeight: $(11)
            }
            handle: Rectangle {
                color: "#b3b5b6"
                x: $(2)
                y: $(2)
                implicitWidth: $(7)
                implicitHeight: $(7)
                radius: $(4)
            }
            transientScrollBars: false
            handleOverlap: $(1)
            minimumHandleLength: $(10)
        }
    }

    DownloadDialog {
        id: dlDialog
        onVisibleChanged: {
            //if (!visible)
            //    liveUSBData.currentImage.
        }
    }
    FileDialog {
        id: fileDialog
        nameFilters: [ qsTranslate("", "Image files (*.iso)"), qsTranslate("", "All files (*)")]
        onAccepted: {
            liveUSBData.currentImage.path = fileUrl
        }
    }
}
