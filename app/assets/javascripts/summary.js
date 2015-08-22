var error = '';

function email_check()
{
	if( !isValidEmailAddress( $('#email').val() ) || !$('#email').val())
	{
		alert('Enter your email correctly!');
		$('#email').focus();
		return false;
	}
	else
	{
		alert('Email : ' + $('#email').val());	
		location.href = '/';
	}
	
}

function isValidEmailAddress(emailAddress) {
    var pattern = new RegExp(/^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/);
    return pattern.test(emailAddress);
}

function check_payment() {
    var re16digit = /^\d{16}$/;
    if (!re16digit.test( $('#card-number').val() ) ) {
        alert("Please enter your 16 digit credit card numbers");
        $('#card-number').focus();
        return false;
    }
    if(!check_expire( $('#month').val(), $('#day').val())){
    	alert(get_error() );
    	$('#month').focus();
    	return false;
    }
    if(!check_cv($('#cv').val())){
    	alert(get_error());
    	$('#cv').focus();
    	return false;
    }
    alert('card : ' + $('#card-number').val() + ' Expiry: ' + $('#month').val() + '/' + $('#day').val() + ' cv: ' + $('#cv').val() );
    location.href = '/';
}

function get_error()
{
	return error;
}

function check_expire(mon, day)
{
	mon = parseInt(mon);
	day = parseInt(day);
	
	if(mon.length == 0){
		error = 'Enter the month!';
		return false;
	}
	else if(!mon )
	{
		error = 'Month should be Number!';
		return false;
	}
	else if(mon == 0 || mon > 12){
		error = 'Enter correct month!';
		return false
	}

	if(day.length == 0){
		error = 'Enter the day!';
		return false;
	}
	else if(!day )
	{
		error = 'Day should be Number!';
		return false;
	}
	else if(day.length == 1){
		day = '0' + day;
		$('#day').val(day);
	}
	else if(day == 0)
	{
		error = 'Enter the correct day!';
		return false;
	}
	else if( mon % 2 == 1 &&  day > 31){
		error = 'Days of the month could not be over 31!';
		return false;
	}
	else if( mon % 2 == 0 && day > 30)
	{
		if(mon == 2 && day > 29){
			error = 'Days of the month could not be over 29!';
			return false;
		}
		error = 'Days of the month could not be over 30!';
		return false;
	}
	return true;
}

function check_cv(cv)
{
	if(cv.length == 0)
	{
		error = 'Enter the cv';
		return false;
	}
	else if( !parseInt(cv) ){
		error = 'CV should be Number!';
		return false;
	}
	return true;
}

function month()
{
	var mon = $('#month').val();
	if( mon.length == 1){
		mon = '0' + mon;
		$('#month').val(mon);
		return true;
	}
	else if(mon == 0){
		$('#month').val('');
		return false;
	}
	return true;
}
function day()
{
	var day = $('#day').val();
	if( day.length == 1){
		day = '0' + day;
		$('#day').val(day);
		return true;
	}
	else if(mon == 0){
		$('#day').val('');
		return false;
	}
	return true;
}