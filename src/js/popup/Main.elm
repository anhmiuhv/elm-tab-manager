port module Main exposing (..)


import Html.Attributes exposing (placeholder, id, autofocus)
import Html.Events exposing (onInput, onClick)
import List.Extra
import Html exposing (..)
import CustomConfig exposing (..)
import Data exposing (..)
import Update
import Table
import Chrome
import Search


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
            , selected = -1
        }
    in (model, Chrome.getAllTabs "")


-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    None -> (model, Cmd.none)

    SetQuery newQuery ->
      ( { model | query = newQuery, selected = -1 }
      , Cmd.none
      )

    SetTableState newState ->
      ( { model | tableState = newState }
      , Cmd.none
      )
    
    AllTabs tabs -> 
      ( {model | tabs = (List.map createFtab tabs), query = ""} 
      , Cmd.none
      )

    ClickFrom id -> (model, Chrome.highlight id)

    CloseFrom id -> 
      ( { model | tabs = List.filter (((/=) id) << .id) model.tabs }
      , Chrome.close id
      )

    KeyChangeSelect what -> Update.keyChangeHandler model what
          
    Mouse id ->
      case List.Extra.findIndex (\t->t.id == id) model.tabs of
        Just i -> ({model | selected = i}, Cmd.none)
        Nothing -> model ! []





-- VIEW

view : Model -> Html Msg
view {tabs, tableState, query, selected} =
    let
      selectedTabs = Search.queryToListTab <| Model tabs tableState query selected
    in
        div [id "body"]
            [ input [id "searchBox",placeholder "Search"
            , onInput SetQuery, onKeyUp emmitUpDown, autofocus True] [],
            Table.view config tableState selectedTabs
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
