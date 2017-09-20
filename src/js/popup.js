import "../css/popup.sass"
import $ from 'jquery'
import Elm from "./popup/Main.elm"

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

app.ports.scrolTo.subscribe((s) => {
    $(() => {
        const dest = $('#selected')
        if (!isScrolledIntoView("#selected"))
            $(window).scrollTop(dest.offset().top + dest.outerHeight(true) - $(window).height())
    })
})

const isScrolledIntoView = (elem) =>
{
    const docViewTop = $(window).scrollTop()
    const docViewBottom = docViewTop + $(window).height()
    const elemTop = $(elem).offset().top
    const elemBottom = elemTop + $(elem).height()
    return ((elemBottom <= docViewBottom) && (elemTop >= docViewTop))
}