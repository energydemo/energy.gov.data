jQuery("document").ready(function (event) {

    var source    = jQuery('#item-template').html();
    var template  = Handlebars.compile(source);
    var container = jQuery('#tagList');

    var source2d    = jQuery('#tag2d-template').html();
    var template2d  = Handlebars.compile(source2d);
    var container2d = jQuery('#tags2dContainer');

    // search for 'solar' tag at DOE; row count should be around 88
    // but set max to 200
    var ajax = jQuery.ajax(
        'https://catalog.data.gov/api/action/package_search?q=tags%3Asolar+AND+organization%3Adoe-gov&rows=200',
        {dataType: "json"}
    );

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
    ajax.done(function(data) {
        var getTagNames = function(result) {
            return result.tags.map(function(tag) {
                return tag.name;
            });
        };
        var tags = {};		// tag names to array of results
        var arry = [];		// array of {tag:..., frequency:...}

        // cycle through results and build tags map
        data.result.results.map(function(res) {
            var tagnames = getTagNames(res);
            tagnames.map(function(tag) {
                if ('solar' == tag) {
                    // do nothing - skip the "solar" tag
                } else if (tags[tag]) {
                    tags[tag].push(res);
                } else {
                    tags[tag] = [res]
                }
            });
        });

        // cycle through has and build array
        for (var t in tags) {
            var frq = tags[t].length;
            arry.push({
                tag: t,
                fontsize: 1 + frq/13,
                frequency: frq,
                weight: Math.pow(3 + Math.log(frq), 2.4)
            });
        }

        var filtered = arry.reduce(
            function(buffer, item, ii) {
                if (item.frequency > 2) {
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
            var rendered = template2d(item);
            container2d.append(rendered);
        });
    });

});
