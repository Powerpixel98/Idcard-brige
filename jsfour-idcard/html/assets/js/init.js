$(document).ready(function () {

  window.addEventListener('message', function (event) {

    if (event.data.action === 'open') {

      var type = event.data.type;
      var userData = event.data.array.user[0];

      // === LICENSES ROBUST LADEN (ARRAY ODER OBJECT) ===
      var rawLicenses = event.data.array.licenses || [];
      var licenses = Array.isArray(rawLicenses) ? rawLicenses : Object.values(rawLicenses);
      var hasLicenses = licenses.length > 0;

      var sex = userData.sex;

      /* =========================
         DRIVER (PERSO ODER FÜHRERSCHEIN)
         ========================= */
      if (type === 'driver') {

        $('img').show();
        $('#licenses').hide().html('');
        $('#name').css('color', '#282828');

        if (sex && sex.toLowerCase() === 'm') {
          $('img').attr('src', 'assets/images/male.png');
          $('#sex').text('male');
        } else {
          $('img').attr('src', 'assets/images/female.png');
          $('#sex').text('female');
        }

        $('#name').text(userData.firstname + ' ' + userData.lastname);
        $('#dob').text(userData.dateofbirth);
        $('#height').text(userData.height);
        $('#signature').text(userData.firstname + ' ' + userData.lastname);

        /* ===== PERSONALAUSWEIS ===== */
        if (!hasLicenses) {

          $('#id-card').css('background', 'url(assets/images/idcard.png)');

        }

        /* ===== FÜHRERSCHEIN ===== */
        else {

          $('#licenses').show().html('');

          licenses.forEach(function (lic) {

            var ltype = lic.type;

            if (ltype === 'drive') ltype = 'car';
            else if (ltype === 'drive_bike') ltype = 'bike';
            else if (ltype === 'drive_truck') ltype = 'truck';
            else if (ltype === 'drive_bus') ltype = 'bus';
            else if (ltype === 'drive_plane') ltype = 'plane';
            else if (ltype === 'drive_boat') ltype = 'boat';
            else return;

            $('#licenses').append('<p>' + ltype + '</p>');
          });

          $('#id-card').css('background', 'url(assets/images/license.png)');
        }
      }

      /* =========================
         WAFFENSCHEIN
         ========================= */
      else if (type === 'weapon') {

        $('img').hide();
        $('#licenses').hide().html('');
        $('#sex').text('');

        $('#name').css('color', '#d9d9d9');
        $('#name').text(userData.firstname + ' ' + userData.lastname);
        $('#dob').text(userData.dateofbirth);
        $('#signature').text(userData.firstname + ' ' + userData.lastname);

        $('#id-card').css('background', 'url(assets/images/firearm.png)');
      }

      $('#id-card').show();

        } else if (event.data.action === 'close') {

      $('#name').text('');
      $('#dob').text('');
      $('#height').text('');
      $('#signature').text('');
      $('#sex').text('');
      $('#licenses').hide().html('');
      $('#id-card').hide();
    }

  }); // ✅ message listener schließen

  // ESC / BACKSPACE schließt den Ausweis
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' || e.key === 'Backspace') {
      e.preventDefault();

      $('#id-card').hide();
      $('#licenses').hide().html('');

      $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}));
    }
  });

});


