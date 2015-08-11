var companyIndex = -1;
var boolNextOop = -1;
var companyData = "";
var boolSelect = -1;

function filter_date(selectDate){
	$.ajax({
		type: "GET",
		dataType: "json",
		url: "/date/" + encodeURIComponent(selectDate),
		success: function(data){
			var tbox = $("#contractor-selector");
			tbox.empty();
			var res = "";
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
		            res += "<button class='button-gallery' onclick='gallery(" + value.id + ")'>Gallery</button>";
		            res += "<button class='button-select' onclick='select(" + value.id + ");'>Select</button>";
		            res += "</div>";
		            res += "</div>";
				});
			}
			else{
				res += "<div id='company-valid'>";
            	res += "<p>Sorry!</p>";
            	res += "<p>There is no contractor company to service to you!</p>";
          		res += "</div>";
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
				if(data["result"].length > 0){
					companyData = data["result"];
					var resDetail = '';
					var resArea = '';
					$.each(data["result"], function(index, value) {
					resDetail = value.description;
					resArea = value.appro;
					resArea += " KM";
					});
					tDetail.append(resDetail);
					tArea.append(resArea);
					if(boolSelect == -1){
						tSelect.empty();
						tSelect.append('Welcome! Contractor is selected by you.');	
					}
					boolSelect = 0;
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
function submitService(){
	if( ( $("#custom-product-content").html() == "In Progress" || $("#custom-product-content").html() == "No Data!" ) && boolNextOop != 0 ){
		boolNextOop = 0;
		$('#next-button-valid').append("<p style='font-weight:bold;'>Oops!</p><p> You haven’t selected a contractor yet. Take a look through the list and select a contractor by clicking “select” next to the contractors name.</p>"); 
		return false;
	}
	else if( $("#custom-product-content").html() != "In Progress" || $("#custom-product-content").html() == "No Data!" ){
		alert(companyData);
		location.href = "/index";
	}
}

function gallery(index){
	$.ajax({
		type: "GET",
		dataType: "json",
		url: "/gallery/" + encodeURIComponent(index),
		success: function(data){
			if(data["galleryresult"].length > 0){
				$.each(data["galleryresult"], function(index, value) {
					alert(value.carousel);
				});
			}
		},
		error: function(req, status, err){
			console.log(status, err);
		}
	});
}