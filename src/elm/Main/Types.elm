module Main.Types exposing (..)

import ActiveTask exposing (MaybeActiveTask)
import Random.Pcg exposing (Seed)
import Time exposing (Time)
import Todo exposing (Todo, TodoGroup, TodoList)
import Toolkit.Helpers exposing (..)
import Toolkit.Operators exposing (..)
import FunctionExtra exposing (..)


type MainViewType
    = AllByGroupView
    | GroupView TodoGroup
    | DoneView
    | BinView


defaultViewType =
    AllByGroupView


type EditMode
    = EditNewTodoMode String
    | EditTodoMode Todo
    | NotEditing


type alias Model =
    { now : Time
    , todoList : TodoList
    , editMode : EditMode
    , mainViewType : MainViewType
    , seed : Seed
    , activeTask : MaybeActiveTask
    }


type alias ModelF =
    Model -> Model
