
import CMP
import UIKit

class ViewController: UIViewController {

    @IBAction func showPopup(_ sender: Any) {
        //show UI
        OpenCmp.showUI()

    }
    
    @IBAction func cleanData(_ sender: Any) {
        //clear saved data
        OpenCmp.clearData()
    }
    
}
