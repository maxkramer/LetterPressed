LetterPressed
=============

LetterPressed is a iOS (cheat) tool I created specifically for generating words that can be used in the iOS Game [LetterPress](https://itunes.apple.com/us/app/letterpress-word-game/id526619424?mt=8) by [Atebits](http://www.atebits.com/).

##Usage

The demo Xcode Project contained in the respository, when run, will install an application called 'LetterPressed' on your iOS Device. 

From there, open the application on your device, insert all letters on the grid into the textfield found at the top of the page, and hit return. Then wait for the magic to happen.

At the moment, all matching words are filtered by their length in descending order. To change this, comment the following line found in the `-locateMatches` method `in the 'ViewController.m' file. When commented out, the results will be ordered alphabetically in ascending order.

    - (void) locateMatches {
        ...
        [self filterMatches]; // comment out this line
       	...
    }



**NB: Please make sure that you are using iOS 5.0 or above as I cannot guarantee that the application will run smoothly on any devices lower.**

##Fin

That's a wrap. Any issues, please open an Issue on this page. Other than that, feel free to drop me a tweet [@_max_k](http://u.maxk.me/1syZ) or an email [hello[at]maxkramer.co](mailto:hello@maxkramer.co)

Enjoy!