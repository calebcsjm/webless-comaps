
protocol PlacePageInfoViewControllerDelegate: AnyObject {
  var shouldShowOpenInApp: Bool { get }

  func didPressCall(to phone: PlacePagePhone)
  func didPressEmail()
  func didPressOpenInApp(from sourceView: UIView)
  func didCopy(_ content: String)
}

class PlacePageInfoViewController: UIViewController {
  private struct Constants {
    static let coordFormatIdKey = "PlacePageInfoViewController_coordFormatIdKey"
  }

  private typealias TapHandler = InfoItemView.TapHandler
  private typealias Style = InfoItemView.Style

  @IBOutlet var stackView: UIStackView!
  @IBOutlet var checkDateLabel: UILabel!
  @IBOutlet var checkDateLabelLayoutConstraint: NSLayoutConstraint!

  private lazy var openingHoursViewController: OpeningHoursViewController = {
    storyboard!.instantiateViewController(ofType: OpeningHoursViewController.self)
  }()

  private var rawOpeningHoursView: InfoItemView?
  private var phoneViews: [InfoItemView] = []
  private var emailView: InfoItemView?
  private var cuisineView: InfoItemView?
  private var operatorView: InfoItemView?
  private var wifiView: InfoItemView?
  private var atmView: InfoItemView?
  private var addressView: InfoItemView?
  private var levelView: InfoItemView?
  private var coordinatesView: InfoItemView?
  private var openWithAppView: InfoItemView?
  private var capacityView: InfoItemView?
  private var roomsView: InfoItemView?
  private var chargeView: InfoItemView?
  private var wheelchairView: InfoItemView?
  private var selfServiceView: InfoItemView?
  private var outdoorSeatingView: InfoItemView?
  private var driveThroughView: InfoItemView?
  private var networkView: InfoItemView?
  private var populationView: InfoItemView?

  weak var placePageInfoData: PlacePageInfoData!
  weak var delegate: PlacePageInfoViewControllerDelegate?
  var coordinatesFormatId: Int {
    get { UserDefaults.standard.integer(forKey: Constants.coordFormatIdKey) }
    set { UserDefaults.standard.set(newValue, forKey: Constants.coordFormatIdKey) }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.spacing = 0
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.addSeparator(.bottom)
    view.addSubview(stackView)
    setupViews()
  }

  // MARK: private
  private func setupViews() {
    if let openingHours = placePageInfoData.openingHours {
      openingHoursViewController.openingHours = openingHours
      openingHoursViewController.openingHoursCheckDate = placePageInfoData.checkDateOpeningHours
      addChild(openingHoursViewController)
      addToStack(openingHoursViewController.view)
      openingHoursViewController.didMove(toParent: self)
    } else if let openingHoursString = placePageInfoData.openingHoursString {
      rawOpeningHoursView = createInfoItem(openingHoursString, icon: UIImage(systemName: "clock.fill"))
      rawOpeningHoursView?.infoLabel.numberOfLines = 0
    }

    if let cuisine = placePageInfoData.cuisine {
      cuisineView = createInfoItem(cuisine, icon: UIImage(systemName: "fork.knife"))
    }

    /// @todo Entrance is missing compared with Android. It's shown in title, but anyway ..

    phoneViews = placePageInfoData.phones.map({ phone in
      var cellStyle: Style = .regular
      if let phoneUrl = phone.url, UIApplication.shared.canOpenURL(phoneUrl) {
        cellStyle = .link
      }
      return createInfoItem(phone.phone,
                                 icon: UIImage(systemName: "phone.fill"),
                                 style: cellStyle,
                                 tapHandler: { [weak self] in
        self?.delegate?.didPressCall(to: phone)
      },
                                 longPressHandler: { [weak self] in
        self?.delegate?.didCopy(phone.phone)
      })
    })

    if let ppOperator = placePageInfoData.ppOperator {
      operatorView = createInfoItem(ppOperator, icon: UIImage(systemName: "person.text.rectangle"))
    }

    if let network = placePageInfoData.network {
      networkView = createInfoItem(network, icon: UIImage(systemName: "point.3.filled.connected.trianglepath.dotted"))
    }
	
    if let population = placePageInfoData.population {
      populationView = createInfoItem(population, icon: UIImage(systemName: "person.2.fill"))
    }

    if let wifi = placePageInfoData.wifiAvailable {
      wifiView = createInfoItem(wifi, icon: UIImage(systemName: "wifi"))
    }

    if let atm = placePageInfoData.atm {
      atmView = createInfoItem(atm, icon: UIImage(systemName: "creditcard"))
    }

    if let level = placePageInfoData.level {
      levelView = createInfoItem(level, icon: UIImage(named: "level"))
    }

    if let capacity = placePageInfoData.capacity {
      capacityView = createInfoItem(capacity, icon: UIImage(systemName: "viewfinder"))
    }
	
    if let rooms = placePageInfoData.rooms {
      roomsView = createInfoItem(rooms, icon: UIImage(systemName: "bed.double.fill"))
    }

    if let charge = placePageInfoData.charge {
        chargeView = createInfoItem(charge, icon: UIImage(systemName: "tag.fill"))
    }

    if let wheelchair = placePageInfoData.wheelchair {
      wheelchairView = createInfoItem(wheelchair, icon: UIImage(systemName: "figure.roll"))
    }

    if let selfService = placePageInfoData.selfService {
      selfServiceView = createInfoItem(selfService, icon: UIImage(named: "service.slash"))
    }

    if let outdoorSeating = placePageInfoData.outdoorSeating {
      outdoorSeatingView = createInfoItem(outdoorSeating, icon: UIImage(named: "outdoorseating"))
    }

    if let driveThrough = placePageInfoData.driveThrough {
      driveThroughView = createInfoItem(driveThrough, icon: UIImage(named: "drivethrough"))
    }

    if let email = placePageInfoData.email {
      emailView = createInfoItem(email,
                                 icon: UIImage(systemName: "envelope.fill"),
                                 style: .link,
                                 tapHandler: { [weak self] in
        self?.delegate?.didPressEmail()
      },
                                 longPressHandler: { [weak self] in
        self?.delegate?.didCopy(email)
      })
    }

    if let address = placePageInfoData.address {
      addressView = createInfoItem(address,
                                   icon: UIImage(named: "address"),
                                   longPressHandler: { [weak self] in
        self?.delegate?.didCopy(address)
      })
    }

    setupCoordinatesView()
    setupOpenWithAppView()

    if let checkDate = placePageInfoData.checkDate {
      let dateString: String
        
      // Check if the date is strictly "Today" or "Yesterday"
      if Calendar.current.isDateInToday(checkDate) || Calendar.current.isDateInYesterday(checkDate) {
        // Case 1: Today/Yesterday -> Use "today" / "yesterday"
        // Can be replaced by Date.RelativeFormatStyle with iOS 18+
        let checkDateFormatter = DateFormatter()
        checkDateFormatter.dateStyle = .medium
        checkDateFormatter.timeStyle = .none
        checkDateFormatter.doesRelativeDateFormatting = true
          
        let rawString = checkDateFormatter.string(from: checkDate)
        // Lowercase first letter: "Today" -> "today"
        dateString = rawString.prefix(1).lowercased() + rawString.dropFirst()
      } else {
        // Case 2: Older -> Use "2 years ago"
        let relativeCheckDateFormatter = RelativeDateTimeFormatter()
        relativeCheckDateFormatter.unitsStyle = .spellOut
        dateString = relativeCheckDateFormatter.localizedString(for: checkDate, relativeTo: Date())
      }
        
      self.checkDateLabel.text = String(format: L("existence_confirmed_time_ago"), dateString)
      checkDateLabel.isHidden = false
      NSLayoutConstraint.activate([checkDateLabelLayoutConstraint])
    } else {
      checkDateLabel.text = String()
      checkDateLabel.isHidden = true
      NSLayoutConstraint.deactivate([checkDateLabelLayoutConstraint])
    }
  }

  private func setupCoordinatesView() {
    guard let coordFormats = placePageInfoData.coordFormats as? Array<String> else { return }
    var formatId = coordinatesFormatId
    if formatId >= coordFormats.count {
      formatId = 0
    }
    coordinatesView = createInfoItem(coordFormats[formatId],
                                     icon: UIImage(systemName: "dot.scope"),
                                     style: .link,
                                     accessoryImage: UIImage(systemName: "chevron.up.chevron.down"),
                                     tapHandler: { [weak self] in
      guard let self else { return }
      let formatId = (self.coordinatesFormatId + 1) % coordFormats.count
      self.setCoordinatesSelected(formatId: formatId)
    },
                                     longPressHandler: { [weak self] in
      self?.copyCoordinatesToPasteboard()
    })
    
    let menu = UIMenu(children: coordFormats.enumerated().map { (index, format) in
      UIAction(title: format, handler: { [weak self] _ in
        self?.setCoordinatesSelected(formatId: index)
        self?.copyCoordinatesToPasteboard()
      })
    })
    coordinatesView?.accessoryButton.menu = menu
    coordinatesView?.accessoryButton.showsMenuAsPrimaryAction = true
  }

  private func setCoordinatesSelected(formatId: Int) {
    guard let coordFormats = placePageInfoData.coordFormats as? Array<String> else { return }
    coordinatesFormatId = formatId
    let coordinates: String = coordFormats[formatId]
    coordinatesView?.infoLabel.text = coordinates
  }

  private func copyCoordinatesToPasteboard() {
    guard let coordFormats = placePageInfoData.coordFormats as? Array<String> else { return }
    let coordinates: String = coordFormats[coordinatesFormatId]
    delegate?.didCopy(coordinates)
  }

  private func setupOpenWithAppView() {
    guard let delegate, delegate.shouldShowOpenInApp else { return }
    openWithAppView = createInfoItem(L("open_in_app"),
                                     icon: UIImage(systemName: "arrow.up.forward.app"),
                                     style: .link,
                                     tapHandler: { [weak self] in
      guard let self, let openWithAppView else { return }
      self.delegate?.didPressOpenInApp(from: openWithAppView)
    })
  }

  private func createInfoItem(_ info: String,
                              icon: UIImage?,
                              tapIconHandler: TapHandler? = nil,
                              style: Style = .regular,
                              accessoryImage: UIImage? = nil,
                              tapHandler: TapHandler? = nil,
                              longPressHandler: TapHandler? = nil,
                              accessoryImageTapHandler: TapHandler? = nil) -> InfoItemView {
    let view = InfoItemView()
    addToStack(view)
    view.iconButton.setImage(icon?.withRenderingMode(.alwaysTemplate), for: .normal)
    view.iconButtonTapHandler = tapIconHandler
    view.infoLabel.text = info
    view.setStyle(style)
    view.infoLabelTapHandler = tapHandler
    view.infoLabelLongPressHandler = longPressHandler
    view.setAccessory(image: accessoryImage, tapHandler: accessoryImageTapHandler)
    return view
  }

  private func addToStack(_ view: UIView) {
    stackView.addArrangedSubviewWithSeparator(view, insets: UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 0))
  }

}

private extension UIStackView {
  func addArrangedSubviewWithSeparator(_ view: UIView, insets: UIEdgeInsets = .zero) {
    if !arrangedSubviews.isEmpty {
      view.addSeparator(thickness: CGFloat(1.0), insets: insets)
    }
    addArrangedSubview(view)
  }
}

extension UIImage {
    func resizedBrandForPlacePage() -> UIImage {
        return image(with: CGSize(width: 23, height: 32))
    }
    
    func image(with size: CGSize) -> UIImage {
        let scaleForAspectRatio = min((size.width / self.size.width), (size.height / self.size.height))
        let sizeWithAspectRatio = CGSize(width: self.size.width * scaleForAspectRatio, height: self.size.height * scaleForAspectRatio)
        let image = UIGraphicsImageRenderer(size: sizeWithAspectRatio).image { _ in
            draw(in: CGRect(origin: .zero, size: sizeWithAspectRatio))
        }
        
        return image.withRenderingMode(renderingMode)
    }
}
