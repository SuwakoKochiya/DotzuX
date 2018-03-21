//
//  DotzuX.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class LogViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var flag: Bool = false
    var selectedSegmentIndex: Int = 0
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var defaultTableView: UITableView!
    @IBOutlet weak var defaultSearchBar: UISearchBar!
    var defaultModels: [LogModel] = [LogModel]()
    var defaultCacheModels: Array<LogModel>?
    var defaultSearchModels: Array<LogModel>?
    
    @IBOutlet weak var colorTableView: UITableView!
    @IBOutlet weak var colorSearchBar: UISearchBar!
    var colorModels: [LogModel] = [LogModel]()
    var colorCacheModels: Array<LogModel>?
    var colorSearchModels: Array<LogModel>?
    
    
    
    //MARK: - tool
    //搜索逻辑
    func searchLogic(_ searchText: String = "") {
        
        if selectedSegmentIndex == 0
        {
            guard let defaultCacheModels = defaultCacheModels else {return}
            defaultSearchModels = defaultCacheModels
            
            if searchText == "" {
                defaultModels = defaultCacheModels
            }else{
                guard let defaultSearchModels = defaultSearchModels else {return}
                
                for _ in defaultSearchModels {
                    if let index = self.defaultSearchModels?.index(where: { (model) -> Bool in
                        return !model.content.lowercased().contains(searchText.lowercased())//忽略大小写
                    }) {
                        self.defaultSearchModels?.remove(at: index)
                    }
                }
                defaultModels = self.defaultSearchModels ?? []
            }
        }
        else
        {
            guard let colorCacheModels = colorCacheModels else {return}
            colorSearchModels = colorCacheModels
            
            if searchText == "" {
                colorModels = colorCacheModels
            }else{
                guard let colorSearchModels = colorSearchModels else {return}
                
                for _ in colorSearchModels {
                    if let index = self.colorSearchModels?.index(where: { (model) -> Bool in
                        return !model.content.lowercased().contains(searchText.lowercased())//忽略大小写
                    }) {
                        self.colorSearchModels?.remove(at: index)
                    }
                }
                colorModels = self.colorSearchModels ?? []
            }
        }
    }
    
    //MARK: - private
    func reloadLogs(_ isFirstIn: Bool = false, _ needReloadData: Bool = true) {
        
        if selectedSegmentIndex == 0
        {
            defaultTableView.isHidden = false
            colorTableView.isHidden = true
            
            if needReloadData == false && defaultModels.count > 0 {return}
            
            defaultModels = LogStoreManager.shared.defaultLogArray
            
            self.defaultCacheModels = self.defaultModels
            
            self.searchLogic(DotzuXSettings.shared.logSearchWordDefault ?? "")
            
            dispatch_main_async_safe { [weak self] in
                self?.defaultTableView.reloadData()
                
                if isFirstIn == false {return}
                
                //table下滑到底部
                guard let count = self?.defaultModels.count else {return}
                if count > 0 {
                    self?.defaultTableView.tableViewScrollToBottom(animated: false)
                    //self?.defaultTableView.scrollToRow(at: IndexPath.init(row: count-1, section: 0), at: .bottom, animated: false)
                    
                    /*
                     //滑动不到最底部, 弃用
                     if let h1 = self?.tableView.contentSize.height, let h2 = self?.tableView.frame.size.height, let bottom = self?.tableView.contentInset.bottom {
                     if h1 > h2 {
                     self?.tableView.setContentOffset(CGPoint.init(x: 0, y: h1-h2+bottom), animated: false)
                     }
                     }*/
                }
            }
        }
        else
        {
            defaultTableView.isHidden = true
            colorTableView.isHidden = false
            
            if needReloadData == false && colorModels.count > 0 {return}
            
            colorModels = LogStoreManager.shared.colorLogArray
            
            self.colorCacheModels = self.colorModels
            
            self.searchLogic(DotzuXSettings.shared.logSearchWordColor ?? "")
            
            dispatch_main_async_safe { [weak self] in
                self?.colorTableView.reloadData()
                
                if isFirstIn == false {return}
                
                //table下滑到底部
                guard let count = self?.colorModels.count else {return}
                if count > 0 {
                    self?.colorTableView.tableViewScrollToBottom(animated: false)
                    //self?.colorTableView.scrollToRow(at: IndexPath.init(row: count-1, section: 0), at: .bottom, animated: false)
                    
                    /*
                     //滑动不到最底部, 弃用
                     if let h1 = self?.tableView.contentSize.height, let h2 = self?.tableView.frame.size.height, let bottom = self?.tableView.contentInset.bottom {
                     if h1 > h2 {
                     self?.tableView.setContentOffset(CGPoint.init(x: 0, y: h1-h2+bottom), animated: false)
                     }
                     }*/
                }
            }
        }
    }
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLogs_notification), name: NSNotification.Name("refreshLogs_DotzuX"), object: nil)
        
        defaultTableView.tableFooterView = UIView()
        defaultTableView.delegate = self
        defaultTableView.dataSource = self
        defaultSearchBar.delegate = self
        defaultSearchBar.text = DotzuXSettings.shared.logSearchWordDefault
        
        colorTableView.tableFooterView = UIView()
        colorTableView.delegate = self
        colorTableView.dataSource = self
        colorSearchBar.delegate = self
        colorSearchBar.text = DotzuXSettings.shared.logSearchWordColor
        
        //segmentedControl
        selectedSegmentIndex = DotzuXSettings.shared.logSelectIndex 
        segmentedControl.selectedSegmentIndex = selectedSegmentIndex
        
        reloadLogs(true)

        //hide searchBar icon
        let textFieldInsideSearchBar = defaultSearchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.leftViewMode = UITextFieldViewMode.never
        
        let textFieldInsideSearchBar2 = colorSearchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar2.leftViewMode = UITextFieldViewMode.never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if flag == true {return}
        flag = true
        
        
        if selectedSegmentIndex == 0
        {
            let count = self.defaultModels.count
            
            if count > 0 {
                //否则第一次进入滑动不到底部
                DispatchQueue.main.async { [weak self] in
                    self?.defaultTableView.tableViewScrollToBottom(animated: false)
                    //self?.defaultTableView.scrollToRow(at: IndexPath.init(row: count-1, section: 0), at: .bottom, animated: false)
                }
            }
        }
        else
        {
            let count = self.colorModels.count
            
            if count > 0 {
                //否则第一次进入滑动不到底部
                DispatchQueue.main.async { [weak self] in
                    self?.colorTableView.tableViewScrollToBottom(animated: false)
                    //self?.colorTableView.scrollToRow(at: IndexPath.init(row: count-1, section: 0), at: .bottom, animated: false)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        defaultSearchBar.resignFirstResponder()
        colorSearchBar.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == defaultTableView {
            return defaultModels.count
        }else{
            return colorModels.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == defaultTableView {
            //否则偶尔crash
            if indexPath.row >= defaultModels.count {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath)
                as! LogCell
            cell.model = defaultModels[indexPath.row]
            return cell
        }else{
            //否则偶尔crash
            if indexPath.row >= colorModels.count {
                return UITableViewCell()
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath)
                as! LogCell
            cell.model = colorModels[indexPath.row]
            return cell
        }
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == defaultTableView {
            tableView.deselectRow(at: indexPath, animated: true)
            defaultSearchBar.resignFirstResponder()
        }else{
            tableView.deselectRow(at: indexPath, animated: true)
            colorSearchBar.resignFirstResponder()
        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == defaultTableView {
            let model = defaultModels[indexPath.row]
            var title = "Tag"
            if model.isTag == true {title = "UnTag"}
            
            let left = UIContextualAction(style: .normal, title: title) { [weak self] (action, sourceView, completionHandler) in
                model.isTag = !model.isTag
                self?.dispatch_main_async_safe { [weak self] in
                    self?.defaultTableView.reloadData()
                }
                completionHandler(true)
            }
            
            defaultSearchBar.resignFirstResponder()
            left.backgroundColor = .init(hexString: "#007aff")
            return UISwipeActionsConfiguration(actions: [left])
        }else{
            let model = colorModels[indexPath.row]
            var title = "Tag"
            if model.isTag == true {title = "UnTag"}
            
            let left = UIContextualAction(style: .normal, title: title) { [weak self] (action, sourceView, completionHandler) in
                model.isTag = !model.isTag
                self?.dispatch_main_async_safe { [weak self] in
                    self?.colorTableView.reloadData()
                }
                completionHandler(true)
            }
            
            colorSearchBar.resignFirstResponder()
            left.backgroundColor = .init(hexString: "#007aff")
            return UISwipeActionsConfiguration(actions: [left])
        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == defaultTableView {
            let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, sourceView, completionHandler) in
                guard let models = self?.defaultModels else {return}
                LogStoreManager.shared.removeLog(models[indexPath.row])
                self?.defaultModels.remove(at: indexPath.row)
                self?.dispatch_main_async_safe { [weak self] in
                    self?.defaultTableView.deleteRows(at: [indexPath], with: .automatic)
                }
                completionHandler(true)
            }
            
            defaultSearchBar.resignFirstResponder()
            return UISwipeActionsConfiguration(actions: [delete])
        }else{
            let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, sourceView, completionHandler) in
                guard let models = self?.colorModels else {return}
                LogStoreManager.shared.removeLog(models[indexPath.row])
                self?.colorModels.remove(at: indexPath.row)
                self?.dispatch_main_async_safe { [weak self] in
                    self?.colorTableView.deleteRows(at: [indexPath], with: .automatic)
                }
                completionHandler(true)
            }
            
            colorSearchBar.resignFirstResponder()
            return UISwipeActionsConfiguration(actions: [delete])
        }
    }
    
    //MARK: - only for ios8/ios9/ios10, not ios11
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == defaultTableView {
            if (editingStyle == .delete) {
                LogStoreManager.shared.removeLog(defaultModels[indexPath.row])
                self.defaultModels.remove(at: indexPath.row)
                self.dispatch_main_async_safe { [weak self] in
                    self?.defaultTableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }else{
            if (editingStyle == .delete) {
                LogStoreManager.shared.removeLog(colorModels[indexPath.row])
                self.colorModels.remove(at: indexPath.row)
                self.dispatch_main_async_safe { [weak self] in
                    self?.colorTableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView == defaultTableView {
            defaultSearchBar.resignFirstResponder()
        }else{
            colorSearchBar.resignFirstResponder()
        }
    }

    //MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchBar == defaultSearchBar {
            DotzuXSettings.shared.logSearchWordDefault = searchText
            searchLogic(searchText)
            
            dispatch_main_async_safe { [weak self] in
                self?.defaultTableView.reloadData()
            }
        }else{
            DotzuXSettings.shared.logSearchWordColor = searchText
            searchLogic(searchText)
            
            dispatch_main_async_safe { [weak self] in
                self?.colorTableView.reloadData()
            }
        }
    }
    
    //MARK: - target action
    @IBAction func resetLogs(_ sender: Any) {
        
        if selectedSegmentIndex == 0
        {
            defaultModels = []
            defaultCacheModels = []
            defaultSearchBar.text = nil
            defaultSearchBar.resignFirstResponder()
            DotzuXSettings.shared.logSearchWordDefault = nil
            
            LogStoreManager.shared.resetDefaultLogs()
            
            dispatch_main_async_safe { [weak self] in
                self?.defaultTableView.reloadData()
            }
        }
        else
        {
            colorModels = []
            colorCacheModels = []
            colorSearchBar.text = nil
            colorSearchBar.resignFirstResponder()
            DotzuXSettings.shared.logSearchWordColor = nil
            
            LogStoreManager.shared.resetColorLogs()
            
            dispatch_main_async_safe { [weak self] in
                self?.colorTableView.reloadData()
            }
        }
    }
    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        selectedSegmentIndex = segmentedControl.selectedSegmentIndex
        DotzuXSettings.shared.logSelectIndex = selectedSegmentIndex
        
        reloadLogs(false, false)
    }
    
    
    //MARK: - notification
    @objc func refreshLogs_notification() {
        reloadLogs()
    }
}



