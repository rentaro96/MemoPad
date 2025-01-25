//
//  MemoCollectionViewController.swift
//  MemoPad
//
//  Created by 鈴木廉太郎 on 2024/12/07.
//

import UIKit
//import Lottie

class MemoCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    //private var animationView: LottieAnimationView?
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    var saveData: UserDefaults = UserDefaults.standard
    
    var titles: [String] = []
    
    var contents : [String] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // animationView = .init(name:"loading")
        //animationView!.frame = view.bounds
       // animationView!.contentMode = .scaleAspectFit
        //animationView!.loopMode = .loop
        //animationView!.animationSpeed = 0.5
        //view.addSubview(animationView!)
        //animationView!.play()
        
        saveData.register(defaults: [ "titles": [], "contents": [] ])
        titles = saveData.object(forKey: "titles") as! [String]
        contents = saveData.object(forKey: "contents") as! [String]
        
        collectionView.dataSource = self
        
        collectionView.delegate = self
        
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        
    }
    
    func collectionView( _ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
        
    }
    func collectionView( _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        var contentConfiguration = UIListContentConfiguration.subtitleCell()
        contentConfiguration.text = titles[indexPath.item]
        contentConfiguration.secondaryText = contents[indexPath.item]
        cell.contentConfiguration = contentConfiguration
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,didSelectItemAt indexPath: IndexPath) {
        
        let selectedTitle = titles[indexPath.item]
        let selectedContent = contents[indexPath.item]
        
        print("選択されたメモ")
        print("タイトル: \(selectedTitle)")
        print("内容: \(selectedContent)")
        
        scheduleNotification(from: selectedContent, title: selectedTitle)
        
    }
    
    func scheduleNotification(from content: String, title: String) {
        let components = content.split(separator: ":")
        if components.count == 2,
           let hours = Int(components[0]),
           let minutes = Int(components[1]) {
            let totalseconds = hours * 3600 + minutes * 60
            
            NotificationManager.setTimeIntervalNotification(title: title, timeInterval: TimeInterval(totalseconds))
            print("通知が設定されました:\(title) - \(totalseconds)秒後")
                                                                                                     } else {
                print("通知設定に失敗しました: 時間情報が不正です (\(content))")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = UIColor.systemGray5
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = UIColor.clear
        }
        
        
        
    }
}

