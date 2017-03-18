module InBasketFlow.View exposing (..)

import Flow
import InBasketFlow
import Toolkit.Helpers exposing (..)
import Toolkit.Operators exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (onClickStopPropagation)
import InBasketFlow.Model as Model exposing (Model)
import Main.Msg as Msg exposing (Msg)


view : Model -> Html Msg
view model =
    Model.mapFlow flowView model


flowView flowModel =
    div []
        [ h1 []
            [ Flow.getQuestion flowModel |> text ]
        , div []
            (nextActionButtons flowModel)
        ]


nextActionButtons flowModel =
    flowModel |> Flow.getNextActions Msg.OnInBasketFlowAction .|> createNAB


createNAB ( buttonText, onClickMsg ) =
    button [ onClick onClickMsg ] [ text buttonText ]
