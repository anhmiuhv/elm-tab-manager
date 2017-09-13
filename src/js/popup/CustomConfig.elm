module CustomConfig exposing (..)
import Html exposing (i)
import Html.Attributes exposing (class, attribute)
import Table exposing (defaultCustomizations)

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


invisibleColumn : String -> (data -> Int) -> Table.Column data msg
invisibleColumn name toInt =
    Table.customColumn 
    {
        name = name,
        viewData = \_ -> "",
        sorter = Table.increasingOrDecreasingBy toInt
    }


deleteButtonColumn: Table.Column data msg
deleteButtonColumn = 
    Table.veryCustomColumn
    {
      name = "delete",
      viewData = \_ -> Table.HtmlDetails [] [i [class "fa fa-times-circle-o icon-close", attribute "aria-hidden" "true"][]],
      sorter = Table.unsortable
    }

--$("<i>", {"class": "fa fa-times-circle-o icon-close ", "data-index": index, "aria-hidden": "true"}
