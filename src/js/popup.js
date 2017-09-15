import "../css/popup.sass";
const Elm = require("./popup/Main.elm")

const mountPoint = document.getElementById("elm-mount")
const app = Elm.Main.embed(mountPoint)

// get tabs ports
app.ports.getAllTabs.subscribe((s) => {
    chrome.tabs.query({windowId: chrome.windows.WINDOW_ID_CURRENT}, (ts) => {
        app.ports.allTabs.send(ts.map((t) => {
            const r = {
                id: t.id,
                name: t.title || "Empty Tab",
                url: t.url || "www.example.com",
                index: t.index
            }
            return r
        }))
    })
})


app.ports.highlight.subscribe((s) => {
    chrome.tabs.get(s, (t) => {
      chrome.tabs.highlight({tabs:t.index})
    })

})

app.ports.close.subscribe((s) => {
    chrome.tabs.remove (s)
})
