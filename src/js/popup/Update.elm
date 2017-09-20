-- update handler

module Update exposing (..)

import Data exposing (..)
import List.Extra exposing (find)
import Chrome
import Search

keyChangeHandler : Model -> What -> (Model, Cmd Msg) 
keyChangeHandler model what =
        let
            sel = model.selected

          in case what of
              Up -> ({ model | selected = sel- 1}, Chrome.scrolTo 1)
              Down -> ({model | selected = sel + 1}, Chrome.scrolTo 1)
              Enter ->
                let
                   selectedTabs =  Search.queryToListTab model
                in case find (\x -> x.selected) selectedTabs of
                  Just t -> (model, Chrome.highlight t.id)
                  Nothing -> (model, Cmd.none)