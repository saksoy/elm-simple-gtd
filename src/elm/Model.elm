module Model exposing (..)

import EditModel
import Model.Internal exposing (..)
import Project
import RunningTodoDetails exposing (RunningTodoDetails)
import Dict
import Json.Encode as E
import List.Extra as List
import Maybe.Extra as Maybe
import Navigation exposing (Location)
import RandomIdGenerator as Random
import Random.Pcg as Random exposing (Seed)
import Time exposing (Time)
import Todo as Todo exposing (TodoGroup, Todo, TodoId)
import Toolkit.Operators exposing (..)
import Toolkit.Helpers exposing (..)
import Tuple2
import Model.Types exposing (..)
import Types exposing (..)


getMainViewType : Model -> MainViewType
getMainViewType =
    (.mainViewType)


setMainViewType : MainViewType -> ModelF
setMainViewType mainViewType model =
    { model | mainViewType = mainViewType }


getNow : Model -> Time
getNow =
    (.now)


setNow : Time -> ModelF
setNow now model =
    { model | now = now }


generate : Random.Generator a -> Model -> ( a, Model )
generate generator m =
    Random.step generator (m.seed)
        |> Tuple.mapSecond (setSeed # m)


init now encodedTodoList encodedProjectList =
    { now = now
    , todoList = Todo.decodeTodoList encodedTodoList
    , editModel = EditModel.init
    , mainViewType = AllByGroupView
    , seed = Random.seedFromTime now
    , runningTodoDetails = RunningTodoDetails.init
    , projectList = Project.decodeProjectList encodedProjectList
    }
