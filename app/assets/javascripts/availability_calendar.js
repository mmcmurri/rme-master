(function() {
  $("#availability-calendar").fullCalendar({
    eventClick: function(calEvent, jsEvent, view) {
      window.location.href = window.location.href.replace(
        /[\?#].*|$/, "?booking=" + calEvent.title
      );
    }
  });
  $("#booking_date").datepicker();

  var form = document.getElementById("booking-form");
  var bookingSubmitter = document.getElementById("booking-submitter");
  bookingSubmitter.addEventListener("click", function bookingSubmitterClicked() {
    form.submit();
  });

  var inputs = form.getElementsByTagName("input");
  document.getElementById("edit-booking-activator")
    .addEventListener("click", function() {
      for (var i = 0, len = inputs.length; i < len; ++i) {
        var input = inputs[i];
        if (input.id !== "booking_id") {
          input.readOnly = false;
        }
      }
    }
  );

  initCalendar();
  function initCalendar() {
    var bookings = JSON.parse(
      document.getElementById("bookings-data").innerText
    );
    for (var i = 0, len = bookings.length; i < len; ++i) {
      var booking = bookings[i];
      if (booking["date"] === null) {
        continue;
      }

      $("#availability-calendar").fullCalendar("addEventSource", [
        {title: booking["id"], start: booking["date"], color: "orange"}
      ]);
    }
  }
})();

