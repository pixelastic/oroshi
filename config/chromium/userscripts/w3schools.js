// ==UserScript==
// @name        Remove w3schools.com from Google
// @namespace   http://www.pixelastic.com
// @include     https://www.google.com/*
// @include     https://www.google.fr/*
// @version     1
// @grant       none
// ==/UserScript==

// Load jQuery first
function addJQuery(callback) {
    var script = document.createElement("script");
    script.setAttribute("src", "//cdnjs.cloudflare.com/ajax/libs/jquery/2.1.4/jquery.min.js");
    script.addEventListener('load', function() {
        var script = document.createElement("script");
        script.textContent = "window.jQ=jQuery.noConflict(true);(" + callback.toString() + ")();";
        document.body.appendChild(script);
    }, false);
    document.body.appendChild(script);
}

function main() {
    var $ = jQ;
    $('cite').each(function(index, element) {
        element = $(element);
        if (element.text().indexOf('www.w3schools.com') === -1) {
            return;
        }
        $(element.closest('.g')[0].remove());
    }); 
}

addJQuery(main);
