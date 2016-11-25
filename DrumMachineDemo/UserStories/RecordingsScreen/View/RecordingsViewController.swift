//
//  RecordingsViewController.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

enum RecordingsViewControllerConstants {
    static let cellHeight: CGFloat = 40.0
    static let cellWidth: CGFloat = 40.0
    static let cellsPerScreen = 32
}

class RecordingsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var viewModel: RecordingsScreenViewModel!
    
    override func viewDidLoad() {
        configureCollectionView()
        viewModel.viewIsReady()
    }
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = layoutForCollectionView()
    }
    
    private func layoutForCollectionView() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: RecordingsViewControllerConstants.cellWidth,
                                 height: RecordingsViewControllerConstants.cellHeight)
        
        return layout
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RecordingsViewControllerConstants.cellsPerScreen
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: RecordingsCell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordingsCell.identifier,
                                                                            for: indexPath) as! RecordingsCell
        cell.configureLabel(withTitle: String(indexPath.row))
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didTap(recordingAt: indexPath.row)
    }
}
