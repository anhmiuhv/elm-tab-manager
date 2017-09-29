module Data exposing (..)
import Table
import Helper
import Dict exposing (Dict, fromList, keys)
import Focus
import Set exposing (Set)

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
  selected: Bool
}

createNameAndId: Ftab -> NameAndId
createNameAndId t = 
  {
    name = t.name,
    id = t.id
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
  | RemoveDuplicate
  | MultiSel
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