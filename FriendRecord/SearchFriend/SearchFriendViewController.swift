import UIKit

class SearchFriendViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setTabBarSearchItem()
        
    }
    
    /*------------------------------------------------------------ Functions. ------------------------------------------------------------*/
    //MARK: func - set TarBar SearchBar.
    func setTabBarSearchItem() {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.placeholder = "搜尋知音"
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
    }
}

/*------------------------------------------------------------ Protocol ------------------------------------------------------------*/
extension SearchFriendViewController :UISearchBarDelegate {
    
}
