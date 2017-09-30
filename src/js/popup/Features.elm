module Features exposing (removeDuplicate)

import Data exposing (..)
import Dict exposing (..)

reconstructUnique: Ftab -> String
reconstructUnique ft = ft.name ++ ft.baseUrl ++ List.foldl (++) "" (keys ft.urlKeywords)
 
-- first list of the tuple is the remove list
removeDuplicate : List Ftab -> (List Ftab ,List Ftab)
removeDuplicate a = removeRecus a [] Dict.empty
            
removeRecus : List Ftab -> List Ftab -> Dict String Ftab -> (List Ftab, List Ftab)
removeRecus list rem dict = 
  case list of
    [] -> (rem, Dict.values dict)
    first :: remain -> 
      let
        unq = reconstructUnique first
        bol = Dict.member unq dict
        newr = if bol then first :: rem
            else rem
        newd = if bol then dict
            else Dict.insert unq first dict
      in removeRecus remain newr newd
