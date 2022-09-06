
import UIKit

class SongCollectionViewCell: UICollectionViewCell {
    static let identifier = "SongCollectionViewCell"
    
    private var songImage = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        songImage.contentMode = .scaleToFill
        songImage.frame = CGRect(x: contentView.bounds.midX - contentView.bounds.width / 2,
                                 y: contentView.bounds.midY - contentView.bounds.height / 2,
                                 width: contentView.frame.width,
                                 height: contentView.frame.height)
        songImage.backgroundColor = .red
        contentView.addSubview(songImage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(image: String) {
        songImage.image = UIImage(named: image)
    }
}
