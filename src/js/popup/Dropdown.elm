module Dropdown exposing (..)

import Html.Attributes exposing (class, style, attribute)
import Html.Events exposing (onInput, onClick)
import Html exposing (..)
import Data exposing (..)
dropdown : Model ->  List (Html Msg)
dropdown model = [div [class "dropdown"]
                    [span [] [text "Option"]
                    , div [class "dropdown-content"] [p [onClick RemoveDuplicate] [text "Remove duplicate"]
                                                    , p [onClick MultiSel] [text "Multiple selection"]]
                    ]  
                , deleteButton <| transparent <| Tuple.first model.multiSel
                , div [class "filter"] [span [] [text "Filter"]]]

deleteButton : Attribute Msg -> Html Msg
deleteButton a = div [class "bigDeleteButton", a] [i [class "fa fa-trash", onClick CloseSelected, attribute "aria-hidden" "true"][]]

transparent : Bool -> Attribute Msg
transparent b = 
        let 
            val = if b then "1"
                    else "0"
        in style [("opacity", val)]