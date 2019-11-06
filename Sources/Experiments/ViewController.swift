//
//  ViewController.swift
//  Public Eyes
//
//  Created by Fitsyu  on 25/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import UIKit

///
/// Looks like this won't be necessary
/// 

class ViewController: UIViewController {
    
    override func loadView() {
                
        if let nibName = NSStringFromClass(self.classForCoder).split(separator: ".").last {
            let nbn = String(nibName)
            view = viewFromNib(named: nbn)
        }
    }
    
    func viewFromNib(named name: String) -> UIView? {
        
        let nib = UINib(nibName: name, bundle: nil)
        
        let nibContents = nib.instantiate(withOwner: self, options: nil)
        
        guard let first = nibContents.first,
            let viewOfNib = first as? UIView else {
                return nil
        }
        
        return viewOfNib
    }
}
