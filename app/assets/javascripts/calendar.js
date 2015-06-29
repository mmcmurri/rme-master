var jobIDNumber = 1; 
var eventCollects    = new Array();
              
function validateInputData(){
    
        if($('#jobID').val() == "" ) {
                prompt("JobID wasn't created... You can create the NewJob by clicking the Add Booking.");
                return false;
            }
        if($('#startDate').val() == ""){
                prompt("startDate wasn't created...");
                return false;
            } 
        if($('#teamSize').val() == ""){
                prompt("teamSize wasn't created...");
                return false;
            }  
        if($('#address').val() == ""){
                prompt("address wasn't created...");
                return false;
            }  
        if($('#city').val() == "" ){
                prompt("city wasn't created...");
                return false;
            }  
        if($('#country').val() == ""){
                prompt("country wasn't created...");
                return false;
            }  
        if($('#customerName').val() == ""){
                prompt("customerName wasn't created...");
                return false;
            }  
        if($('#phone').val() == ""){                                                                               
                prompt("phone wasn't created...");
                return false;
            }  
        if($('#source').val() == ""){
                prompt("SourceData wasn't referenced...");
                return false;
            }  
        return true;
    };     
                
function set_associated_data(){    
    
        alert("New JobID will be created automatically.");    
                        
        document.getElementById("jobID").value = jobIDNumber;    
        document.getElementById("startDate").value = "";
        document.getElementById("teamSize").value = "";
        document.getElementById("address").value = "";
        document.getElementById("city").value = "";
        document.getElementById("country").value = "";
        document.getElementById("customerName").value = "";
        document.getElementById("phone").value = "";
};            

$(document).ready(function(){
    
    $('#calendar').fullCalendar({     
        
        theme: true,
        editable: true,    
        selectable: true,
        selectHelper: true,     
        editable: true,
        
        header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month,agendaWeek,agendaDay'
            },
        events: eventCollects,
        dayClick: function(date, jsEvent, view) {
            document.getElementById("startDate").value = date.format();
        }
    });
        
    $('#savingCommand').click(function(){  
        
            if(validateInputData()){
                
                var job_id = $('#jobID').val();    
                var team_size = $('#teamSize').val();
                
                $("ul").append("<li>Job" + job_id +" - " + team_size + "People" + "<a href='javascript:void(0);' class='remove'>               Remove</a></li>"); 
                $("ul li").addClass('job-log');
                
                jobIDNumber++; 
                
                var newEvent = new Object();
                newEvent.title = $('#customerName').val();                                                     
                newEvent.start = $('#startDate').val();
                newEvent.allDay = false;
                
                $('#calendar').fullCalendar( 'renderEvent', newEvent );  
            }
            
            var sepEvent = [$('#customerName').val(), $('#startDate').val()];    
            
    });    
        
    $(document).on("click", "a.remove" , function() {
        
            $(this).parent().remove();
            
    });                   
      
});  