var currentSearchTerm = '';

onload = function () {
   var e = document.getElementById('search-input');
   e.oninput = changeHandler;
   e.onpropertychange = e.oninput;
    document.getElementById('search-input').addEventListener('keyup', handleKeyPress);
};

function changeHandler(e) {
    currentSearchTerm = e.target.value;
}

function handleKeyPress(e) {
    if (e && e.key === 'Enter') {
        handleSubmit();
    }
}

function handleSubmit() {
    window.open('https://www.google.com/search?q=site:' + window.location.hostname + ' ' + currentSearchTerm);
}

function defer(method) {
    if (window.jQuery) {
        method();
    } else {
        setTimeout(function() { defer(method) }, 50);
    }
}

function updateWebmentionCounts(){
  var urls = [];
  var base;

  $("*[data-webmention-count]").each(function(i,e){
    var parser = document.createElement('a');
    parser.href = $(e).data('url');
    base = parser.protocol + "//" + parser.hostname;
    urls.push(parser.pathname+parser.search);
  });

  $.getJSON("https://webmention.io/api/count", {
    base: base,
    targets: urls.join(",")
  }, function(data){
    $("*[data-webmention-count]").each(function(i,e){
      $(e).text(data.count[$(e).data('url')]);
    });
  });
};

defer(updateWebmentionCounts);