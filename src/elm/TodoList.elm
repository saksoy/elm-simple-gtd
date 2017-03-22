module TodoList exposing (..)

import List.Extra
import Main.Model exposing (Model)
import Maybe.Extra
import Random.Pcg as Random
import Return exposing (Return, ReturnF)
import Task
import Time exposing (Time)
import Todo exposing (Todo, TodoGroup, TodoId)
import Toolkit.Helpers exposing (..)
import Toolkit.Operators exposing (..)
import FunctionExtra exposing (..)
import Main.TodoListMsg exposing (..)
import PouchDB
import Tuple2


toggleDone =
    UpdateTodo ToggleDone


delete =
    UpdateTodo Delete


setGroup : TodoGroup -> TodoId -> TodoListMsg
setGroup =
    SetGroup >> UpdateTodo


setText : String -> TodoId -> TodoListMsg
setText =
    SetText >> UpdateTodo


addNewTodo : String -> TodoListMsg
addNewTodo =
    AddNewTodo


update : TodoListMsg -> Model -> ( Model, Cmd TodoListMsg )
update msg =
    Return.singleton
        >> case msg of
            UpdateTodo action id ->
                withNow (UpdateTodoAt action id)

            UpdateTodoAt action id now ->
                updateAndPersistMaybeTodo (updateTodoAt action id now)

            AddNewTodo text ->
                withNow (AddNewTodoAt text)

            AddNewTodoAt text now ->
                updateAndPersistMaybeTodo (addNewTodoAt text now)


addNewTodoAt text now m =
    if String.trim text |> String.isEmpty then
        ( m, Nothing )
    else
        Random.step (Todo.generator now text) (Main.Model.getSeed m)
            |> Tuple.mapSecond (Main.Model.setSeed # m)
            |> apply2 ( uncurry addTodo, Tuple.first >> Just )


addTodo todo =
    Main.Model.updateTodoList (Main.Model.getTodoList >> (::) todo)


updateAndPersistMaybeTodo updater =
    Return.andThen
        (updater >> Tuple2.mapSecond persistMaybeTodoCmd)


withNow : (Time -> TodoListMsg) -> ReturnF TodoListMsg Model
withNow msg =
    Task.perform msg Time.now |> Return.command


persistMaybeTodoCmd =
    Maybe.Extra.unwrap Cmd.none persistTodoCmd


persistTodoCmd todo =
    PouchDB.pouchDBBulkDocsHelp "todo-db" (Todo.encodeSingleton todo)


updateTodoAt action todoId now =
    let
        --        todoId = Todo.getId todo
        todoActionUpdater =
            case action of
                SetGroup group ->
                    Todo.setListType group

                ToggleDone ->
                    Todo.toggleDone

                Delete ->
                    Todo.markDeleted

                SetText text ->
                    Todo.setText text

        modifiedAtUpdater =
            Todo.setModifiedAt now

        todoUpdater =
            todoActionUpdater >> modifiedAtUpdater
    in
        updateTodoMaybe todoUpdater todoId


updateTodoMaybe : (Todo -> Todo) -> TodoId -> Model -> ( Model, Maybe Todo )
updateTodoMaybe updater todoId m =
    let
        todoList =
            m.todoList
                |> List.Extra.updateIf (Todo.hasId todoId) updater
    in
        ( Main.Model.setTodoList todoList m
        , List.Extra.find (Todo.hasId todoId) todoList
        )
