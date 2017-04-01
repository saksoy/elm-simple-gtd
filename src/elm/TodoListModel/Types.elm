module TodoListModel.Types exposing (..)

import TodoModel.Types exposing (EncodedTodo, TodoModel)
import Toolkit.Helpers exposing (..)
import Toolkit.Operators exposing (..)
import FunctionExtra exposing (..)

type alias TodoListModel =
    List TodoModel


type alias EncodedTodoList =
    List EncodedTodo


