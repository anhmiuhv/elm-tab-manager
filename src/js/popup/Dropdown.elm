module Dropdown exposing (dropdown, deleteButton)

import Html.Attributes exposing (class, style, attribute)
import Html.Events exposing (onInput, onClick)
import Html exposing (..)
import Data exposing (..)
import Table
dropdown : Model ->  List (Html Msg)
dropdown model = 
    let
        multiMode = Tuple.first model.multiSel
        indexMode = isInMode model "Index"
        highMode = isInMode model "LastHighlight"
        urlMode = isInMode model "BaseURL"
    in
        [div [class "dropdown"]
                    [span [] [text "Option"]
                    , div [class "dropdown-content"] [p [onClick RemoveDuplicate] [text "Remove duplicate"]
                                                    , p [onClick MultiSel, bold multiMode] [text "Multiple selection"]]
                    ]  
        , deleteButton <| transparent multiMode
        , div [class "filter"] 
                    [span [] [text "Filter and Sort"]
                    , div [class "dropdown-content"] [ p [bold indexMode, onClick <| SetTableState <| Table.initialSort "Index"]
                                                        [text "Sort by order"]
                                                     , p [bold highMode, onClick <| SetTableState <| Table.initialSort "LastHighlight"] 
                                                        [text "Sort by last view"]
                                                     , p [bold urlMode, onClick <| SetTableState <| Table.initialSort "BaseURL"] 
                                                        [text "Sort by url"]
                                                      ]]
            ]

deleteButton : Attribute Msg -> Html Msg
deleteButton a = div [class "bigDeleteButton", a] [i [class "fa fa-trash", onClick CloseSelected, attribute "aria-hidden" "true"][]]

thisIf : String -> Bool -> String -> String -> Attribute Msg
thisIf attr cond trueR falseR =
    if cond then style [(attr, trueR)]
    else style [(attr, falseR)]

infixr 9 :?

transparent : Bool -> Attribute Msg
transparent b = thisIf "opacity" b "1" "0"


isInMode : Model -> String -> Bool
isInMode model s = (stateHead model.tableState) == s

bold: Bool -> Attribute Msg
bold b = thisIf "font-weight"  b "bold" "normal"