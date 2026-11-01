(function () {
  var params = new URLSearchParams(window.location.search);
  var mode = params.get("mode");
  if (mode !== "anonymous") {
    return;
  }

  function clickSkip() {
    var nodes = document.querySelectorAll("a, button");
    for (var i = 0; i < nodes.length; i++) {
      var label = (nodes[i].innerText || nodes[i].textContent || "").trim();
      if (/skip.*anonym/i.test(label)) {
        nodes[i].click();
        return true;
      }
    }
    return false;
  }

  document.addEventListener("DOMContentLoaded", function () {
    if (clickSkip()) {
      return;
    }
    window.setTimeout(clickSkip, 800);
  });
})();
