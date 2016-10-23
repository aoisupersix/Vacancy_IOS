//
//  PopUpPickerViewBase.swift
//  AITravel-iOS
//
//  Created by 村田 佑介 on 2016/06/27.
//  Copyright © 2016年 Best10, Inc. All rights reserved.
//

import UIKit

class PopUpPickerViewBase: UIView {

    var pickerToolbar: UIToolbar!
    var toolbarItems = [UIBarButtonItem]()
    lazy var doneButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.endPicker))
    }()

    // MARK: Initializer
    init() {
        super.init(frame: CGRect.zero)
        initFunc()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initFunc()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initFunc()
    }

    fileprivate func initFunc() {
        let screenSize = UIScreen.main.bounds.size
        self.backgroundColor = UIColor.black

        pickerToolbar = UIToolbar()
        pickerToolbar.isTranslucent = true

        self.bounds = CGRect(x: 0, y: 0, width: screenSize.width, height: 260)
        self.frame = CGRect(x: 0, y: parentViewHeight(), width: screenSize.width, height: 260)
        pickerToolbar.bounds = CGRect(x: 0, y: 0, width: screenSize.width, height: 44)
        pickerToolbar.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 44)

        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        space.width = 12
        let cancelItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(PopUpPickerView.cancelPicker))
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        toolbarItems = [space, cancelItem, flexSpaceItem, doneButtonItem, space]

        pickerToolbar.setItems(toolbarItems, animated: false)
        self.addSubview(pickerToolbar)
    }

    // MARK: Actions
    func showPicker() {
    }

    func cancelPicker() {
    }

    func endPicker() {
    }

    func hidePicker() {
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: 0.2, animations: {
            self.frame = CGRect(x: 0, y: self.parentViewHeight(), width: screenSize.width, height: 260.0)
        }) 
    }

    func parentViewHeight() -> CGFloat {
        return superview?.frame.height ?? UIScreen.main.bounds.size.height
    }

}
