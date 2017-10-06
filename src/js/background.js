import '../img/icon-128.png'
import '../img/icon.png'
import '../img/icon-48.png'

var dictionary = {}

chrome.tabs.onHighlighted.addListener((o) => {
	dictionary[o.tabIds[0].toString()] = Date.now()
	console.log(dictionary)
	if (Object.keys(dictionary).length > 1000) dictionary = {}
})

chrome.tabs.onRemoved.addListener((o) => {
	delete dictionary[o]
	console.log(o)
})

chrome.runtime.onMessage.addListener(
  function(request, sender, sendResponse) {
    console.log(sender.tab ?
                "from a content script:" + sender.tab.url :
                "from the extension");
    if (request.greeting == "hello")
      sendResponse({dictionary: dictionary});
  });