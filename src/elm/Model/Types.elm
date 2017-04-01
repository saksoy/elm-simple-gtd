module Model.Types exposing (..)

import EditModel.Types exposing (..)
import Project exposing (ProjectList, ProjectName)
import Random.Pcg exposing (Seed)
import RunningTodoDetails exposing (RunningTodoDetails)
import TodoListModel.Types exposing (..)
import Toolkit.Helpers exposing (..)
import Toolkit.Operators exposing (..)
import FunctionExtra exposing (..)
import Time exposing (Time)
import TodoModel.Types exposing (..)


type MainViewType
    = AllByTodoContextView
    | TodoContextView TodoContext
    | DoneView
    | BinView
    | ProjectsView


type alias Model =
    { now : Time
    , todoList : TodoListModel
    , editModel : EditModel
    , mainViewType : MainViewType
    , seed : Seed
    , runningTodoDetails : Maybe RunningTodoDetails
    , projectList : ProjectList
    }


type ModelField
    = NowField Time
    | MainViewTypeField MainViewType


type alias ModelF =
    Model -> Model
