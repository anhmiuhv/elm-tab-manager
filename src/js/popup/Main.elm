port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder, id)
import Html.Events exposing (onInput, onClick)
import Data exposing (tbs, Tab)
import CustomConfig exposing (customizations, invisibleColumn)
import Table
import Chrome 

main =
    Html.program
    { 
    init = init tbs
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


type Msg
  = SetQuery String
  | SetTableState Table.State
  | AllTabs (List Tab)
  | ClickFrom Int

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

    ClickFrom i -> (model, Chrome.highlight i)
    


-- VIEW

view : Model -> Html Msg
view {tabs, tableState, query} =
    let
      lowerQuery =
        String.toLower query

      querriedTabs =
        List.filter (String.contains lowerQuery << String.toLower << .name) tabs
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
            clickableColumn "Name" createNameAndIndex
            , invisibleColumn "Index" .index
            ]
        , customizations = customizations
        }

createNameAndIndex: Tab -> NameAndIndex
createNameAndIndex t = {
    name = t.name,
    index = t.index
 } 
type alias NameAndIndex = {
  name: String,
  index: Int
 }

clickableColumn :  String -> (data ->NameAndIndex) -> Table.Column data Msg
clickableColumn name toStr =
   Table.veryCustomColumn
       {
            name = name,
            viewData = clickableData << toStr,
            sorter = Table.increasingOrDecreasingBy  <| .name << toStr
      }

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Chrome.allTabs AllTabs


clickableData : NameAndIndex -> Table.HtmlDetails Msg
clickableData x = Table.HtmlDetails [onClick (ClickFrom x.index)] [ Html.text (x.name) ]

