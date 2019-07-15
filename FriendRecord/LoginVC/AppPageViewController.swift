import UIKit

protocol AppPageViewControllerDelegate: class {
    
    /// 設定頁數
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - numberOfPage: _
    func pageViewController(_ pageViewController: AppPageViewController, didUpdateNumberOfPage numberOfPage: Int)
    
    /// 當 pageViewController 切換頁數時，設定 pageControl 的頁數
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - pageIndex: _
    func pageViewController(_ pageViewController: AppPageViewController, didUpdatePageIndex pageIndex: Int)
}


class AppPageViewController: UIPageViewController {
    
    var viewControllerList: [UIViewController] = [UIViewController]()
    var AppPagedelegate :AppPageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 依 storyboard ID 生成 viewController 並加到要用來顯示 pageViewController 畫面的陣列裡
        self.viewControllerList.append(self.getViewController(withStoryboardID: "page-1"))
        self.viewControllerList.append(self.getViewController(withStoryboardID: "page-2"))
        self.viewControllerList.append(self.getViewController(withStoryboardID: "page-3"))
        self.viewControllerList.append(self.getViewController(withStoryboardID: "page-4"))
        
        self.delegate = self
        self.dataSource = self
        
        // 設定 pageViewControoler 的首頁
        self.setViewControllers([self.viewControllerList.first!], direction:UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
    }
    
    fileprivate func getViewController(withStoryboardID storyboardID: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyboardID)
    }
}

extension AppPageViewController :UIPageViewControllerDelegate {
    /// 切換完頁數觸發的 func
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - finished: _
    ///   - previousViewControllers: _
    ///   - completed: _
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // 取得當前頁數的 viewController
        let currentViewController: UIViewController = (self.viewControllers?.first)!
        
        // 取得當前頁數的 index
        let currentIndex: Int =  self.viewControllerList.index(of: currentViewController)!
        
        // 設定 RootViewController 上 PageControl 的頁數
        self.AppPagedelegate?.pageViewController(self, didUpdatePageIndex: currentIndex)
    }
}

extension AppPageViewController :UIPageViewControllerDataSource {
    /// 上一頁
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - viewController: _
    /// - Returns: _
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        // 取得當前頁數的 index(未翻頁前)
        let currentIndex: Int =  self.viewControllerList.index(of: viewController)!
        
        // 設定上一頁的 index
        let priviousIndex: Int = currentIndex - 1
        
        // 判斷上一頁的 index 是否小於 0，若小於 0 則停留在當前的頁數
        return priviousIndex < 0 ? nil : self.viewControllerList[priviousIndex]
    }
    
    /// 下一頁
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - viewController: _
    /// - Returns: _
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        // 取得當前頁數的 index(未翻頁前)
        let currentIndex: Int =  self.viewControllerList.index(of: viewController)!
        
        // 設定下一頁的 index
        let nextIndex: Int = currentIndex + 1
        
        // 判斷下一頁的 index 是否大於總頁數，若大於則停留在當前的頁數
        return nextIndex > self.viewControllerList.count - 1 ? nil : self.viewControllerList[nextIndex]
    }
}
