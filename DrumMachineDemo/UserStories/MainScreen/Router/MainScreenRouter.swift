//
//  MainScreenRouter.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 09.12.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

class MainScreenRouter {
    func openRecordings(from vc: UIViewController, delegate: RecordingsScreenViewModelDelegate) {
        let destinationVC = vc.storyboard?.instantiateViewController(withIdentifier: "RecordingsViewController") as! RecordingsViewController
        destinationVC.delegate = delegate
        vc.present(destinationVC, animated: true, completion: nil)
    }
}
