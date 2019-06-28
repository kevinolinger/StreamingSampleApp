//
//  StreamPlayerViewController.swift
//  StreamingSampleApp
//
//  Created by Kevin Olinger on 9/21/18.
//  Copyright © 2018 Universal Music Group. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

class StreamPlayerViewController: AVPlayerViewController{
    var playerItem:AVPlayerItem?
    var albumArtView:UIImageView?
    
    override func viewWillAppear(_ animated: Bool) {
        let url = URL(string: "https://dcwsdmsexj.execute-api.us-east-1.amazonaws.com/dev/v1/upc/00602527364216/cover")!
        var request = URLRequest(url: url);
        request.setValue("8F2E1lR1tJ9UaMHaSJ8k44RpRiWAYgy05C56vi3v", forHTTPHeaderField: "x-api-key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let jsonWithObjectRoot = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJson = jsonWithObjectRoot as? [String: Any] {
                if let coverUrl = responseJson["coverUrl"] as? String {
                    self.albumArtView = UIImageView()
                    self.downloadImage(urlstr: coverUrl, imageView: self.albumArtView!)
                }
            }
        }
        task.resume()
        self.player?.play()
    }
    
    func downloadImage(urlstr: String, imageView: UIImageView) {
        let url = URL(string: urlstr)!
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async { // Make sure you're on the main thread here
                imageView.frame = UIScreen.main.bounds
                imageView.bounds = CGRect(x: 0, y: 0, width: 250, height: 250)
                imageView.image = UIImage(data: data)
            }
        }
        task.resume()
    }}

