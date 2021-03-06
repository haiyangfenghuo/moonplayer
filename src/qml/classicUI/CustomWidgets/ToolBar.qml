/* Copyright 2013-2020 Yikun Liu <cos.lyk@gmail.com>
 *
 * This program is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
 * Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see http://www.gnu.org/licenses/.
 */
 
import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Rectangle {
    id: toolBar
    color: "#f2f2f2"
    height: 40
    
    signal playPauseButtonClicked()
    signal stopButtonClicked()
    signal settingsButtonClicked()
    signal volumeButtonClicked()
    signal playlistButtonClicked()
    signal explorerButtonClicked()
    signal seekRequested(int time)

    property bool isPlaying: false
    property int time: 0
    property int duration: 0
    property alias volumeButton: volumeButton

    function toHHMMSS(seconds) {
        var hours = Math.floor(seconds / 3600);
        seconds -= hours*3600;
        var minutes = Math.floor(seconds / 60);
        seconds -= minutes*60;

        if (hours   < 10) {hours   = "0"+hours;}
        if (minutes < 10) {minutes = "0"+minutes;}
        if (seconds < 10) {seconds = "0"+seconds;}
        return hours+':'+minutes+':'+seconds;
    }

    RowLayout {
        spacing: 10
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        CustomImageButton {
            id: playPauseButton
            image: isPlaying ? "qrc:/images/pause_grey.png" : "qrc:/images/play_grey.png"
            width: 16
            height: 16
            onClicked: playPauseButtonClicked()
        }

        CustomImageButton {
            id: stopButton
            image: "qrc:/images/stop_grey.png"
            width: 16
            height: 16
            onClicked: stopButtonClicked()
        }

        CustomImageButton {
            id: volumeButton
            image: "qrc:/images/volume_grey.png"
            width: 16
            height: 16
            onClicked: volumeButtonClicked()
        }
           
        Label {
            id: timeText
            text: toHHMMSS(time)
            color: "black"
        }
        
        Slider {
            id: timeSlider
            from: 0
            to: duration
            focusPolicy: Qt.NoFocus
            Layout.fillWidth: true
            onPressedChanged: {
                if (!pressed)  // released
                    seekRequested(value);
            }
        }
        
        Label {
            id: durationText
            text: toHHMMSS(duration)
            color: "black"
        }

        CustomImageButton {
            id: explorerButton
            image: "qrc:/images/net_grey.png"
            width: 16
            height: 16
            onClicked: explorerButtonClicked()
        }

        CustomImageButton {
            id: settingsButton
            image: "qrc:/images/settings_grey.png"
            width: 16
            height: 16
            onClicked: settingsButtonClicked()
        }

        CustomImageButton {
            id: playlistButton
            image: "qrc:/images/playlist_grey.png"
            width: 16
            height: 16
            onClicked: playlistButtonClicked()
        }
    }

    onTimeChanged: {
        if (!timeSlider.pressed)
            timeSlider.value = time;
    }
}
