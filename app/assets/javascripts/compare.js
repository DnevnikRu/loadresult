function showColumn(btn_name, column) {
    var btn = document.getElementById(btn_name);
    var request_table = $('div#collapseRequestsData');
    if (btn.checked) {
        request_table.find('.' + column).show();
    } else {
        request_table.find('.' + column).hide();
    }
}

$(document).ready(function () {
    var request_table = $('div#collapseRequestsData');
    request_table.find('.min').hide();
    request_table.find('.max').hide();
    request_table.find('.throughput').hide();
    request_table.find('.failed_request').hide();

    $('td.trend').each(function (i, n) {
        if ($(n).text() < -15) $(n).css('background-color', '#DFF5DF');
        if ($(n).text() > 15) $(n).css('background-color', '#F5E0DF');
    });
});

$(function () {
    $('[data-toggle="tooltip"]').tooltip({
        'delay': {show: 1200, hide: 20}, container: 'body', placement: 'bottom', html: true
    });
});

$(document).ready(function () {
    $('.sticky-header').stickyTableHeaders({cacheHeaderHeight: true});
});
