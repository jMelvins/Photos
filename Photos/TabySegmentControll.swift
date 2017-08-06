//
//  TabySegmentControll.swift
//  Photos
//
//  Created by Vladislav Shilov on 05.08.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import UIKit

class TabySegmentedControl: UISegmentedControl {
    
    //    func drawRect(){
    //        super.drawRect()
    //        initUI()
    //    }
    
    func initUI(){
        setupBackground()
        setupFonts()
    }
    
    func setupBackground(){
//        let backgroundImage = UIImage(named: "segmented_unselected_bg")
//        let dividerImage = UIImage(named: "segmented_separator_bg")
//        let backgroundImageSelected = UIImage(named: "segmented_selected_bg")
        
        let backgroundImage = UIImage(named: "filledSegment")
        let dividerImage = UIImage(named: "separator")
        let backgroundImageSelected = UIImage(named: "leftSegment")
        
        self.setBackgroundImage(backgroundImage, for: UIControlState(), barMetrics: .default)
        self.setBackgroundImage(backgroundImageSelected, for: .highlighted, barMetrics: .default)
        self.setBackgroundImage(backgroundImageSelected, for: .selected, barMetrics: .default)
        
        self.setDividerImage(dividerImage, forLeftSegmentState: UIControlState(), rightSegmentState: .selected, barMetrics: .default)
        self.setDividerImage(dividerImage, forLeftSegmentState: .selected, rightSegmentState: UIControlState(), barMetrics: .default)
        self.setDividerImage(dividerImage, forLeftSegmentState: UIControlState(), rightSegmentState: UIControlState(), barMetrics: .default)
    }
    
    func setupFonts(){
        let font = UIFont.systemFont(ofSize: 16.0)
        
        
        let normalTextAttributes = [
            NSForegroundColorAttributeName: UIColor.init(red: 93/255, green: 208/255, blue: 192/255, alpha: 1),
            NSFontAttributeName: font
        ]
        
        self.setTitleTextAttributes(normalTextAttributes, for: UIControlState())
        self.setTitleTextAttributes(normalTextAttributes, for: .highlighted)
        self.setTitleTextAttributes(normalTextAttributes, for: .selected)
    }
    
}
