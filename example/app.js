var cardio = require('com.likelysoft.cardio');

var win = Ti.UI.createWindow({
    backgroundColor: 'white'
});

var button = Ti.UI.createButton({
    title: 'Scan Card'
});

cardio.addEventListener("complete", function(data) {
    // NOTE this is for demonstration only, never log the
    // complete credit card number. Use redactedCardNumber
    // instead.
    Ti.API.info("Card number: " + data.cardNumber);
    Ti.API.info("Redacted card number: " + data.redactedCardNumber);
    Ti.API.info("Expiration month: " + data.expiryMonth);
    Ti.API.info("Expiration year: " + data.expiryYear);
    Ti.API.info("CVV code: " + data.cvv);
});

cardio.addEventListener("error", function(e) {
    console.log("error");
});

button.addEventListener('click', function() {
    // Setup card settings:
    cardio.setCardIOLogo(false);
    cardio.setPaypalLogo(true);
    cardio.setGuideColor("#FAA81A");
    cardio.setLocale("de");
    cardio.setCollectCVV(true);
    
    // Open modal scanner window
    cardio.scanCard();
});

win.add(button);
win.open();
