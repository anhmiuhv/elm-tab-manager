port module Main exposing (..)


import Html.Attributes exposing (placeholder, id, autofocus, class)
import Html.Events exposing (onInput, onClick)
import Html exposing (..)
import CustomConfig exposing (..)
import Data exposing (..)
import Helper exposing (..)
import Update
import Table
import Chrome
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
            , selected = 0
            , deltaSel = -1000000
            , multiSel = (False, Set.empty)
        }
    in (model, Chrome.getAllTabs "")


-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        m = {model | deltaSel = if model.deltaSel == -1000000 then model.deltaSel
                                else 0}
    in    
  case msg of
    None -> (m, Cmd.none)
    SetQuery newQuery -> Update.setQueryHandler newQuery m
    SetTableState newState -> Update.setTableStateHandler newState m
    AllTabs tabs -> Update.allTabsHandler tabs m
    KeyChangeSelect what -> Update.keyChangeHandler model  what
    RemoveDuplicate -> if Focus.get multiSelBol m then (m ! [])
                        else (Update.removeDupHandler m)
    CloseFrom id -> Update.closeFromHandler id m
    MultiSel -> Focus.update multiSelBol not m ! []
    ClickFrom id -> if (not <| Focus.get multiSelBol m) then (m, Chrome.highlight id) 
                    else (Focus.update multiSelSet (maybeInsert id) m ! [])
    MouseIn id ->{m | selected = id, deltaSel = 0} ! []
    Deselect id -> if (model.deltaSel == 0) then ({model | deltaSel = -1000000, selected = -1} ! [])
                    else (model ! [])
    CloseSelected -> Update.closeSelectedHandler m
    HighlightHist a -> Update.highlightHistHandler m a





-- VIEW

view : Model -> Html Msg
view {tabs, tableState, query, selected, deltaSel, multiSel} =
    let
      model = Model tabs tableState query selected deltaSel multiSel
      queriedTabs = Search.queryToListTab model      
    in
        div [id "body", onKeyUp emmitUpDown]
            [ div [class "dropdown-container"] (Dropdown.dropdown model)
            , input [id "searchBox",placeholder "Search"
            , onInput SetQuery,  autofocus True] [],
            Table.view config tableState queriedTabs
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
