//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QS_NO_RELOAD_POPUP=1

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

ShellRoot {
    id: root

    property int barHeight: 44
    property bool dashboardOpen: false
    property bool powerOpen: false
    property int monthOffset: 0

    property string weatherText: "Clima --"
    property string netText: "NET --"
    property string resourcesText: "CPU --  RAM --"
    property string batteryText: "AC"
    property string volumeText: "VOL --"
    property string mediaText: ""

    readonly property color bg: "#0f1417"
    readonly property color surface: "#171d22"
    readonly property color surfaceSoft: "#222b32"
    readonly property color surfaceLift: "#2c363e"
    readonly property color text: "#e8edf2"
    readonly property color muted: "#94a2ad"
    readonly property color accent: "#5fd0b5"
    readonly property color accent2: "#f4a261"
    readonly property color accent3: "#9db4ff"
    readonly property color danger: "#f26d6d"

    readonly property string clockText: Qt.formatDateTime(clock.date, "HH:mm")
    readonly property string dateText: Qt.formatDateTime(clock.date, "ddd dd MMM")

    function launch(command) {
        Quickshell.execDetached(["bash", "-lc", command]);
    }

    function refreshProcess(process) {
        if (!process.running)
            process.running = true;
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    IpcHandler {
        target: "shell"

        function toggleDashboard(): void {
            root.dashboardOpen = !root.dashboardOpen;
            if (root.dashboardOpen)
                root.powerOpen = false;
        }

        function togglePower(): void {
            root.powerOpen = !root.powerOpen;
            if (root.powerOpen)
                root.dashboardOpen = false;
        }

        function close(): void {
            root.dashboardOpen = false;
            root.powerOpen = false;
        }

        function reload(): void {
            Quickshell.reload(true);
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshProcess(networkProc)
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.refreshProcess(resourcesProc);
            root.refreshProcess(volumeProc);
            root.refreshProcess(mediaProc);
        }
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshProcess(batteryProc)
    }

    Timer {
        interval: 600000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshProcess(weatherProc)
    }

    Process {
        id: weatherProc
        command: ["bash", Quickshell.shellPath("scripts/status/weather.sh")]
        stdout: StdioCollector {
            onStreamFinished: root.weatherText = text.trim() || "Clima --"
        }
    }

    Process {
        id: networkProc
        command: ["bash", Quickshell.shellPath("scripts/status/network-speed.sh")]
        stdout: StdioCollector {
            onStreamFinished: root.netText = text.trim() || "NET --"
        }
    }

    Process {
        id: resourcesProc
        command: ["bash", Quickshell.shellPath("scripts/status/resources.sh")]
        stdout: StdioCollector {
            onStreamFinished: root.resourcesText = text.trim() || "CPU --  RAM --"
        }
    }

    Process {
        id: batteryProc
        command: ["bash", Quickshell.shellPath("scripts/status/battery.sh")]
        stdout: StdioCollector {
            onStreamFinished: root.batteryText = text.trim() || "AC"
        }
    }

    Process {
        id: volumeProc
        command: ["bash", Quickshell.shellPath("scripts/status/volume.sh")]
        stdout: StdioCollector {
            onStreamFinished: root.volumeText = text.trim() || "VOL --"
        }
    }

    Process {
        id: mediaProc
        command: ["bash", Quickshell.shellPath("scripts/status/media.sh")]
        stdout: StdioCollector {
            onStreamFinished: root.mediaText = text.trim()
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property ShellScreen modelData

            screen: modelData
            color: "transparent"
            implicitHeight: root.barHeight
            exclusiveZone: root.barHeight
            WlrLayershell.namespace: "quickshell-edots"
            WlrLayershell.layer: WlrLayer.Top

            anchors {
                top: true
                left: true
                right: true
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 6
                radius: 8
                color: root.surface
                border.width: 1
                border.color: "#2b3540"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    RowLayout {
                        spacing: 4
                        Layout.alignment: Qt.AlignVCenter

                        Repeater {
                            model: 5
                            WorkspaceButton {
                                required property int index
                                number: index + 1
                            }
                        }
                    }

                    Separator {}

                    Text {
                        text: Hyprland.activeToplevel?.title || "Escritorio"
                        color: root.muted
                        elide: Text.ElideRight
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                        Layout.fillWidth: true
                        Layout.minimumWidth: 80
                    }

                    Pill {
                        visible: root.mediaText.length > 0
                        text: root.mediaText
                        fg: root.accent3
                        Layout.maximumWidth: 280
                    }

                    Pill {
                        text: root.resourcesText
                    }

                    Pill {
                        text: root.netText
                    }

                    Pill {
                        text: root.weatherText
                        fg: root.accent2
                        clickable: true
                        onClicked: root.dashboardOpen = !root.dashboardOpen
                    }

                    Pill {
                        text: root.volumeText
                        clickable: true
                        onClicked: root.launch("pavucontrol")
                    }

                    Pill {
                        text: root.batteryText
                        fg: root.accent
                    }

                    RowLayout {
                        visible: SystemTray.items.values.length > 0
                        spacing: 4
                        Layout.alignment: Qt.AlignVCenter

                        Repeater {
                            model: ScriptModel {
                                values: SystemTray.items.values
                            }

                            TrayButton {
                                required property SystemTrayItem modelData
                                item: modelData
                            }
                        }
                    }

                    Pill {
                        text: root.clockText
                        fg: root.text
                        bg: root.surfaceLift
                        clickable: true
                        onClicked: root.dashboardOpen = !root.dashboardOpen
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: dashboard
            required property ShellScreen modelData

            visible: root.dashboardOpen
            screen: modelData
            color: "transparent"
            implicitWidth: 390
            implicitHeight: 530
            exclusiveZone: 0
            focusable: true
            WlrLayershell.namespace: "quickshell-edots-dashboard"
            WlrLayershell.layer: WlrLayer.Overlay

            anchors {
                top: true
                right: true
            }

            margins {
                top: root.barHeight + 8
                right: 10
            }

            Rectangle {
                anchors.fill: parent
                radius: 8
                color: root.surface
                border.width: 1
                border.color: "#31404a"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true

                            Text {
                                text: root.clockText
                                color: root.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 42
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: root.dateText
                                color: root.muted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                            }
                        }

                        ActionButton {
                            label: "Cerrar"
                            accentColor: root.surfaceLift
                            onClicked: root.dashboardOpen = false
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: "#2c363e"
                    }

                    MiniCalendar {
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        StatusTile {
                            title: "Clima"
                            value: root.weatherText
                            accentColor: root.accent2
                            Layout.fillWidth: true
                        }

                        StatusTile {
                            title: "Sistema"
                            value: root.resourcesText
                            accentColor: root.accent
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        ActionButton {
                            label: "Audio"
                            accentColor: root.accent3
                            Layout.fillWidth: true
                            onClicked: root.launch("pavucontrol")
                        }

                        ActionButton {
                            label: "Red"
                            accentColor: root.accent
                            Layout.fillWidth: true
                            onClicked: root.launch("nm-connection-editor")
                        }

                        ActionButton {
                            label: "Bluetooth"
                            accentColor: root.accent2
                            Layout.fillWidth: true
                            onClicked: root.launch("blueman-manager")
                        }
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: power
            required property ShellScreen modelData

            visible: root.powerOpen
            screen: modelData
            color: "#99000000"
            exclusiveZone: 0
            focusable: true
            WlrLayershell.namespace: "quickshell-edots-power"
            WlrLayershell.layer: WlrLayer.Overlay

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Rectangle {
                width: 430
                height: 260
                radius: 8
                color: root.surface
                border.width: 1
                border.color: "#3b4852"
                anchors.centerIn: parent

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Energía"
                            color: root.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 24
                            font.weight: Font.DemiBold
                            Layout.fillWidth: true
                        }

                        ActionButton {
                            label: "Cerrar"
                            accentColor: root.surfaceLift
                            onClicked: root.powerOpen = false
                        }
                    }

                    GridLayout {
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 10
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        PowerButton {
                            label: "Bloquear"
                            command: "pidof hyprlock || hyprlock"
                            accentColor: root.accent3
                        }

                        PowerButton {
                            label: "Salir"
                            command: "hyprctl dispatch exit"
                            accentColor: root.accent
                        }

                        PowerButton {
                            label: "Reiniciar"
                            command: "systemctl reboot"
                            accentColor: root.accent2
                        }

                        PowerButton {
                            label: "Apagar"
                            command: "systemctl poweroff"
                            accentColor: root.danger
                        }
                    }
                }
            }
        }
    }

    component Separator: Rectangle {
        color: "#2c363e"
        implicitWidth: 1
        implicitHeight: 22
        Layout.alignment: Qt.AlignVCenter
    }

    component WorkspaceButton: Rectangle {
        id: ws
        required property int number
        readonly property bool active: Hyprland.focusedWorkspace?.id === number
        readonly property bool occupied: Hyprland.workspaces.values.some(workspace => workspace.id === number)

        implicitWidth: 24
        implicitHeight: 24
        radius: 7
        color: active ? root.accent : (occupied ? root.surfaceLift : "transparent")
        border.width: active ? 0 : 1
        border.color: occupied ? "#3a4650" : "#273039"

        Text {
            anchors.centerIn: parent
            text: ws.number
            color: ws.active ? root.bg : (ws.occupied ? root.text : root.muted)
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            font.weight: ws.active ? Font.Bold : Font.Medium
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Hyprland.dispatch("workspace " + ws.number)
            onWheel: wheel => {
                if (wheel.angleDelta.y < 0)
                    Hyprland.dispatch("workspace r+1");
                else if (wheel.angleDelta.y > 0)
                    Hyprland.dispatch("workspace r-1");
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 140
            }
        }
    }

    component Pill: Rectangle {
        id: pill
        property string text: ""
        property color bg: root.surfaceSoft
        property color fg: root.muted
        property bool clickable: false
        signal clicked

        implicitHeight: 28
        implicitWidth: Math.max(54, label.implicitWidth + 22)
        radius: 7
        color: mouse.containsMouse && clickable ? root.surfaceLift : bg
        border.width: 1
        border.color: "#303a44"
        clip: true

        Text {
            id: label
            anchors.centerIn: parent
            width: parent.width - 18
            text: pill.text
            color: pill.fg
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            font.weight: Font.Medium
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: pill.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                if (pill.clickable)
                    pill.clicked();
            }
        }
    }

    component TrayButton: Rectangle {
        id: tray
        required property SystemTrayItem item

        visible: item.status !== Status.Passive
        implicitWidth: visible ? 26 : 0
        implicitHeight: 26
        radius: 7
        color: mouse.containsMouse ? root.surfaceLift : root.surfaceSoft
        border.width: 1
        border.color: "#303a44"

        Image {
            anchors.centerIn: parent
            width: 16
            height: 16
            fillMode: Image.PreserveAspectFit
            source: tray.item.icon ? Quickshell.iconPath(tray.item.icon, "image-missing") : ""
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: event => {
                if (event.button === Qt.RightButton && tray.item.hasMenu)
                    tray.item.display(tray.QsWindow.window, tray.width, tray.height);
                else
                    tray.item.activate();
            }
        }
    }

    component ActionButton: Rectangle {
        id: button
        property string label: ""
        property color accentColor: root.accent
        signal clicked

        implicitHeight: 36
        radius: 7
        color: mouse.containsMouse ? Qt.lighter(accentColor, 1.15) : accentColor
        opacity: 0.95

        Text {
            anchors.centerIn: parent
            text: button.label
            color: root.bg
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            font.weight: Font.Bold
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

    component PowerButton: ActionButton {
        required property string command
        Layout.fillWidth: true
        Layout.fillHeight: true
        onClicked: {
            root.powerOpen = false;
            root.launch(command);
        }
    }

    component StatusTile: Rectangle {
        id: tile
        property string title: ""
        property string value: ""
        property color accentColor: root.accent

        implicitHeight: 78
        radius: 8
        color: root.surfaceSoft
        border.width: 1
        border.color: "#303a44"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            Text {
                text: tile.title
                color: tile.accentColor
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                font.weight: Font.Bold
            }

            Text {
                text: tile.value
                color: root.text
                elide: Text.ElideRight
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                Layout.fillWidth: true
            }
        }
    }

    component MiniCalendar: ColumnLayout {
        id: cal

        readonly property var shownDate: new Date(clock.date.getFullYear(), clock.date.getMonth() + root.monthOffset, 1)
        readonly property int year: shownDate.getFullYear()
        readonly property int month: shownDate.getMonth()
        readonly property int firstDay: (shownDate.getDay() + 6) % 7
        readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()
        readonly property int todayYear: clock.date.getFullYear()
        readonly property int todayMonth: clock.date.getMonth()
        readonly property int todayDay: clock.date.getDate()

        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            ActionButton {
                label: "<"
                accentColor: root.surfaceLift
                implicitWidth: 36
                onClicked: root.monthOffset -= 1
            }

            Text {
                text: Qt.formatDate(cal.shownDate, "MMMM yyyy")
                color: root.text
                horizontalAlignment: Text.AlignHCenter
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 15
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }

            ActionButton {
                label: ">"
                accentColor: root.surfaceLift
                implicitWidth: 36
                onClicked: root.monthOffset += 1
            }
        }

        GridLayout {
            columns: 7
            rowSpacing: 6
            columnSpacing: 6
            Layout.fillWidth: true

            Repeater {
                model: ["L", "M", "X", "J", "V", "S", "D"]

                Text {
                    required property string modelData
                    text: modelData
                    color: root.muted
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }
            }

            Repeater {
                model: 42

                Rectangle {
                    required property int index
                    readonly property int dayNumber: index - cal.firstDay + 1
                    readonly property bool inMonth: dayNumber >= 1 && dayNumber <= cal.daysInMonth
                    readonly property bool isToday: inMonth && cal.year === cal.todayYear && cal.month === cal.todayMonth && dayNumber === cal.todayDay

                    Layout.fillWidth: true
                    implicitHeight: 32
                    radius: 7
                    color: isToday ? root.accent : (mouse.containsMouse && inMonth ? root.surfaceLift : "transparent")
                    border.width: inMonth && !isToday ? 1 : 0
                    border.color: "#2b3540"

                    Text {
                        anchors.centerIn: parent
                        text: parent.inMonth ? parent.dayNumber : ""
                        color: parent.isToday ? root.bg : (parent.inMonth ? root.text : root.muted)
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.weight: parent.isToday ? Font.Bold : Font.Medium
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }
        }
    }
}
