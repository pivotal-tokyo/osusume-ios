import BrightFutures
import BSImagePicker
import Photos

enum NewRestuarantTableViewRow: Int {
    case AddPhotosCell = 0
    case FormDetailsCell
    case Count

    static var count: Int {
        get {
            return NewRestuarantTableViewRow.Count.rawValue
        }
    }
}

class NewRestaurantViewController: UIViewController {
    // MARK: - Properties
    private let router: Router
    private let restaurantRepo: RestaurantRepo
    private let photoRepo: PhotoRepo
    private var imagePicker: ImagePicker?

    private(set) var images: [UIImage]
    private let imagePickerViewController: BSImagePickerViewController

    let addRestaurantPhotosTableViewCell: AddRestaurantPhotosTableViewCell
    let addRestaurantFormTableViewCell: AddRestaurantFormTableViewCell

    // MARK: - View Elements
    let tableView: UITableView

    // MARK: - Initializers
    init(
        router: Router,
        restaurantRepo: RestaurantRepo,
        photoRepo: PhotoRepo,
        imagePicker: ImagePicker?)
    {
        self.router = router
        self.restaurantRepo = restaurantRepo
        self.photoRepo = photoRepo
        self.imagePicker = imagePicker

        images = [UIImage]()
        imagePickerViewController = BSImagePickerViewController()

        tableView = UITableView.newAutoLayoutView()

        addRestaurantPhotosTableViewCell = AddRestaurantPhotosTableViewCell()
        addRestaurantFormTableViewCell = AddRestaurantFormTableViewCell()

        super.init(nibName: nil, bundle: nil)
    }

    convenience init(
        router: Router,
        restaurantRepo: RestaurantRepo,
        photoRepo: PhotoRepo)
    {
        self.init(
            router: router,
            restaurantRepo: restaurantRepo,
            photoRepo: photoRepo,
            imagePicker: nil
        )

        self.imagePicker = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported for NewRestaurantViewController")
    }

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Restaurant"

        configureNavigationBar()
        addSubviews()
        configureSubviews()
        addConstraints()
    }

    // MARK: - View Setup
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: #selector(NewRestaurantViewController.didTapDoneButton(_:))
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: #selector(NewRestaurantViewController.didTapCancelButton(_:))
        )
    }

    private func addSubviews() {
        view.addSubview(tableView)
    }

    private func configureSubviews() {
        tableView.allowsSelection = false
        tableView.dataSource = self

        addRestaurantPhotosTableViewCell.configureCell(
            self,
            dataSource: self,
            reloader: DefaultReloader()
        )

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
    }

    private func addConstraints() {
        tableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero)
    }

    // MARK: - Actions
    @objc private func didTapDoneButton(sender: UIBarButtonItem?) {
        let photoUrls = photoRepo.uploadPhotos(images)

        let restaurantTableViewCellIndexPath = NSIndexPath(
            forRow: NewRestuarantTableViewRow.FormDetailsCell.rawValue,
            inSection: 0
        )
        let maybeCell = tableView.dataSource?.tableView(
            tableView,
            cellForRowAtIndexPath: restaurantTableViewCellIndexPath
        ) as? AddRestaurantFormTableViewCell

        if let cell = maybeCell {
            let formView = cell.formView

            let newRestaurant = NewRestaurant(
                name: formView.getNameText()!,
                address: formView.getAddressText()!,
                cuisineType: formView.getCuisineTypeText() ?? "",
                cuisineId: formView.selectedCuisine.id,
                priceRangeId: formView.selectedPriceRange.id,
                offersEnglishMenu: formView.getOffersEnglishMenuState()!,
                walkInsOk: formView.getWalkInsOkState()!,
                acceptsCreditCards: formView.getAcceptsCreditCardsState()!,
                notes: formView.getNotesText()!,
                photoUrls: photoUrls
            )

            restaurantRepo.create(newRestaurant)
                .onSuccess(ImmediateExecutionContext) { [unowned self] _ in
                    self.router.dismissPresentedNavigationController()
            }
        }
    }

    @objc private func didTapCancelButton(sender: UIBarButtonItem?) {
        self.router.dismissPresentedNavigationController()
    }

    @objc func didTapAddPhotoButton(sender: UIButton?) {
        imagePicker?.bs_presentImagePickerController(
            imagePickerViewController,
            animated: true,
            select: nil,
            deselect: nil,
            cancel: nil,
            finish: gatherImageAssets,
            completion: nil
        )
    }

    // MARK: - Private Methods
    private func gatherImageAssets(assets: [PHAsset]) {
        images.removeAll()

        let imageManager = PHImageManager.defaultManager()
        for asset in assets {
            imageManager.requestImageForAsset(
                asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .Default,
                options: nil,
                resultHandler: addImageToCollectionView
            )
        }
    }

    private func addImageToCollectionView(maybeImage: UIImage?, info: [NSObject: AnyObject]?) {
        guard let image = maybeImage else {
            return
        }

        images.append(image)
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension NewRestaurantViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(
        tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int
    {
        return NewRestuarantTableViewRow.count
    }

    func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath
        ) -> UITableViewCell
    {
        switch indexPath.row {
        case NewRestuarantTableViewRow.AddPhotosCell.rawValue:
            addRestaurantPhotosTableViewCell.configureCell(
                self,
                dataSource: self,
                reloader: DefaultReloader()
            )
            return addRestaurantPhotosTableViewCell

        case NewRestuarantTableViewRow.FormDetailsCell.rawValue:
            addRestaurantFormTableViewCell.configureCell(self)
            return addRestaurantFormTableViewCell

        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension NewRestaurantViewController: UICollectionViewDataSource {
    func collectionView(
        collectionView: UICollectionView,
        numberOfItemsInSection section: Int
        ) -> Int
    {
        return images.count
    }

    func collectionView(
        collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath
        ) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            String(UICollectionViewCell),
            forIndexPath: indexPath
        )

        cell.backgroundView = UIImageView(image: images[indexPath.row])

        return cell
    }
}

// MARK: - NewRestaurantViewControllerPresenterProtocol
extension NewRestaurantViewController: NewRestaurantViewControllerPresenterProtocol {
    func showFindCuisineScreen() {
        router.showFindCuisineScreen()
    }

    func showFindRestaurantScreen() {
        router.showFindRestaurantScreen()
    }

    func showPriceRangeScreen() {
        router.showPriceRangeListScreen()
    }
}
