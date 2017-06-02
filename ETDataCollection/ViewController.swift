//
//  ViewController.swift
//  ETDataCollection
//
//  Created by Jones, Morgan on 5/19/17.
//  Copyright © 2017 Jones, Morgan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet open weak var previewView: UIView?
    
    var guideRectCALayer:CALayer?
    var foo:Foo?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        foo = Foo.init(viewController:self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        foo?.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        foo?.viewDidAppear(animated)
    }
}
