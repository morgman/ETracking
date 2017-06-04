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
        foo = Foo.init(alert: alert)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        foo?.viewDidLoad(bounds:view.bounds, previewView: previewView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        foo?.viewDidAppear(animated)
    }
    
    open func alert(view:UIViewController) {
        present(view, animated: true, completion: {})
    }
}
