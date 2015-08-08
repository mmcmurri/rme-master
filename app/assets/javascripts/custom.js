var companyIndex = -1;
var boolNextOop = -1;
var companyData = "";
var boolSelect = -1;
var customAddress = "50.30.20.30";
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
						$("#custom-address-content").empty();
						tSelect.append('Welcome! Contractor is selected by you.');
						$("#custom-address-content").append(customAddress);
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
	if( $("#custom-product-content").html() == "In Progress" && boolNextOop != 0 ){
		boolNextOop = 0;
		$('#next-button-valid').append("<p style='font-weight:bold;'>Oops!</p><p> You haven’t selected a contractor yet. Take a look through the list and select a contractor by clicking “select” next to the contractors name.</p>"); 
		return false;
	}
	else if( $("#custom-product-content").html() != "In Progress" ){
		alert(companyData);
		location.href = "/index";
	}
}