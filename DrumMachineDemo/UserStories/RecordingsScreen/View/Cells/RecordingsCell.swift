
import Foundation
import UIKit

class RecordingsCell: UICollectionViewCell {
    
    @IBOutlet weak var recordingsLabel: UILabel!
    
    override func awakeFromNib() {
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.white.cgColor
    }
    
    func configureLabel(withTitle title: String) {
        recordingsLabel.text = title
    }
}
