//
//  MemoViewController.swift
//  MemoPad
//
//  Created by 鈴木廉太郎 on 2024/11/23.
//

import UIKit

class MemoViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var datepicker: UIDatePicker!
    
    func getPickerValue() -> String{
        let selectedTime = datepicker.countDownDuration
        let hour = (Int(selectedTime) / 3600)
        let minutes = Int(selectedTime) / 60 % 60
       
        print(selectedTime)
        print("選択された時間:\(hour)時間 \(minutes)分 ")
        let timeString: String = "\(hour):\(minutes)"
        return timeString
    }
    
    var saveData: UserDefaults = UserDefaults.standard
    
    var titles: [String] = []
    var contents: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveData.register(defaults: ["titles":[], "contents": [] ])
        titles = saveData.object(forKey:"titles") as! [String]
        contents = saveData.object(forKey:"contents") as! [String]
        
        print(titles)
        print(contents)
    titleTextField.delegate = self
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveMemo() {
        
        let title = titleTextField.text!
        let content = getPickerValue()
        
        titles.append(title)
        contents.append(content)
        
        saveData.set(titles,forKey:"titles")
        saveData.set(contents,forKey:"contents")
        
        let alert: UIAlertController = UIAlertController(title:"保存",message:"メモの保存が完了しました。",preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK",
                          style: .default,
                          handler:{ action in
                              self.navigationController?.popViewController(animated: true)
                              
                              
                          })
            
        )
        present (alert,animated: true,completion: nil)
        
        
        
        
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
        
        
    }
}
