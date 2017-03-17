module InBasketFlow.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (onClickStopPropagation)
import InBasketFlow.Model as Model exposing (Model)


flowDialogView model =
    div []
        [ h1 []
            [ Model.getQuestion model |> text ]
        , div []
            [ button [] [ "Yes" |> text ]
            , button [] [ "No" |> text ]
            ]
        ]
