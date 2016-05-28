//
//  SelectionTextField.swift
//  UsefulPickerVIew
//
//  Created by jasnig on 16/4/16.
//  Copyright © 2016年 ZeroJ. All rights reserved.
// github: https://github.com/jasnig
// 简书: http://www.jianshu.com/users/fb31a3d1ec30/latest_articles

//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//
import UIKit

struct AssociatedDataModel {
    var key: String
    var valueArray: [String]?
    init (key: String, valueArray: [String]? = nil) {
        self.key = key
        self.valueArray = valueArray
    }
}

class Picker: UIView {
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    
    // 使用模型初始化数据示例
    let associatedData: [[AssociatedDataModel]] = [
        // 第一列数据 (key)
        [   AssociatedDataModel(key: "交通工具"),
            AssociatedDataModel(key: "食品"),
            AssociatedDataModel(key: "游戏")
        ],
        // 第二列数据 (valueArray)
        [    AssociatedDataModel(key: "交通工具", valueArray: ["陆地", "空中", "水上"]),
             AssociatedDataModel(key: "食品", valueArray: ["健康食品", "垃圾食品"]),
             AssociatedDataModel(key: "游戏", valueArray: ["益智游戏", "角色游戏"]),
            
        ],
        
        // 第三列数据 (valueArray)
        [   AssociatedDataModel(key: "陆地", valueArray: ["公交车", "小轿车", "自行车"]),
            AssociatedDataModel(key: "空中", valueArray: ["飞机"]),
            AssociatedDataModel(key: "水上", valueArray: ["轮船"]),
            AssociatedDataModel(key: "健康食品", valueArray: ["蔬菜", "水果"]),
            AssociatedDataModel(key: "垃圾食品", valueArray: ["辣条", "不健康小吃"]),
            AssociatedDataModel(key: "益智游戏", valueArray: ["消消乐", "消灭星星"]),
            AssociatedDataModel(key: "角色游戏", valueArray: ["lol", "cf"])
            
        ]
        
        
    ]

    
    enum PickerStyles {
        case Single
        case Multiple
        case MultipleAssociated
    }
    
    
    var pickerStyle: PickerStyles = .Single
    
    // 完成按钮的响应Closure
    typealias BtnAction = () -> Void
    typealias SingleDoneAction = (selectedIndex: Int, selectedValue: String) -> Void
    typealias MultipleDoneAction = (selectedIndexs: [Int], selectedValues: [String]) -> Void

    private var cancelAction: BtnAction? = nil {
        didSet {
            tool.cancelAction = cancelAction
        }
    }
    //MARK:- 只有一列的时候用到的属性
    private var singleDoneOnClick:SingleDoneAction? = nil {
        didSet {
            tool.doneAction =  {[unowned self] in
                
                self.singleDoneOnClick?(selectedIndex: self.selectedIndex, selectedValue: self.selectedValue)
            }
        }
    }
    
    private var defalultSelectedIndex: Int? = nil {
        didSet {
            if let defaultIndex = defalultSelectedIndex, singleData = singleColData {// 判断下标是否合法
                assert(defaultIndex >= 0 && defaultIndex < singleData.count, "设置的默认选中Index不合法")
                if defaultIndex >= 0 && defaultIndex < singleData.count {
                    // 设置默认值
                    selectedIndex = defaultIndex
                    selectedValue = singleData[defaultIndex]
                    // 滚动到默认位置
                    pickerView.selectRow(defaultIndex, inComponent: 0, animated: false)

                }
                
             } else {// 没有默认值设置0行为默认值
                selectedIndex = 0
                selectedValue = singleColData![0]
                pickerView.selectRow(0, inComponent: 0, animated: false)
                
            }
        }
    }
    private var singleColData: [String]? = nil
    
    private var selectedIndex: Int = 0
    private var selectedValue: String = ""
    
    
    //MARK:- 有多列不关联的时候用到的属性
    var multipleDoneOnClick:MultipleDoneAction? = nil {
        didSet {

            tool.doneAction =  {[unowned self] in
                self.multipleDoneOnClick?(selectedIndexs: self.selectedIndexs, selectedValues: self.selectedValues)
            }
        }
    }
    
    private var multipleColsData: [[String]]? = nil {
        didSet {
            if let multipleData = multipleColsData {
                for _ in multipleData.indices {
                    selectedIndexs.append(0)
                    selectedValues.append(" ")
                }
                
            }
        }
    }

    private var selectedIndexs: [Int] = []
    private var selectedValues: [String] = []

    private var defalultSelectedIndexs: [Int]? = nil {
        didSet {
            if let defaultIndexs = defalultSelectedIndexs {
                
                defaultIndexs.enumerate().forEach({ (component: Int, row: Int) in
                    
                    assert(component < pickerView.numberOfComponents && row < pickerView.numberOfRowsInComponent(component), "设置的默认选中Indexs有不合法的")
                    if component < pickerView.numberOfComponents && row < pickerView.numberOfRowsInComponent(component){
                        
                        // 滚动到默认位置
                        pickerView.selectRow(row, inComponent: component, animated: false)
                        
                        // 设置默认值
                        selectedIndexs[component] = row
                        selectedValues[component] = self.pickerView(pickerView, titleForRow: row, forComponent: component) ?? " "


                    }
                    
                 })
                
            } else {
                multipleColsData?.indices.forEach({ (index) in
                    // 滚动到默认位置
                    pickerView.selectRow(0, inComponent: index, animated: false)

                    // 设置默认选中值
                    selectedIndexs[index] = 0

                    selectedValues[index] = self.pickerView(pickerView, titleForRow: 0, forComponent: index) ?? " "

                })
            }
        }
    }
    
    
    
    //MARK:- 有多列关联的时候用到的属性

    private var multipleAssociatedColsData: [[AssociatedDataModel]]? = nil {
        didSet {
            
            if let multipleAssociatedData = multipleAssociatedColsData {
                // 初始化选中的values
                for _ in multipleAssociatedData.indices {
                    selectedIndexs.append(0)
                    selectedValues.append(" ")
                }
            }
        }
    }
    
    // 设置第一组的数据, 使用数组是因为字典无序,需要设置默认选中值的时候获取到准确的下标滚动到相应的行
    private var defaultSelectedValues: [String]? = nil {
        didSet {
            
            if let defaultValues = defaultSelectedValues {
                // 设置默认值
                selectedValues = defaultValues
                defaultValues.enumerate().forEach { (component: Int, element: String) in
                    var row: Int? = nil
                    if component == 0 {
                        let firstData = multipleAssociatedColsData![0]
                        for (index,associatedModel) in firstData.enumerate() {
                            if associatedModel.key == element {
                                row = index
                            }
                        }
                    } else {
                        
                        let associatedModels = multipleAssociatedColsData![component]
                        var arr: [String]?
                        
                        for associatedModel in associatedModels {
                            if associatedModel.key == selectedValues[component - 1] {
                                arr = associatedModel.valueArray
                            }
                        }
                        
                        row = arr?.indexOf(element)
                        
                    }
                    
                    assert(row != nil, "第\(component)列设置的默认值有误")
                    if row == nil {
                        row = 0
                        print("第\(component)列设置的默认值有误")
                    }
                    if component < pickerView.numberOfComponents {
//                        print(" \(component) ----\(row!)")
                        // 滚动到默认的位置
                        pickerView.selectRow(row!, inComponent: component, animated: false)
                        // 设置选中的下标
                        selectedIndexs[component] = row!
                        
                    }
                    
                }
                
            } else {
                multipleAssociatedColsData?.indices.forEach({ (index) in
                    // 滚动到默认的位置 0 行
                    pickerView.selectRow(0, inComponent: index, animated: false)
                    // 设置默认的选中值
                    selectedValues[index] = self.pickerView(pickerView, titleForRow: 0, forComponent: index) ?? " "
                    selectedIndexs[index] = 0
                })
            }

        }
        
    }
    
    
    
    private lazy var pickerView: UIPickerView! = { [unowned self] in
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.whiteColor()
        return picker
    }()
    
    private lazy var tool: ToolBarView! = ToolBarView()
    
    private let pickerViewHeight = 216.0
    private let toolBarHeight = 44.0
    
    let screenW = UIScreen.mainScreen().bounds.size.width
    
    //MARK:- 初始化
    init() {
        let frame = CGRect(x: 0.0, y: 0.0, width: Double(screenW), height: toolBarHeight + pickerViewHeight)
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        
    }
    
    func commonInit() {
        
        addSubview(tool)
        addSubview(pickerView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tool.frame = CGRect(x: 0.0, y: 0.0, width: Double(screenWidth), height: toolBarHeight)
        pickerView.frame = CGRect(x: 0.0, y: 44.0, width: Double(screenW), height: pickerViewHeight)
    }
    
    
}

extension Picker: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        switch pickerStyle {
            case .Single:
                return singleColData == nil ? 0 : 1
            case .Multiple:
                return multipleColsData?.count ?? 0
            case .MultipleAssociated:
                return multipleAssociatedColsData?.count ?? 0
            
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerStyle {
            case .Single:
                return singleColData?.count ?? 0
            case .Multiple:
                return multipleColsData?[component].count ?? 0
            case .MultipleAssociated:
                if let multipleAssociatedData = multipleAssociatedColsData {

                    if component == 0 {
                        return multipleAssociatedData[0].count
                    }else {
                        let associatedDataModels = multipleAssociatedData[component]
                        var arr: [String]?
                        
                        for associatedDataModel in associatedDataModels {
                            if associatedDataModel.key == selectedValues[component - 1] {
                                arr = associatedDataModel.valueArray
                            }
                        }
                        
                        return arr?.count ?? 0
                        
                    }
                    
                }
                
                return 0
            
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerStyle {
            case .Single:
                selectedIndex = row
                selectedValue = singleColData![row]
            case .Multiple:
                selectedIndexs[component] = row
                selectedValues[component] = self.pickerView(pickerView, titleForRow: row, forComponent: component) ?? " "
            case .MultipleAssociated:
                // 设置选中值
                selectedValues[component] = self.pickerView(pickerView, titleForRow: row, forComponent: component) ?? " "
                selectedIndexs[component] = row
                // 更新下一列关联的值
                if component < multipleAssociatedColsData!.count - 1 {
                    pickerView.reloadComponent(component + 1)
                    // 递归
                    self.pickerView(pickerView, didSelectRow: 0, inComponent: component+1)
                    pickerView.selectRow(0, inComponent: component+1, animated: true)
                    
                }

        }
        
        
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerStyle {
            case .Single:
                return singleColData?[row]
            case .Multiple:
                return multipleColsData?[component][row]
            case .MultipleAssociated:
                
                if let multipleAssociatedData = multipleAssociatedColsData {

                    if component == 0 {
                        return multipleAssociatedData[0][row].key
                    }else {
                        let associatedDataModels = multipleAssociatedData[component]
                        var arr: [String]?
                        
                        for associatedDataModel in associatedDataModels {
                            if associatedDataModel.key == selectedValues[component - 1] {
                                arr = associatedDataModel.valueArray
                            }
                        }
                        if arr?.count == 0 {// 空数组
                            return nil
                        }
                        return arr?[row]
                        
                    }
                    
                }
                
                return nil
            
        }
    }
}

//MARK: 快速使用方法
extension Picker {
    
    /// 单列
    class func singleColPicker(singleColData: [String], defaultIndex: Int?,cancelAction: BtnAction?, doneAction: SingleDoneAction?) -> Picker {
        let pic = Picker()
        
        pic.pickerStyle = .Single
        pic.singleColData = singleColData
        pic.defalultSelectedIndex = defaultIndex
        
        pic.singleDoneOnClick = doneAction
        pic.cancelAction = cancelAction
        return pic
        
    }
    
    /// 多列不关联
    class func multipleCosPicker(multipleColsData: [[String]], defaultSelectedIndexs: [Int]?,cancelAction: BtnAction?, doneAction: MultipleDoneAction?) -> Picker {
        
        let pic = Picker()
        
        pic.pickerStyle = .Multiple
        
        pic.multipleColsData = multipleColsData
        pic.defalultSelectedIndexs = defaultSelectedIndexs
        pic.cancelAction = cancelAction
        pic.multipleDoneOnClick = doneAction
        return pic
        
    }
    
    /// 多列关联
    class func multipleAssociatedCosPicker(multipleAssociatedColsData: [[AssociatedDataModel]], defaultSelectedValues: [String]?,cancelAction: BtnAction?, doneAction: MultipleDoneAction?) -> Picker {
        
        let pic = Picker()
        pic.pickerStyle = .MultipleAssociated
        pic.multipleAssociatedColsData = multipleAssociatedColsData
        
        pic.defaultSelectedValues = defaultSelectedValues
        pic.cancelAction = cancelAction
        pic.multipleDoneOnClick = doneAction
        return pic
        
    }
    
    /// 城市选择器
    class func citiesPicker(defaultSelectedValues: [String]?, cancelAction: BtnAction?, doneAction: MultipleDoneAction?) -> Picker {
        
        let provincePath = NSBundle.mainBundle().pathForResource("Province", ofType: "plist")
        let cityPath = NSBundle.mainBundle().pathForResource("City", ofType: "plist")
        let areaPath = NSBundle.mainBundle().pathForResource("Area", ofType: "plist")
        
        let proviceArr = NSArray(contentsOfFile: provincePath!)
        let cityArr = NSDictionary(contentsOfFile: cityPath!)
        let areaArr = NSDictionary(contentsOfFile: areaPath!)
        
        var provinceModelArr: [AssociatedDataModel] = []
        var citiesModelArr: [AssociatedDataModel] = []
        var areasModelArr: [AssociatedDataModel] = []
        
        proviceArr?.forEach({ (element) in
            if let province = element as? String {
                provinceModelArr.append(AssociatedDataModel(key: province))
                
                let citys = cityArr?[province] as? [String]
                citiesModelArr.append(AssociatedDataModel(key: province, valueArray: citys))
                
                citys?.forEach({ (element) in
                    let city = element
                    let areas = areaArr?[city]as? [String]
                    areasModelArr.append(AssociatedDataModel(key: city, valueArray: areas))
                    
                })
            }
        })
        
        let citiesArr = [provinceModelArr, citiesModelArr, areasModelArr]
        
        
        let pic = Picker.multipleAssociatedCosPicker(citiesArr, defaultSelectedValues: defaultSelectedValues, cancelAction: cancelAction, doneAction: doneAction)
        return pic
        
    }
}