//
//  InputViewController.swift
//  taskapp
//
//  Created by PC-SYSKAI553 on 2021/03/23.
//

import UIKit
import RealmSwift


class InputViewController: UIViewController {
    @IBOutlet weak var titletextfield: UITextField!
    @IBOutlet weak var contentstextview: UITextView!
    @IBOutlet weak var datapicker: UIDatePicker!
    
    let realm = try! Realm()
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        //viewプロパティにtapGestureを追加
        self.view.addGestureRecognizer(tapGesture)
        
        titletextfield.text = task.title
        contentstextview.text = task.contents
        datapicker.date = task.date
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titletextfield.text!
            self.task.contents = self.contentstextview.text!
            self.task.date = self.datapicker.date
            self.realm.add(self.task, update: .modified)
        }

        super.viewWillDisappear(animated)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
