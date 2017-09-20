module Helper exposing (analyseURL)

import Dict exposing (Dict)
import List.Extra exposing (getAt)
import Maybe.Extra exposing (join,(?))

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
   in (baseURL, dict)



