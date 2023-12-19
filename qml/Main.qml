import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import OPC_UA_Browser

ApplicationWindow {
    id: window

    property ThemeMainWindow theme: Style.mainWindow
    property int themeIndex: 0
    onThemeIndexChanged: Style.currentThemeIndex = themeIndex

    Settings {
        property alias themeIndex: window.themeIndex
    }

    Component.onCompleted: {
        Style.currentThemeIndex = window.themeIndex
    }

    width: 350
    height: 640
    visible: true
    color: theme.background
    title: qsTr("OPC UA Browser")
    header: Rectangle {
        id: headerItem

        property bool isSaveMode: false

        height: childrenRect.height
        color: theme.header.background
        clip: true

        Behavior on height {
            PropertyAnimation {}
        }

        ColumnLayout {
            width: parent.width

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                IconImage {
                    id: leftImage

                    readonly property alias showBackButton: contentView.showBackButtonInHeader

                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    height: 25
                    width: height
                    source: leftImage.showBackButton ? "qrc:/icons/back.png" : "qrc:/icons/menu.png"
                    color: theme.header.iconColor

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (leftImage.showBackButton) {
                                contentView.goBack()
                            } else {
                                sideMenu.open()
                            }
                        }
                    }
                }

                Image {
                    anchors.centerIn: parent
                    height: parent.height - 10
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/icons/logo_basyskom.svg"
                }

                IconImage {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    height: 25
                    width: height
                    source: "qrc:/icons/save.png"
                    color: theme.header.iconColor
                    visible: contentView.canSaveDashboard
                             && !headerItem.isSaveMode

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: headerItem.isSaveMode = true
                    }
                }
            }

            StyledTextField {
                id: name

                visible: headerItem.isSaveMode
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                captionText: qsTr("Name")
                text: contentView.currentDashboardName
            }

            Item {
                visible: headerItem.isSaveMode
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.topMargin: 5
                Layout.bottomMargin: 5

                StyledButton {
                    anchors.left: parent.left
                    height: 35
                    width: parent.width / 2 - 5
                    highlighted: false
                    text: qsTr("Cancel")

                    onClicked: {
                        name.text = contentView.currentDashboardName
                        headerItem.isSaveMode = false
                    }
                }

                StyledButton {
                    anchors.right: parent.right
                    height: 35
                    width: parent.width / 2 - 5
                    text: qsTr("Ok")
                    visible: name.text.length > 0

                    onClicked: {
                        BackEnd.saveCurrentDashboard(name.text)
                        headerItem.isSaveMode = false
                    }
                }
            }

            Rectangle {
                id: rect
                visible: headerItem.isSaveMode
                Layout.fillWidth: true
                Layout.preferredHeight: 2
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                color: theme.header.dividerColor
            }
        }
    }

    SideMenu {
        id: sideMenu

        y: -header.height
        menuHeight: parent.height + header.height
        menuWidth: 0.8 * parent.width

        onAddConnectionSelected: {
            // ToDo: add new connection
            BackEnd.disconnectFromEndpoint()
            BackEnd.clearServerList()
            BackEnd.clearEndpointList()
            contentView.showConnectionView()
        }

        onCloseConnectionSelected: {
            BackEnd.disconnectFromEndpoint()
            contentView.showConnectionView()
        }
        onShowDashboardsSelected: contentView.showDashboardView()
        onShowExpertModeSelected: contentView.showExpertBrowserView()
        onShowImprintSelected: contentView.showImprintView()
        onShowSettingsSelected: contentView.showSettingsView()
    }

    ContentView {
        id: contentView

        anchors.fill: parent
    }
}
