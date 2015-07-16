function initGeocode() {
    var geocoder;
    var autocomplete;
    function initialize() {
        //geocoder = new google.maps.Geocoder();
        autocomplete = new google.maps.places.Autocomplete(/** @type {HTMLInputElement} */(document.getElementById('address')), { types: ['geocode'] });
        google.maps.event.addListener(autocomplete, 'place_changed', function () {
            codeAddress();
        });
    }
    function codeAddress() {
        var place = autocomplete.getPlace();
        var latlng = place.geometry.location;
        location.href = "map.html?x=" + latlng.lng() + "&y=" + latlng.lat();
    }

    google.maps.event.addDomListener(window, 'load', initialize);
}