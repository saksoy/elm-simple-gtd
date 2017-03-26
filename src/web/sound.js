"use strict";

import R from "ramda"
const _ = R

import howler from "howler"


export default () => {
    const Howl = howler.Howl

    const sound = new Howl({
        src: ['alarm.ogg']
    });

    let id1 = null;

    const start = () => {
        stop()
        id1 = sound.play()
        sound.fade(0, 1, 5000, id1)
    }

    const stop = () => {
        if (id1) sound.stop()
    }

    return {
        start,
        stop
    }
}