module Search exposing (..)

import Data exposing (..)
import Regex exposing (..)
import List.Extra exposing (..)



search : List Tab -> List String -> List (Tab, Int)
search tabs keywords =
  let
    re = caseInsensitive <| regex <| "\\b(" ++ String.join "|" keywords ++ ")"
    countMatches = List.length << Regex.find All re << .name
    indexes = List.map countMatches tabs
    tup = zip tabs indexes
  in
    List.filter (((/=) 0) << Tuple.second) tup
