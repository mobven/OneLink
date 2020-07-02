import UIKit

let url = URL(string: "https://bkt.com/cards/retailer/?id=12312&blah=21")!

print(url.path)
print(url.pathComponents)
print(url.query!)

print(url.absoluteString)
