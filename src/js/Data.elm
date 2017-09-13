module Data exposing (tbs, Tab)

type alias Tab =
    {
    id : Int,
    name : String, 
    index: Int,
    url: String
}


tbs : List Tab
tbs = 
    [
    Tab 1 "Hello" 8 "www.edu.edu",
    Tab 23 "Besy" 2 "wpi.edu",
    Tab 43 "gh" 1 "google.com"
    ]