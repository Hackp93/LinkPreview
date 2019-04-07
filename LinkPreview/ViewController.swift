//
//  ViewController.swift
//  LinkPreview
//
//  Created by Manu Singh on 07/04/19.
//  Copyright © 2019 Manu Singh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var previewTitle: UILabel!
    @IBOutlet weak var linkDescription: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onClickCreate(_ sender: Any) {
        guard !(textField.text?.isEmpty ?? true) else { return }
        
        if let linkUrl = textField.text!.getLink() {
            
            generatePreview(for: linkUrl, completion: {
                preview in
                self.previewTitle.text = preview.title// + preview.description!
                self.linkDescription.text = preview.linkDescription
                self.previewImage.setImage(withUrl: preview.previewImageUrl!, placeholder: nil)
                
            })
        }
    }
    
}

