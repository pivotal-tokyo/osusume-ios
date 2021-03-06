import Nimble
import XCTest

@testable import Osusume

class RestaurantParserTest: XCTestCase {

    // MARK: parseList
    func test_parsingMultipleRestaurants() {
        let restaurantParser = RestaurantParser()

        let json: [[String: AnyObject]] = [
            [
                "name": "first restaurant",
                "id": 1,
                "address": "",
                "cuisine_type": "",
                "notes": "notes",
                "created_at": "2016-02-29T06:07:55.000Z",
                "user": ["name": "Bambi"],
                "photo_urls": [
                    ["id": 10, "url": "http://www.example.com"]
                ]
            ],
            [
                "name": "second restaurant",
                "id": 2,
                "address": "",
                "cuisine_type": "",
                "notes": "notes",
                "created_at": "2016-02-29T06:07:55.000Z",
                "user": ["name": "Bambi"],
                "photo_urls": [
                    ["id": 20, "url": "http://www.example.com"]
                ]
            ]
        ]

        let restaurants: [Restaurant] = restaurantParser.parseList(json).value!

        expect(restaurants.count).to(equal(2))
        expect(restaurants[0].name).to(equal("first restaurant"))
        expect(restaurants[0].cuisineType).to(equal(""))
        expect(restaurants[1].name).to(equal("second restaurant"))
        expect(restaurants[0].createdAt).to(equal(NSDate(timeIntervalSince1970: 1456726075)))
    }

    func test_parsingMultipleRestaurants_omittingRestaurantsWithBadData() {
        let restaurantParser = RestaurantParser()

        let json: [[String: AnyObject]] = [
            ["id": 1, "name": "first restaurant"],
            ["bad": "data"]
        ]

        let result = restaurantParser.parseList(json)
        expect(result.error).to(beNil())

        let restaurants = result.value!
        expect(restaurants.count).to(equal(1))
    }

    func test_parsingMultipleRestaurantsWithbadData_returnsNil() {
        let restaurantParser = RestaurantParser()

        let json: [[String: AnyObject]] = [
            [
                "bad": "data",
                "id": 1,
            ],
            [
                "name": "second restaurant",
                "really bad": "data",
            ]
        ]

        let result = restaurantParser.parseList(json)
        expect(result.error).to(beNil())
    }

    // MARK: parseSingle
    func test_parsingASingleRestaurantWithMultipleComments() {
        let restaurantParser = RestaurantParser()

        let json: [String: AnyObject] = [
            "name": "first restaurant",
            "id": 1232,
            "comments": [
                [
                    "id": 1,
                    "comment": "first comment",
                    "created_at": "2016-02-29T06:07:55.000Z",
                    "restaurant_id": 1232,
                    "user": [
                        "id": 100,
                        "name": "Witta"
                    ]
                ],
                [
                    "id": 2,
                    "comment": "second comment",
                    "created_at": "2016-02-29T06:07:59.000Z",
                    "restaurant_id": 1232,
                    "user": [
                        "id": 200,
                        "name": "Danny"
                    ]
                ]
            ]
        ]

        let restaurant: Restaurant = restaurantParser.parseSingle(json).value!
        let expectedFirstComment = PersistedComment(
            id: 1,
            text: "first comment",
            createdDate: NSDate(timeIntervalSince1970: 1456726075),
            restaurantId: 1232,
            userId: 100,
            userName: "Witta"
        )
        expect(restaurant.comments[0]).to(equal(expectedFirstComment))

        let expectedSecondComment = PersistedComment(
            id: 2,
            text: "second comment",
            createdDate: NSDate(timeIntervalSince1970: 1456726079),
            restaurantId: 1232,
            userId: 200,
            userName: "Danny"
        )
        expect(restaurant.comments[1]).to(equal(expectedSecondComment))
    }

    func test_parse_handlesLikeStatus() {
        let restaurantParser = RestaurantParser()

        let json: [String: AnyObject] = [
            "id": 1232,
            "name": "liked restaurant",
            "liked": true
        ]


        let restaurant = restaurantParser.parseSingle(json).value!

        expect(restaurant.liked).to(equal(true))
    }

    func test_parse_handlesNumberOfLikes() {
        let restaurantParser = RestaurantParser()

        let json: [String: AnyObject] = [
            "id": 1232,
            "name": "Restaurant liked by several people",
            "num_likes": 3
        ]


        let restaurant = restaurantParser.parseSingle(json).value!


        expect(restaurant.numberOfLikes).to(equal(3))
    }

    func test_parse_handlesUnlikeStatus() {
        let restaurantParser = RestaurantParser()

        let json: [String: AnyObject] = [
            "id": 1232,
            "name": "liked restaurant",
            "liked": false
        ]


        let restaurant = restaurantParser.parseSingle(json).value!

        expect(restaurant.liked).to(equal(false))
    }

    func test_parse_handlesCreatedByUser() {
        let restaurantParser = RestaurantParser()

        let json: [String: AnyObject] = [
            "id": 1232,
            "name": "Any restaurant",
            "user" : [
                "id": 100,
                "name": "Danny",
                "email": "danny@pivotal.io"
            ]
        ]


        let restaurant = restaurantParser.parseSingle(json).value!


        expect(restaurant.createdByUser.id).to(equal(100))
        expect(restaurant.createdByUser.name).to(equal("Danny"))
        expect(restaurant.createdByUser.email).to(equal("danny@pivotal.io"))
    }

    func test_parse_handlesCuisine() {
        let restaurantParser = RestaurantParser()

        let json: [String: AnyObject] = [
            "id": 1232,
            "name": "liked restaurant",
            "cuisine": [
                "id": 1,
                "name": "Italian"
            ]
        ]


        let restaurant = restaurantParser.parseSingle(json).value!


        let actualCuisine = restaurant.cuisine
        expect(actualCuisine.id).to(equal(1))
        expect(actualCuisine.name).to(equal("Italian"))
    }

    func test_parse_handlesPriceRange() {
        let restaurantParser = RestaurantParser()

        let json: [String: AnyObject] = [
            "id": 1232,
            "name": "liked restaurant",
            "price_range": [
                "id": 1,
                "range": "0~999"
            ]
        ]


        let restaurant = restaurantParser.parseSingle(json).value!


        let expectedPriceRange = PriceRange(id: 1, range: "0~999")
        expect(restaurant.priceRange).to(equal(expectedPriceRange))
    }

    func test_parse_handlesNearestStation() {
        let restaurantParser = RestaurantParser()

        let json: [String: AnyObject] = [
            "id": 1232,
            "name": "liked restaurant",
            "nearest_station": "Shinjuku"        ]


        let restaurant = restaurantParser.parseSingle(json).value!


        expect(restaurant.nearestStation).to(equal("Shinjuku"))
    }

    func test_parsingASingleRestaurant_withoutComments() {
        let restaurantParser = RestaurantParser()

        let json: [String: AnyObject] = [
            "name": "first restaurant",
            "id": 1232,
            "address": "",
            "cuisine_type": "",
            "created_at": "2016-02-03T06:18:40.000Z",
            "photo_urls": [
                ["id": 10, "url": "http://www.example.com"],
                ["id": 11, "url": "my-awesome-url"]
            ],
            "comments": [
            ]
        ]

        let restaurant = restaurantParser.parseSingle(json).value!
        expect(restaurant.name).to(equal("first restaurant"))
        expect(restaurant.createdAt!).to(equal(NSDate(timeIntervalSince1970: 1454480320)))
        expect(restaurant.photoUrls[0].url.absoluteString).to(equal("http://www.example.com"))
        expect(restaurant.photoUrls[1].url.absoluteString).to(equal("my-awesome-url"))
        expect(restaurant.comments.count).to(equal(0))
    }

    func test_parsingASingleRestaurant_skipsInvalidComments() {
        let restaurantParser = RestaurantParser()

        let json: [String: AnyObject] = [
            "name": "first restaurant",
            "id": 1,
            "comments": [
                [
                    "id": 1,
                    "comment": "first comment",
                    "created_at": "2016-02-29T06:07:55.000Z",
                    "restaurant_id": 9,
                    "user": [
                        "id": 100,
                        "name": "Witta"
                    ]
                ],
                [
                    "id": 2,
                    "comment": "second comment",
                    "created_at": "2016-02-29T06:07:55.000Z",
                    "restaurant_id": 9,
                    "user": [
                        "id": 100,
                        "name": "Witta"
                    ]
                ],
                [ "bad": "commentData"]
            ]
        ]

        let restaurant: Restaurant = restaurantParser.parseSingle(json).value!
        expect(restaurant.comments.count).to(equal(2))
    }

    func test_parsingASingleRestaurant_onFailure() {
        let restaurantParser = RestaurantParser()

        let json: [String: AnyObject] = [ "bad": "data" ]

        let parseError: RestaurantParseError = restaurantParser.parseSingle(json).error!

        expect(parseError).to(equal(RestaurantParseError.InvalidField))
    }

    func test_convert_usesDefaultsWhenOptionalFieldsAreMissing() {
        let restaurantParser = RestaurantParser()
        let json: [String: AnyObject] = ["name": "first restaurant", "id": 1]

        let restaurant = restaurantParser.parseSingle(json).value!
        expect(restaurant.address).to(equal(""))
        expect(restaurant.createdAt).to(beNil())
    }

    func test_parsingASingleRestaurant_withPhotoUrls() {
        let restaurantParser = RestaurantParser()

        let json: [String: AnyObject] = [
            "id": -1,
            "name": "Name",
            "photo_urls": [
                ["id": 123, "url": "http://www.example.com"],
                ["id": 234, "url": "my-awesome-url"]
            ]
        ]

        let restaurant = restaurantParser.parseSingle(json).value!
        expect(restaurant.photoUrls[0].id).to(equal(123))
        expect(restaurant.photoUrls[0].url.absoluteString).to(equal("http://www.example.com"))
        expect(restaurant.photoUrls[1].id).to(equal(234))
        expect(restaurant.photoUrls[1].url.absoluteString).to(equal("my-awesome-url"))
    }

}
