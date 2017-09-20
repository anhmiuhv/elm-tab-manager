-- update handler

module Update exposing (..)

import Data exposing (..)
import List.Extra exposing (updateIfIndex, (!!), updateAt)
import Chrome

keyChangeHandler : Model -> Direction -> (Model, Cmd Msg) 
keyChangeHandler model direction =
        let
            sel = model.selected
            len = List.length model.tabs

            changeSelectedPropTo : Bool -> Ftab -> Ftab
            changeSelectedPropTo bool = \t -> {t | selected = False}
            
            selectAnother i = model.tabs
                                |> updateIfIndex ((==) sel) (changeSelectedPropTo False)
                                |> updateIfIndex ((==) <| (sel - i) % len) (changeSelectedPropTo True)
              
          in case direction of
              Up -> ({ model | selected = (sel- 1) % len,
                               tabs = selectAnother 1
                               }, Chrome.scrolTo 1)
              Down -> ({model | selected = (sel + 1) % len,
                               tabs = selectAnother -1
                               }, Chrome.scrolTo 1)