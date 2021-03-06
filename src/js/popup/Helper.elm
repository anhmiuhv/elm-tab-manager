module Helper exposing (analyseURL, maybeInsert, (:?), (?))

import Dict exposing (Dict)
import List.Extra exposing (getAt)
import Maybe.Extra exposing (join,(?))
import Set exposing (Set)

import Regex
{-
spit out nicely formatted url. 'String' is the URL
regex spit format
       $1 = http:
       $2 = http
       $3 = //www.ics.uci.edu
       $4 = www.ics.uci.edu
       $5 = /pub/ietf/uri/
       $6 = <undefined>
       $7 = <undefined>
       $8 = #Related
       $9 = Related
-}

regexURL : Regex.Regex
regexURL = Regex.regex "^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?"


analyseURL: String -> (String, Dict String Int)
analyseURL url =
  let
    answer = case List.head <| Regex.find Regex.All regexURL url of
                   Just a -> a.submatches
                   Nothing -> []
    baseURL = (join <| getAt 3 answer) ? ""
    dict = (join <| getAt 4 answer) ? ""
               |> String.split "/"
               |> List.map (\x -> (x, 1))
               |> Dict.fromList
    dict2 = baseURL
              |> String.words
              |> List.map (\x -> (x,1))
              |> Dict.fromList

   in (baseURL, Dict.union dict dict2)

maybeInsert : Int -> Set Int -> Set Int
maybeInsert i s = if (Set.member i s) then Set.remove i s
                  else Set.insert i s

-- syntaxtic sugar if else then
(:?) : Bool -> a -> Maybe a
(:?) bol trC = if bol then Just trC
                else Nothing

-- syntaxtic sugar if else then
(?) : Maybe a -> a -> a
(?) mx x =
    Maybe.withDefault x mx
