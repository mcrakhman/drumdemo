//
//  RecordingsScreenRouter.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 09.12.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

class RecordingsScreenRouter {
    func closeModule(from vc: UIViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
}
