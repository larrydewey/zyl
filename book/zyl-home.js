// Adds a link from the book's menu bar back to the Zyl site one level above the book.
(function () {
    var bar = document.querySelector('.right-buttons');
    if (!bar || typeof path_to_root === 'undefined') return;
    var a = document.createElement('a');
    a.href = path_to_root + '../';
    a.title = 'Zyl home';
    a.setAttribute('aria-label', 'Zyl home');
    a.textContent = 'zyl home';
    a.style.cssText = 'font-family: ui-monospace, monospace; font-size: 0.8em; margin-right: 0.8em; text-decoration: none;';
    bar.insertBefore(a, bar.firstChild);
})();
