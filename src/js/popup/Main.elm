port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (placeholder, id)
import Html.Events exposing (onInput, onClick)
import CustomConfig exposing (..)
import Data exposing (..)
import Maybe.Extra exposing ((?))
import List.Extra exposing (updateIfIndex, (!!), updateAt)
import Table
import Chrome
import Search
import Regex


main : Program Never Model Msg
main =
    Html.program
    {
    init = init []
    , update = update
    , view = view
    , subscriptions = subscriptions
    }


  -- MODEL

init : List Tab -> (Model, Cmd Msg)
init tbs =
    let
        model =
        { tabs = List.map createFtab tbs
            , tableState = Table.initialSort "Index"
            , query = ""
            , selected = []
        }
    in (model, Chrome.getAllTabs "")


-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    None -> (model, Cmd.none)

    SetQuery newQuery ->
      ( { model | query = newQuery }
      , Cmd.none
      )

    SetTableState newState ->
      ( { model | tableState = newState }
      , Cmd.none
      )
    
    AllTabs tabs -> ( {model | tabs = (List.map createFtab tabs), query = ""} , Cmd.none)

    ClickFrom id -> (model, Chrome.highlight id)

    CloseFrom id -> ( { model | tabs = List.filter (((/=) id) << .id) model.tabs }, Chrome.close id)

    KeyChangeSelect direction -> 
          let 
            sel = List.head model.selected ? 0
            selectAnother i = model.tabs
                                |> updateIfIndex ((==) sel) (\t -> {t | selected = False })
                                |> updateIfIndex ((==) <| sel - i) (\t -> {t | selected = True})
          in case direction of
              Up -> ({ model | selected = updateAt 0 (\x -> x -1) model.selected ? [0],
                               tabs = selectAnother 1 }, Cmd.none)
              Down -> (model, Cmd.none)



-- VIEW

view : Model -> Html Msg
view {tabs, tableState, query} =
    let
      keywords =
        String.words << String.toLower << Regex.escape <| query

      querriedTabs =
        List.map Tuple.first <| Search.search tabs keywords
    in
        div [id "body", onKeyUp emmitUpDown]
            [ input [id "searchBox",placeholder "Search", onInput SetQuery] [],
            Table.view config tableState querriedTabs
            ]

config : Table.Config Ftab Msg
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
