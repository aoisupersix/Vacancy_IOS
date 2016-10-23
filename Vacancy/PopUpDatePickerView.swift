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
    
    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    let pickerView: UIDatePicker = {
        let p = UIDatePicker()
        p.datePickerMode = .dateAndTime
        p.minuteInterval = 1
        p.backgroundColor = UIColor.white
        let appdel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        p.setDate(appdel.date as Date, animated: true)
        return p
    }()

    lazy var itemSelected: Driver<Date> = {
        return self.doneButtonItem.rx.tap.asDriver()
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

    convenience init(min: Date?, max: Date?, initial: Date?) {
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

    fileprivate func initFunc() {
        let screenSize = UIScreen.main.bounds.size
        pickerView.bounds = CGRect(x: 0, y: 0, width: screenSize.width, height: 216)
        pickerView.frame = CGRect(x: 0, y: 44, width: screenSize.width, height: 216)

        self.addSubview(pickerView)
    }

    // MARK: Actions
    override func showPicker() {
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: 0.2, animations: {
            self.frame = CGRect(x: 0, y: self.parentViewHeight() - 260.0, width: screenSize.width, height: 260.0)
        }) 
    }

    override func cancelPicker() {
        hidePicker()
    }

    override func endPicker() {
        self.datepickerDelegate?.endPicker()
    }

}
