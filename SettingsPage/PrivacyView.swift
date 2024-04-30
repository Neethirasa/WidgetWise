//
//  PrivacyView.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-08.
//
import SwiftUI
import WebKit

struct PrivacyView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> PrivacyViewController {
        let privacyViewController = PrivacyViewController()
        privacyViewController.loadURL(url)
        return privacyViewController
    }

    func updateUIViewController(_ uiViewController: PrivacyViewController, context: Context) {}
}

class PrivacyViewController: UIViewController {
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.backgroundColor = .black // Set background color to black
    }

    func loadURL(_ url: URL) {
        webView.load(URLRequest(url: url))
    }
}


/*
 #Preview {
 PrivacyView()
 }
 */
