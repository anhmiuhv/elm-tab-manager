port module Chrome exposing (..)

import Data exposing (Tab)
-- get all current tabs in the window
port getAllTabs: String -> Cmd msg

-- port for listening for all tabs from JavaScript
port allTabs : (List Tab -> msg) -> Sub msg

port highlight : Int -> Cmd msg

port close : Int -> Cmd msg
