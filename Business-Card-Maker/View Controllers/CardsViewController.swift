//
//  CardsViewController.swift
//  Business-Card-Maker
//
//  Created by Saud Almutlaq on 16/06/2020.
//  Copyright © 2020 Saud Soft. All rights reserved.
//

import UIKit
import CoreData

class CardsViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var toggleViewOutlet: UIBarButtonItem!
    
    var _fetchedResultsController: NSFetchedResultsController<Card>? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var isCardView = false
    var cardItems = [CardItem]()
    let cellScale: CGFloat = 0.7
    var vCards: [NSManagedObject] = []
    
    @IBAction func toggleView(_ sender: Any) {
        toggleViewType()
    }
    
    func toggleViewType() {
        print("toggleViewType")
        if isCardView {
            print("isCardView = ture")
            collectionView.isHidden = true
            tableView.isHidden = false
            toggleViewOutlet.image = UIImage(named: "CardsView")
            isCardView = !isCardView
        } else {
            print("isCardView = false")
            collectionView.isHidden = false
            tableView.isHidden = true
            toggleViewOutlet.image = UIImage(named: "ListView")
            isCardView = !isCardView
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        print("RowCount: \(vCards.count)")
        loadData()
        
        let itemID = UserDefaults.standard.integer(forKey: UserDefaults.keys.selectedItemIndex)
        
        if itemID >= 0 {
            DispatchQueue.main.async {
                // Code you want to be delayed
                self.collectionView.selectItem(at: IndexPath(item: itemID, section: 0), animated: true, scrollPosition: .top)
                self.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: itemID, section: 0))
            }
        }
        
        
        print(itemID)
    }
    
    func loadData() {
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Card")
        
        //3
        do {
            vCards = try managedContext.fetch(fetchRequest)
            print("Data Loaded :)")
            cardItems = CardItem.fetchVCards(vCards: vCards)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        self.collectionView.reloadData()
        
        self.tableView.reloadData()
        
        print("RowCount2: \(vCards.count)")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = NSLocalizedString("myCards", comment: "My Cards")
        toggleViewType()
        
        didShowInterstitialAd = false
        // Uncomment the following line to preserve selection between presentations
        
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        lpgr.minimumPressDuration = 1.0
        lpgr.delegate = self
        //        lpgr.delaysTouchesBegan = true
        self.collectionView?.addGestureRecognizer(lpgr)
    }
    
    func updateUI() {
        
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScale)
        let cellHeight = floor(screenSize.height)
        let insetX = (view.bounds.width - cellWidth) / 2.0
        let insetY = (view.bounds.height - cellHeight) / 2.0
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        
        self.collectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer) {
        
        if (gestureRecognizer.state != UIGestureRecognizer.State.began){
            return
        }
        
        let p = gestureRecognizer.location(in: self.collectionView)
        
        if let indexPath: IndexPath = (self.collectionView?.indexPathForItem(at: p)) {
            //do whatever you need to do
            let item = collectionView.cellForItem(at: indexPath) as! CardItemCollectionViewCell
            item.cardDeleteButton.isHidden = false
            print(indexPath.item)
        }
        
    }
    
    func getCard(vCard:NSManagedObject) -> SSCContact {
        let cTitle = vCard.value(forKeyPath: vcTitles.cardTitle) as? String
        let gName = vCard.value(forKeyPath: vcTitles.givenName) as? String
        let mName = vCard.value(forKeyPath: vcTitles.middleName) as? String
        let fName = vCard.value(forKeyPath: vcTitles.familyName) as? String
        let mNum = vCard.value(forKeyPath: vcTitles.mobileNumber) as? String
        let fNum = vCard.value(forKeyPath: vcTitles.faxNumber) as? String
        let eMl = vCard.value(forKeyPath: vcTitles.emailAddress) as? String
        let wURL = vCard.value(forKeyPath: vcTitles.websiteURL) as? String
        let jT = vCard.value(forKeyPath: vcTitles.jobTitle) as? String
        let oN = vCard.value(forKeyPath: vcTitles.orgnizationName) as? String
        
        let card = SSCContact(withCardTitle: cTitle!, givenName: gName!, middleName: mName!, familyName: fName!, mobileNumber: mNum!, emailAddress: eMl!, webAddress: wURL!, faxNumber: fNum!, jobTitle: jT!, orgnizationName: oN!)
        
        return card
    }
    
    func deleteObject(vCard: NSManagedObject) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        managedContext.delete(vCard)
        
        do {
            try managedContext.save()
            loadData()
        } catch {
            print("ERROR DELETEING")
        }
        
        print("Card Deleted!")
        
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "CardDet2") {
            var myBool = false
            let cell = sender as! CardItemCollectionViewCell
            let noCardText = NSLocalizedString("noCards", comment: "No Cards!")
            
            if cell.cardTitleLabel.text != noCardText {
                myBool = true
            }
            
            if myBool  {
                // your code here, like badParameters  = false, e.t.c
                return true
            }
            return false
        }
        
        return true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = tableView.indexPathForSelectedRow {
            if (segue.identifier == "CardDet") {
                let vc = segue.destination as! CardDetailsViewController
                vc.vCard = vCards[indexPath.row]
            }
        }
        
        if (segue.identifier == "CardDet2") {
            let cell = sender as! CardItemCollectionViewCell
            let noCardText = NSLocalizedString("noCards", comment: "No Cards!")
            if cell.cardTitleLabel.text != noCardText {
                let vc = segue.destination as! CardDetailsViewController
                
                let indexPath = self.collectionView.indexPath(for: cell)
                let vCard = self.vCards[indexPath!.row]
                vc.vCard = vCard
                UserDefaults.standard.set(indexPath?.row, forKey: UserDefaults.keys.selectedItemIndex)
            }
        }
    }
}

//MARK: - TableView Extension
extension CardsViewController : UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return NSLocalizedString("myCards", comment: "My Cards")
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("vCards.count: \(vCards.count)")
        return vCards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("ROW#: \(indexPath.row)")
        let vCard = vCards[indexPath.row]
        
        let cnCard = getCard(vCard: vCard)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! CardTableViewCell
        
        // Configure the cell...
        cell.cardTitle.text =  vCard.value(forKeyPath: vcTitles.cardTitle) as? String
        
        cell.qrcodeImage.image = cnCard.makeQRCode()
        return cell
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let vCard = vCards[indexPath.row]
            deleteObject(vCard: vCard)
            
            print("ENTER DELETE ON TABLE")
            // Delete the row from the data source
            //            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func configureCell(_ cell: CardTableViewCell, withEvent card: Card) {
        //        cell.cardTitle.text = card.cardTitle
        //        cell.qrcodeImage.image = UIImage()
        loadData()
    }
}

//MARK: - CollectionView Extension
extension CardsViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardItemCollectionViewCell", for: indexPath) as! CardItemCollectionViewCell
        
        let cardItem = cardItems[indexPath.item]
        
        cell.cardItem = cardItem
        
        return cell
    }
}

extension CardsViewController : UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
        
        targetContentOffset.pointee = offset
    }
}
