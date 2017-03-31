module Model.ProjectList exposing (..)

import List.Extra as List
import Model
import Toolkit.Helpers exposing (..)
import Toolkit.Operators exposing (..)
import FunctionExtra exposing (..)
import Project exposing (Project, ProjectList, ProjectName)
import Types exposing (Model, ModelF)


init =
    []


getProjectIdByName projectName =
    getProjectByName projectName >> Maybe.map Project.getId


getProjectByName projectName =
    getProjectList >> List.find (Project.nameEquals projectName)


createProject : ProjectName -> Model -> ( Project, Model )
createProject projectName =
    Model.generate (Project.projectGenerator projectName)
        >> addProjectFromTuple


addProjectFromTuple : ( Project, Model ) -> ( Project, Model )
addProjectFromTuple =
    apply2 ( Tuple.first, uncurry addProject )


addProject project =
    updateProjectList (getProjectList >> (::) project)


getProjectList : Model -> ProjectList
getProjectList =
    (.projectList)


setProjectList : ProjectList -> ModelF
setProjectList projectList model =
    { model | projectList = projectList }


updateProjectList : (Model -> ProjectList) -> ModelF
updateProjectList updater model =
    setProjectList (updater model) model
