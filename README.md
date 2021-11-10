## BTC-USD

##Goal
Build an iOS app that displays a live BTC/USD order book from the Bitfinex API.

## Challenge description
You will use the Bitfinex API to display different information on the screen. The top part should contain a summary of the BTCUSD pair (last price, volume, low, high, change), followed by the live order-book using a WebSocket. These information are available on the Bitfinex documentation at

[1] for the ticker and

[2] for the order-book.
Use the attached screenshot as an example (ignore trades tab), but feel free to be creative with your own UI!

[1] https://docs.bitfinex.com/v1/reference#ws-public-ticker

[2] https://docs.bitfinex.com/v1/reference#ws-public-order-books

## Suggestions
- use RxSwift. It could perhaps be useful in this case.
- use as many external libraries as you need. Cocoapods is our dependency manager.- We like beautiful User Interfaces but you are not asked to spend time on the UI. However, feel free to be creative!
- App should be resilient to network errors.
- Consider implementing some unit tests for your code.

## Languages, libraries and tools used

 * [Swift](https://www.swift.org)
 * [UIkIt](https://developer.apple.com/documentation/uikit/)
 * [Starscream](https://github.com/daltoniam/Starscream)
 * [RxSwift](https://github.com/ReactiveX/RxSwift)
 * [RxCocoa](https://github.com/ReactiveX/RxSwift)
 * MVVM architecture


## Screenshots
<img width="300" alt="Screenshot 2021-11-09 at 08 59 19" src="https://user-images.githubusercontent.com/20171941/141124044-451c1fc0-5ee2-4a26-97bc-9b42675fc4fa.png">
<img width="300" alt="Screenshot 2021-11-10 at 14 38 45" src="https://user-images.githubusercontent.com/20171941/141124051-0e71c23b-cd08-40de-9897-98a4e1fd7640.png">

