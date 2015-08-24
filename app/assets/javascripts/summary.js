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
