//
//  DetailViewController.swift
//  TareaNube3
//
//  Created by Oscar Zarco on 23/09/16.
//  Copyright © 2016 oscarzarco. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet var titulo: UILabel!
    @IBOutlet var isbn: UILabel!
    @IBOutlet var autores: UILabel!
    @IBOutlet var portada: UIImageView!


    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.timestamp!.description
                autores.text = detail.autores?.description
                titulo.text = detail.titulo?.description
                isbn.text = detail.isbn?.description
                portada.image = detail.portada as! UIImage?
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Event? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }


}

