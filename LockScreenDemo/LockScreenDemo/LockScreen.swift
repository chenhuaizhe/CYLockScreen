//
//  LockScreen.swift
//  LockScreenDemo
//
//  Created by CY on 2017/7/13.
//  Copyright © 2017年 CY. All rights reserved.
//

import UIKit
import LocalAuthentication


class LockScreen: UIWindow {
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var dot_5: UIView!
    @IBOutlet weak var dot_4: UIView!
    @IBOutlet weak var dot_3: UIView!
    @IBOutlet weak var dot_2: UIView!
    @IBOutlet weak var dot_1: UIView!
    @IBOutlet weak var stateLabel: UILabel!
    
    static let shareLockScreen = LockScreen()
    
    
    
    var contentView : UIView!
    //初始化时将xib中的view添加进来
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = loadViewFromNib()
        self.addSubview(contentView)
        addConstraints()
        //初始化属性配置
        initialSetup()

    }
    
    //初始化时将xib中的view添加进来
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView = loadViewFromNib()
        self.addSubview(contentView)
        addConstraints()
        //初始化属性配置
        initialSetup()
    }
    
    //初始化默认属性配置
    func initialSetup(){
        //添加12个按钮
        let w = screen.bounds.size.width/3
        let h = (screen.bounds.size.height)*2/3/4
        var index = 0
        for i in 0..<3 {
            for j in 0..<3 {
                index += 1
                let button = UIButton(type:.custom)
                button.frame = CGRect(x: CGFloat(j)*CGFloat(w), y: CGFloat(i)*CGFloat(h), width: w,height:h);
                button.setTitle(String.init(stringInterpolationSegment: index), for: .normal)
                button.titleLabel?.font = UIFont.init(name: "BanglaSangamMN-Bold", size: 30)
                button.backgroundColor = UIColor.gray
                button.addTarget(self, action: #selector(numberBtnClicked(_:)), for: .touchUpInside)
                self.bottomView.addSubview(button)
            }

        }
        //指纹按钮
        let button_10 = UIButton(type:.custom)
        button_10.frame = CGRect(x: CGFloat(0)*CGFloat(w), y: CGFloat(3)*CGFloat(h), width: w,height:h);
        button_10.setTitle("指纹", for: .normal)
        button_10.backgroundColor = UIColor.gray
        button_10.addTarget(self, action: #selector(touchIDBtnClicked(_:)), for: .touchUpInside)
        self.bottomView.addSubview(button_10)
        //0
        let button_11 = UIButton(type:.custom)
        button_11.frame = CGRect(x: CGFloat(1)*CGFloat(w), y: CGFloat(3)*CGFloat(h), width: w,height:h);
        button_11.setTitle(String.init(stringInterpolationSegment: 0), for: .normal)
        button_11.titleLabel?.font = UIFont.init(name: "BanglaSangamMN-Bold", size: 30)

        button_11.backgroundColor = UIColor.gray
        button_11.addTarget(self, action: #selector(numberBtnClicked(_:)), for: .touchUpInside)
        self.bottomView.addSubview(button_11)
        //删除按钮
        let button_12 = UIButton(type:.custom)
        button_12.frame = CGRect(x: CGFloat(2)*CGFloat(w), y: CGFloat(3)*CGFloat(h), width: w,height:h);
        button_12.setTitle("删除", for: .normal)
        button_12.backgroundColor = UIColor.gray
        button_12.addTarget(self, action: #selector(deleteBtnClicked(_:)), for: .touchUpInside)
        self.bottomView.addSubview(button_12)
        
    }
    
    //加载xib
    func loadViewFromNib() -> UIView {
        let className = type(of: self)
        let bundle = Bundle(for: className)
        let name = NSStringFromClass(className).components(separatedBy: ".").last
        let nib = UINib(nibName: name!, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    //设置好xib视图约束
    func addConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        var constraint = NSLayoutConstraint(item: contentView, attribute: .leading,
                                            relatedBy: .equal, toItem: self, attribute: .leading,
                                            multiplier: 1, constant: 0)
        addConstraint(constraint)
        constraint = NSLayoutConstraint(item: contentView, attribute: .trailing,
                                        relatedBy: .equal, toItem: self, attribute: .trailing,
                                        multiplier: 1, constant: 0)
        addConstraint(constraint)
        constraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal,
                                        toItem: self, attribute: .top, multiplier: 1, constant: 0)
        addConstraint(constraint)
        constraint = NSLayoutConstraint(item: contentView, attribute: .bottom,
                                        relatedBy: .equal, toItem: self, attribute: .bottom,
                                        multiplier: 1, constant: 0)
        addConstraint(constraint)
    }
    
    //MARK:
    //MARK: - Action
    
    func show() {
        self.makeKey()
        self.isHidden = false
        
        //如果本地没有密码，初始密码定为12345
        if (self.localPWD == nil) {
            self.localPWD = "12345"
        }else {
            
            //如果本地有密码，先验证指纹
            touchIDBtnClicked(_:UIButton.init())
        }
    }
    

    func setPWD() {
        //
    }
    
    var dotLightCount = 0 //亮起的小点的个数
    var pwdString = "" //用户输入的密码
    var localPWD = UserDefaults.standard.object(forKey: "Local_PWD")
    

    //0-9数字按钮点击事件
    func numberBtnClicked(_ btn:UIButton){
        //获取到按钮所代表的数字
        let number = btn.titleLabel?.text
        pwdString.append(number!)
        //顶部小点状态改变
        dotLightCount += 1
        self.dotStateChange(withCount: self.dotLightCount)
        //小点如果5个全亮，去验证密码正确性
        if self.dotLightCount == 5 {
            //更新小点状态
            dotLightCount = 0
            //密码正确时，隐藏密码页面
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dotStateChange(withCount: self.dotLightCount)
                if self.localPWD as! String == self.pwdString {
                    self.stateLabel.text = "请输入密码"
                    self.pwdString = "";
                    self.resignKey()
                    self.isHidden = true
                }
                    //密码错误时，更新顶部提示语
                else {
                    self.stateLabel.text = "密码输入错误"
                    self.pwdString = "";
                    
                }
                }
            

            
        }

    }
    
    //验证指纹
    func touchIDBtnClicked(_ btn:UIButton){
        let context = LAContext()
        let deviceSupportTouchID = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if deviceSupportTouchID {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "使用您的touch id来进入app", reply: { (success, error) in
                print("是否验证成功：\(success)\n"+"error = \(String(describing: error))")
                if success {
                    //成功
                    DispatchQueue.global().async {
                        
                        DispatchQueue.main.async {
                            
                            self.dotStateChange(withCount: self.dotLightCount)
                            self.stateLabel.text = "请输入密码"
                            self.pwdString = "";
                            self.resignKey()
                            self.isHidden = true
                        } 
                        
                    }
                  
                }else {
                    //失败
                }
            })
        }else {
            print("设备不支持Touch ID")
        }

    }
    
    //删除按钮
    func deleteBtnClicked(_ btn:UIButton) {
        //顶部小点个数小于1，结束
        if dotLightCount < 1 {return}
        //减少顶部小点个数，删除缓存的密码最后一位
        dotLightCount -= 1
        self.dotStateChange(withCount: dotLightCount)
        self.pwdString = pwdString.substring(to: pwdString.endIndex)
        
    }
    
    private func dotStateChange(withCount count:NSInteger) {
        if count == 0 {
            dot_1.backgroundColor = UIColor.gray
            dot_2.backgroundColor = UIColor.gray
            dot_3.backgroundColor = UIColor.gray
            dot_4.backgroundColor = UIColor.gray
            dot_5.backgroundColor = UIColor.gray
        }
        else if count == 1 {
            dot_1.backgroundColor = UIColor.darkGray
            dot_2.backgroundColor = UIColor.gray
            dot_3.backgroundColor = UIColor.gray
            dot_4.backgroundColor = UIColor.gray
            dot_5.backgroundColor = UIColor.gray
        }
        else if count == 2 {
            dot_1.backgroundColor = UIColor.darkGray
            dot_2.backgroundColor = UIColor.darkGray
            dot_3.backgroundColor = UIColor.gray
            dot_4.backgroundColor = UIColor.gray
            dot_5.backgroundColor = UIColor.gray
        }
        else if count == 3 {
            dot_1.backgroundColor = UIColor.darkGray
            dot_2.backgroundColor = UIColor.darkGray
            dot_3.backgroundColor = UIColor.darkGray
            dot_4.backgroundColor = UIColor.gray
            dot_5.backgroundColor = UIColor.gray
        }
        else if count == 4 {
            dot_1.backgroundColor = UIColor.darkGray
            dot_2.backgroundColor = UIColor.darkGray
            dot_3.backgroundColor = UIColor.darkGray
            dot_4.backgroundColor = UIColor.darkGray
            dot_5.backgroundColor = UIColor.gray
        }
        else  {
            dot_1.backgroundColor = UIColor.darkGray
            dot_2.backgroundColor = UIColor.darkGray
            dot_3.backgroundColor = UIColor.darkGray
            dot_4.backgroundColor = UIColor.darkGray
            dot_5.backgroundColor = UIColor.darkGray
        }
     
        
    }

}
