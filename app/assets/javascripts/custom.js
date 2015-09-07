var companyIndex = -1;
var boolNextOop = -1;
var companyData = "";
var boolSelect = -1;
var galleryIndex = -1;
var contractor_count = 0;

function filter_date(selectDate){
	$.ajax({
		type: "GET",
		dataType: "json",
		url: "/date/" + encodeURIComponent(selectDate),
		success: function(data){
			var tbox = $("#contractor-selector");
			tbox.empty();
			var res = "";
			var galleryImgs;
			if(data["dateresult"].length > 0){
				$.each(data["dateresult"], function(index, value){
					res += "<div class='contractor-box'>";
		            res += "<div class='company-logo'>";
		            res += "<div class='logo-img'><img src='assets/" + value.logo + "' />"
		            res += "</div>";
		            res += "</div>";
		            res += "<div class='company-info'>";
		            res += "<div class='company-name'>" +  value.name +"</div>";
		            res += "<div class='company-desc'>" + value.description + "</div>";
		            res += "<div class='company-certif'>";
		            if(value.certi1) 
		                res += "<img src='assets/" + value.certi1 +"' />";
		            else
		             	res += "<div class='certifi-img'></div>";
		                 
		            if(value.certi2) 
		                res += "<img src='assets/" + value.certi2 + "' class='last-img' />";
		            else 
		                res += "<div class='certifi-img last-img'></div>";
		               
		            res += "</div>";
		            res += "</div>";
		            res += "<div class='company-controller'>";
		            res += "<div class='wrap-gallery-btm" + value.id + "'>";
		            galleryImgs = value.carousel.split(",");
                  	res += "<a href='assets/" + galleryImgs[0] + "' class='gallery click-btn button-gallery'>Gallery</a>";
                  	for(var i = 1; i < galleryImgs.length; i++)
                	{
                		res += "<a class='gallery' href='assets/" + galleryImgs[i] + "'></a>";
                	}
                	res += "</div>";
               	 	res += "<a href='#' class='click-btn button-select' onclick='select(" + value.id + ");'>Select</a>";
		            res += "</div>";
		            res += "</div>";
				});
				res += "<script type='text/javascript' src='assets/featherlight.min.js' charset='utf-8'></script>";
  				res += "<script type='text/javascript' src='assets/featherlight.gallery.min.js' charset='utf-8'></script>";
				res += "<script type='text/javascript'>var wrap;for(var i = 1; i <= " + galleryImgs.length + "; i ++){wrap = '';wrap = '.wrap-gallery-btm';wrap += i;wrap += ' .gallery';$(wrap).featherlightGallery({gallery: {fadeIn: 100,fadeOut: 100,next: '&#9664;',previous: '&#9654'},openSpeed:    300,closeSpeed:   300,variant: 'featherlight-gallery'});} </script>";
			}
			else{
				res += "<div id='company-valid'>";
            	res += "<p>Sorry!</p>";
            	res += "<p>There is no contractor company to service to you!</p>";
          		res += "</div>";
          		contractor_count = 0;
			}
			tbox.append(res);
		},
		error: function(req, status, err) {console.log(status, err);}
	});
}

function select(index){	
	companyIndex = index;
	$.ajax({
			type: "GET",
			dataType: "json",
			url: "/custom/" + encodeURIComponent(index),
			success: function(data){
				var tDetail = $("#custom-product-content");
				var tArea = $("#custom-area-content");
				var tSelect = $("#custom-consel-content");
				tDetail.empty();
				tArea.empty();
				tSelect.empty();
				if(data["result"].length > 0){
					var resDetail = '';
					var resArea = '';
					var resName = '';
					$.each(data["result"], function(index, value) {
						companyData = value;
						resDetail = value.description;
						resName = value.name;
						resArea = value.appro;
						resArea += " KM";
					});
					tDetail.append(resDetail);
					tArea.append(resArea);
					tSelect.append(resName);	
				}
				else{
					tDetail.append('No Data!');
					tArea.append('No Data!');
					tSelect.append('No Data!');
				}
			},
			error: function( req, status, err ) {
				console.log( 'something went wrong', status, err );
			}
		});
}
function submitService(date){
	console.log(date);
	
	if( ( $("#custom-product-content").html() == "In Progress" || $("#custom-product-content").html() == "No Data!" ) && boolNextOop != 0 ){
		boolNextOop = 0;
		$('#next-button-valid').append("<p style='font-weight:bold;'>Oops!</p><p> You haven’t selected a contractor yet. Take a look through the list and select a contractor by clicking “select” next to the contractors name.</p>"); 
		return false;
	}
	else if( $("#custom-product-content").html() != "In Progress" || $("#custom-product-content").html() == "No Data!" ){
		var url = "summary/" + encodeURIComponent(companyData.name) + "/" + encodeURIComponent(date);
		location.href = url;
	}
}

function set_contractor_count(setCount){
	contractor_count = setCount;
}

function get_contractor_count(){
	return contractor_count;
}