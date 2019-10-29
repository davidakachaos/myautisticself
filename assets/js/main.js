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


function showTranslation(){
  var getFirstBrowserLanguage = function () {
    var nav = window.navigator,
    browserLanguagePropertyKeys = ['language', 'browserLanguage', 'systemLanguage', 'userLanguage'],
    i,
    language;

    /* support for HTML 5.1 "navigator.languages" */
    if (Array.isArray(nav.languages)) {
      for (i = 0; i < nav.languages.length; i++) {
        language = nav.languages[i];
        if (language && language.length) {
          return language;
        }
      }
    }

    /* support for other well known properties in browsers */
    for (i = 0; i < browserLanguagePropertyKeys.length; i++) {
      language = nav[browserLanguagePropertyKeys[i]];
      if (language && language.length) {
        return language;
      }
    }

    return null;
  };

  $('.message .close')
    .on('click', function() {
      $(this)
        .closest('.message')
        .transition('fade')
      ;
      var cook_name = $(this).closest('.message').attr('id').split('-').join('');
      Cookies.set(cook_name, 'dontshow');
    })
  ;
  var pref_lang = getFirstBrowserLanguage().split('-')[0];
  $(document).ready(function(){
    var cook_val;
    if (document.documentElement.lang == 'nl') {
      cook_val = Cookies.get("langchangetoen");
    }else{
      cook_val = Cookies.get("langchangetonl");
    }
    if(cook_val == 'dontshow'){
      return;
    }else{
        $('#change-to-nl').attr("href", $('a.item.nl')[0].href);
        $('#change-to-en').attr("href", $('a.item.en')[0].href);
        if (pref_lang != document.documentElement.lang){
          $('#lang-change-to-' + pref_lang).show();
        }
    }
  });
}

defer(updateWebmentionCounts);
defer(showTranslation);