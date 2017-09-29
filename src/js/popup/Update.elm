-- update handler

module Update exposing (..)

import Data exposing (..)
import List.Extra exposing (find)
import Chrome
import Table
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

removeDupHandler : Model -> (Model, Cmd Msg)
removeDupHandler model =
    let
      (remList, keepList) = removeDuplicate model.tabs
    in {model | tabs = keepList} ! [Chrome.closeMany <| Debug.log "list" <| List.map (.id) remList]

setQueryHandler : String -> Model -> (Model , Cmd Msg)
setQueryHandler newQuery model = 
  ( { model | query = newQuery, selected = -1 }
      , Cmd.none
      )

setTableStateHandler : Table.State -> Model -> (Model, Cmd Msg)
setTableStateHandler newState model =
  ( { model | tableState = newState }
      , Cmd.none
      )

allTabsHandler : List Tab -> Model -> (Model, Cmd Msg)
allTabsHandler tabs model =
     ( {model | tabs = (List.map createFtab tabs), query = ""} 
      , Cmd.none
      )

closeFromHandler : Int -> Model -> (Model, Cmd Msg)
closeFromHandler id model =
  ( { model | tabs = List.filter (((/=) id) << .id) model.tabs }
      , Chrome.close id
      )