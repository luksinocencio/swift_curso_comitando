import UIKit

public protocol ViewCodeHelper {
    func buildViewHierarchy()
    func setupConstraints()
    func setupAdditionalConfiguration()
    func setupView()
}

public extension ViewCodeHelper {
    func setupView() {
        buildViewHierarchy()
        setupConstraints()
        setupAdditionalConfiguration()
    }
    
    func setupAdditionalConfiguration() { }
}

final class RestaurantItemCell: UITableViewCell {
    private(set) lazy var hStack = renderStack(axis: .horizontal, spacing: 16, alignment: .center)
    private(set) lazy var vStack = renderStack(axis: .vertical, spacing: 4, alignment: .leading)
    private(set) lazy var hRatingStack = renderStack(axis: .horizontal, spacing: 0, alignment: .fill)
    private(set) lazy var mapImage = renderImage("map")
    private(set) lazy var title = renderLabel(font: .preferredFont(forTextStyle: .title2))
    private(set) lazy var location = renderLabel(font: .preferredFont(forTextStyle: .body))
    private(set) lazy var distance = renderLabel(font: .preferredFont(forTextStyle: .body))
    private(set) lazy var parasols = renderLabel(font: .preferredFont(forTextStyle: .body))
    private(set) lazy var collectionOfRating = renderCollectionOfImage()
    
    private func renderLabel(font: UIFont, textColor: UIColor = .label) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }
    
    private func renderStack(
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat,
        alignment: UIStackView.Alignment,
        distribuition: UIStackView.Distribution = .fill
    ) -> UIStackView {
        let stack = UIStackView()
        stack.axis = axis
        stack.spacing = spacing
        stack.alignment = alignment
        stack.distribution = distribuition
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }
    
    private func renderImage(_ systemName: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: systemName)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }
    
    private func renderCollectionOfImage() -> [UIImageView] {
        var collection = [UIImageView]()
        
        for _ in 1...5 {
            collection.append(renderImage("star"))
        }
        
        return collection
    }
}
