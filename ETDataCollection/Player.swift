import AVFoundation
import UIKit

class Player {

    open func play(previewView: UIView, tempFilePath: URL) {
        previewView.isHidden = false
        let commentPlayer = AVPlayer.init(url: tempFilePath)//[AVPlayer playerWithURL:fileURL];
        commentPlayer.actionAtItemEnd = .none
        
        let aPlayerLayer = AVPlayerLayer.init(player: commentPlayer)
        aPlayerLayer.backgroundColor = UIColor.blue.cgColor
        previewView.layer.addSublayer(aPlayerLayer)
        aPlayerLayer.frame = previewView.bounds
        aPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        commentPlayer.play()
    }
}
