"use strict";

var currentSearchTerm = '';

onload = function onload() {
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
    setTimeout(function () {
      defer(method);
    }, 250);
  }
}

function deferMailChimp(method) {
  if (window.dojoRequire) {
    method();
  } else {
    setTimeout(function () {
      deferMailChimp(method);
    }, 500);
  }
}

function loadTruePush() {
  if (window.truepush) {
    truepush.push(function () {
      truepush.Init({
        id: "5e96e8cf39eeb37a3a6bfa8d"
      }, function (error) {
        if (error) console.error(error);
      });
    });
  } else {
    setTimeout(function () {
      loadTruePush();
    }, 300);
  }
}

function updateWebmentionCounts() {
  var urls = [];
  var base;
  $("*[data-webmention-count]").each(function (i, e) {
    var parser = document.createElement('a');
    parser.href = $(e).data('url');
    base = parser.protocol + "//" + parser.hostname;
    urls.push(parser.pathname + parser.search);
  });
  $.getJSON("https://webmention.io/api/count", {
    base: base,
    targets: urls.join(",")
  }, function (data) {
    $("*[data-webmention-count]").each(function (i, e) {
      $(e).text(data.count[$(e).data('url')]);
    });
  });
}

;

function subscribeFBLike() {
  if (typeof FB !== "undefined") {
    FB.Event.subscribe('edge.create', function (url) {
      ga('send', 'social', 'facebook', 'like', url);
    });
  } else {
    setTimeout(subscribeFBLike, 250);
  }
}

function callFB() {
  window.fbAsyncInit = function () {
    FB.init({
      appId: '482973958831772',
      // App ID
      // channelURL : '//WWW.YOUR_DOMAIN.COM/channel.html', // Channel File
      status: true,
      // check login status
      cookie: true,
      // enable cookies to allow the server to access the session
      oauth: false,
      // enable OAuth 2.0
      xfbml: true,
      // parse XFBML
      autoLogAppEvents: true,
      version: 'v6.0'
    }); // Additional initialization code here
  }; // Load the SDK Asynchronously


  (function (d) {
    var js,
        id = 'facebook-jssdk';

    if (d.getElementById(id)) {
      return;
    }

    js = d.createElement('script');
    js.id = id;
    js.async = true;
    js.defer = true;
    js.crossorigin = "anonymous";

    if (document.documentElement.lang == "nl") {
      js.src = "https://connect.facebook.net/nl_NL/sdk.js";
    } else {
      js.src = "https://connect.facebook.net/en_US/sdk.js";
    }

    d.getElementsByTagName('head')[0].appendChild(js);
  })(document);
}

function loadMailChimp() {
  window.dojoRequire(["mojo/signup-forms/Loader"], function (L) {
    L.start({
      "baseUrl": "mc.us3.list-manage.com",
      "uuid": "25d2d8c9b20b892603f68fb5e",
      "lid": "4f8fedd4d3",
      "uniqueMethods": true
    });
  });
} // *** TO BE CUSTOMISED ***


var style_cookie_name = "style";
var style_cookie_duration = 30; // *** END OF CUSTOMISABLE SECTION ***
// You do not need to customise anything below this line

function switch_style(css_title) {
  // You may use this script on your site free of charge provided
  // you do not remove this notice or the URL below. Script from
  // https://www.thesitewizard.com/javascripts/change-style-sheets.shtml
  // console.log('Switching style -> ' + css_title);
  var i, link_tag;

  for (i = 0, link_tag = document.getElementsByTagName("link"); i < link_tag.length; i++) {
    if (link_tag[i].rel.indexOf("stylesheet") != -1 && link_tag[i].title) {
      link_tag[i].disabled = true;

      if (link_tag[i].title == css_title) {
        link_tag[i].disabled = false;
      }
    }
  }

  set_cookie("style", css_title, 30, '');
}

function set_style_from_cookie() {
  var css_title = get_cookie("style");
  console.log('Found style: ' + css_title);

  if (css_title.length) {
    switch_style(css_title);
  }
}

function set_cookie(cookie_name, cookie_value, lifespan_in_days, valid_domain) {
  // https://www.thesitewizard.com/javascripts/cookies.shtml
  var domain_string = valid_domain ? "; domain=" + valid_domain : '';
  console.log('Setting style cookie');
  var content = cookie_name + "=" + encodeURIComponent(cookie_value) + "; max-age=" + 60 * 60 * 24 * lifespan_in_days + "; path=/" + domain_string + "; SameSite=Strict;";
  console.log('Adding; ' + content);
  document.cookie = content;
  console.log(document.cookie);
}

function get_cookie(cookie_name) {
  // https://www.thesitewizard.com/javascripts/cookies.shtml
  var cookie_string = document.cookie;

  if (cookie_string.length != 0) {
    var cookie_array = cookie_string.split('; ');
    var i, cookie_value;

    for (i = 0; i < cookie_array.length; i++) {
      cookie_value = cookie_array[i].match(cookie_name + '=(.*)');

      if (cookie_value != null) {
        return decodeURIComponent(cookie_value[1]);
      }
    }
  }

  return '';
}

function r(f) {
  /in/.test(document.readyState) ? setTimeout(r, 9, f) : f();
} // r(function(){/*code to run*/});


deferMailChimp(loadMailChimp);
loadTruePush();
r(updateWebmentionCounts); // r(showTranslation);

r(callFB);
r(subscribeFBLike);
r(set_style_from_cookie);