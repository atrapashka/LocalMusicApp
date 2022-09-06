
import AVKit
import MediaPlayer
import AVFoundation
import UIKit

class PlayerViewController: UIViewController {
    
    var position: Int = 0
    var songs: [Song] = []
    
    private var minutes: Int = 0
    private var seconds: Int = 0
    private var durationMinutes = Int()
    private var durationSeconds = Int()
    private var progressLineWidth: CGFloat = 0
    private var visualDuration: CGFloat = 0
    private var swipeLeftGestureRecognizer = UISwipeGestureRecognizer()
    private var swipeRightGestureRecognizer = UISwipeGestureRecognizer()
    private var player = AVAudioPlayer()
    private var timer = Timer()

    private var songListCollectionView: UICollectionView!
    private var mainView = UIView()
    private var lineLabel = UILabel()
    private var progressLineLabel = UILabel()
    private var artistLabel = UILabel()
    private var songLabel = UILabel()
    private var currentTime = UILabel()
    private var endTime = UILabel()
    private var playButton = UIButton()
    private var nextButton = UIButton()
    private var previousButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = averageColor(image: UIImage(named: songs[position].imageName)!)
        setupBackgroundUI()
        setupControlsUI()
        setupAudioInfoUI()
        setupCollectionView()
        setUpPlayer()
        
        setupRemoteTransportControls()
        setupNowPlaying()
        setupAVAudioSession()
        
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(fireTimer),
                                     userInfo: nil,
                                     repeats: true)
        
        songListCollectionView.scrollToItem(at: IndexPath(row: position, section: 0),
                                            at: .centeredHorizontally,
                                            animated: true)
    }
    
    //MARK: - Actions
    //MARK: -
    
    @objc private func fireTimer() {
        if progressLineWidth < lineLabel.bounds.width {
            progressLineWidth = progressLineWidth + visualDuration
        } else {
            progressLineWidth = 0
        }
        progressLineLabel.frame.size = CGSize(width: progressLineWidth, height: 3)
        
        if seconds < 59 {
            seconds = seconds + 1
        } else {
            seconds = 0
            minutes = minutes + 1
        }
        
        if durationSeconds > 0 {
            durationSeconds = durationSeconds - 1
        } else {
            durationSeconds = 59
            durationMinutes = durationMinutes - 1
        }
        
        if seconds < 10 {
            currentTime.text = "\(minutes):0\(seconds)"
        } else {
            currentTime.text = "\(minutes):\(seconds)"
        }
        
        if durationSeconds < 10 {
            endTime.text = "\(durationMinutes):0\(durationSeconds)"
        } else {
            endTime.text = "\(durationMinutes):\(durationSeconds)"
        }
    }
    
    @objc private func onPlayButton() {
        if player.isPlaying == true {
            playButton.setImage(UIImage(named: "playButton"), for: .normal)
            player.pause()
            timer.invalidate()
        } else {
            player.play()
            playButton.setImage(UIImage(named: "pauseButton"), for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(fireTimer),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    @objc private func onNextButton() {
        if position < (songs.count - 1) {
            position = position + 1
        } else {
            position = 0
        }
        songListCollectionView.scrollToItem(at: IndexPath(row: position, section: 0),
                                            at: .centeredHorizontally,
                                            animated: true)
        view.backgroundColor = averageColor(image: UIImage(named: songs[position].imageName)!)
        setupAudioInfoUI()
        setUpPlayer()
        setupNowPlaying()
        
        minutes = 0
        seconds = 0
        progressLineWidth = 0
    }
    
    @objc private func onPreviousButton() {
        if position > 0 {
            position = position - 1
        } else {
            position = (songs.count - 1)
        }
        
        songListCollectionView.scrollToItem(at: IndexPath(row: position, section: 0),
                                            at: .centeredHorizontally,
                                            animated: true)
        view.backgroundColor = averageColor(image: UIImage(named: songs[position].imageName)!)
        setupAudioInfoUI()
        setUpPlayer()
        setupNowPlaying()
        
        minutes = 0
        seconds = 0
        progressLineWidth = 0
    }
    
    //MARK: - Private Functions
    //MARK: -
    
    private func setupAVAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            debugPrint("AVAudioSession is Active and Category Playback is set")
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            debugPrint("Error: \(error)")
        }
    }
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [unowned self] event in
            print("Play command - is playing: \(self.player.isPlaying)")
            if !self.player.isPlaying {
                self.play()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { [unowned self] event in
            print("Pause command - is playing: \(self.player.isPlaying)")
            if self.player.isPlaying {
                self.pause()
                return .success
            }
            return .commandFailed
        }
    }

    func setupNowPlaying() {
        let song = songs[position]
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = song.trackName

        if let image = UIImage(named: song.imageName) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    func play() {
        player.play()
        updateNowPlaying(isPause: false)
        print("Play - current time: \(player.currentTime) - is playing: \(player.isPlaying)")
    }

    func pause() {
        player.pause()
        updateNowPlaying(isPause: true)
        print("Pause - current time: \(player.currentTime) - is playing: \(player.isPlaying)")
    }

    func updateNowPlaying(isPause: Bool) {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo!

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPause ? 0 : 1

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupCollectionView() {
        let layoutFlow = UICollectionViewFlowLayout()
        layoutFlow.scrollDirection = .horizontal
        layoutFlow.itemSize = CGSize(width: mainView.bounds.width / 1.55,
                                     height: mainView.bounds.width / 1.55)
        let collectionViewWidth: CGFloat = mainView.bounds.width
        let collectionViewHeight: CGFloat = mainView.bounds.width / 1.5
        let collectionViewFrame = CGRect(x: mainView.bounds.midX - collectionViewWidth / 2,
                                         y: mainView.bounds.minY + collectionViewHeight / 1.9,
                                         width: collectionViewWidth,
                                         height: collectionViewHeight)
        songListCollectionView = UICollectionView(frame: collectionViewFrame,
                                                  collectionViewLayout: layoutFlow)
        songListCollectionView.backgroundColor = .none
        songListCollectionView.isScrollEnabled = false
        songListCollectionView.register(SongCollectionViewCell.self,
                                        forCellWithReuseIdentifier: SongCollectionViewCell.identifier)
        songListCollectionView.dataSource = self
        songListCollectionView.delegate = self
        songListCollectionView.showsHorizontalScrollIndicator = false
        
        mainView.addSubview(songListCollectionView)
        
        swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self,
                                                              action: #selector(onNextButton))
        swipeLeftGestureRecognizer.direction = .left
        songListCollectionView.addGestureRecognizer(swipeLeftGestureRecognizer)
        
        swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self,
                                                               action: #selector(onPreviousButton))
        swipeRightGestureRecognizer.direction = .right
        songListCollectionView.addGestureRecognizer(swipeRightGestureRecognizer)
    }
    
    private func setupBackgroundUI() {
        mainView.frame = view.bounds
        view.addSubview(mainView)
        
        let blur = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blur)
        blurEffectView.frame = mainView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainView.addSubview(blurEffectView)
    }
    
    private func setupControlsUI() {
        let lineWidth: CGFloat = view.bounds.width / 1.2
        let lineHeight: CGFloat = 3
        let playButtonWidth: CGFloat = view.bounds.width / 6
        let playButtonHeight: CGFloat = view.bounds.width / 6
        let sideButtonWidth: CGFloat = view.bounds.width / 10
        let sideButtonHeight: CGFloat = view.bounds.width / 10
        
        lineLabel.backgroundColor = .gray
        lineLabel.alpha = 0.5
        lineLabel.frame = CGRect(x: view.bounds.midX - lineWidth / 2,
                                 y: view.bounds.midY + lineWidth / 3,
                                 width: lineWidth,
                                 height: lineHeight)
        mainView.addSubview(lineLabel)
        
        playButton.frame = CGRect(x: view.bounds.midX - playButtonWidth / 2,
                                  y: view.bounds.midY + playButtonHeight * 3,
                                  width: playButtonWidth,
                                  height: playButtonHeight)
        
        playButton.addTarget(self, action: #selector(onPlayButton), for: .touchUpInside)
        playButton.setImage(UIImage(named: "pauseButton"), for: .normal)
        mainView.addSubview(playButton)
        
        nextButton.frame = playButton.frame.offsetBy(dx: 100, dy: 14)
        nextButton.frame.size = CGSize(width: sideButtonWidth,
                                       height: sideButtonHeight)
        nextButton.addTarget(self, action: #selector(onNextButton), for: .touchUpInside)
        nextButton.setImage(UIImage(named: "nextButton"), for: .normal)
        mainView.addSubview(nextButton)
        
        previousButton.frame = playButton.frame.offsetBy(dx: -75, dy: 14)
        previousButton.frame.size = CGSize(width: sideButtonWidth,
                                       height: sideButtonHeight)
        previousButton.addTarget(self, action: #selector(onPreviousButton), for: .touchUpInside)
        previousButton.setImage(UIImage(named: "previousButton"), for: .normal)
        mainView.addSubview(previousButton)
    }
    
    private func averageColor(image: UIImage) -> UIColor {
            let inputImage = CIImage(image: image)
            let extentVector = CIVector(x: inputImage!.extent.origin.x,
                                        y: inputImage!.extent.origin.y,
                                        z: inputImage!.extent.size.width,
                                        w: inputImage!.extent.size.height)

            let filter = CIFilter(name: "CIAreaAverage",
                                  parameters: [kCIInputImageKey: inputImage,
                                              kCIInputExtentKey: extentVector])
            let outputImage = filter!.outputImage

            var bitmap = [UInt8](repeating: 0, count: 4)
            let context = CIContext(options: [.workingColorSpace: kCFNull])
            context.render(outputImage!,
                           toBitmap: &bitmap,
                           rowBytes: 4,
                           bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                           format: .RGBA8,
                           colorSpace: nil)

            return UIColor(red: CGFloat(bitmap[0]) / 255,
                           green: CGFloat(bitmap[1]) / 255,
                           blue: CGFloat(bitmap[2]) / 255,
                           alpha: CGFloat(bitmap[3]) / 255)
    }
    
    func setUpPlayer() {
        let song = songs[position]
        do {
            let url = Bundle.main.url(forResource: song.trackName, withExtension: "mp3")
            player = try AVAudioPlayer(contentsOf: url!)
            player.prepareToPlay()
        } catch let error as NSError {
            print("Failed to init audio player: \(error)")
        }
        player.play()
    }
    
    private func setupAudioInfoUI() {
        
        let song = songs[position]
        let urlString = Bundle.main.path(forResource: song.trackName, ofType: "mp3")
        
        let labelWidth: CGFloat = lineLabel.bounds.width
        let labelHeight: CGFloat = labelWidth / 12

        artistLabel.frame = lineLabel.frame.offsetBy(dx: 0, dy: -60)
        artistLabel.frame.size = CGSize(width: labelWidth, height: labelHeight)
        artistLabel.text = song.artistName
        artistLabel.textColor = .systemGray5
        mainView.addSubview(artistLabel)
        
        songLabel.frame = artistLabel.frame.offsetBy(dx: 0, dy: -35)
        songLabel.text = song.name
        songLabel.font = UIFont(name: "Helvetica-Bold", size: 18)
        songLabel.textColor = .white
        mainView.addSubview(songLabel)
        
        currentTime.frame = CGRect(x: view.bounds.minX + (view.bounds.width - labelWidth) / 2,
                                   y: lineLabel.frame.maxY + 5,
                                   width: labelWidth / 2,
                                   height: labelHeight)
        
        let audioAsset = AVURLAsset.init(url: URL(fileURLWithPath: urlString!), options: nil)
        let duration = audioAsset.duration
        let durationGlobal = CMTimeGetSeconds(duration)
        durationMinutes = Int(durationGlobal) / 60
        durationSeconds = Int(durationGlobal) - durationMinutes * 60
        
        visualDuration = lineLabel.bounds.width / ((CGFloat(durationMinutes) * 60) + CGFloat(durationSeconds))
        
        currentTime.text = "0:00"
        currentTime.textAlignment = .left
        currentTime.textColor = .white
        mainView.addSubview(currentTime)
        
        endTime.frame = CGRect(x: view.bounds.midX,
                               y: lineLabel.frame.maxY + 5,
                               width: labelWidth / 2,
                               height: labelHeight)
        endTime.text = "\(durationMinutes):\(durationSeconds)"
        endTime.textColor = .white
        endTime.textAlignment = .right
        mainView.addSubview(endTime)
        
        progressLineLabel.backgroundColor = .white
        progressLineLabel.frame = CGRect(x: view.bounds.midX - labelWidth / 2,
                                         y: view.bounds.midY + labelWidth / 3,
                                         width: progressLineWidth,
                                         height: 3)
        mainView.addSubview(progressLineLabel)
    }
}

extension PlayerViewController: UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongCollectionViewCell.identifier,
                                                      for: indexPath) as! SongCollectionViewCell
        let song = songs[indexPath.item]
        cell.configure(image: song.imageName)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let totalCellWidth = 80 * songListCollectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = 10 * (songListCollectionView.numberOfItems(inSection: 0) - 1)

        let leftInset = (songListCollectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2.2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}
