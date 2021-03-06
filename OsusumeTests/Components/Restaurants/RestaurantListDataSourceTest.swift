import XCTest
import Nimble
@testable import Osusume

class RestaurantListDataSourceTest: XCTestCase {
    var restaurantListDataSource: RestaurantListDataSource!
    let fakePhotoRepo = FakePhotoRepo()
    var restaurants: [Restaurant]!
    var callToActionCallback_called = false

    override func setUp() {
        restaurantListDataSource = RestaurantListDataSource(photoRepo: fakePhotoRepo)
    }

    override func tearDown() {
        callToActionCallback_called = false
    }

    func test_tableView_configuresCellCount() {
        restaurants = [
            RestaurantFixtures.newRestaurant(name: "Pizzakaya")
        ]
        restaurantListDataSource.updateRestaurants(restaurants)

        let numberOfRows = restaurantListDataSource.tableView(
            UITableView(),
            numberOfRowsInSection: 0
        )


        expect(numberOfRows).to(equal(1))
    }

    func test_tableView_configuresCellsWithAppropriateType() {
        restaurants = [
            RestaurantFixtures.newRestaurant(name: "Pizzakaya")
        ]
        restaurantListDataSource.updateRestaurants(restaurants)

        let tableView = UITableView()
        tableView.registerClass(
            RestaurantTableViewCell.self,
            forCellReuseIdentifier: String(RestaurantTableViewCell)
        )


        let firstCell = restaurantListDataSource.tableView(
            tableView,
            cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)
        )


        expect(firstCell).to(beAKindOf(RestaurantTableViewCell))
    }

    func test_tableView_setsNilAsBackgroundView_whenThereAreRestaurantsToShow() {
        let tableView = UITableView()
        restaurants = [
            RestaurantFixtures.newRestaurant(name: "Pizzakaya")
        ]
        restaurantListDataSource.updateRestaurants(restaurants)

        restaurantListDataSource.tableView(tableView, numberOfRowsInSection: 0)

        expect(tableView.backgroundView).to(beNil())
    }
}
