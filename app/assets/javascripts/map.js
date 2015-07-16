
var vertexIcon = 'http://icons.iconarchive.com/icons/emey87/trainee/16/Bullseye-icon.png';



var query = location.search.substring(1);


var x = 0;
var y = 0;

var map;
var rooftop, Line, Vertex;
var vertices = [];
var markers = [];
var clickPT;


// split the rest at each "&" character to give a list of  "argname=value"  pairs
var pairs = query.split("&");
for (var i = 0; i < pairs.length; i++) {
    // break each pair at the first "=" to obtain the argname and value
    var pos = pairs[i].indexOf("=");
    var argname = pairs[i].substring(0, pos);
    var value = pairs[i].substring(pos + 1);

    // process each possible argname
    if (argname == "x") { x = parseFloat(value); }
    if (argname == "y") { y = parseFloat(value); }

}


function initialize() {
    var mapOptions = {
        zoom: 21,
        mapTypeId: google.maps.MapTypeId.SATELLITE,
        center: new google.maps.LatLng(y, x)
    };

    map = new google.maps.Map(document.getElementById('map-canvas'),
        mapOptions);
    map.setTilt(0);
    map.setOptions({ draggableCursor: 'crosshair' });

    var CenterMarker = new google.maps.Marker({
        position: map.getCenter(),
        map: map,
        title: 'Click to zoom'
    });


    google.maps.event.addListener(map, 'click', function (e) {
        placeMarker(e.latLng, map);
    });




    //wire up the results dialog
    $("#Results").dialog({
        autoOpen: false,
        resizable: false,
        buttons: {
            "Send": function () {
                alert("Send results to database here.");
                $(this).dialog("close");
                var g = map;
            }
        },
        dialogClass: "no-title",
        hide: {
            effect: "scale",
            easing: "easeInBack"
        },
        show: {
            effect: "scale",
            easing: "easeOutBack"
        }
    });

    function placeMarker(position, map) {
        if (rooftop != null) {
            rooftop.setMap(null);
        }

        var Vertex = new google.maps.Marker({
            position: position,
            icon: vertexIcon,
            map: map
        });


        vertices.push(Vertex.position);
        markers.push(Vertex);
        clickPT = position;


        if (vertices.length == 2) {
            Line = new google.maps.Polyline({
                path: vertices,
                geodesic: true,
                strokeColor: '#FF0000',
                strokeOpacity: 1.0,
                strokeWeight: 2
            });

            Line.setMap(map);
        }

        if (vertices.length > 2) {

            if (rooftop != null) {
                rooftop.setMap(null)
            }
            rooftop = new google.maps.Polygon({
                paths: vertices,
                clickable: false,
                strokeColor: '#FF0000',
                strokeOpacity: 0.8,
                strokeWeight: 2,
                fillColor: '#FF0000',
                fillOpacity: 0.35
            });

            google.maps.event.addListener(rooftop, 'click', function (e) {
                placeMarker(e.latLng, map);
            });

            rooftop.setMap(map);
        }

    }



}



google.maps.event.addDomListener(window, 'load', initialize);




function DoMeasure() {

    var polyPath = rooftop.getPath();


    if (polyPath != null) {
        var measurement = google.maps.geometry.spherical.computeArea(polyPath);
        var squareMeters = measurement.toFixed(2);
        var squareFeet = (squareMeters * 10.7639).toFixed(2);
        $("#divResult").html("Rooftop Area: " + squareFeet.toString() + " Sq Feet");
        $("#Results").dialog("open");

    }
    else {
        $("#divResult").html("Rooftop Area: 0 Sq Feet");
        $("#Results").dialog("open");
    }
}

function Undo() {

    for (var i = 0; i < markers.length; i++) {
        markers[i].setMap(null);
    }
    //  markers = null;

    vertices.pop();
    if (rooftop != null) {
        rooftop.setMap(null)
    }
    if (Line != null) {
        Line.setMap(null);
    }

    if (vertices.length < 2) {
        Line.setMap(null);
    }
    var verticesClone = [];
    for (var i = 0; i < vertices.length; i++) {
        var Vertex = new google.maps.Marker({
            position: vertices[i],
            icon: vertexIcon,
            map: map
        });


        verticesClone.push(Vertex.position);
        markers.push(Vertex);
    }

    vertices = verticesClone;
    verticesClone = null;



    if (vertices.length == 2) {
        Line = new google.maps.Polyline({
            path: vertices,
            geodesic: true,
            strokeColor: '#FF0000',
            strokeOpacity: 1.0,
            strokeWeight: 2
        });

        Line.setMap(map);
    }

    if (vertices.length > 2) {

        if (rooftop != null) {
            rooftop.setMap(null)
        }
        rooftop = new google.maps.Polygon({
            clickable: false,
            paths: vertices,
            strokeColor: '#FF0000',
            strokeOpacity: 0.8,
            strokeWeight: 2,
            fillColor: '#FF0000',
            fillOpacity: 0.35
        });

        rooftop.setMap(map);
    }


}