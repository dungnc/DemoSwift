//
//  MapViewController.swift
//  TediousProvider
//
//  Created by Nguyen Chi Dung on 5/3/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import UIKit
import GoogleMaps
import SVProgressHUD

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    fileprivate var viewModel: MapViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Provider.current != nil {
            if viewModel == nil {
                viewModel = MapViewModel()
                setupTasks()
                setupLocation()
            } else {
                reloadData(true)
            }
        }
    }
    
    // MARK: - Private Methods
    
    func setupLocation() {
        viewModel.rx_currentLocation.asObservable()
            .filter({ $0 != nil })
            .map({ $0! })
            .take(1)
            .subscribe(onNext: { [weak self] (location) in
                if (self?.viewModel.rx_taskViewModels.value ?? []).count == 0 {
                    self?.mapView.setMinZoom(1, maxZoom: 15)
                    self?.mapView.moveCamera(.setTarget(location.coordinate))
                    self?.mapView.setMinZoom(1, maxZoom: 100)
                }
            }).disposed(by: rx.disposeBag)
    }
    
    func reloadData(_ needsUpdateMap: Bool) {
        self.mapView.clear()
        if let tasks = viewModel.rx_taskViewModels.value {
            let markers = self.displayTasks(tasks)
            if needsUpdateMap {
                self.updateMap(with: markers)
            }
        }
    }
    
    func setupTasks() {
        var needsUpdateMap = true
        SVProgressHUD.show()
        viewModel.rx_taskViewModels.asObservable()
            .filter({ $0 != nil })
            .map({ $0! })
            .subscribe(onNext: { [weak self] (tasks) in
                guard let `self` = self else { return }
                SVProgressHUD.dismiss()
                self.reloadData(needsUpdateMap)
                needsUpdateMap = false
            })
            .disposed(by: viewModel.rx.disposeBag)
    }
    
    
    func displayTasks(_ allTasks: [TaskDetailsViewModel]) -> [GMSMarker] {
        guard allTasks.count > 0 else {
            return []
        }
        let tasks: [TaskDetailsViewModel] = Array(allTasks.prefix(K.Value.Map.MarkersLimit))
        var markers: [GMSMarker] = []
        for i in 0..<tasks.count {
            let task = tasks[i].rx_task.value
            let marker = GMSMarker(position: task.location.coordinate)
            marker.title = task.address
            marker.tracksViewChanges = false
            let markerFrame = CGRect(x: 0, y: 0, width: 48, height: 84)
            let markerView = UIView(frame: markerFrame)
            markerView.backgroundColor = UIColor.clear
            let photoImageView = UIImageView(frame: markerView.bounds)
            photoImageView.backgroundColor = UIColor.clear
            photoImageView.image = UIImage(named: "task_pin")
            markerView.addSubview(photoImageView)
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.iconView = markerView
            marker.map = self.mapView
            markers += [marker]
        }
        return markers
    }
    
    func updateMap(with markers: [GMSMarker]) {
        var bounds = markers.reduce(GMSCoordinateBounds()) {
            $0.includingCoordinate($1.position)
        }
        if let currentLocation = viewModel.rx_currentLocation.value {
            bounds = bounds.includingCoordinate(currentLocation.coordinate)
        }
        mapView.setMinZoom(1, maxZoom: 15)
        mapView.moveCamera(.fit(bounds, withPadding: 30))
        mapView.setMinZoom(1, maxZoom: 100)
    }
}
