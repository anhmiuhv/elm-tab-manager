import "../css/popup.css";
import hello from "./popup/example";
var Elm = require("./Main.elm")
require('../popup.html');

var mountPoint = document.getElementById("elm-mount")
var app = Elm.Main.embed(mountPoint)