-- update handler

module Update exposing (..)

import Data exposing (..)
import Features exposing (..)
import List.Extra exposing (find)
import Chrome
import Set
import Table
import Search
import Focus

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
    in {model | tabs = keepList} ! [Chrome.closeMany <| List.map (.id) remList]

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

closeSelectedHandler : Model -> (Model, Cmd Msg)
closeSelectedHandler model =
    let
      closeSet = Focus.get multiSelSet model
    in ({model | tabs = List.filter (\x->not <| Set.member x.id closeSet) model.tabs},  Chrome.closeMany <| Set.toList closeSet)