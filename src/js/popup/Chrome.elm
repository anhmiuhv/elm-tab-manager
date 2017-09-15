port module Chrome exposing (..)

import Data exposing (Tab)
-- get all current tabs in the window
port getAllTabs: String -> Cmd msg

-- port for listening for all tabs from JavaScript
port allTabs : (List Tab -> msg) -> Sub msg

-- highlight a tab. 'Int' is tabId
port highlight : Int -> Cmd msg

-- close a tab. 'Int' is tabId
port close : Int -> Cmd msg
