module CustomConfig exposing (..)

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

