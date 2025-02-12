// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fk.Pages
import Fk.RoomElement

Flickable {
  id: root
  anchors.fill: parent
  property var extra_data: ({})
  property int pid

  signal finish()

  contentHeight: details.height
  ScrollBar.vertical: ScrollBar {}

  ColumnLayout {
    id: details
    width: parent.width - 40
    x: 20

    // TODO: player details
    Text {
      id: screenName
      font.pixelSize: 18
      color: "#E4D5A0"
    }

    Text {
      id: playerGameData
      Layout.fillWidth: true
      font.pixelSize: 18
      color: "#E4D5A0"
    }

    RowLayout {
      MetroButton {
        text: Backend.translate("Give Flower")
        onClicked: {
          enabled = false;
          root.givePresent("Flower");
          root.finish();
        }
      }

      MetroButton {
        text: Backend.translate("Give Egg")
        onClicked: {
          enabled = false;
          if (Math.random() < 0.03) {
            root.givePresent("GiantEgg");
          } else {
            root.givePresent("Egg");
          }
          root.finish();
        }
      }

      MetroButton {
        text: Backend.translate("Give Wine")
        enabled: Math.random() < 0.3
        onClicked: {
          enabled = false;
          root.givePresent("Wine");
          root.finish();
        }
      }

      MetroButton {
        text: Backend.translate("Give Shoe")
        enabled: Math.random() < 0.3
        onClicked: {
          enabled = false;
          root.givePresent("Shoe");
          root.finish();
        }
      }

      MetroButton {
        text: config.blockedUsers.indexOf(screenName.text) === -1 ? Backend.translate("Block Chatter") : Backend.translate("Unblock Chatter")
        enabled: pid !== Self.id && pid > 0
        onClicked: {
          const idx = config.blockedUsers.indexOf(screenName.text);
          if (idx === -1) {
            config.blockedUsers.push(screenName.text);
          } else {
            config.blockedUsers.splice(idx, 1);
          }
          config.blockedUsersChanged();
        }
      }

      MetroButton {
        text: Backend.translate("Kick From Room")
        visible: !roomScene.isStarted && roomScene.isOwner
        enabled: pid !== Self.id
        onClicked: {
          ClientInstance.notifyServer("KickPlayer", pid.toString());
          root.finish();
        }
      }
    }

    RowLayout {
      spacing: 20
      ColumnLayout {
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 16

        GeneralCardItem {
          id: mainChara
          name: "caocao"
          visible: name !== ""
        }
        GeneralCardItem {
          id: deputyChara
          name: "caocao"
          visible: name !== ""
        }
      }

      TextEdit {
        id: skillDesc

        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        font.pixelSize: 18
        color: "#E4D5A0"

        readOnly: true
        selectByKeyboard: true
        selectByMouse: false
        wrapMode: TextEdit.WordWrap
        textFormat: TextEdit.RichText
      }
    }
  }

  function givePresent(p) {
    ClientInstance.notifyServer(
      "Chat",
      JSON.stringify({
        type: 2,
        msg: "$!" + p + ":" + pid
      })
    );
  }

  onExtra_dataChanged: {
    if (!extra_data.photo) return;
    screenName.text = "";
    playerGameData.text = "";
    skillDesc.text = "";

    const id = extra_data.photo.playerid;
    if (id == 0) return;
    root.pid = id;

    screenName.text = extra_data.photo.screenName;
    mainChara.name = extra_data.photo.general;
    deputyChara.name = extra_data.photo.deputyGeneral;

    if (!config.observing) {
      const gamedata = JSON.parse(Backend.callLuaFunction("GetPlayerGameData", [id]));
      const total = gamedata[0];
      const win = gamedata[1];
      const run = gamedata[2];
      const totalTime = gamedata[3];
      const winRate = (win / total) * 100;
      const runRate = (run / total) * 100;
      playerGameData.text = total === 0 ? Backend.translate("Newbie") :
        Backend.translate("Win=%1 Run=%2 Total=%3").arg(winRate.toFixed(2))
        .arg(runRate.toFixed(2)).arg(total);

      const h = (totalTime / 3600).toFixed(2);
      const m = Math.floor(totalTime / 60);
      if (m < 100) {
        playerGameData.text += " " + Backend.translate("TotalGameTime: %1 min").arg(m);
      } else {
        playerGameData.text += " " + Backend.translate("TotalGameTime: %1 h").arg(h);
      }
    }

    const data = JSON.parse(Backend.callLuaFunction("GetPlayerSkills", [id]));
    data.forEach(t => {
      skillDesc.append("<b>" + Backend.translate(t.name) + "</b>: " + t.description)
    });

    const equips = JSON.parse(Backend.callLuaFunction("GetPlayerEquips", [id]));
    equips.forEach(cid => {
      const t = JSON.parse(Backend.callLuaFunction("GetCardData", [cid]));
      skillDesc.append("--------------------");
      skillDesc.append("<b>" + Backend.translate(t.name) + "</b>: " + Backend.translate(":" + t.name));
    });
  }
}
