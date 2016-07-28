//
//  PopUpDatePickerView.swift
//  AITravel-iOS
//
//  Created by 村田 佑介 on 2016/06/27.
//  Copyright © 2016年 Best10, Inc. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

protocol PopUpDatePickerViewDelegate{
    func endPicker()
}

class PopUpDatePickerView: PopUpPickerViewBase {
    
    var datepickerDelegate: PopUpDatePickerViewDelegate?
    
    let app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    let pickerView: UIDatePicker = {
        let p = UIDatePicker()
        p.datePickerMode = .DateAndTime
        p.minuteInterval = 10
        p.backgroundColor = UIColor.whiteColor()
        let appdel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        p.setDate(appdel.date, animated: true)
        return p
    }()

    lazy var itemSelected: Driver<NSDate> = {
        return self.doneButtonItem.rx_tap.asDriver()
            .map { [unowned self] _ in
                self.hidePicker()
                return self.pickerView.date
            }
            .startWith(self.pickerView.date)
    }()
    // MARK: Initializer
    override init() {
        super.init()
        initFunc()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initFunc()
    }

    convenience init(min: NSDate?, max: NSDate?, initial: NSDate?) {
        self.init()
        pickerView.minimumDate = min
        pickerView.maximumDate = max
        if let initial = initial {
            pickerView.date = initial
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initFunc()
    }

    private func initFunc() {
        let screenSize = UIScreen.mainScreen().bounds.size
        pickerView.bounds = CGRectMake(0, 0, screenSize.width, 216)
        pickerView.frame = CGRectMake(0, 44, screenSize.width, 216)

        self.addSubview(pickerView)
    }

    // MARK: Actions
    override func showPicker() {
        let screenSize = UIScreen.mainScreen().bounds.size
        UIView.animateWithDuration(0.2) {
            self.frame = CGRectMake(0, self.parentViewHeight() - 260.0, screenSize.width, 260.0)
        }
    }

    override func cancelPicker() {
        hidePicker()
    }

    override func endPicker() {
        app.date = pickerView.date
        self.datepickerDelegate?.endPicker()
    }

}
