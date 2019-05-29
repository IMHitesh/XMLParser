//
//  ViewController.swift
//  HIteshSuraniPractical
//
//  Created by sooryen on 28/05/19.
//  Copyright © 2019 sooryen. All rights reserved.
//

import UIKit

let baseURL = "http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topsongs/l%20imit=25/xml"

let DB_TBL_NAME = "tblAudioData"
let placeHolder = UIImage(named: "placeholder")

class AudioListVC: UIViewController {
    
    //MARK: XML Elements name
    var id = String()
    var titleValue = String()
    var audioURL = String()
    var imageURL = String()
    var elementName = String()
    
    var aryAudio = [ModelAudio]()
    
    @IBOutlet weak var tblAudioList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchData()
    }
    
    func setupView(){
        tblAudioList.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tblAudioList.tableFooterView = UIView()
        self.title = "Audio List"
    }
    
    func fetchData(){
        fetchDataFromDB()
        if aryAudio.count == 0 {
            callAppleAudioListAPI()
        }
    }
}


//MARK:- API Call
extension AudioListVC{
    
    func callAppleAudioListAPI() {
        
        guard let url = URL(string: baseURL) else{
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                print(error.debugDescription)
                return}
            
            DispatchQueue.main.async {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        }
        task.resume()
    }
}


//MARK:- XML Parser delegate methods
extension AudioListVC:XMLParserDelegate{
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == ElementName.entry.rawValue{
            titleValue = String()
            audioURL = String()
        }else if elementName == ElementName.link.rawValue{
            if(attributeDict["type"] == "audio/x-m4a"){
                audioURL = attributeDict["href"] ?? ""
            }
        }else if elementName == ElementName.id.rawValue{
            id = attributeDict["im:id"] ?? ""
        }
        self.elementName = elementName
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "entry"{
            let objAudio = ModelAudio.init(id:id,title: titleValue, audioURL: audioURL, image: imageURL)
            HSDBManager.sharedInstance.methodToInsertUpdateDeleteData(prepareInsertQuery(audio: objAudio)) { (status) in
                print(status)
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            if self.elementName == ElementName.title.rawValue{
                titleValue = data
            }else if self.elementName == ElementName.imimage.rawValue{
                imageURL = data
            }
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        fetchDataFromDB()
    }
    
    fileprivate func fetchDataFromDB() {
        HSDBManager.sharedInstance.methodToSelectData("SELECT * FROM \(DB_TBL_NAME)") { (aryAudioData) in
            for dict in aryAudioData{
                if let dictAudio = dict as? NSDictionary {
                    let id = dictAudio.value(forKey: "id") as? String ?? ""
                    let title = dictAudio.value(forKey: "title") as? String ?? ""
                    let audioURL = dictAudio.value(forKey: "audioURL") as? String ?? ""
                    let image = dictAudio.value(forKey: "image") as? String ?? ""
                    let objAudio = ModelAudio.init(id: id, title: title, audioURL: audioURL, image: image)
                    self.aryAudio.append(objAudio)
                }
            }
            self.tblAudioList.reloadData()
            print(self.aryAudio)
        }
    }
    
    func prepareInsertQuery(audio:ModelAudio) -> String{
        let id = audio.id!
        let title = audio.title!
        let audioURL = audio.audioURL!
        let image = audio.image!
        
        return "INSERT INTO \(DB_TBL_NAME) (id,title,audioURL,image) VALUES('\(id)','\(title)','\(audioURL)','\(image)')"
    }
}

//MARK:- UITableView Datasource and delegate methods
extension AudioListVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryAudio.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let objAudio = aryAudio[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = objAudio.title
        cell.imageView?.image = placeHolder
        HSImageLoader.image(for: objAudio.image ?? "") { (image) in
            if image == nil{
                cell.imageView?.image = placeHolder
            }else{
                cell.imageView?.image = image
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let objAudioDetails = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioDetailsVC") as! AudioDetailsVC
        objAudioDetails.objModelAudio = aryAudio[indexPath.row]
        self.navigationController?.pushViewController(objAudioDetails, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
