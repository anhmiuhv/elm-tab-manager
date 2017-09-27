module Dropdown exposing (..)

import Html.Attributes exposing (class)
import Html.Events exposing (onInput, onClick)
import Html exposing (..)

dropdown : Html msg
dropdown = div [class "dropdown"]
            [span [] [text "Edit"]
            , div [class "dropdown-content"] [p [] [text "Remove duplicate..."]]
            ]
