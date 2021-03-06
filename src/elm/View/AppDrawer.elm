module View.AppDrawer exposing (..)

import Html.Attributes.Extra exposing (..)
import Html.Keyed as Keyed
import Html exposing (Attribute, Html, div, hr, node, span, text)
import Html.Attributes exposing (attribute, autofocus, class, classList, id, style, value)
import Html.Events exposing (..)
import KeyboardExtra as KeyboardExtra exposing (onEscape, onKeyUp)
import Model.TodoList
import Msg exposing (Msg(SetMainViewType))
import View.TodoLists exposing (allTodoListByTodoContextView)
import Maybe.Extra as Maybe
import Polymer.Attributes exposing (icon)
import Toolkit.Helpers exposing (..)
import Toolkit.Operators exposing (..)
import DebugExtra.Debug exposing (tapLog)
import DecodeExtra exposing (traceDecoder)
import Json.Decode
import Json.Encode
import List.Extra as List
import Model exposing (..)
import Todo
import Todo.Types exposing (..)
import Polymer.Paper exposing (..)
import Polymer.App as App
import FunctionExtra exposing (..)
import FunctionExtra.Operators exposing (..)
import Model.Types exposing (..)


appDrawerView m =
    App.drawer [ attribute "slot" "drawer" ]
        [ div
            [ style [ "height" => "100%", "overflow" => "scroll" ]
            ]
            [ menu
                [ stringProperty "selected" "0"
                ]
                ([ item [ onClick (SetMainViewType AllByTodoContextView) ] [ text "All" ]
                 , divider
                 , projectsItemView m
                 , divider
                 ]
                    ++ todoContextsMenuItems m
                    ++ [ divider
                       , binItemView m
                       , doneItemView m
                       ]
                )
            ]
        ]


divider =
    hr [] []


projectsItemView m =
    item [ onClick (SetMainViewType ProjectsView) ] [ text "Projects" ]


binItemView m =
    item [ onClick (SetMainViewType BinView) ] [ text "Bin" ]


doneItemView m =
    item [ onClick (SetMainViewType DoneView) ] [ text "Done" ]


todoContextsMenuItems =
    Model.TodoList.getTodoContextsViewModel
        >> List.map contextMenuItem


contextMenuItem vm =
    let
        badgeForId =
            "id-for-badge-" ++ vm.name
    in
        item [ class "has-hover-items" ]
            ([ span [ id badgeForId ] [ text (vm.name) ]
             , itemBody [] []
             , badge
                [ classList
                    [ "hidden" => (vm.isEmpty)
                    , "drawer-list-type-badge" => True
                    ]
                , intProperty "label" (vm.count)
                , attribute "for" badgeForId
                ]
                []
             ]
                ++ addHoverItems vm.todoContext
            )


addHoverItems context =
    case context of
        --        Inbox ->
        --            [ iconButton
        --                [ class "hover-items"
        --                , icon "vaadin-icons:start-cog"
        --                , onClick ProcessInbox
        --                ]
        --                []
        --            ]
        _ ->
            []
