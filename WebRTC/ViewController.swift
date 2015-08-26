//
//  ViewController.swift
//  WebRTC
//
//  Created by Koji Murata on 2015/08/26.
//  Copyright (c) 2015年 Koji Murata. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var myIdLabel: UILabel!

    private lazy var peer: SKWPeer = {
        let options = SKWPeerOption()
        options.key = "cd470ab3-71c9-4322-b940-3e0259bf0980"
        options.domain = "malt.dip.jp"
        let peer = SKWPeer(options: options)
        
        peer.on(._PEER_EVENT_OPEN) { (obj) in
            if let id = obj as? String {
                dispatch_async(dispatch_get_main_queue()) {
                    self.myIdLabel.text = id
                }
            }
        }
        
        peer.on(._PEER_EVENT_CALL) { (obj) in
            if let connection = obj as? SKWMediaConnection {
                connection.answer(self.localMediaStream)
                self.setCallbackToConnection(connection)
            }
        }
        
        return peer
    }()
    
    private lazy var localMediaStream: SKWMediaStream = {
        let constraints = SKWMediaConstraints()
        constraints.maxWidth = 540
        constraints.maxWidth = 960
        constraints.videoFlag = true
        constraints.audioFlag = true

        SKWNavigator.initialize(self.peer)
        
        return SKWNavigator.getUserMedia(constraints)
    }()
    private var remoteMediaStream: SKWMediaStream?

    private var remoteVideo: SKWVideo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var x = localMediaStream
        remoteVideo = SKWVideo(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        view.addSubview(remoteVideo)
    }
    
    private func setCallbackToConnection(connection: SKWMediaConnection) {
        connection.on(._MEDIACONNECTION_EVENT_STREAM) { (obj) in
            if let stream = obj as? SKWMediaStream {
                self.remoteMediaStream = stream
                dispatch_async(dispatch_get_main_queue()) {
                    self.remoteVideo.addSrc(stream, track: 0)
                }
            }
        }
    }
}