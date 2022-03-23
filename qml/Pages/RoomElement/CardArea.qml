import QtQuick 2.15

// CardArea stores CardItem.

Item {
    property var cards: []
    property int length: 0

    id: root

    function add(inputs)
    {
        if (inputs instanceof Array) {
            cards.push(...inputs);
        } else {
            cards.push(inputs);
        }
        length = cards.length;
    }

    function remove(outputs)
    {
        var result = [];
        for (var i = 0; i < cards.length; i++) {
            for (var j = 0; j < outputs.length; j++) {
                if (outputs[j] === cards[i].cid) {
                    result.push(cards[i]);
                    cards.splice(i, 1);
                    i--;
                    break;
                }
            }
        }
        length = cards.length;
        return result;
    }

    function updateCardPosition(animated)
    {
        var i, card;

        var overflow = false;
        for (i = 0; i < cards.length; i++) {
            card = cards[i];
            card.origX = i * card.width;
            if (card.origX + card.width >= root.width) {
                overflow = true;
                break;
            }
            card.origY = 0;
        }

        if (overflow) {
            // TODO: Adjust cards in multiple lines if there are too many cards
            var xLimit = root.width - card.width;
            var spacing = xLimit / (cards.length - 1);
            for (i = 0; i < cards.length; i++) {
                card = cards[i];
                card.origX = i * spacing;
                card.origY = 0;
            }
        }

        var parentPos = roomScene.mapFromItem(root, 0, 0);
        for (i = 0; i < cards.length; i++) {
            card = cards[i];
            card.origX += parentPos.x;
            card.origY += parentPos.y;
        }

        if (animated) {
            for (i = 0; i < cards.length; i++)
                cards[i].goBack(true);
        }
    }
}

