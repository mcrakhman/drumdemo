//
//  ViewController.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import UIKit

enum MainScrenConstants {
    static let cellsPerScreen = 16
}

class MainScreenViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, SequencerDisplay {

    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var arrowDownCollectionView: UICollectionView!
    @IBOutlet weak var kickCollectionView: UICollectionView!
    @IBOutlet weak var hatCollectionView: UICollectionView!
    @IBOutlet weak var snareCollectionView: UICollectionView!
    @IBOutlet weak var collectionStackView: UIStackView!
    
    var viewModel: MainScreenViewModel!
    
    let constants = MainScrenConstants.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViews()
        
        viewModel = MainScreenViewModel(view: self)
        viewModel.viewIsReady()
    }
    
    @IBAction func changeMode(_ sender: Any) {
        viewModel.shouldChangeMode()
    }
    // MARK: Конфигурация
    
    private func configureCollectionViews() {
        for view in collectionStackView.subviews {
            if let collectionView = view as? UICollectionView {
                let layout = layoutForCollectionView()
                collectionView.collectionViewLayout = layout
                collectionView.dataSource = self
                collectionView.delegate = self
            }
        }
    }
    
    private func layoutForCollectionView() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: calculateItemWidth(constants.cellsPerScreen),
                                 height: hatCollectionView.frame.height)
        
        return layout
    }
    
    private func calculateItemWidth(_ amountOfCellsInRow: Int) -> CGFloat {
        return self.view.frame.width / CGFloat(amountOfCellsInRow)
    }
    
    private func changeActiveCell(for collection: UICollectionView,
                                 atIndexPath indexPath: IndexPath,
                                 active: Bool? = nil) {
        if let cell = collection.cellForItem(at: indexPath) as? DrumCell {
            if let active = active {
                cell.setActive(active)
            } else {
                cell.changeState()
            }
        }
    }
    
    private func setArrowGrid(_ counter: Int) {
        for indexPath in arrowDownCollectionView.indexPathsForVisibleItems {
            if let cell = arrowDownCollectionView.cellForItem(at: indexPath) as? ArrowDownCell {
                cell.setActive(indexPath.row == counter)
            }
        }
    }
    
    private func setDrumGrid(_ sequence: [SequenceNode], forCollection collection: UICollectionView) {
        for indexPath in collection.indexPathsForVisibleItems {
            changeActiveCell(for: collection, atIndexPath: indexPath, active: sequence[indexPath.row].enabled)
        }
    }
    
    private func instrument(from collectionView: UICollectionView) -> Instruments {
        switch collectionView {
        case kickCollectionView:
            return .kick
        case snareCollectionView:
            return .snare
        case hatCollectionView:
            return .hat
        default:
            return .kick
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MainScrenConstants.cellsPerScreen
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        if collectionView == arrowDownCollectionView {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArrowDownCell.identifier, for: indexPath)
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrumCell.identifier, for: indexPath)
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard collectionView != arrowDownCollectionView else { return }
        
        let instrumentType = instrument(from: collectionView)
        changeActiveCell(for: collectionView,
                         atIndexPath: indexPath)
        viewModel.didTap(instrumentType, at: indexPath.row)
    }

    // MARK: SequencerDisplay
    
    func show(_ configuration: SequencerDisplayConfiguration) {
        setArrowGrid(configuration.position)
        tempoLabel.text = String(configuration.tempo)
    }
    
    func shouldUpdate(kickSequence: [SequenceNode],
                      snareSequence: [SequenceNode],
                      hatSequence: [SequenceNode]) {
        setDrumGrid(kickSequence, forCollection: kickCollectionView)
        setDrumGrid(snareSequence, forCollection: snareCollectionView)
        setDrumGrid(hatSequence, forCollection: hatCollectionView)
    }
}

