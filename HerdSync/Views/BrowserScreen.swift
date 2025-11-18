import SwiftUI
import WebKit

struct BrowserScreen: UIViewControllerRepresentable {
    let link: String
    
    func makeUIViewController(context: Context) -> BrowserViewController {
        let controller = BrowserViewController()
        controller.link = link
        return controller
    }
    
    func updateUIViewController(_ uiViewController: BrowserViewController, context: Context) {
    }
}

class BrowserViewController: UIViewController, WKNavigationDelegate {
    var link: String = ""
    private var browserView: WKWebView!
    private var loadingView: UIView!
    private var activityIndicator: UIActivityIndicatorView!
    private var isFirstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = .all
        view.backgroundColor = .black
        
        loadingView = UIView()
        loadingView.backgroundColor = .black
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        loadingView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
        ])
        
        browserView = WKWebView()
        browserView.navigationDelegate = self
        browserView.translatesAutoresizingMaskIntoConstraints = false
        browserView.backgroundColor = .black
        browserView.alpha = 0
        if #available(iOS 11.0, *) {
            browserView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(browserView)
        
        NSLayoutConstraint.activate([
            browserView.topAnchor.constraint(equalTo: view.topAnchor),
            browserView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            browserView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            browserView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.bringSubviewToFront(loadingView)
        
        if let linkAddress = URL(string: link) {
            let request = URLRequest(url: linkAddress)
            browserView.load(request)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DispatchQueue.main.async {
            if self.isFirstLoad {
                self.showLoadingView()
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            if self.isFirstLoad {
                self.hideLoadingView()
                self.isFirstLoad = false
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            if self.isFirstLoad {
                self.hideLoadingView()
                self.isFirstLoad = false
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            if self.isFirstLoad {
                self.hideLoadingView()
                self.isFirstLoad = false
            }
        }
    }
    
    private func showLoadingView() {
        loadingView.alpha = 1
        activityIndicator.startAnimating()
        browserView.alpha = 0
    }
    
    private func hideLoadingView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingView.alpha = 0
            self.browserView.alpha = 1
        }) { _ in
            self.loadingView.removeFromSuperview()
            self.activityIndicator.stopAnimating()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        AppDelegate.orientationLock = .all
        setOrientationSupport(allOrientations: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        AppDelegate.orientationLock = .all
        setOrientationSupport(allOrientations: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setOrientationSupport(allOrientations: false)
    }
    
    private func setOrientationSupport(allOrientations: Bool) {
        AppDelegate.orientationLock = allOrientations ? .all : .portrait
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return
            }
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: AppDelegate.orientationLock))
            UIViewController.attemptRotationToDeviceOrientation()
        } else {
            if allOrientations {
                UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
}

