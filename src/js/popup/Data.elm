module Data exposing (..)
import Table
import Helper
import Dict exposing (Dict, fromList, keys)
import Focus
import Set exposing (Set)
import Json.Decode as Decode


type alias URLparsed = {
  baseURL : String ,
  others : List String
}

type alias Model =
    {
    tabs : List Ftab
    , tableState : Table.State
    , query : String
    , selected : Int
    , deselect : Int
    , deltaSel : Int
    , multiSel : (Bool, Set Int)
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
  selected: Bool,
  multiSel: Bool,
  lastHighlight: Int
}

createNameAndId: Ftab -> NameAndId
createNameAndId t = 
  {
    name = t.name,
    id = t.id,
    baseUrl = t.baseUrl
  }

type What = Up | Down | Enter
type Msg
  = SetQuery String
  | SetTableState Table.State
  | AllTabs (List Tab)
  | ClickFrom Int
  | CloseFrom Int
  | KeyChangeSelect What
  | MouseIn Int
  | Deselect Int
  | CloseSelected
  | RemoveDuplicate
  | MultiSel
  | HighlightHist (Dict String Int)
  | None

-- Helper function for creating types
createFtab : Tab -> Ftab
createFtab tab =
  let
    analyzed = Helper.analyseURL tab.url
  in
    Ftab tab.id tab.name tab.index (Tuple.first analyzed) (Tuple.second analyzed) False False 0


type alias NameAndId = {
  name: String,
  id: Int, 
  baseUrl: String
}

multiSelSet : Focus.Focus Model (Set Int)
multiSelSet = 
  let
    update : (Set Int -> Set Int) -> Model -> Model
    update fun model = {model | multiSel = (Tuple.first model.multiSel
                                            , model.multiSel
                                                |> Tuple.second 
                                                |> fun )}
      
  in
    Focus.create (\x -> Tuple.second x.multiSel) update

multiSelBol : Focus.Focus Model Bool
multiSelBol =
  let
    update : (Bool -> Bool) -> Model -> Model
    update fun model = {model | multiSel = (model.multiSel
                                              |> Tuple.first 
                                              |> fun
                                            , Set.empty)}
  in
    Focus.create (\x->Tuple.first x.multiSel) update

decodeHist : Decode.Value -> Result String (Dict String Int)
decodeHist =
    Decode.decodeValue (Decode.dict Decode.int)

toHighlightHist : Result String (Dict String Int) -> Msg
toHighlightHist result =
    case result of
        Ok a -> HighlightHist a
        _ -> None


stateHead : Table.State -> String
stateHead (Table.State s b) = s

stateTail : Table.State -> Bool
stateTail (Table.State s b) = b

titleToFunc : String -> Table.Sorter Ftab
titleToFunc s =
  case s of
    "Index" -> Table.Increasing <| List.sortBy .index
    "LastHighlight" -> Table.Increasing <| List.sortBy .lastHighlight
    "BaseURL" -> Table.Increasing <| List.sortBy .baseUrl
    _ -> Table.Increasing <| List.sortBy .baseUrl