module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder, id)
import Html.Events exposing (onInput)
import Data exposing (tbs, Tab)
import CustomConfig exposing (customizations, invisibleColumn)
import Table

main =
    Html.program
    { 
    init = init tbs
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    }


  -- MODEL

type alias Model = 
    { 
    tabs : List Tab
    , tableState : Table.State
    , query : String
    }

init : List Tab -> (Model, Cmd Msg)
init tbs = 
    let 
        model = 
        { tabs = tbs
            , tableState = Table.initialSort "Index"
            , query = ""
        }
    in (model, Cmd.none)


-- UPDATE


type Msg
  = SetQuery String
  | SetTableState Table.State


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SetQuery newQuery ->
      ( { model | query = newQuery }
      , Cmd.none
      )

    SetTableState newState ->
      ( { model | tableState = newState }
      , Cmd.none
      )


-- VIEW

view : Model -> Html Msg
view {tabs, tableState, query} =
    div []
        [ input [id "searchBox",placeholder "Search"] [],
        Table.view config tableState tabs
        ]

config : Table.Config Tab Msg
config = 
    Table.customConfig 
        { toId = toString << .id
        , toMsg = SetTableState
        , columns =
            [
            Table.stringColumn "Name" .name
            , invisibleColumn "Index" .index
            ]
        , customizations = customizations
        }





