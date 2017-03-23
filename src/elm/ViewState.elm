module ViewState exposing (..)

import Todo exposing (Todo, TodoGroup)
import Toolkit.Helpers exposing (..)
import Toolkit.Operators exposing (..)
import FunctionExtra exposing (..)


type NavigationAction
    = ShowAllTodoLists
    | StartProcessingInbox


type ViewState
    = All
    | Group TodoGroup
    | Done
    | Bin


defaultViewState =
    All
