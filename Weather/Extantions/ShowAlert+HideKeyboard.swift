//
//  Extantions.swift
//  Weather
//
//  Created by Илья Синицын on 21.03.2022.
//

import UIKit

extension UIViewController {
    func showAlert (with messageError: String) {
        let alert = UIAlertController(title: nil, message: messageError, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
