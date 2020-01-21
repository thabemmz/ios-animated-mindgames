//
//  ConcentrationThemePickerViewController.swift
//  AnimatedMindGames
//
//  Created by Christiaan van Bemmel on 30/09/2019.
//  Copyright © 2019 Christiaan van Bemmel. All rights reserved.
//

import UIKit

class ConcentrationThemePickerViewController: UIViewController, UISplitViewControllerDelegate {
    let themeMapper: [String: String] = [
        "🐶": "animals",
        "🤪": "faces",
        "⚽️": "balls",
        "🍏": "food",
        "🌧": "weather",
        "🚗": "travel"
    ]
    
    override func awakeFromNib() {
        splitViewController?.delegate = self
        splitViewController?.preferredDisplayMode = UISplitViewController.DisplayMode.allVisible
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let concentrationViewController = secondaryViewController as? ConcentrationGameViewController {
            if concentrationViewController.themeName == nil {
                return true
            }
        }
        
        return false
    }
    
    @IBAction func changeTheme(_ sender: Any) {
        if let concentrationViewController = splitViewDetailConcentrationViewController {
            setTheme(of: sender, for: concentrationViewController)
        } else if let concentrationViewController = lastSeguedConcentrationViewController {
            setTheme(of: sender, for: concentrationViewController)
            navigationController?.pushViewController(concentrationViewController, animated: true)
        } else {
            performSegue(withIdentifier: "Choose Theme", sender: sender)
        }
    }
    
    private func setTheme(of sender: Any, for cvc: ConcentrationGameViewController) {
        if let themeID = (sender as? UIButton)?.currentTitle, let themeName = themeMapper[themeID] {
            cvc.themeName = themeName
        }
    }
    
    private var splitViewDetailConcentrationViewController: ConcentrationGameViewController? {
        return splitViewController?.viewControllers.last as? ConcentrationGameViewController
    }
    
    // MARK: - Navigation
    private var lastSeguedConcentrationViewController: ConcentrationGameViewController?
        
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Choose Theme" {
            if let themeID = (sender as? UIButton)?.currentTitle, let themeName = themeMapper[themeID] {
                if let concentrationViewController = segue.destination as? ConcentrationGameViewController {
                    concentrationViewController.themeName = themeName
                    lastSeguedConcentrationViewController = concentrationViewController
                }
            }
        }
    }
}
