port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder, id)
import Html.Events exposing (onInput, onClick)
import CustomConfig exposing (customizations, invisibleColumn, deleteButtonColumn,
                              clickableData, clickableColumn)
import Table
import Chrome
import Search
import Regex
import List.Extra
import Data exposing (..)


main =
    Html.program
    {
    init = init []
    , update = update
    , view = view
    , subscriptions = subscriptions
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
    in (model, Chrome.getAllTabs "")


-- UPDATE


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

    AllTabs tabs -> ( Model tabs (Table.initialSort "Index") "", Cmd.none)

    ClickFrom id -> (model, Chrome.highlight id)

    CloseFrom id -> ( { model | tabs = List.filter (((/=) id) << .id) model.tabs }, Chrome.close id)



-- VIEW

view : Model -> Html Msg
view {tabs, tableState, query} =
    let
      keywords =
        String.words << String.toLower << Regex.escape <| query

      querriedTabs =
        List.map Tuple.first <| Search.search tabs keywords
    in
        div [id "body"]
            [ input [id "searchBox",placeholder "Search", onInput SetQuery] [],
            Table.view config tableState querriedTabs
            ]

config : Table.Config Tab Msg
config =
    Table.customConfig
        { toId = toString << .id
        , toMsg = SetTableState
        , columns =
            [
            clickableColumn "Name" clickableData createNameAndId
            , invisibleColumn "Index" .index
            , deleteButtonColumn CloseFrom .id
            ]
        , customizations = customizations
        }



-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Chrome.allTabs AllTabs
