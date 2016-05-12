import BrightFutures
import XCTest
import Nimble
@testable import Osusume

class FakePriceRangeSelectionDelegate: PriceRangeSelectionDelegate {
    var priceRangeSelected_arg = PriceRange(id: -1, range: "")
    func priceRangeSelected(priceRange: PriceRange) {
        priceRangeSelected_arg = priceRange
    }
}

class FakePriceRangeRepo: PriceRangeRepo {
    var getAll_wasCalled = false
    var getAll_returnValue = Future<[PriceRange], RepoError>()
    func getAll() -> Future<[PriceRange], RepoError> {
        getAll_wasCalled = true
        return getAll_returnValue
    }
}

class PriceRangeListViewControllerTest: XCTestCase {
    let fakeReloader = FakeReloader()
    let fakeRouter = FakeRouter()
    var fakePriceRangeRepo = FakePriceRangeRepo()
    var fakePriceRangeSelectionDelegate = FakePriceRangeSelectionDelegate()
    var priceRangeListVC: PriceRangeListViewController!
    var returnPriceRangeListPromise: Promise<[PriceRange], RepoError>!

    override func setUp() {
        super.setUp()

        returnPriceRangeListPromise = Promise<[PriceRange], RepoError>()
        fakePriceRangeRepo.getAll_returnValue = returnPriceRangeListPromise.future

        priceRangeListVC = PriceRangeListViewController(
            priceRangeRepo: fakePriceRangeRepo,
            reloader: fakeReloader,
            router: fakeRouter,
            priceRangeSelection: fakePriceRangeSelectionDelegate
        )
        priceRangeListVC.view.setNeedsLayout()
    }

    func test_viewDidLoad_callsGetAllOnPriceRangeRepo() {
        expect(self.fakePriceRangeRepo.getAll_wasCalled).to(beTrue())
    }

    func test_viewDidLoad_setsDataSourceForTableView() {
        let actualDataSource = self.priceRangeListVC.tableView.dataSource
        expect(actualDataSource) === self.priceRangeListVC
    }

    func test_retrievalOfPriceRangeData_reloadsTableView() {
        returnPriceRangeListPromise.success([])
        NSRunLoop.osu_advance()


        expect(self.fakeReloader.reload_wasCalled).to(beTrue())
    }

    func test_viewDidLoad_showsTableWithOneSection() {
        let tableView = priceRangeListVC.tableView
        let actualNumberOfSections = priceRangeListVC.numberOfSectionsInTableView(tableView)
        expect(actualNumberOfSections).to(equal(1))
    }

    func test_getAllOfPriceRangeData_fillsTableWithAppropriateNumberOfRows() {
        let priceRangeList = [
            PriceRange(id: 1, range: "price-range-1"),
            PriceRange(id: 2, range: "price-range-2")
        ]


        returnPriceRangeListPromise.success(priceRangeList)
        NSRunLoop.osu_advance()


        let tableView = priceRangeListVC.tableView
        let actualNumberOfRows = priceRangeListVC.tableView(
            tableView,
            numberOfRowsInSection: 0
        )
        expect(actualNumberOfRows).to(equal(2))
    }

    func test_getAllOfPriceData_showsCellsContainingPriceData() {
        let priceRangeList = [
            PriceRange(id: 1, range: "price-range-1")
        ]


        returnPriceRangeListPromise.success(priceRangeList)
        NSRunLoop.osu_advance()


        let tableView = priceRangeListVC.tableView
        let cell = priceRangeListVC.tableView(
            tableView,
            cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)
        )
        expect(cell.textLabel?.text).to(equal("price-range-1"))
    }

    func test_tappingCancelBarButtonItem_callsDismissPresentedViewControllerOnRouter() {
        let cancelBarButtonItem = priceRangeListVC.navigationItem.leftBarButtonItem!


        tapNavBarButton(cancelBarButtonItem)


        expect(self.fakeRouter.dismissPresentedNavigationController_wasCalled).to(beTrue())
    }

    func test_tappingPriceRangeCell_passesSelectedPriceRangeToDelegate() {
        let priceRangeList = [PriceRange(id: 0, range: "0~999")]
        returnPriceRangeListPromise.success(priceRangeList)
        waitForFutureToComplete(returnPriceRangeListPromise.future)


        priceRangeListVC.tableView(
            priceRangeListVC.tableView,
            didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)
        )


        expect(self.fakePriceRangeSelectionDelegate.priceRangeSelected_arg)
            .to(equal(priceRangeList[0]))
    }
}
