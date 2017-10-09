module Search exposing (queryToListTab)

import Data exposing (..)
import Regex exposing (..)
import List.Extra exposing (..)
import Maybe.Extra exposing ((?))
import Focus
import Dict
import Table
import Set

{- heuristics search using splitted words from user queries
  2 point for each exact words match for name and url
  1 point for substring match for name-}

search : List Ftab -> List String -> List (Ftab, Int)
search tabs keywords =
  let
    re = "\\b(" ++ String.join "|" keywords ++ ")"
            |> regex 
            |> caseInsensitive 
    re2 = String.join "" keywords
            |> regex
            |> caseInsensitive
    countMatches = List.length << Regex.find All re << .name
    countMatches2 = List.length << Regex.find All re2 << .name
    countMatches3 = List.length << Regex.find All re << String.join " " << Dict.keys << .urlKeywords
    indexes = List.map (((*) 2) << countMatches) tabs
    indexes2 = List.map countMatches2 tabs
    indexes3 = List.map countMatches3 tabs
    total = (\a b c -> a + b + c)
              |> flip List.map indexes2
              |> andMap indexes
              |> andMap indexes3
    tup = zip tabs total
  in
    List.filter (((/=) 0) << Tuple.second) tup


{- produce a querried list of tabs using model-}
queryToListTab : Model -> List Ftab
queryToListTab model = 
    let
        keywords =
          String.words << String.toLower << Regex.escape <| model.query
        multi = Focus.get multiSelSet model
        querriedTabs =
            if model.query == "" then model.tabs
            else
               search model.tabs keywords
                  |> List.map (\(t, i) -> ({t | index = i}, i))
                  |> List.map Tuple.first
        sortedTabs = Table.applySorter (stateTail model.tableState)
                                            (titleToFunc <| stateHead model.tableState)
                                             querriedTabs
        index = findIndex (\x -> x.id == model.selected) sortedTabs ? 0      
    in List.indexedMap (\i t -> {t | selected = (model.deltaSel /= -1000000)  
                                    && ((model.deltaSel + index) % (List.length sortedTabs)) == i
                                    , multiSel = Set.member t.id multi}) sortedTabs 
                             
        