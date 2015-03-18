$("document").ready(function (event) {

    var ajax = jQuery.ajax('keyword_counts.json', {dataType: "json"});
    ajax.done(function(rawdata) {
        var arry = rawdata.data;
        var filtered = arry.reduce(
            function(buffer, item, ii) {
                if (item.frequency > 10) {
                    buffer.push(item);
                }
                return buffer;
            },
            []
        );

        $("#tagcloud").ejTagCloud({
            dataSource: filtered,
            titleText: "Dept. of Energy Data Tags"
        });

    });

});
