## Appcelerator Card.io Module

Appcelerator wrapper for the Card.io credit card scanning library. Use the phone's camera to read credit card numbers and expiration dates.

### Using the module

#### Android

Methods:
* setCardIOLogo(bool)
* setPayPalLogo(bool)
* setLocale(String)
* scanCard()

Events:
* complete
* error

#### iOS
* scanCard(callback)

See example/app.js for usage.

### Building iOS from source

If you need to rebuild the iOS module from source, you will need to add the card.io library yourself. 

The required header files are present, so you just need to [download the SDK](https://github.com/card-io/card.io-iOS-SDK) from card.io and then unzip and move the libCardIO.a file into the CardIO folder in the iphone directory.

After that you may or may not need to re-add that file in XCode.

_Additionally, don't forget to update titanium.xcconfig with your SDK path._
