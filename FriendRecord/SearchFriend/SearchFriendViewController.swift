import UIKit

class SearchFriendViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        let searchController = UISearchController(searchResultsController: nil)
//        searchController.searchResultsUpdater = self
//        searchController.dimsBackgroundDuringPresentation = false
//        navigationItem.searchController = searchController
//        definesPresentationContext = true
    }
}

/*------------------------------------------------------------ Protocol ------------------------------------------------------------*/
extension SearchFriendViewController :UISearchResultsUpdating {
    //MARK: func - UISearchResultsUpdating.
    func updateSearchResults(for searchController: UISearchController) {
        //...
    }
}
