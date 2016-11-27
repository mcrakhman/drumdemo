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
    static let alertControllerTitle = "Уведомление"
}

class MainScreenViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, SequencerDisplay {

    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var arrowDownCollectionView: UICollectionView!
    @IBOutlet weak var kickCollectionView: UICollectionView!
    @IBOutlet weak var hatCollectionView: UICollectionView!
    @IBOutlet weak var snareCollectionView: UICollectionView!
    @IBOutlet weak var collectionStackView: UIStackView!
    
    // Buttons
    
    @IBOutlet weak var firstBarButton: CircleButton!
    @IBOutlet weak var secondBarButton: CircleButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var viewModel: MainScreenViewModel!
    
    let constants = MainScrenConstants.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViews()
        
        viewModel = MainScreenViewModel(view: self)
        viewModel.viewIsReady()
    }
    
    // MARK: CollectionViewConfiguration
    
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
    
    // MARK: StateChanges
    
    func changePlayingState(_ isPlaying: Bool) {
        if isPlaying {
            playButton.setImage(UIImage.pause, for: .normal)
        } else {
            playButton.setImage(UIImage.play, for: .normal)
        }
    }
    
    func changeMode(_ mode: SequencerMode) {
        if mode == .playingTempo {
            modeButton.setTitle("R", for: .normal)
        } else {
            modeButton.setTitle("W", for: .normal)
        }
    }
    
    func animateRecord(_ animate: Bool) {
        
    }
    
    func animateDownload(_ animate: Bool) {
        
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: constants.alertControllerTitle,
                                                message: message,
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок",
                                   style: .default,
                                   handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: ButtonActions
    
    @IBAction func firstBarButtonTapped(_ sender: Any) {
        viewModel.didTap(bar: 1)
    }
    
    @IBAction func secondBarButtonTapped(_ sender: Any) {
        viewModel.didTap(bar: 2)
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        viewModel.didTapRecord()
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        viewModel.didTapPlay()
    }
    
    @IBAction func downloadButtonTapped(_ sender: Any) {
        viewModel.didTapDownload()
    }
    
    @IBAction func modeButtonTapped(_ sender: Any) {
        viewModel.didTapMode()
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
        if configuration.bar == 0 {
            firstBarButton.visualState = .selected
            secondBarButton.visualState = .unselected
        } else {
            firstBarButton.visualState = .unselected
            secondBarButton.visualState = .selected
        }
        setArrowGrid(configuration.position)
        tempoLabel.text = String(Int(configuration.tempo))
    }
    
    func shouldUpdate(kickSequence: [SequenceNode],
                      snareSequence: [SequenceNode],
                      hatSequence: [SequenceNode]) {
        setDrumGrid(kickSequence, forCollection: kickCollectionView)
        setDrumGrid(snareSequence, forCollection: snareCollectionView)
        setDrumGrid(hatSequence, forCollection: hatCollectionView)
    }
}

