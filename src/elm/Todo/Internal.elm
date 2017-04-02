module Todo.Internal exposing (..)

import Project
import Todo.Types exposing (..)
import Toolkit.Helpers exposing (..)
import Toolkit.Operators exposing (..)
import FunctionExtra exposing (..)
import Time exposing (Time)


type alias Model =
    Todo


type alias ModelF =
    Model -> Model


getDeleted : Model -> Bool
getDeleted =
    (.deleted)


setDeleted : Bool -> ModelF
setDeleted deleted model =
    { model | deleted = deleted }


updateDeleted : (Model -> Bool) -> ModelF
updateDeleted updater model =
    setDeleted (updater model) model


getModifiedAt : Model -> Time
getModifiedAt =
    (.modifiedAt)


setModifiedAt : Time -> ModelF
setModifiedAt modifiedAt model =
    { model | modifiedAt = modifiedAt }


updateModifiedAt : (Model -> Time) -> ModelF
updateModifiedAt updater model =
    setModifiedAt (updater model) model


update : TodoUpdateAction -> ModelF
update field model =
    case field of
        SetDone done ->
            { model | done = done }

        SetDeleted deleted ->
            { model | deleted = deleted }

        SetText text ->
            { model | text = text }

        SetContext context ->
            { model | context = context }

        SetProjectId projectId ->
            { model | projectId = projectId }

        SetProject project ->
            update (SetProjectId (Just (Project.getId project))) model


updateAll : List TodoUpdateAction -> Time -> ModelF
updateAll action now =
    (List.foldl update # action)
        >> setModifiedAt now