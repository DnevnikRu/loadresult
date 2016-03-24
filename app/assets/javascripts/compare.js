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

    $('tr').each(function (i, n) {
        if ($(n).children('.mean.trend').text() < -15) $(n).children('.mean').css('background-color', '#DFF5DF');
        if ($(n).children('.mean.trend').text() > 15) $(n).children('.mean').css('background-color', '#F5E0DF');

        if ($(n).children('.median.trend').text() < -15) $(n).children('.median').css('background-color', '#DFF5DF');
        if ($(n).children('.median.trend').text() > 15) $(n).children('.median').css('background-color', '#F5E0DF');

        if ($(n).children('.line90.trend').text() < -15) $(n).children('.line90').css('background-color', '#DFF5DF');
        if ($(n).children('.line90.trend').text() > 15) $(n).children('.line90').css('background-color', '#F5E0DF');

        if ($(n).children('.failed_request.trend').text() < -15) $(n).children('.failed_request').css('background-color', '#DFF5DF');
        if ($(n).children('.failed_request.trend').text() > 15) $(n).children('.failed_request').css('background-color', '#F5E0DF');
    });
});

$(function () {
    $('[data-toggle="tooltip"]').tooltip({
        'delay': {show: 1200, hide: 20}, container: 'body', placement: 'bottom', html: true
    });
});