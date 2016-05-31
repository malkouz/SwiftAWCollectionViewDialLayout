//
//  AWCollectionViewDialLayout.swift
//  AWCollectionViewDialLayoutDemo
//
//  Created by Moayad on 5/29/16.
//  Copyright © 2016 Moayad. All rights reserved.
//

import UIKit


enum WheelAlignmentType{
    case LEFT, CENTER
}

class AWCollectionViewDialLayout: UICollectionViewFlowLayout {
    var cellCount:Int!
    var wheelType:WheelAlignmentType!
    var center:CGPoint!
    var offset:CGFloat!
    var itemHeight:CGFloat!
    var xOffset:CGFloat!
    var cellSize:CGSize!
    var angularSpacing:CGFloat!
    var dialRadius:CGFloat!
    var currentIndexPath:NSIndexPath!
    
    var shouldSnap = false
    var shouldFlip = false
    
    var lastVelocity:CGPoint!
    
    init(raduis: CGFloat, angularSpacing: CGFloat, cellSize:CGSize, alignment:WheelAlignmentType, itemHeight:CGFloat, xOffset:CGFloat) {
        super.init()
        
        self.dialRadius = raduis
        self.angularSpacing = angularSpacing
        self.wheelType = alignment
        self.itemHeight = itemHeight
        self.cellSize = cellSize
        self.itemSize = cellSize
        
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
        self.itemHeight = itemHeight
        self.angularSpacing = angularSpacing
        self.sectionInset = UIEdgeInsetsZero
        self.scrollDirection = .Vertical
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        self.offset = 0.0;
    }
    
    override func prepareLayout(){
        super.prepareLayout()
        if self.collectionView!.numberOfSections() > 0{
            self.cellCount = self.collectionView?.numberOfItemsInSection(0)
        }else{
            self.cellCount = 0
        }
        self.offset = -self.collectionView!.contentOffset.y / self.itemHeight
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    
    func getRectForItem(itemIndex: Int) -> CGRect{
        let newIndex =  CGFloat(itemIndex) + self.offset
        let scaleFactor = fmax(0.6, 1 - fabs( newIndex * 0.25))
        let deltaX = self.cellSize.width/2
        
        let temp = Float(self.angularSpacing)
        let dds = Float(self.dialRadius + (deltaX*scaleFactor))
        
        var rX = cosf(temp * Float(newIndex) * Float(M_PI/180)) * dds
        
        let rY = sinf(temp * Float(newIndex) * Float(M_PI/180)) * dds
        var oX = -self.dialRadius + self.xOffset - (0.5 * self.cellSize.width);
        let oY = self.collectionView!.bounds.size.height/2 + self.collectionView!.contentOffset.y - (0.5 * self.cellSize.height)
        
        
        if(shouldFlip){
            oX = self.collectionView!.frame.size.width + self.dialRadius - self.xOffset - (0.5 * self.cellSize.width)
            rX *= -1
        }
        
        let itemFrame = CGRectMake(oX + CGFloat(rX), oY + CGFloat(rY), self.cellSize.width, self.cellSize.height)
        
        return itemFrame
    }
    
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var theLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        let maxVisiblesHalf:Int = 180 / Int(self.angularSpacing)
        //var lastIndex = -1
        
        for i in 0 ..< self.cellCount{
            let itemFrame = self.getRectForItem(i)
            
            if(CGRectIntersectsRect(rect, itemFrame) && i > (-1 * Int(self.offset) - maxVisiblesHalf) && i < (-1 * Int(self.offset) + maxVisiblesHalf)){
                
                let indexPath = NSIndexPath(forItem: i, inSection: 0)
                let theAttributes = self.layoutAttributesForItemAtIndexPath(indexPath)
                theLayoutAttributes.append(theAttributes!)
                //lastIndex = i;
            }
        }
        
        return theLayoutAttributes;
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if(shouldSnap){
            let index = Int(floor(proposedContentOffset.y / self.itemHeight))
            let off = (Int(proposedContentOffset.y) % Int(self.itemHeight))
            
            let height = Int(self.itemHeight)
            
            var targetY = index * height
            if( off > Int((self.itemHeight * 0.5)) && index <= self.cellCount ){
                targetY = (index+1) * height
            }
            
            return CGPointMake(proposedContentOffset.x, CGFloat(targetY))
        }else{
            return proposedContentOffset;
        }
    }
    
    
    override func targetIndexPathForInteractivelyMovingItem(previousIndexPath: NSIndexPath, withPosition position: CGPoint) -> NSIndexPath {
        return NSIndexPath(forItem: 0, inSection: 0)
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: self.collectionView!.bounds.size.width, height: CGFloat(self.cellCount-1) * self.itemHeight + self.collectionView!.bounds.size.height)
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let newIndex = CGFloat(indexPath.item) + self.offset
        
        let theAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        theAttributes.size = self.cellSize
        
        var scaleFactor:CGFloat
        var deltaX:CGFloat
        var translationT:CGAffineTransform
      
        
        let rotationValue = self.angularSpacing * newIndex * CGFloat(M_PI/180)
        var rotationT = CGAffineTransformMakeRotation(rotationValue)
        
        if(shouldFlip){
            rotationT = CGAffineTransformMakeRotation(-rotationValue)
        }
        
        if( self.wheelType == .LEFT){
            scaleFactor = fmax(0.6, 1 - fabs( CGFloat(newIndex) * 0.25))
            let newFrame = self.getRectForItem(indexPath.item)
            theAttributes.frame = CGRectMake(newFrame.origin.x , newFrame.origin.y, newFrame.size.width, newFrame.size.height)
            
            translationT = CGAffineTransformMakeTranslation(0 , 0)
        }else  {
            scaleFactor = fmax(0.4, 1 - fabs( CGFloat(newIndex) * 0.50))
            deltaX =  self.collectionView!.bounds.size.width / 2
            
            if(shouldFlip){
                theAttributes.center = CGPointMake( self.collectionView!.frame.size.width + self.dialRadius - self.xOffset , self.collectionView!.bounds.size.height/2 + self.collectionView!.contentOffset.y)
                
                translationT = CGAffineTransformMakeTranslation( -1 * (self.dialRadius  + ((1 - scaleFactor) * -30)) , 0)
                print("should Flip ")
            }else{
                theAttributes.center = CGPointMake(-self.dialRadius + self.xOffset , self.collectionView!.bounds.size.height/2 + self.collectionView!.contentOffset.y);
                translationT = CGAffineTransformMakeTranslation(self.dialRadius  + ((1 - scaleFactor) * -30) , 0);
                print("should not Flip ")
            }
        }
        
        
        
        let scaleT:CGAffineTransform = CGAffineTransformMakeScale(scaleFactor, scaleFactor)
        theAttributes.alpha = scaleFactor
        theAttributes.hidden = false
        
        theAttributes.transform = CGAffineTransformConcat(scaleT, CGAffineTransformConcat(translationT, rotationT))
        
        return theAttributes 

    }
}
