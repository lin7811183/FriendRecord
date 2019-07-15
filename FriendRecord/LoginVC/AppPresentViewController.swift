//
//  AppPresentViewController.swift
//  FriendRecord
//
//  Created by 林易興 on 2019/7/15.
//  Copyright © 2019 林易興. All rights reserved.
//

import UIKit

class AppPresentViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: func - Go to MainAPPVC
    @IBAction func goToMainApp(_ sender: Any) {
        let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbarVC") as! MyTabBarController
        self.present(tabbarVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let appPageVC = segue.destination as? AppPageViewController {
            
            // 代理 pageViewController
            appPageVC.AppPagedelegate = self
        }
    }
}

extension AppPresentViewController :AppPageViewControllerDelegate {
    /// 設定總頁數
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - numberOfPage: _
    func pageViewController(_ pageViewController: AppPageViewController, didUpdateNumberOfPage numberOfPage: Int) {
        self.pageControl.numberOfPages = numberOfPage
    }
    
    /// 設定切換至第幾頁
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - pageIndex: _
    func pageViewController(_ pageViewController: AppPageViewController, didUpdatePageIndex pageIndex: Int) {
        self.pageControl.currentPage = pageIndex
    }
    
    
}
