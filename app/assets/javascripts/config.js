$.getJSON("/configuration.json", function(data) {
    var OneClick = window.OneClick || {}
    if (typeof OneClick.Config == 'undefined') {
        OneClick.Config = {}
    }
    $.each(data, function(key, val) {
        OneClick.Config[key] = val
    })
})