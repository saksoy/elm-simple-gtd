module KeyboardExtra exposing (..)

import DecodeExtra exposing (traceDecoder)
import Html exposing (Attribute)
import Html.Events as Events
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline as D
import Keyboard.Extra as KX exposing (Key)
import FunctionExtra.Operators exposing (..)


onKeyUp : (KeyboardEvent -> msg) -> Attribute msg
onKeyUp onKeyMsg =
    Events.on "keyup" (D.map onKeyMsg keyboardEventDecoder)


targetKeyDecoder : Decoder Key
targetKeyDecoder =
    D.map KX.fromCode (D.field "keyCode" D.int)


keyboardEventDecoder : Decoder KeyboardEvent
keyboardEventDecoder =
    D.succeed KeyboardEvent
        |> D.custom targetKeyDecoder
        |> D.required "shiftKey" D.bool


type alias KeyboardEvent =
    { key : Key, isShiftDown : Bool }


succeedIfDecodedKeyEquals key msg =
    KX.targetKey
        |> D.andThen
            (\actualKey ->
                let
                    _ =
                        Debug.log "actualKey, expectedKey" ( actualKey, key )
                in
                    if key == actualKey then
                        D.succeed msg
                    else
                        D.fail "Not intrested"
            )


onEscape : msg -> Attribute msg
onEscape msg =
    Events.on "keyup" (succeedIfDecodedKeyEquals KX.Escape msg)


onEnter : msg -> Attribute msg
onEnter msg =
    Events.on "keyup" (succeedIfDecodedKeyEquals KX.Enter msg)


keyUps =
    KX.ups


init =
    KX.initialState


subscription tagger =
    Sub.map tagger KX.subscriptions


update setter =
    KX.update >>> setter


isShiftDown =
    KX.isPressed KX.Shift


isControlDown =
    KX.isPressed KX.Control


isAltDown =
    KX.isPressed KX.Alt


isMetaDown =
    KX.isPressed KX.Meta
