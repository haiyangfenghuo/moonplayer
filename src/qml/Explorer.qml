import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0 as QSettings
import MoonPlayer 1.0
import CustomWidgets 1.0

CustomDialog {
    id: explorer
    width: 600
    height: 400
    title: qsTr("Explorer")
    
    // Remember the last used plugin
    QSettings.Settings {
        category: "explorer"
        property alias last_plugin: pluginComboBox.currentIndex
    }
    
    property QtObject currentPlugin: plugins[pluginComboBox.currentIndex]
    
    contentItem: Item {

        GridLayout {
            columns: 3
            visible: plugins.length !== 0
            anchors.fill: parent
            anchors.margins: 10
        
            // Search input
            ComboBox {
                id: pluginComboBox
                model: plugins
                textRole: "name"
            }
        
            TextField {
                id: keywordInput
                Layout.fillWidth: true
                onAccepted: {
                    currentPlugin.keyword = keywordInput.text;
                    pageSpinBox.value = 1;
                }
            }
            Button {
                id: searchButton
                text: qsTr("Search")
                implicitWidth: pageSpinBox.width
                onClicked: {
                    currentPlugin.keyword = keywordInput.text;
                    pageSpinBox.value = 1;
                }
            }

            // Search result
            ScrollView {
                Layout.columnSpan: 3
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
            
                ListView {
                    model: currentPlugin.resultModel
                    delegate: Rectangle {
                        height: 30
                        width: parent.width
                        color: "transparent"
                    
                        Label { text: modelData; anchors.fill: parent; verticalAlignment: Text.AlignVCenter }
                    
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = Color.listItemHovered
                            onExited: parent.color = "transparent"
                            onDoubleClicked: currentPlugin.openItem(index)
                        }
                    }
                }
            }
            Label { text: qsTr("Page: "); horizontalAlignment: Text.AlignRight; Layout.fillWidth: true; Layout.columnSpan: 2 }
            SpinBox {
                id: pageSpinBox
                from: 1
                to: 100
                value: 1
                implicitWidth: 120
                onValueChanged: currentPlugin.page = value
            }
        }
    
        Label {
            text: qsTr("<p>No plugins found.</p><p><a href=\"moonplayer:plugin\">Download plugins</a></p>")
            visible: plugins.length === 0
            anchors.centerIn: parent
            onLinkActivated: utils.updateParser()
        }
    }
}

