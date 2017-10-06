port module Chrome exposing (..)
import Json.Decode as Decode
import Data exposing (Tab)
-- get all current tabs in the window
port getAllTabs: String -> Cmd msg

-- port for listening for all tabs from JavaScript
port allTabs : (List Tab -> msg) -> Sub msg

-- listen for highlight history
port highlightHist: (Decode.Value -> msg) -> Sub msg

port sortSetting: (String -> msg) -> Sub msg

port setSort: String -> Cmd msg

-- highlight a tab. 'Int' is tabId
port highlight : Int -> Cmd msg

-- close a tab. 'Int' is tabId
port close : Int -> Cmd msg

--scroll to selected
port scrolTo : Int -> Cmd msg

--close many tabs
port closeMany : List Int -> Cmd msg

