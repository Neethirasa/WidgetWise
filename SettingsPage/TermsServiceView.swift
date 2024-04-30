//
//  TermsServiceView.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-08.
//

import SwiftUI
import WebKit

struct TermsServiceView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> TermsServiceViewController {
        let TermsServiceViewController = TermsServiceViewController()
        TermsServiceViewController.loadURL(url)
        return TermsServiceViewController
    }

    func updateUIViewController(_ uiViewController: TermsServiceViewController, context: Context) {}
}

class TermsServiceViewController: UIViewController {
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
        
        view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0) // Set background color to black
    }

    func loadURL(_ url: URL) {
        webView.load(URLRequest(url: url))
    }
}
/*
 #Preview {
 TermsServiceView()
 }
 */
