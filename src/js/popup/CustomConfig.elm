module CustomConfig exposing (..)
import Html exposing (i, div)
import Html.Attributes exposing (class, attribute)
import Html.Events exposing (onClick)
import Table exposing (defaultCustomizations)
import Data exposing (..)

-- remove thead, otherwise use popup.sass for design
customizations : Table.Customizations data msg
customizations =
    {
        tableAttrs = defaultCustomizations.tableAttrs
      , caption = defaultCustomizations.caption
      , thead = \_ -> Table.HtmlDetails [] []
      , tfoot = defaultCustomizations.tfoot
      , tbodyAttrs = defaultCustomizations.tbodyAttrs
      , rowAttrs = defaultCustomizations.rowAttrs
    }

{-invisible Column-}
invisibleColumn : String -> (data -> Int) -> Table.Column data msg
invisibleColumn name toInt =
    Table.customColumn
    {
        name = name,
        viewData = \_ -> "",
        sorter = Table.increasingOrDecreasingBy toInt
    }

{- delete buttons-}
deleteButtonColumn: (Int -> msg) -> (data -> Int) -> Table.Column data msg
deleteButtonColumn msg toIndex =
    Table.veryCustomColumn
    {
      name = "delete",
      viewData = \x -> Table.HtmlDetails [onClick << msg << toIndex <| x ] [div [class "close"] [
          i [class "fa fa-times-circle-o icon-close", attribute "aria-hidden" "true"][]]],
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
clickableData x = Table.HtmlDetails [onClick (ClickFrom x.id)] [ Html.text (prettyFormat x.name) ]


--$("<i>", {"class": "fa fa-times-circle-o icon-close ", "data-index": index, "aria-hidden": "true"}
