//
//  ViewController.swift
//  taskapp
//
//  Created by PC-SYSKAI553 on 2021/03/23.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    //Realmインスタンスをrealmに格納。（個人データを編集するのに使用）
    let realm = try! Realm()
    
    // DB内のタスクが格納される配列。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    // 検索結果用の配列
    var searchArray: Results<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchbar.delegate = self
        searchbar.enablesReturnKeyAutomatically = false
        
        searchArray = taskArray
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //InputVCインスタンスを作成
        let inputVC: InputViewController = segue.destination as! InputViewController
        
        //セルタップの場合の値受け渡し
        if segue.identifier == "cellSegue" {
            //セル位置情報を取得、格納
            let indexPath = tableView.indexPathForSelectedRow
            //セル位置に応じたデータをinputVCのtaskに格納
            inputVC.task = searchArray[indexPath!.row]
        } else {            //追加時の値受け渡し
            let task = Task()
            let alltasks = realm.objects(Task.self)
            //すでにデータがある場合はidに+1する
            if alltasks.count != 0 {
                task.id = alltasks.max(ofProperty: "id")! + 1
            }
            //idを更新した状態でinputVCのtaskに格納
            inputVC.task = task
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //取り出したデータをtaskに格納
        let task = searchArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //セルタップで呼ばれるSegueを指定
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        //UITableViewCell.EditingStyleプロパティにdeleteを設定、列挙型を参照
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            //削除するtaskを取得
            let task = searchArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    //検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる。
        searchBar.endEditing(true)
    }
 
 
    //テキスト変更時の呼び出しメソッド
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchbar.text == "") {
            //検索文字列が空の場合はすべてを表示する。
            searchArray = taskArray
        } else {
            searchArray = realm
                .objects(Task.self)
                .filter("category BEGINSWITH %@", searchText)
        }
        
        //テーブルを再読み込みする。
        tableView.reloadData()
    }

}

