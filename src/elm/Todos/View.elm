module Todos.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (onClickStopPropagation, onEnter)
import Todos exposing (EditMode(..), TodosModel)
import Todos.Todo as Todo exposing (TodoId)


type alias ViewConfig msg =
    { onAddTodoClicked : msg
    , onDeleteTodoClicked : TodoId -> msg
    , onEdit : TodoId -> msg
    , onNewTodoTextChanged : String -> msg
    , onNewTodoBlur : msg
    , onNewTodoEnterPressed : msg
    }


allTodosView : ViewConfig msg -> EditMode -> TodosModel -> Html msg
allTodosView viewConfig editMode todosModel =
    div []
        [ todoListView editMode viewConfig todosModel
        , addTodoView editMode viewConfig
        ]


addTodoView editMode viewConfig =
    case editMode of
        EditNewTodoMode text ->
            addNewTodoView viewConfig text

        _ ->
            addTodoButton viewConfig


addTodoButton viewConfig =
    button
        [ onClick viewConfig.onAddTodoClicked
        ]
        [ text "Add Todo" ]


addNewTodoView viewConfig text =
    input
        [ onInput viewConfig.onNewTodoTextChanged
        , value text
        , onBlur viewConfig.onNewTodoBlur
        , autofocus True
        , onEnter viewConfig.onNewTodoEnterPressed
        ]
        []


todoListView editMode viewConfig todosModel =
    ul []
        (todosModel
            |> Todos.map
                (todoView viewConfig.onDeleteTodoClicked viewConfig.onEdit editMode viewConfig)
        )


todoView onDeleteTodoClicked onEdit editMode viewConfig todo =
    case editMode of
        EditTodoMode todoId ->
            todoListEditView viewConfig todo

        _ ->
            todoListItemView onDeleteTodoClicked onEdit todo


todoListItemView onDeleteTodoClicked onEdit todo =
    let
        deleteOnClick =
            onClick (onDeleteTodoClicked (Todo.getId todo))

        editOnClick =
            onClick (onEdit (Todo.getId todo))
    in
        div []
            [ button [ deleteOnClick ] [ text "x" ]
            , div [ editOnClick ] [ Todo.getText todo |> text ]
            ]


todoListEditView viewConfig todo =
    input
        [ onInput viewConfig.onNewTodoTextChanged
        , value (Todo.getText todo)
        , onBlur viewConfig.onNewTodoBlur
        , autofocus True
        , onEnter viewConfig.onNewTodoEnterPressed
        ]
        []
