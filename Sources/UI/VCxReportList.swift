//
//  ShotsViewController.swift
//  Public Eyes
//
//  Created by Fitsyu  on 24/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import UIKit

final class VCxReportList: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var huntButton: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var removeSelectedButton: UIButton!
    
    @IBOutlet weak var removeAllButton: UIButton!
    
    @IBOutlet weak var removeButtonsStackView: UIStackView!
        
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: Actions
    
    @IBAction func actOnHuntButton(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toVCxHunt", sender: self)
    }
    
    @IBAction func actOnEditButton(_ sender: UIButton) {
        
        if let title = sender.currentTitle, title == "Edit" {
            
            ReportList.Act.Edit.dispatch()
        } else {
            
            ReportList.Act.DoneEditing.dispatch()
        }
    }
    
    @IBAction func actOnRemoveSelectedButton(_ sender: UIButton) {

       // ReportList.Act.RemoveSelected([]).dispatch()
    }
    
    @IBAction func actOnRemoveAllButton(_ sender: UIButton) {

        ReportList.Act.RemoveAll.dispatch()
    }
    
    // MARK: Properties
    var models: [Report] = []
    
    // MARK: Life Cycles
    
    override func viewDidLoad() {
        
        let nib = UINib(nibName: ReportCell.ID, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ReportCell.ID)
        
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.contentInset.top = 64
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        ReportList.store.subscribe(self) 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // TODO:
        // for testing only
        // remove later
        ReportList.Act.Show.dispatch()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        ReportList.store.unsubscribe(self)
    }
}

extension VCxReportList: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ReportCell.ID, for: indexPath) as! ReportCell
        cell.data = models[indexPath.row]
        
        return cell
    }
    
}


extension VCxReportList: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("didSelect")
//        if !tableView.isEditing {
        
            let report: Report = models[indexPath.row]
            
            //        let nvc = VCxReportDetail()
            //        present(nvc, animated: true, completion: {
            //            ReportDetail.Act.Show(report).dispatch()
            //        })
            
            performSegue(withIdentifier: "toVCxReportDetail", sender: self)
            ReportDetail.Act.Show(report).dispatch()
//        } else {
//
//
//        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let action = UITableViewRowAction(style: .destructive,
                                          title: "Remove") { (action: UITableViewRowAction, indexPath: IndexPath) in
                                            
                                            print(action, indexPath)
        }
        
        return [action]
        
    }
}

import ReSwift

extension VCxReportList: StoreSubscriber {
    
    func newState(state: ReportList.State) {
        
        if state.isEditing {
            editButton.setTitle("Done", for: .normal)
        } else {
            editButton.setTitle("Edit", for: .normal)
        }
        
        tableView.setEditing(state.isEditing, animated: true)
        
        removeButtonsStackView.isHidden = !state.isEditing
        
        tableView.isHidden  = state.reports.isEmpty
//        editButton.isHidden = state.reports.isEmpty
        emptyLabel.isHidden = !state.reports.isEmpty
        

        models = state.reports.reversed()
        tableView.reloadData()
//        var paths = (0..<models.count).map { IndexPath(row: $0, section: 0) }
//        tableView.deleteRows(at: paths, with: .right)
//
//        models = state.reports
//        paths = (0..<models.count).map { IndexPath(row: $0, section: 0) }
//        tableView.insertRows(at: paths, with: .left)
        
        
        tableViewBottomConstraint.constant = state.isEditing ? 72 : 0
    }
}
