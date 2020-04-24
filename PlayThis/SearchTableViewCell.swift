//
//  SearchTableViewCell.swift
//  PlayThis
//
//  Created by Logan Pratt on 7/17/15.
//  Copyright (c) 2015 Logan Pratt. All rights reserved.
//

import UIKit
//import Parse

import Firebase
import FirebaseDatabase
import Alamofire
import SwiftyJSON

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var songCover: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var addSongButton: UIButton!
    @IBOutlet weak var addedLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var titleConstraint: NSLayoutConstraint!
    
    
    var songId = ""
    var groupCode = ""
    let songs = SongsHelper.sharedInstance
    var ref = Database.database().reference()
    var song: Song? = nil
    let apikey = "AIzaSyD1-VaGgcjv_AcIcuXTTgNRvzvQ02jWLXU"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
   
    func setCode(_ code: String) {
        groupCode = code
    }
    
    @objc func setUpCell(_ imageUrl: String, songTitle: String, songArtist: String, songId: String, code: String) {
        if let checkedUrl = URL(string: imageUrl) {
            songCover.kf.setImage(with: checkedUrl)
        }
        let detailsUrl = "https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=\(songId)&key=\(apikey)"
        AF.request(detailsUrl).responseJSON { (data) -> Void in
            switch data.result{
            case .success(let value):
                let json = JSON(value)
                print(json)
                if let duration = json["items", 0, "contentDetails", "duration"].string {
                    self.song = Song(group: code, name: songTitle, artist: songArtist, coverURL: imageUrl, id: songId, key:"", duration: duration)
                            self.durationLabel.text = self.song?.duration
                }
            case .failure(let error):
                print(error)
            }
        }
        songTitleLabel.text = songTitle
        songArtistLabel.text = songArtist
        self.songId = songId
        groupCode = code
        addSongButton.isHidden = false
        
        let songIsAdded = (songs.songs.filter() { $0.id == songId }.count > 0)
        
        if songIsAdded {
            addedLabel.isHidden = false
            addSongButton.isHidden = true
        } else {
            addedLabel.isHidden = true
            addSongButton.isHidden = false
        }
    }
 
    @objc func getDataFromUrl(_ urL:URL, completion: @escaping ((_ data: Data?) -> Void)) {
        URLSession.shared.dataTask(with: urL) { (data, response, error) in
            completion(data)
            }.resume()
    }
    
 
    @objc func downloadImage(_ url:URL){
//        println("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
        getDataFromUrl(url) { data in
            DispatchQueue.main.async {
//                println("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                self.songCover.image = UIImage(data: data!)
            }
        
        }
    }
    
    
    
    @IBAction func addSong(_ sender: AnyObject) {
        addSongButton.isHidden = !addSongButton.isHidden
        addedLabel.isHidden = !addedLabel.isHidden
        titleConstraint.constant = 55

        let songRef = self.ref.child("songs")
        songRef.childByAutoId().setValue(song?.toAnyObject())

       // songRef.setValue(song?.toAnyObject())
        
        //groupRef.setValue(group.toAnyObject())
       // var group: Group;// = Group()
        //let groupRef = self.ref.child("groups").child(groupCode)
        //groupRef.value(forKeyPath: "")
        //groupRef.updateChildValues(["songs": groupRef.value])
//        let query = PFQuery(className: "Group")
//        query.whereKey("groupCode", equalTo: groupCode)
//        query.findObjectsInBackground {(groups: [AnyObject]?, error: Error?) -> Void in
//            
//            if error == nil {
//                if let groups = groups as? [PFObject] {
//                    for group in groups {
//                        let newSong = PFObject(className: "Song")
//                        newSong["songId"] = self.songId
//                        newSong["group"] = group
//                        newSong["likes"] = 0
//                        newSong.saveInBackground()
//                    }
//                }
//            } else {
//                // Log details of the failure
//                print("Error: \(error!) \(error!._userInfo)")
//            }
//        }HERE
 
 
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
