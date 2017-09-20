module Data exposing (..)
import Table
import Helper
import Dict exposing (Dict)

type alias URLparsed = {
  baseURL : String ,
  others : List String
}

type alias Model =
    {
    tabs : List Ftab
    , tableState : Table.State
    , query : String
    , selected : List Int
    }

type alias Tab =
    {
    id : Int,
    name : String,
    index: Int,
    url: String
    }

type alias Ftab = {
  id : Int,
  name : String,
  index: Int,
  baseUrl: String,
  urlKeywords: Dict String Int,
  selected: Bool
}

createNameAndId: Ftab -> NameAndId
createNameAndId t = 
  {
    name = t.name,
    id = t.id
  }

type Direction = Up | Down
type Msg
  = SetQuery String
  | SetTableState Table.State
  | AllTabs (List Tab)
  | ClickFrom Int
  | CloseFrom Int
  | KeyChangeSelect Direction
  | None

-- Helper function for creating types
createFtab : Tab -> Ftab
createFtab tab =
  let
    analyzed = Helper.analyseURL tab.url
  in
    Ftab tab.id tab.name tab.index (Tuple.first analyzed) (Tuple.second analyzed) False


type alias NameAndId = {
  name: String,
  id: Int
}
