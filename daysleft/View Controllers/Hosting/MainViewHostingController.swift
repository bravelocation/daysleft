//
//  MainViewHostingController.swift
//  DaysLeft
//
//  Created by John Pollard on 21/09/2022.
//  Copyright © 2022 Brave Location Software. All rights reserved.
//

import Foundation
import SwiftUI

class MainViewHostingController<Content: View>: UIHostingController<Content>, ViewModelActionDelegate {

    let dataManager = AppSettingsDataManager()
    let viewModel: DaysLeftViewModel

    init() {
        self.viewModel = DaysLeftViewModel(dataManager: self.dataManager)
        
        let rootView = MainView(model: self.viewModel)
        super.init(rootView: AnyView(rootView) as! Content)
        
        self.viewModel.delegate = self
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Customise the nav bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "MainAppColor")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        
        let buttonAppearance = UIBarButtonItemAppearance(style: .plain)
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.buttonAppearance = buttonAppearance
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func share() {
        let modelText = self.dataManager.appSettings.fullDescription(Date())
        let objectsToShare = [modelText]
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        //activityViewController.popoverPresentationController?.barButtonItem = self.shareButton
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func edit() {
        let settingsViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SettingsViewController")
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
}
