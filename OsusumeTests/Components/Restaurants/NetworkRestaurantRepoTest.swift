import XCTest
import BrightFutures

@testable import Osusume

class NetworkRestaurantRepoTest: XCTestCase {
    let fakeHttp = FakeHttp()
    let fakeSessionRepo = FakeSessionRepo()
    var networkRestaurantRepo: NetworkRestaurantRepo!

    override func setUp() {
        let restaurantListRepo = NetworkRestaurantListRepo(
            http: fakeHttp,
            parser: RestaurantParser()
        )

        networkRestaurantRepo = NetworkRestaurantRepo(
            http: fakeHttp,
            restaurantListRepo: restaurantListRepo
        )
    }

    func test_getAll_hitsExpectedEndpoint() {
        networkRestaurantRepo.getAll()


        XCTAssertEqual("/restaurants", fakeHttp.get_args.path)
    }

    func test_getOne_hitsExpectedEndpoint() {
        networkRestaurantRepo.getOne(999)


        XCTAssertEqual("/restaurants/999", fakeHttp.get_args.path)
    }

    func test_create_formatsBodyWithRestaurantData() {
        networkRestaurantRepo.create(
            NewRestaurant(
                name: "Danny's Diner",
                address: "123 Main Street",
                placeId: "abcd",
                latitude: 1.23,
                longitude: 2.34,
                cuisine: Cuisine(id: 9, name: "Creole"),
                priceRange: PriceRange(id: 1, range: "Range"),
                nearestStation: "Roppongi",
                notes: "So good",
                photoUrls: ["my-cool-url", "my-awesome-url"]
            )
        )

        let actualRestaurantParams = fakeHttp.post_args.parameters["restaurant"]!

        XCTAssertEqual("/restaurants", fakeHttp.post_args.path)
        XCTAssertEqual("Danny's Diner", actualRestaurantParams["name"])
        XCTAssertEqual("123 Main Street", actualRestaurantParams["address"])
        XCTAssertEqual("abcd", actualRestaurantParams["place_id"])
        XCTAssertEqual(1.23, actualRestaurantParams["latitude"])
        XCTAssertEqual(2.34, actualRestaurantParams["longitude"])
        XCTAssertEqual("Creole", actualRestaurantParams["cuisine_type"])
        XCTAssertEqual(9, actualRestaurantParams["cuisine_id"])
        XCTAssertEqual(1, actualRestaurantParams["price_range_id"])
        XCTAssertEqual("Roppongi", actualRestaurantParams["nearest_station"])
        XCTAssertEqual("So good", actualRestaurantParams["notes"])
        XCTAssertEqual([["url": "my-cool-url"], ["url": "my-awesome-url"]], actualRestaurantParams["photo_urls"])
    }

    func test_update_formatsBodyWithRestaurantData() {
        networkRestaurantRepo.update(
            999,
            params: [
                "name":  "Danny's Diner",
                "address":  "123 Main Street",
                "place_id": "abcd",
                "latitude": 1.23,
                "longitude": 2.34,
                "cuisine_type":  "Creole",
                "cuisine_id": 9,
                "price_range_id" : 1,
                "notes": "So good",
                "photo_urls": ["my-cool-url", "my-awesome-url"] as [String]
            ]
        )

        let actualRestaurantParams = fakeHttp.patch_args.parameters["restaurant"]!
        XCTAssertEqual("/restaurants/999", fakeHttp.patch_args.path)
        XCTAssertEqual("Danny's Diner", actualRestaurantParams["name"])
        XCTAssertEqual("123 Main Street", actualRestaurantParams["address"])
        XCTAssertEqual("abcd", actualRestaurantParams["place_id"])
        XCTAssertEqual(1.23, actualRestaurantParams["latitude"])
        XCTAssertEqual(2.34, actualRestaurantParams["longitude"])
        XCTAssertEqual("Creole", actualRestaurantParams["cuisine_type"])
        XCTAssertEqual(9, actualRestaurantParams["cuisine_id"])
        XCTAssertEqual(1, actualRestaurantParams["price_range_id"])
        XCTAssertEqual("So good", actualRestaurantParams["notes"])
        XCTAssertEqual([["url": "my-cool-url"], ["url": "my-awesome-url"]], actualRestaurantParams["photo_urls"])
    }
}
