module Data exposing (..)
import Table
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
