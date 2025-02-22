//
//  MemoCollectionViewController.swift
//  MemoPad
//
//  Created by 鈴木廉太郎 on 2024/12/07.
//

import UIKit
import Lottie
import AVFoundation

class MemoCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, AVAudioPlayerDelegate {

    var timer: Timer?
    var countdown: Int = 0
    var startTime: Date?
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet weak var animationView: LottieAnimationView!

    var saveData: UserDefaults = UserDefaults.standard
    var titles: [String] = []
    var contents: [String] = []
    var player: AVAudioPlayer?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    func refreshData() {
        titles = saveData.object(forKey: "titles") as? [String] ?? []
        contents = saveData.object(forKey: "contents") as? [String] ?? []
        collectionView.reloadData()
    }

    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            let deleteAction = UIContextualAction(style: .destructive, title: "削除") { [weak self] (_, _, completionHandler) in
                self?.deleteMemo(at: indexPath)
                completionHandler(true)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        //セクションのレイアウトを設定
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            //スワイプアクションの設定を保持
            configuration.trailingSwipeActionsConfigurationProvider = {[weak self]indexPath in
                let deleteAction = UIContextualAction(style: .destructive, title: "削除"){[weak self](action,view, completionHandler) in
                    self?.deleteMemo(at: indexPath)
                    completionHandler(true)
                }
                return UISwipeActionsConfiguration(actions: [deleteAction])
            }
            
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            
            //セクション全体の余白を設定
            section.contentInsets = NSDirectionalEdgeInsets(top: 10,leading: 10,bottom: 10, trailing: 10)
            //セル間の間隔を設定
            section.interGroupSpacing = 10
            
            return section
        }
        collectionView.collectionViewLayout = layout
        }

    func deleteMemo(at indexPath: IndexPath) {
        titles.remove(at: indexPath.item)
        contents.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
        saveData.set(titles, forKey: "titles")
        saveData.set(contents, forKey: "contents")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerLabel.isHidden = false
        timerLabel.alpha = 1.0
        
        
        //timerLabel?.frame = CGRect(x: 50, y: 100, width: 200, height: 50)
        
        
        prepareSound()
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.5
        animationView.play()

        saveData.register(defaults: ["titles": [], "contents": []])
        setupCollectionView()
        
        
    }
    
    

    func prepareSound() {
        guard let soundFilePath = Bundle.main.path(forResource: "alarm", ofType: "mp3") else {
            print("サウンドファイルが見つかりません")
            return
        }
        let soundURL = URL(fileURLWithPath: soundFilePath)
        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
            player?.delegate = self
            player?.prepareToPlay()
        } catch {
            print("サウンドの読み込みに失敗しました: \(error)")
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        var contentConfiguration = UIListContentConfiguration.subtitleCell()
        
        contentConfiguration.text = titles[indexPath.item]
        contentConfiguration.textProperties.font = .systemFont(ofSize: 24,weight: .medium)
        contentConfiguration.textProperties.color = .label
        //サブタイトル（内容）のフォントサイズと設定
        contentConfiguration.secondaryText = contents[indexPath.item]
        contentConfiguration.secondaryTextProperties.font = .systemFont(ofSize: 16)
        contentConfiguration.secondaryTextProperties.color = .secondaryLabel
        
        //テキストの間の余白を設定
        contentConfiguration.textToSecondaryTextVerticalPadding = 8
        
        //セル内のコンテンツの余白を設定
        contentConfiguration.directionalLayoutMargins = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        
        
        cell.contentConfiguration = contentConfiguration
        
        //セルの最小高さを設定
        cell.frame.size.height = 64
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTitle = titles[indexPath.item]
        let selectedContent = contents[indexPath.item]

        print("選択されたメモ")
        print("タイトル: \(selectedTitle)")
        print("内容: \(selectedContent)")

        scheduleNotification(from: selectedContent, title: selectedTitle)
        statusLabel.text = "\(selectedTitle)を進行中"
        animationView.animation = LottieAnimation.named("work")
        animationView.play()
    }

    func scheduleNotification(from content: String, title: String) {
        let components = content.split(separator: ":")
        if components.count == 2,
           let hours = Int(components[0]),
           let minutes = Int(components[1]) {
            let totalSeconds = hours * 3600 + minutes * 60
            countdown = totalSeconds
            startTime = Date()
            //timerLabel.text = "\(hours):\(minutes)"

            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)

            NotificationManager.setTimeIntervalNotification(title: title, timeInterval: TimeInterval(totalSeconds))
            print("通知が設定されました: \(title) - \(totalSeconds)秒後")

            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(totalSeconds)) {
                self.statusLabel.text = "達成！"
                self.animationView.animation = LottieAnimation.named("達成")
                self.animationView.play()
                self.player?.play()

                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.player?.stop()
                    self.statusLabel.text = "動作中アラームなし"
                    self.animationView.animation = LottieAnimation.named("chair")
                    self.animationView.play()
                }
            }
        } else {
            print("通知設定に失敗しました: 時間情報が不正です (\(content))")
        }
    }

    @objc func updateTimer() {
       guard let startTime = startTime else { return }
        let elapsed = Int(Date().timeIntervalSince(startTime))
        let remainingTime = max(countdown - elapsed, 0)
        
        if remainingTime > 0{
            let hours = remainingTime / 3600
            let minutes = (remainingTime % 3600) / 60
            let seconds = remainingTime % 60
           
            var timeString : String
            if hours > 0 {
                timeString = String(format: "%d:%02d:%02d", hours, minutes, seconds)
            }else  {
                timeString = String(format: "%02d:%02d", minutes, seconds)
                
            }
            print("タイマー更新\(timeString)")
           
            }
            
            print("タイマー終了")
            timerLabel.text = ""
            timer?.invalidate()
            DispatchQueue.main.async {
                self.statusLabel.text = "達成！"
                self.animationView.animation = LottieAnimation.named("達成")
                self.animationView.play()
                self.player?.play()
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.player?.stop()
                    self.statusLabel.text = "動作中アラームなし"
                    self.animationView.animation = LottieAnimation.named("chair")
                    self.animationView.play()
                }
            
            }
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


