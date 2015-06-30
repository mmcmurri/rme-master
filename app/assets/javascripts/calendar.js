var jobIDNumber = 1;  
        var registeredId;                                
        var eventCollects    = new Array();
        
        function initialInputData(){
                
                if($('#jobID').val() == "" ) {
                        alert("JobID wasn't created... You can create the NewJob by clicking the Add Booking.");
                        return false;
                    }  
                if($('#startDate').val() == ""){
                    alert("StartDate wasn't created...");
                    return false;
                }
                if($('#teamSize').val() == ""){
                        alert("TeamSize wasn't created...");
                        return false;
                    }  
                if($('#address').val() == ""){
                        alert("Address wasn't created...");
                        return false;
                    }  
                if($('#city').val() == "" ){
                        alert("City wasn't created...");
                        return false;
                    }  
                if($('#country').val() == ""){
                        alert("Country wasn't created...");
                        return false;
                    }  
                if($('#customerName').val() == ""){
                        alert("CustomerName wasn't created...");
                        return false;
                    }  
                if($('#phone').val() == ""){                                                                               
                        alert("Phone wasn't created...");
                        return false;
                    }  
                if($('#source').val() == ""){
                        alert("SourceData wasn't referenced...");
                        return false;
                    }  
                return true;
            };     
                        
        function set_associated_data(){    
            
                document.getElementById("jobID").value = jobIDNumber;
                alert("New JobID was created automatically.");          
                registeredId = jobIDNumber;
                document.getElementById("teamSize").value = "";
                document.getElementById("address").value = "";
                document.getElementById("city").value = "";
                document.getElementById("country").value = "";
                document.getElementById("customerName").value = "";
                document.getElementById("phone").value = "";
        }; 
        
        function  insert_eventlist(){
            
        }          
        
        $(document).ready(function(){    
            
            $('#calendar').fullCalendar({     
                
                theme: true,
                editable: true,    
                selectable: true,
                selectHelper: true,     
                editable: true,
                
                header: {
                    left: 'prev',
                    center: 'title', 
                    right: 'next'
                    },
                <!-- --> 
                eventClick: function (calEvent, jsEvent, view) {
                    $('#calendar').fullCalendar('removeEvents', function (calEvent) {
                        return true;
                    });
                },

                dayClick: function(date, jsEvent, view) {

                    document.getElementById("startDate").value = date.format();

                }
            });
                
            $('#savingCommand').click(function(){  
                    if(initialInputData()){    
                        
                        var jobId = $('#jobID').val();    
                        var teamSize = $('#teamSize').val();    
                        var startDate = $('#startDate').val();    
                        var address = $('#address').val();    
                        var city = $('#city').val();    
                        var country = $('#country').val();    
                        var customerNumber = $('#customerNumber').val();    
                        var phone = $('#phone').val();    
                        var source = $('#source').val();
                        
                        insert_eventlist();
                        $("ul").append("<li>Job" + jobId +" - " + team_size + "People" + "</li>"); 
                        $("ul li").addClass('job-log'); 
                            
                        var newEvent = new Object();
                        newEvent.id = jobId;
                        newEvent.title = $('#customerName').val();                         
                        newEvent.start = $('#startDate').val();
                        newEvent.allDay = false;                            
                        $('#calendar').fullCalendar( 'renderEvent', newEvent );   
                        jobIDNumber++;  
                    }   
                           
            });    
            
            $('#editBooking').click(function(){  
                var editEventId = prompt("Enter your JobId you want to edit. : ", "your name here");
                alert(editEventId );                           
            }); 
                
            $(document).on("click", "a.remove" , function() {    
                    $(this).parent().remove()  
            });                   
              
        }); 