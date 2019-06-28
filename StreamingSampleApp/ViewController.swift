//
//  ViewController.swift
//  StreamingSampleApp
//
//  Created by Kevin Olinger on 9/21/18.
//  Copyright © 2018 Universal Music Group. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {

    var upc: String = ""
    var trackNumber: String = ""
    var albumArtView: UIImageView?
    var apiHost: String = ""
    var apiKey: String = ""
    
    func getCoverUrl(upc: String, completion:@escaping (String)->Void) {
        let urlString = String(format: "https://%@/prod/v1/isrc/%@/cover", apiHost, upc)
        let url = URL(string: urlString)!
        var request = URLRequest(url: url);
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let jsonWithObjectRoot = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJson = jsonWithObjectRoot as? [String: Any] {
                if let coverUrl = responseJson["coverUrl"] as? String {
                    completion(coverUrl)
                }
            }
        }
        task.resume()
    }
    
    func downloadImage(urlstr: String, completion:@escaping (Data)->Void) {
        let url = URL(string: urlstr)!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            completion(data)
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var upcText: UITextField!
    @IBOutlet weak var trackNumberText: UITextField!
    
    @IBAction func playAudio(_ sender: Any) {
        let defaults = UserDefaults.standard;
        apiHost = defaults.string(forKey: "api_host_preference") ?? ""
        apiKey = defaults.string(forKey: "api_key_preference") ?? ""
        upc = upcText.text!
        //trackNumber = trackNumberText.text!
        let urlString = String(format: "https://%@/prod/v1/isrc/%@/stream.m3u8", apiHost, upc)
        guard let url = URL(string: urlString) else {
            return
        }
        let keyHeader = ["x-api-key": apiKey]
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": keyHeader])
        let playerItem = AVPlayerItem(asset: asset)
        
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
        let player = AVPlayer(playerItem: playerItem)
        
        // Create a new AVPlayerViewController and pass it a reference to the player.
        let controller = AVPlayerViewController()
     
        controller.player = player
        
        getCoverUrl(upc: upc) { (url) in
            self.downloadImage(urlstr: url) { (data) in
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    self.albumArtView = UIImageView()
                    self.albumArtView?.frame = UIScreen.main.bounds
                    self.albumArtView?.bounds = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: Int(UIScreen.main.bounds.width))
                    self.albumArtView?.image = UIImage(data: data)
                    controller.view.addSubview(self.albumArtView!)
                }
            }
        }
        
        // Modally present the player and call the player's play() method when complete.
        present(controller, animated: true) {
            player.play()
        }
    }
}

