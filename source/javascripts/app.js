var sendEmail = function (formData){

    let userData = getUserData ();

    userData.formData = formData;

    $.post( "https://hooks.zapier.com/hooks/catch/178342/9pofo2/", userData, function( data ) {
        window.location.replace("/response");
    });

}

var calculateTestResult = function (formData) {
    var total = 0;

    $.each(formData.domanda, function(key, value) {

        total += (value*1);

    });

    return total
}


var saveUserData = function (formData, total) {

    let response = getResponse(total);

    let userData = {
        nome_cognome: formData.nome_cognome,
        email: formData.email,
        risultatoTest: total,
        response: response
    }

    localStorage.setItem("userData", JSON.stringify(userData));

    return userData;
}

var getResponse = function (total){

    let response = {
        message: 'Non sei a rischio',
        code: 'no_rischio'
    }

    if (total >= 8 && total<= 15 ){
        response.message = 'Ci sono dei segnali';
        response.code = 'moderato';
    }

    if (total >=16 ){
        response.message = 'Sei a Rischio';
        response.code = 'rischio';
    }

    return response;

}


$( "#formTestJquery" ).submit(function( event ) {

    event.preventDefault();

    var formData = $('form#formTestJquery').serializeObject();

    let total = calculateTestResult (formData);
    let datiUtente = saveUserData (formData, total);


    sendEmail (formData);

});

var getUserData = function (){
    return JSON.parse(localStorage.getItem("userData"))
}

var showResponse = function (){
    let userData = getUserData();

    if (userData == null){
        window.location.replace("/");
    }

    let responseCode = userData.response.code;

    let templateUrl = '/templates/' + responseCode

    console.log (userData);

    $('.message').html(userData.response.message);
    $('.nome_cognome').html(userData.nome_cognome);

    $( "input[name=nome_cognome]" ).val(userData.nome_cognome);
    $( "input[name=email]" ).val(userData.email);
    $( "input[name=risultatoTest]" ).val(userData.risultatoTest);

    $.get(templateUrl, function(template) {
        var rendered = Mustache.render(template, userData);
        $('#risultato').html(rendered);
    });

    console.log (responseCode)
}
