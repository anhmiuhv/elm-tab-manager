module Dropdown exposing (..)

import Html.Attributes exposing (class)
import Html.Events exposing (onInput, onClick)
import Html exposing (..)
import Data exposing (..)
dropdown : Html Msg
dropdown = div [class "dropdown"]
            [span [] [text "Option"]
            , div [class "dropdown-content"] [p [onClick RemoveDuplicate] [text "Remove duplicate..."]
                                            , p [onClick MultiSel] [text "Multi Select on..."]]
            ]
