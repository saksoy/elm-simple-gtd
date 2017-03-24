port module Main exposing (..)

import Dom
import DomTypes exposing (DomId)
import DomUpdate
import Json.Encode as E
import Keyboard.Extra exposing (Key(Enter, Escape))
import Main.Model as Model exposing (Model)
import Main.Msg as Msg exposing (..)
import Main.Routing
import Main.View exposing (appView)
import Navigation exposing (Location)
import Return exposing (Return)
import RouteUrl exposing (RouteUrlProgram)
import Task
import Time exposing (Time)
import PouchDB
import TodoList
import Toolkit.Operators exposing (..)
import Toolkit.Helpers exposing (..)
import Maybe.Extra as Maybe
import Todo as Todo exposing (EncodedTodoList, Todo, TodoId)
import Tuple2
import Function exposing ((>>>))
import Html


type alias UpdateReturn =
    Return MsgLow Model


type alias UpdateReturnF =
    UpdateReturn -> UpdateReturn


type alias Flags =
    { now : Time, encodedTodoList : EncodedTodoList }


main : RouteUrlProgram Flags Model Msg
main =
    RouteUrl.programWithFlags
        { delta2url = Main.Routing.delta2hash
        , location2messages = Function.map (List.map LowFrequencyMsg) Main.Routing.hash2messages
        , init = Function.map (Return.mapCmd LowFrequencyMsg) init
        , update = masterUpdate
        , view = Function.map (Html.map LowFrequencyMsg) appView
        , subscriptions = \m -> Sub.batch [ Time.every Time.second (UpdateNow >> HighFrequencyMsg) ]
        }


masterUpdate : Msg -> Model -> ( Model, Cmd Msg )
masterUpdate msg =
    Return.singleton
        >> case msg of
            HighFrequencyMsg msg ->
                Return.andThen (updateHighMsg msg >> Return.mapCmd HighFrequencyMsg)

            LowFrequencyMsg msg ->
                Return.andThen (update msg >> Return.mapCmd LowFrequencyMsg)


updateHighMsg : MsgHigh -> Model -> Return MsgHigh Model
updateHighMsg msg =
    Return.singleton
        >> case msg of
            UpdateNow now ->
                Return.map (Model.setNow now)


init : Flags -> UpdateReturn
init { now, encodedTodoList } =
    Model.init now encodedTodoList |> Return.singleton


update : MsgLow -> Model -> UpdateReturn
update msg =
    Return.singleton
        >> case msg of
            NoOp ->
                identity

            OnAddTodoClicked focusInputId ->
                activateEditNewTodoMode ""
                    >> domFocus focusInputId

            OnNewTodoTextChanged text ->
                activateEditNewTodoMode text

            OnNewTodoBlur ->
                deactivateEditingMode

            OnNewTodoKeyUp text key ->
                case key of
                    Enter ->
                        addNewTodoAndContinueAdding text

                    Escape ->
                        deactivateEditingMode

                    _ ->
                        identity

            OnEditTodoClicked focusInputId todo ->
                Return.map (Model.activateEditTodoMode todo)
                    >> domFocus focusInputId

            OnEditTodoTextChanged text ->
                Return.map (Model.updateEditTodoText text)

            OnEditTodoBlur todo ->
                setTodoTextAndDeactivateEditing todo

            OnEditTodoKeyUp todo key ->
                case key of
                    Enter ->
                        setTodoTextAndDeactivateEditing todo

                    Escape ->
                        deactivateEditingMode

                    _ ->
                        identity

            OnSetTodoGroupClicked todoGroup todo ->
                onTodoListMsg (TodoList.setGroup todoGroup (Todo.getId todo))

            OnDeleteTodoClicked todoId ->
                onTodoListMsg (TodoList.toggleDelete todoId)

            OnTodoDoneClicked todoId ->
                onTodoListMsg (TodoList.toggleDone todoId)

            OnTodoListMsg msg ->
                Return.andThen (TodoList.update msg >> Return.mapCmd OnTodoListMsg)

            OnDomMsg msg ->
                Return.andThen (DomUpdate.update msg >> Return.mapCmd OnDomMsg)

            ChangeView viewState ->
                Return.map (Model.setViewState viewState)



--            _ ->
--                let
--                    _ =
--                        Debug.log "WARN: msg ignored" (msg)
--                in
--                    identity


onTodoListMsg =
    OnTodoListMsg >> update >> Return.andThen


onDomMsg =
    OnDomMsg >> update >> Return.andThen


domFocus : DomId -> UpdateReturnF
domFocus =
    DomTypes.focus >> onDomMsg


addNewTodoAndContinueAdding text =
    onTodoListMsg (TodoList.addNewTodo text)
        >> activateEditNewTodoMode ""


activateEditNewTodoMode text =
    Return.map (Model.activateEditNewTodoMode text)


setTodoTextAndDeactivateEditing todo =
    onTodoListMsg (TodoList.setText (Todo.getText todo) (Todo.getId todo))
        >> deactivateEditingMode


deactivateEditingMode =
    Return.map (Model.deactivateEditingMode)
