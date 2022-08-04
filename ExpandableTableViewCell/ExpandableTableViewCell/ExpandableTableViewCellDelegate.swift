//
//  ExpandableTableViewCellDelegate.swift
//  ExpandableTableViewCell
//
//  Created by Thomas Asheim Smedmann on 05/08/2022.
//

import UIKit

protocol ExpandableTableViewCellDelegate: AnyObject {
    func expandableTableViewCell(_ tableViewCell: UITableViewCell, expanded: Bool)
}
