
import UIKit

class ViewController: UIViewController {
    
    private var transitButton = UIButton()
    private var audioList = UITableView()
    private var songs = [Song]()
    private var logo = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureSongs()
        
        title = "AUDIO LIST"
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        logo.text = "L   O   C   A   L"
        logo.textAlignment = .center
        logo.textColor = .white
        logo.font = UIFont(name: "MontserratAlternates-Light", size: 35)
        logo.frame = CGRect(x: view.bounds.midX - 150,
                            y: view.bounds.maxY - 80,
                            width: 300,
                            height: 30)
        view.addSubview(logo)
        
        let audioListWidth: CGFloat = view.bounds.width / 1.03
        let audioListHeight: CGFloat = view.bounds.height / 1.3
        let audioListFrame = CGRect(x: view.bounds.midX - audioListWidth / 2,
                                         y: view.bounds.midY - audioListHeight / 2,
                                         width: audioListWidth,
                                         height: audioListHeight)
        audioList = UITableView(frame: audioListFrame)
        audioList.layer.cornerRadius = 25
        
        audioList.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        audioList.showsVerticalScrollIndicator = false
        audioList.delegate = self
        audioList.dataSource = self
        audioList.contentInset = UIEdgeInsets(top: audioListWidth / 20, left: 0, bottom: 0, right: 0)
        
        view.addSubview(audioList)
    }
    
    private func configureSongs() {
        songs.append(Song(name: "Fortunate Song",
                          artistName: "Creedence Clearwater Revival",
                          imageName: "CCR",
                          trackName: "CCR - Fortunate Song"))
        songs.append(Song(name: "Whole Lotta Love",
                          artistName: "Led Zeppelin",
                          imageName: "LedZeppelin",
                          trackName: "Led Zeppelin - Whole Lotta Love"))
        songs.append(Song(name: "One Of These Nights",
                          artistName: "Eagles",
                          imageName: "Eagles",
                          trackName: "Eagles - One Of These Nights"))
    }
    
    @objc private func onTransitButton() {
        let storyboard = UIStoryboard.init(name: "PlayerViewController", bundle: Bundle.main)
        let vc = storyboard.instantiateInitialViewController() as! PlayerViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: UITableViewDelegate & UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let song = songs[indexPath.row]
        // configure
        cell.textLabel?.text = song.trackName
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = UIImage(named: song.imageName)
        
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 18)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //present the player
        let position = indexPath.row
        let storyboard = UIStoryboard.init(name: "PlayerViewController", bundle: Bundle.main)
        let vc = storyboard.instantiateInitialViewController() as! PlayerViewController
        navigationController?.pushViewController(vc, animated: true)
        
        vc.songs = songs
        vc.position = position
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return audioList.bounds.width / 5
    }
}

struct Song {
    let name: String
    let artistName: String
    let imageName: String
    let trackName: String
}

