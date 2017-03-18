module InBasketFlow exposing (..)

import Flow
import InBasketFlow.Model as Model
import Main.Msg exposing (Msg(OnFlowTrashItClicked))
import TodoCollection.Todo exposing (Todo)
import Toolkit.Operators exposing (..)
import Toolkit.Helpers exposing (..)


init todoList =
    Model.modelConstructor todoList


updateWithActionType =
    Model.updateWithActionType


type alias Model =
    Model.Model


mapFlow =
    Model.mapFlow
