module View.AllTodoLists exposing (..)

import Dom
import Html.Attributes.Extra exposing (..)
import Html.Keyed as Keyed
import Keyboard.Extra exposing (Key)
import KeyboardExtra as KeyboardExtra exposing (KeyboardEvent, onEscape, onKeyUp)
import Model.EditMode
import Model.ProjectList
import Model.TodoList exposing (TodoGroupViewModel)
import Msg exposing (..)
import Polymer.Attributes exposing (icon)
import Time exposing (Time)
import Toolkit.Helpers exposing (..)
import Toolkit.Operators exposing (..)
import Html exposing (Html, div, hr, node, span, text)
import Html.Attributes exposing (attribute, autofocus, class, classList, id, style, value)
import Html.Events exposing (..)
import DebugExtra.Debug exposing (tapLog)
import DecodeExtra exposing (traceDecoder)
import Json.Decode
import Json.Encode
import List.Extra as List
import Model as Model
import Types exposing (EditMode(..), EditTodoModel, Model, ModelF)
import Todo as Todo exposing (TodoGroup(Inbox), Todo, TodoId)
import Polymer.Paper as Paper exposing (badge, button, fab, iconButton, item, itemBody, material, menu, tab, tabs)
import Polymer.App exposing (..)
import FunctionExtra exposing (..)
import View.Todo


type alias ViewConfig msg =
    { onDeleteTodoClicked : TodoId -> msg
    , onEditTodoKeyUp : Todo -> KeyboardEvent -> msg
    , noOp : msg
    , onTodoMoveToClicked : TodoGroup -> TodoId -> msg
    , now : Time
    , editTodoModelFor : Todo -> Maybe EditTodoModel
    , onTodoDoneClicked : TodoId -> msg
    , onTodoStartClicked : TodoId -> msg
    , encodedProjectNames : Json.Encode.Value
    }


createTodoListViewConfig : Model -> ViewConfig Msg
createTodoListViewConfig model =
    { onDeleteTodoClicked = Msg.toggleDelete
    , onEditTodoKeyUp = onEditTodoKeyUp
    , noOp = NoOp
    , onTodoMoveToClicked = Msg.setGroup
    , now = Model.getNow model
    , editTodoModelFor = Model.EditMode.getEditTodoModelForTodo model
    , onTodoDoneClicked = Msg.toggleDone
    , onTodoStartClicked = Msg.start
    , encodedProjectNames = Model.ProjectList.getEncodedProjectNames model
    }


allTodoListByGroupView : Model -> Html Msg
allTodoListByGroupView =
    apply2 ( todoViewFromModel >> keyedTodoGroupView, Model.TodoList.getTodoGroupsViewModel )
        >> uncurry List.filterMap
        >> Keyed.node "div" []


todoListView : Model -> Html Msg
todoListView =
    apply2 ( todoViewFromModel, Model.TodoList.getFilteredTodoList )
        >> (\( todoView, todoList ) ->
                Keyed.node "paper-material" [ class "todo-list" ] (todoList .|> todoView)
           )


todoViewFromModel =
    createTodoListViewConfig >> todoView


type alias TodoView =
    Todo -> ( TodoId, Html Msg )


keyedTodoGroupView : TodoView -> TodoGroupViewModel -> Maybe ( String, Html Msg )
keyedTodoGroupView todoView vm =
    if vm.isEmpty then
        Nothing
    else
        Just
            ( vm.name
            , div [ class "todo-list-container" ]
                [ div [ class "todo-list-title" ]
                    [ div [ class "paper-badge-container" ]
                        [ span [] [ text vm.name ]
                        , badge [ intProperty "label" (vm.count) ] []
                        ]
                    ]
                , Keyed.node "paper-material" [ class "todo-list" ] (vm.todoList .|> todoView)
                ]
            )


todoView : ViewConfig Msg -> TodoView
todoView vc todo =
    ( Todo.getId todo
    , case vc.editTodoModelFor todo of
        Just etm ->
            View.Todo.todoViewEditing vc etm

        Nothing ->
            View.Todo.todoViewNotEditing vc todo
    )
