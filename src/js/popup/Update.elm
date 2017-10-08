-- update handler

module Update exposing (..)

import Data exposing (..)
import Features exposing (..)
import List.Extra exposing (find)
import Chrome
import Set
import Table
import Search
import Dict
import Focus

keyChangeHandler : Model -> What -> (Model, Cmd Msg) 
keyChangeHandler model what =
          let
            actualval deltaSel d =
              case deltaSel of
                -1000000 -> 0
                _ -> deltaSel + d
              
          in
              
           case what of
              Up -> ({ model |  deltaSel =  actualval model.deltaSel -1}, Chrome.scrolTo 1)
              Down -> ({model |  deltaSel = actualval model.deltaSel 1}, Chrome.scrolTo 1)
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
  ( { model | query = newQuery}
      , Cmd.none
      )

setTableStateHandler : Table.State -> Model -> (Model, Cmd Msg)
setTableStateHandler newState model =
  ( { model | tableState = newState}
      , Chrome.setSort <| stateHead newState
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

highlightHistHandler : Model -> Dict.Dict String Int -> (Model, Cmd Msg)
highlightHistHandler m a =
  let
            transform : Ftab -> Ftab
            transform b = 
                case Dict.get (toString b.id) a of
                    Just i -> {b | lastHighlight = i}
                    _ -> b
            
        in      
            {m | tabs = List.map transform m.tabs } ! []