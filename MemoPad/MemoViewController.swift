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
    
    var saveDeta: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField .text  = saveDeta.object(forKey:"title")as? String
        contentTextView.text = saveDeta.object(forKey:"content")as?String
        titleTextField.delegate = self
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveMemo(_ sender : Any) {
        
        saveDeta.set (titleTextField.text, forKey:"title")
        saveDeta.set (contentTextView.text, forKey:"content")
        
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
