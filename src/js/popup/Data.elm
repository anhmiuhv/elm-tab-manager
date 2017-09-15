module Data exposing (..)
import Table
import List.Extra exposing (..)
import Maybe.Extra exposing (..)
import Regex
import Dict exposing (Dict)

type alias URLparsed = {
  baseURL : String ,
  others : List String
}
{-
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


type alias Tab =
    {
    id : Int,
    name : String,
    index: Int,
    url: String
    }

type Msg
  = SetQuery String
  | SetTableState Table.State
  | AllTabs (List Tab)
  | ClickFrom Int
  | CloseFrom Int


createNameAndId: Tab -> NameAndId
createNameAndId t = {
    name = t.name,
    id = t.id
 }

type alias NameAndId = {
  name: String,
  id: Int
 }
