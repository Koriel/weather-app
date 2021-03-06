/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.1
import QtQuick.Layouts 1.0
import "../js/utils.js" as Utils
import org.qtproject.demo.weather 1.0

GridLayout {
    id: root
    flow: ApplicationInfo.isPortraitMode ? GridLayout.LeftToRight : GridLayout.TopToBottom

    property alias slider: touchSlider
    property QtObject model
    property real adjustementNeeded: 1
    property real sliderGapWidth: adjustementNeeded * ApplicationInfo.sliderGapWidth
    property real sliderHandleWidth: adjustementNeeded * ApplicationInfo.sliderHandleWidth
    property real sliderHandleHeight: adjustementNeeded * ApplicationInfo.sliderHandleHeight

    Separator {}
    Canvas {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        id: canvasSlider
        property int sliderItemWidth : (model.periodCount() + 1) * sliderGapWidth
        property var rangeTemp: Utils.getMaxMinTemp(model)

        implicitWidth: sliderItemWidth
        implicitHeight: rowTemp.implicitHeight + column.implicitHeight

        property int marginsTemperaturesDrawing: calibrate(rangeTemp[1]) +  10 * ApplicationInfo.ratio
        property real circleIconWidth: adjustementNeeded * 20 * ApplicationInfo.ratio
        property real weatherIconWidth: adjustementNeeded * 80 * ApplicationInfo.ratio

        function calibrate(temperature) {
            return 2 * ApplicationInfo.ratio * temperature
        }

        antialiasing: true
        smooth: true
        onPaint: {
            var ctx = getContext('2d')
            var count = model.periodCount()
            if (count <= 0)
                return
            ctx.save()
            ctx.beginPath();
            ctx.fillStyle = ApplicationInfo.colors.doubleDarkGray
            ctx.lineWidth = 1

            var yOffset = canvasSlider.weatherIconWidth
            var item = repeater.itemAt(0).children[3]
            var pos = item.mapToItem(canvasSlider)
            ctx.moveTo(item.width/2 + pos.x, item.height/2 + pos.y)

            for (var i = 1; i < count; i++) {
                item = repeater.itemAt(i).children[3]
                pos = item.mapToItem(canvasSlider)
                ctx.lineTo(item.width/2 + pos.x, item.height/2 + pos.y)
            }
            ctx.stroke()
            ctx.closePath()
            ctx.restore();
        }

        RowLayout {
            id: rowTemp
            spacing: 0
            anchors { left: parent.left; right: parent.right; top: parent.top; leftMargin:  sliderGapWidth/2; rightMargin: sliderGapWidth/2}
            Repeater {
                id: repeater
                model: root.model.periodCount()
                Column {
                    property int temperature: Utils.getTemperature(index, root.model)
                    Layout.fillWidth: true
                    Item {
                        width: 1
                        height: -canvasSlider.calibrate(temperature) + canvasSlider.marginsTemperaturesDrawing
                    }
                    Image {
                        source: Utils.getWeatherUrl(index, root.model)
                        width: canvasSlider.weatherIconWidth
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Item {
                        height: 15 * ApplicationInfo.ratio
                        width: height
                    }
                    Image {
                        id: circle
                        source: ApplicationInfo.getImagePath("Circle.png")
                        width: canvasSlider.circleIconWidth
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Item {
                        height: 15 * ApplicationInfo.ratio
                        width: height
                    }
                    TouchLabel {
                        text: Utils.getTempFormat(temperature)
                        pixelSize: 24
                        color: temperature > 0 ? ApplicationInfo.colors.doubleDarkGray : ApplicationInfo.colors.blue
                        anchors.horizontalCenter: parent.horizontalCenter
                        Accessible.ignored: true
                    }
                }
            }
        }

        ColumnLayout {
            id: column
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            TouchSlider {
                id: touchSlider
                sliderHandleWidth: root.sliderHandleWidth
                sliderHandleHeight: root.sliderHandleHeight
                Layout.preferredWidth: (model.periodCount() - 1) * sliderGapWidth + sliderHandleWidth
                Layout.alignment: Qt.AlignHCenter
                minimumValue: 0
                maximumValue: model.periodCount() - 1

                // these properties are needed for accessibility, for some reason I cannot put the Math.round expression in the same line
                readonly property int sliderValue: Math.round(touchSlider.value)
                Accessible.name: qsTr("%1 - %2").arg(Utils.getFromTime(sliderValue, root.model)).arg(Utils.getToTime(sliderValue, root.model))
                Accessible.description: qsTr("change value to get weather information for part of the day")

                Accessible.onIncreaseAction: {
                    touchSlider.value += 1
                }
                Accessible.onDecreaseAction: {
                    touchSlider.value -= 1
                }
            }
            RowLayout {
                id: rowTime
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                spacing: 0
                Layout.preferredWidth: canvasSlider.sliderItemWidth
                Repeater {
                    model: root.model.periodCount() + 1
                    TouchLabel {
                        pixelSize: 22
                        Layout.fillWidth: true
                        Layout.preferredWidth: sliderGapWidth
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignBaseline
                        text: (!!root.model && index !== root.model.periodCount()) ? Utils.getFromTime(index, root.model) : Utils.getToTime(index-1, root.model)
                        Accessible.ignored: true
                    }
                }
            }
        }
    }

    Separator {}
}
