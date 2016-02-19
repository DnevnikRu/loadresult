function showColumn(btn_name, column) {
    var btn = document.getElementById(btn_name);
    if (btn.checked) {
        $('.' + column).show();
    } else {
        $('.' + column).hide();
    }
}

$(document).ready(function () {
    $('.min').hide();
    $('.max').hide();
    $('.throughput').hide();
    $('.failed_request').hide();
});