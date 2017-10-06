module CustomConfig exposing (..)
import Html exposing (i, div, br, span)
import Html.Attributes exposing (id, class, attribute)
import Html.Events exposing (onClick, keyCode, onWithOptions, defaultOptions, onMouseEnter, onMouseLeave)
import Table exposing (defaultCustomizations)
import Json.Decode as Json
import Data exposing (..)

-- remove thead, otherwise use popup.sass for design
customizations : Table.Customizations Ftab Msg
customizations =
    {
        tableAttrs = defaultCustomizations.tableAttrs
      , caption = defaultCustomizations.caption
      , thead = \_ -> Table.HtmlDetails [] []
      , tfoot = defaultCustomizations.tfoot
      , tbodyAttrs = defaultCustomizations.tbodyAttrs
      , rowAttrs = highlightSelectedRow
    }

invisibleColumn : String -> (data -> Int) -> Table.Column data msg
invisibleColumn name toInt =
    Table.veryCustomColumn
    {
        name = name,
        viewData = \_ -> Table.HtmlDetails [class "veryEmpty"] [],
        sorter = Table.decreasingBy toInt
    }

stringInvisibleColumn : String -> (data -> String) -> Table.Column data msg
stringInvisibleColumn name toStr =
    Table.veryCustomColumn
    {
        name = name,
        viewData = \_ -> Table.HtmlDetails [class "veryEmpty"] [],
        sorter = Table.decreasingBy toStr
    }

deleteButtonColumn: (Int -> msg) -> (data -> Int) -> Table.Column data msg
deleteButtonColumn msg toIndex =
    Table.veryCustomColumn
    {
      name = "delete",
      viewData = \x -> Table.HtmlDetails [onClick << msg << toIndex <| x ] [div [class "close"] [
          div [class "icon-container"] [i [class "fa fa-times-circle-o icon-close", attribute "aria-hidden" "true"][]]]],
      sorter = Table.unsortable
    }

{-clickable column for tabs name-}
clickableColumn : String -> (NameAndId -> Table.HtmlDetails msg) -> (data -> NameAndId) -> Table.Column data msg
clickableColumn name emitter toType =
  Table.veryCustomColumn
  {
    name = name,
    viewData = emitter << toType,
    sorter = Table.increasingOrDecreasingBy <| .name << toType
  }

-- limitted tabs name to 53 letters (artistic decisions)
prettyFormat : String -> String
prettyFormat str =
  if String.length str < 53 then
    str
  else
    String.left 53 str ++ "..."

clickableData : NameAndId -> Table.HtmlDetails Msg
clickableData x = Table.HtmlDetails [onClick (ClickFrom x.id)] 
                                    [ div [class "smallRow"] [Html.text (prettyFormat x.name)
                                    , br [] []
                                    , span [class "baseUrl"] [Html.text x.baseUrl]]]

selectedId : String
selectedId = "selected"

multiSel : String
multiSel = "multiSel"

highlightSelectedRow: Ftab -> List (Html.Attribute Msg)
highlightSelectedRow tab =
    let 
      one = if (tab.selected) then [id selectedId]
            else []
      two = if (tab.multiSel) then [class multiSel]
            else [] 
    in 
    List.append [onMouseEnter <| MouseIn tab.id
                , onMouseLeave <| Deselect tab.id] <| one ++ two

onKeyUp : (Int -> msg) -> Html.Attribute msg
onKeyUp tagger =
  onWithOptions "keyup" {defaultOptions | preventDefault = True} (Json.map tagger keyCode)

emmitUpDown : Int -> Msg
emmitUpDown keyCode = 
  case keyCode of
    38 -> KeyChangeSelect Up
    40 -> KeyChangeSelect Down
    13 -> KeyChangeSelect Enter
    _ -> None