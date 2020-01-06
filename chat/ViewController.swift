//
//  ViewController.swift
//  chat
//
//  Created by Atiaf on 1/6/20.
//  Copyright © 2020 Atiaf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

//
//  ChatVC.swift
//  delivary
//
//  Created by Atiaf on 12/11/19.
//  Copyright © 2019 Atiaf. All rights reserved.
//

import UIKit

class ChatVC: UIViewController {
    
    
    var chat_txt = [[String:Any]]()
    var meta = [String:Any]()
    var page = 0
    var flag = 0
    
    
    //MARK:- loading
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var subview: UIView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    func loading(_ value:Bool){
        if value{
            self.container.isHidden = !value
            self.loading.startAnimating()
        }else{
            DispatchQueue.main.async {
                self.container.isHidden = !value
                self.loading.stopAnimating()
            }
        }
    }
    
    
    //MARK:- outlets
    @IBOutlet weak var test_label: UILabel!
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var txt_view: UIView!
    @IBOutlet weak var txt_message: UITextView!
    @IBOutlet weak var chat: UICollectionView!
    @IBOutlet weak var txt_message_height: NSLayoutConstraint!
    @IBOutlet weak var down_constraint: NSLayoutConstraint!
    @IBOutlet weak var back_btn: UIButton!
    @IBOutlet weak var send_btn: UIButton!
    
    
    //functions
    func display(){
        self.txt_view.layer.cornerRadius = 25
        self.txt_view.static_shadow()
    }
    
    func delegete(){
        self.chat.delegate = self
        self.chat.dataSource = self
    }
    
    func set_chat(_ chatTXT:[[String:Any]]){
        
        for item in chatTXT{
            self.chat_txt.insert(item, at: 0)
        }
        
        self.delegete()
        self.chat.reloadData()
        if self.page == 0 {
            self.chat.scrollToItem(at: IndexPath(row: self.chat_txt.count-1, section: 0), at: .bottom, animated: true)
            
        }
    }
    
    
    //MARK:- actions
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func send_message(_ sender: UIButton) {
        if self.txt_message.text!.isEmpty || self.txt_message.text == " "{
            DispatchQueue.main.async {
                self.present(alert.ALERT("can not send empty message", ""), animated: true, completion: nil)
            }
        }else{
            self.loading(true)
            let text = txt_message.text!
            self.send_reply("\(text)")
        }
    }
    
    //MARK:- viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UserDefaults.standard.object(forKey: "lang") as! String) == "ar"{
            self.set_chat_directions("ar")
        }else{
            self.set_chat_directions("en")
        }
        
        self.heading.text = "\(UserDefaults.standard.object(forKey: "customer_name") as! String)"
        
        self.subview.layer.cornerRadius = 10
        self.loading(true)
        self.get_chat()
        self.txt_message.delegate = self
        self.txt_message.resignFirstResponder()
        self.display()
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.down_constraint.constant == 0 {
                self.down_constraint.constant = -keyboardSize.height-60
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.down_constraint.constant != 0 {
            self.down_constraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
}




//MARK:- chat collection
extension ChatVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var
        height = self.test_label.heightForLabel(text: self.chat_txt[indexPath.row]["content"] as! String, font: UIFont(descriptor: UIFontDescriptor(name: "System", size: 18), size: 18), width: (UIScreen.main.bounds.width-176))
        
        
        if height < 65{
            height = 65
        }else{
            
        }
        
        return CGSize(width: UIScreen.main.bounds.width-20, height: (height+101.5))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.chat_txt.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chat cell", for: indexPath) as! ChatCell
        
        
        let date = functions.get_spaceific_formater_from_date("\(self.chat_txt[indexPath.row]["created_at"] as! String)", "MM-dd-yyyy HH:mm")
        
        if self.chat_txt[indexPath.row]["customer_id"] as! String == "\(UserDefaults.standard.object(forKey: UserID) as! String)"{
            cell.is_me_who_send(true)
            cell.me_text.text = "\(self.chat_txt[indexPath.row]["content"] as! String)"
            cell.me_date.text = "\(date)"
            
        }else{
            cell.is_me_who_send(false)
            cell.member_text.text = "\(self.chat_txt[indexPath.row]["content"] as! String)"
            cell.member_date.text = "\(date)"
            
            
            
            //set the customer photo
            let customer = self.chat_txt[indexPath.row]["customer"] as! [String:Any]
            
            let imgURL = URL(string: "\(customer["img"] as! String)")
            cell.image.sd_setImage(with: imgURL)
            
            
            
        }
        
        if indexPath.row == self.chat_txt.count-1 && self.flag == 0{
            self.flag = 1
        }
        cell.member_display()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == 0 && self.flag == 1 && self.chat_txt.count != self.meta["total"] as! Int{
            self.page += 1
            self.get_chat()
        }
    }
    
    
    
}



//MARK:- text view extension
extension ChatVC:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        else{
            self.txt_message_height.constant = textView.contentSize.height
            
        }
        return true
    }
}


extension ChatVC{
    func send_reply(_ text:String){
        let parameters = [
            "key": KEY,
            "content": "\(text)",
            "ticket_id": "\(UserDefaults.standard.object(forKey: "chat_id") as! String)",
            "customer_id": "\(UserDefaults.standard.object(forKey: UserID) as! String)",
            "time": "\(functions.get_current_time())"
        ]
        
        let url = URL(string: SendReply)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("\(UserDefaults.standard.object(forKey: UserTOKEN) as! String)", forHTTPHeaderField: "Token")
        request.setValue("\(UserDefaults.standard.object(forKey: "lang") as! String)", forHTTPHeaderField: "Lang")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard let data = data else {
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    
                    
                    if let _ = json["errNum"] {
                        DispatchQueue.main.async {
                            self.present(alert.ALERT(json["message"] as! String, ""), animated: true, completion: nil)
                        }
                    }else{
                        self.page = 0
                        self.flag = 1
                        self.chat_txt.removeAll()
                        DispatchQueue.main.async {
                            self.get_chat()
                            self.txt_message.text = ""
                        }
                        
                    }
                    
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    
    
    func get_chat(){
        let parameters = [
            "key": KEY,
            "ticket_id": "\(UserDefaults.standard.object(forKey: "chat_id") as! String)",
            "page_number": "\(self.page)"
        ]
        
        let url = URL(string: Tickets)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("\(UserDefaults.standard.object(forKey: UserTOKEN) as! String)", forHTTPHeaderField: "Token")
        request.setValue("\(UserDefaults.standard.object(forKey: "lang") as! String)", forHTTPHeaderField: "Lang")
        request.setValue("ar", forHTTPHeaderField: "Lang")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard let data = data else {
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    
                    print("caht - > \(json)")
                    
                    
                    if self.flag == 0{
                        self.loading(false)
                    }
                    
                    let result = json["result"] as! [[String:Any]]
                    
                    DispatchQueue.main.async {
                        self.meta = json["meta"] as! [String:Any]
                        self.set_chat(result)
                    }
                    
                    
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
}
