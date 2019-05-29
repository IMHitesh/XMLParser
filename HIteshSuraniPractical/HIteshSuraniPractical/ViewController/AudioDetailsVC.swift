//
//  AudioDetailsVC.swift
//  HIteshSuraniPractical
//
//  Created by sooryen on 28/05/19.
//  Copyright © 2019 sooryen. All rights reserved.
//

import UIKit
import AVFoundation

class AudioDetailsVC: UIViewController {
    
    @IBOutlet weak var imgAlbum: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var player : AVPlayer?
    var isPlaying = false
    var objModelAudio:ModelAudio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView(){
        lblTitle.text = objModelAudio.title
        HSImageLoader.image(for: objModelAudio.image ?? "") { (image) in
            if image == nil{
                self.imgAlbum?.image = placeHolder
            }else{
                self.imgAlbum.image = image
            }
        }
        
        guard let url = URL.init(string: objModelAudio.audioURL ?? "") else { return }
        let playerItem = AVPlayerItem.init(url: url)
        player = AVPlayer.init(playerItem: playerItem)
    }
    
    @IBAction func btnPlayAudioTap(){
        playAudio()
    }
    
    func playAudio() {
        
        if !isPlaying{
            player?.play()
            isPlaying = true
        }else{
            player?.pause()
            isPlaying = false
        }
    }
}
