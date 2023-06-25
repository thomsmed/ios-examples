//
//  Application.swift
//  AlternateAppIcon
//
//  Created by Thomas Asheim Smedmann on 25/06/2023.
//

import UIKit

protocol Application: AnyObject {
    var alternateIconName: String? { get }
    func setAlternateIconName(_ alternateIconName: String?, completionHandler: ((Error?) -> Void)?)
}

extension UIApplication: Application {}
