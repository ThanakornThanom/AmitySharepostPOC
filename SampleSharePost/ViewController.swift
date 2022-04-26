//
//  ViewController.swift
//  SampleSharePost
//
//  Created by Thanakorn Thanom on 26/4/2565 BE.
//

import UIKit
import AmityUIKit
import AmitySDK
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        AmityFeedUISettings.shared.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "customcell1")
        AmityFeedUISettings.shared.dataSource = self
        // Do any additional setup after loading the view.
        let feedViewController = AmityGlobalFeedViewController.make()
        
        self.navigationController?.pushViewController(feedViewController, animated: true)
    

    }


}

extension ViewController: AmityFeedDataSource {
    
    // 2.
    // Provide your rendering component for custom post.
    func getUIComponentForPost(post: AmityPostModel, at index: Int) -> AmityPostComposable? {
        switch post.dataType {
        case "custom.textType":
            return MyCustomPostComponent(post: post)
        default:
            return nil
        }
    }
}

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var contentString: UITextView!
    @IBOutlet weak var diplayName: UILabel!
    var token: AmityNotificationToken?
    var postRepository: AmityPostRepository?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.postRepository = AmityPostRepository(client: AmityUIKitManager.client)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


struct MyCustomPostComponent: AmityPostComposable {
  
    
    var post: AmityPostModel
  
    // Post data model which you can use to render ui.
     init(post: AmityPostModel) {
        self.post = post
        
    }
    
    func getComponentCount(for index: Int) -> Int {
        return 3
    }
    
    func getComponentCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: AmityPostHeaderTableViewCell.cellIdentifier, for: indexPath) as! AmityPostHeaderTableViewCell
                     // ... populate cell data here
            cell.display(post: self.post)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "customcell1", for: indexPath) as! CustomTableViewCell
            guard let sharedPostID:String = post.data["postID"] as? String else{
                return cell
            }
            print(sharedPostID)
            cell.postText.text = post.data["text"] as? String
            cell.token = cell.postRepository?.getPostForPostId(sharedPostID).observeOnce { liveObject, error in
                if let error = error{
                    print(error)
                }
                else{
                    cell.diplayName.text = liveObject.object?.postedUser?.displayName
                    cell.contentString.text = liveObject.object?.data!["text"] as! String
                  
                }
          
                
            }
               
            
            return cell
          
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmityPostFooterTableViewCell", for: indexPath) as! AmityPostFooterTableViewCell
                     // ... populate cell data here
            cell.display(post: self.post)
            return cell
        default:
                        fatalError("indexPath is out of bound")
        }
    }
    
    // Height for each cell component
    func getComponentHeight(indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


