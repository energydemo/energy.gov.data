jQuery("document").ready(function (event) {

    var source    = jQuery('#item-template').html();
    var template  = Handlebars.compile(source);
    var container = jQuery('#tagList');

    var source2d    = jQuery('#tag2d-template').html();
    var template2d  = Handlebars.compile(source2d);
    var container2d = jQuery('#tags2dContainer');

    var ajax = jQuery.ajax('keyword_counts.json', {dataType: "json"});

    // configuration
    var gradient = {
        0:    '#f00', // red
        0.33: '#ff0', // yellow
        0.66: '#0f0', // green
        1:    '#00f'  // blue
    };
    TagCanvas.dragControl = true;
    TagCanvas.initial = [0.02,-0.02];
    TagCanvas.maxSpeed = 0.02;
    TagCanvas.reverse = true;
    TagCanvas.weight = true;
    TagCanvas.weightGradient = gradient;
    TagCanvas.weightFrom = 'data-weight';
    TagCanvas.weightMode = 'both';
    TagCanvas.wheelZoom = false;

    // start the whole thing off with Ajax call
    ajax.done(function(rawdata) {
        var arry = rawdata.data;
        var filtered = arry.reduce(
            function(buffer, item, ii) {
                if (item.frequency >= 20) {
                    item.weight = Math.pow(Math.log(item.frequency), 2.4);
                    buffer.push(item);
                }
                return buffer;
            },
            []
        );

        // render list items
        jQuery.each(filtered, function(ii, item) {
            var rendered = template(item);
            container.append(rendered);
        });

        // fill tag canvas
        try {
            TagCanvas.Start('myCanvas', 'tagList');
        } catch(e) {
            // something went wrong, hide the canvas container
            // document.getElementById('myCanvasContainer').style.display = 'none';
            console.log('ERROR', e);
        }

        // render list items
        jQuery.each(arry, function(ii, item) {
            var rendered;

            item.fontsize = item.frequency / 19;
            rendered = template2d(item);
            container2d.append(rendered);
        });
    });

});
