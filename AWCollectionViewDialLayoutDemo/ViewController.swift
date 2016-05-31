//
//  ViewController.swift
//  AWCollectionViewDialLayoutDemo
//
//  Created by Moayad on 5/29/16.
//  Copyright © 2016 Moayad. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {
    
    var thumbnailCache = [String: UIImage]()
    var dialLayout:AWCollectionViewDialLayout!
    var cell_height:CGFloat!
    
    var type:Int = 0
    
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var segType:UISegmentedControl!
    var items = [[String: String]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        type = 0
        let jsonPath = NSBundle.mainBundle().pathForResource("photos", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonPath!)
        
        
        do{
            self.items = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions(rawValue: 0)) as! [[String : String]]
            
            
            let radius = CGFloat(0.39 * 1000)
            let angularSpacing = CGFloat(0.16 * 90)
            let xOffset = CGFloat(0.23 * 320)
            let cell_width = CGFloat(240)
            cell_height = 100
            print("Items :: ", self.items)
            dialLayout = AWCollectionViewDialLayout(raduis: radius, angularSpacing: angularSpacing, cellSize: CGSizeMake(cell_width, cell_height) , alignment: WheelAlignmentType.CENTER, itemHeight: cell_height, xOffset: xOffset)
            dialLayout.shouldSnap = true
            dialLayout.shouldFlip = true
            collectionView.collectionViewLayout = dialLayout
            dialLayout.scrollDirection = .Horizontal
            
            self.switchExample()
        }catch let err{
            print("Err :: ", err)
        }
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func switchExample(){
        
        var radius:CGFloat = 0 ,angularSpacing:CGFloat  = 0, xOffset:CGFloat = 0
        
        if(type == 0){
            dialLayout.cellSize = CGSizeMake(340, 100)
            dialLayout.wheelType = .LEFT
            dialLayout.shouldFlip = false
            
            radius = 300
            angularSpacing = 18
            xOffset = 70
        }else if(type == 1){
            dialLayout.cellSize = CGSizeMake(260, 50)
            dialLayout.wheelType = .CENTER
            dialLayout.shouldFlip = true
            
            radius = 320
            angularSpacing = 5
            xOffset = 124
        }
        
        dialLayout.dialRadius = radius
        dialLayout.angularSpacing = angularSpacing
        dialLayout.xOffset = xOffset
        
        collectionView.reloadData();
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:AWCollectionCell!
        if(type == 0){
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell1", forIndexPath: indexPath) as! AWCollectionCell
        }else{
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell2", forIndexPath: indexPath) as! AWCollectionCell
        }
        
        let item = self.items[indexPath.item]
        cell.label.text = item["name"]
        
       
        
        if(type == 0){
            let imgURL = item["picture"]!
            if let img = thumbnailCache[imgURL]
            {
                cell.icon.image = img
            }else{
                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI
                    let img = UIImage(named: imgURL)
                    cell.icon.image = img
                    self.thumbnailCache[imgURL] = img
                }
            }
        }
        
        if let hexStr = item["color"]{
            
            cell.label.textColor =  hexStringToUIColor(hexStr)
        }
    
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Select Item :: ", indexPath.item)
        
       //collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
    }
    @IBAction func changeLayoutType(sender: AnyObject) {
        type = segType.selectedSegmentIndex
        print("TYPE :: ", type)
        switchExample()
    }

}

