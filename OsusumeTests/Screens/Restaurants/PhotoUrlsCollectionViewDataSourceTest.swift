import XCTest
import Nimble
@testable import Osusume

class PhotoUrlsCollectionViewDataSourceTest: XCTestCase {

    func test_dataSource_configuresNumberOfRowsPerSection() {
        let collectionView = UICollectionView(
            frame: CGRectZero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        let photoUrls = [
            NSURL(string: "url1")!,
            NSURL(string: "url2")!
        ]
        let dataSource = PhotoUrlsCollectionViewDataSource(
            photoUrls: photoUrls,
            editMode: false,
            deletePhotoClosure: nil
        )


        let numberOfItems = dataSource.collectionView(
            collectionView,
            numberOfItemsInSection: 0
        )


        expect(numberOfItems).to(equal(2))
    }

    func test_dataSource_configuresCellWithImageView() {
        let collectionView = initializeImageCollectionView()
        let photoUrls = [
            NSURL(string: "url")!
        ]
        let dataSource = PhotoUrlsCollectionViewDataSource(
            photoUrls: photoUrls,
            editMode: false,
            deletePhotoClosure: nil
        )
        collectionView.dataSource = dataSource


        let firstImageCell = dataSource.collectionView(
            collectionView,
            cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0)
        )


        let firstImageView = firstImageCell.backgroundView as? UIImageView
        expect(firstImageView?.sd_imageURL())
            .to(equal(NSURL(string: "url")!))
    }

    func test_dataSource_configureCellWithDeleteButtonHidden() {
        let collectionView = initializeImageCollectionView()
        let photoUrls = [
            NSURL(string: "url")!
        ]


        let dataSource = PhotoUrlsCollectionViewDataSource(
            photoUrls: photoUrls,
            editMode: false,
            deletePhotoClosure: nil
        )
        collectionView.dataSource = dataSource
        let cell = dataSource.collectionView(
            collectionView,
            cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0)
            ) as? PhotoCollectionViewCell


        expect(cell?.deleteButton.hidden).to(beTrue())
    }

    func test_dataSource_configureCellWithDeleteButtonDisplayed() {
        let collectionView = initializeImageCollectionView()
        let photoUrls = [
            NSURL(string: "url")!
        ]


        let dataSource = PhotoUrlsCollectionViewDataSource(
            photoUrls: photoUrls,
            editMode: true,
            deletePhotoClosure: nil
        )
        collectionView.dataSource = dataSource
        let cell = dataSource.collectionView(
            collectionView,
            cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0)
        ) as? PhotoCollectionViewCell


        expect(cell?.deleteButton.hidden).to(beFalse())
    }

    func test_tappingDeletePhotoButton_invokesDeleteOnPhotoRepo() {
        let collectionView = initializeImageCollectionView()
        let photoUrls = [
            NSURL(string: "url")!
        ]
        var deletePhotoClosureWasCalled = false

        let dataSource = PhotoUrlsCollectionViewDataSource(
            photoUrls: photoUrls,
            editMode: true,
            deletePhotoClosure: { url in
                deletePhotoClosureWasCalled = true
            }
        )
        collectionView.dataSource = dataSource


        let cell = dataSource.collectionView(
            collectionView,
            cellForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0)
            ) as? PhotoCollectionViewCell
        tapButton((cell?.deleteButton)!)


        expect(deletePhotoClosureWasCalled).to(beTrue())
    }

    // MARK: - Private Methods
    func initializeImageCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(
            frame: CGRectZero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.registerClass(
            PhotoCollectionViewCell.self,
            forCellWithReuseIdentifier: String(PhotoCollectionViewCell)
        )

        return collectionView
    }

}
