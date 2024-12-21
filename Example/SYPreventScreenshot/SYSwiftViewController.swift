//
//  SYSwiftViewController.swift
//  SYPreventScreenshot_Example
//
//  Created by sy on 2024/12/19.
//  Copyright © 2024 SyNvNX. All rights reserved.
//

import UIKit
import SYPreventScreenshot

class SYSwiftViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUp()
    }
    
    private func setUp() {
        let imageView = SYPreventScreenshotImageView(image: UIImage(named: "image"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
          ])
        
        
        let label = SYPreventScreenshotLabel(text: " Hello, world! ")
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        let constraint = label.topAnchor.constraint(equalTo: imageView.bottomAnchor)
        constraint.constant = 10
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            constraint
          ])
    }

}
