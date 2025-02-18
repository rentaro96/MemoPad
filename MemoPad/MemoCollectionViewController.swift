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
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
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
        
        
        timerLabel?.frame = CGRect(x: 50, y: 100, width: 200, height: 50)
        
        
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
        contentConfiguration.secondaryText = contents[indexPath.item]
        cell.contentConfiguration = contentConfiguration
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
            timerLabel.text = "\(hours):\(minutes)"

            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)

            NotificationManager.setTimeIntervalNotification(title: title, timeInterval: TimeInterval(totalSeconds))
            print("通知が設定されました: \(title) - \(totalSeconds)秒後")

            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(totalSeconds)) {
                self.statusLabel.text = "達成！"
                self.animationView.animation = LottieAnimation.named("success")
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
        if countdown > 0 {
            let remainingMinutes = countdown / 60
            let remainingSeconds = countdown % 60
            let timeString = String(format: "%02d:%02d", remainingMinutes, remainingSeconds)
            print("タイマー更新: \(timeString)")
            DispatchQueue.main.async {
                self.timerLabel.text = timeString
                self.timerLabel.textColor = .black
                print("timerLabel:" , self.timerLabel ?? "nil")
            }
            
            countdown -= 1
            
        } else {
            print("タイマー終了")
            timer?.invalidate()
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

