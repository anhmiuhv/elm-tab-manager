port module Main exposing (..)


import Html.Attributes exposing (placeholder, id, autofocus, class)
import Html.Events exposing (onInput, onClick)
import List.Extra
import Html exposing (..)
import CustomConfig exposing (..)
import Data exposing (..)
import Helper exposing (..)
import Update
import Table
import Chrome
import Dict
import Search
import Focus
import Set
import Dropdown


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
            , deselect = -1
            , multiSel = (False, Set.empty)
        }
    in (model, Chrome.getAllTabs "")


-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    None -> (model, Cmd.none)
    SetQuery newQuery -> Update.setQueryHandler newQuery model
    SetTableState newState -> Update.setTableStateHandler newState model
    AllTabs tabs -> Update.allTabsHandler tabs model
    KeyChangeSelect what -> Update.keyChangeHandler {model | deselect = -1} what
    RemoveDuplicate -> if Focus.get multiSelBol model then model ! [] 
                        else Update.removeDupHandler model
    CloseFrom id -> Update.closeFromHandler id model
    MultiSel -> Focus.update multiSelBol not model ! []
    ClickFrom id -> if not <| Focus.get multiSelBol model then (model, Chrome.highlight id)
                    else Focus.update multiSelSet (maybeInsert id) model ! []
          
    MouseIn id ->
      case List.Extra.findIndex (\t->t.id == id) model.tabs of
        Just i -> ({model | selected = i, deselect = -1}, Cmd.none)
        Nothing -> model ! []

    Deselect id ->
      case List.Extra.findIndex (\t->t.id == id) model.tabs of
        Just i -> ({model | deselect = i}, Cmd.none)
        Nothing -> model ! []

    CloseSelected -> Update.closeSelectedHandler model
    HighlightHist a -> let
            transform : Ftab -> Ftab
            transform b = 
                case Dict.get (toString b.id) a of
                    Just i -> {b | lastHighlight = i}
                    _ -> b
            
        in      
            {model | tabs = List.map transform model.tabs } ! []





-- VIEW

view : Model -> Html Msg
view {tabs, tableState, query, selected, deselect, multiSel} =
    let
      model = Model tabs tableState query selected deselect multiSel
      selectedTabs = Search.queryToListTab model
      
    in
        div [id "body"]
            [ div [class "dropdown-container"] (Dropdown.dropdown model)
            , input [id "searchBox",placeholder "Search"
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
            , invisibleColumn "LastHighlight" .lastHighlight
            , stringInvisibleColumn "BaseURL" .baseUrl
            , deleteButtonColumn CloseFrom .id
            ]
        , customizations = customizations
        }



-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [
          Chrome.allTabs AllTabs
          , Chrome.highlightHist (decodeHist >> toHighlightHist)
          , Chrome.sortSetting (Table.initialSort >> SetTableState )
          ]
