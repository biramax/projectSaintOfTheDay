//
//  ViewController.swift
//  SaintsOfTheDay
//
//  Created by Максим Бобков on 28.02.2024.
//

import UIKit

class ViewController: UITableViewController {

    private let networkService = NetworkService()
    private let coreDataService = CoreDataService()
    private var saints: [Saint] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        
        title = "Святые сегодняшнего дня"
        
        // Для возможности переиспользовать ячейки
        tableView.register(SaintCell.self, forCellReuseIdentifier: "cell")
        
        // Возможность обновить данные, потянув за экран
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(update), for: .valueChanged)
        
        getSaints()
    }
    
    func getSaints() {
        
        // Если в CoreData имеются данные о святых по состоянию на сегодняшнее число, то берём данные из CoreData
        let currentDate = Date()
        
        if let lastUpdateDate = coreDataService.getSaintsDate() {
            
            // Сравниваем дату последнего обновления с сегодняшней датой
            if Calendar.current.isDate(currentDate, inSameDayAs: lastUpdateDate) {
                
                // Данные для сегодняшней даты уже доступны в CoreData, считываем и загружаем в список
                saints = coreDataService.getSaints()
                self.tableView.reloadData()
                
                StaticVars.dataSource = "CoreData"
                print("Данные из CoreData")
            }
        }
        
        if StaticVars.dataSource == "API" {
            
            print("Данные из API")
            
            // Получаем токен
            networkService.getToken()
            
            // Получаем массив id святых сегодняшнего дня
            networkService.getSaintsIds(date: DateHelper.getCurrentDate()) { saintsIds in
                if let saintsIds = saintsIds {
                    
                    print(saintsIds)
                    
                    // По id запрашиваем данные - имя и икону святого
                    self.getSaintsByIds(saintsIds: saintsIds)
                    
                } else {
                    print("Произошла ошибка при получении данных")
                }
            }
        }
    }
    
    // Получаем данные о святых по собранным id
    func getSaintsByIds(saintsIds: [Int]) {
  
        networkService.getSaintsByIds(saintsIds: saintsIds) { saints in
            if let saints = saints {
                
                print(saints)
                
                self.saints = saints
                
                // Сохраняем данные о святых в CoreData
                self.coreDataService.saveSaints(saints: saints)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } else {
                print("Произошла ошибка при получении данных")
            }
        }
    }
    
    // Определяем количество ячеек в каждом разделе
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        saints.count
    }
    
    // Саму ячеку определяем в отдельном классе FriendsCell в отдельном файле
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Проверяем, а точно ли ячейка, полученная через dequeueReusableCell, имеет нужный нам тип - SaintCell.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SaintCell else {
            return UITableViewCell()
        }
        
        cell.updateCell(saint: saints[indexPath.row])
        
        cell.tap = { [weak self] saintId in
            self?.navigationController?.pushViewController(SaintViewController(saintId: saintId ?? 0), animated: true)
        }
        return cell
    }
    
    // Возможность обновить данные, потянув за экран
    @objc func update() {
        
        // Получаем токен
        networkService.getToken()
        
        // Получаем массив id святых сегодняшнего дня
        networkService.getSaintsIds(date: DateHelper.getCurrentDate()) { saintsIds in
            if let saintsIds = saintsIds {
                
                print(saintsIds)
                
                // По id запрашиваем данные - имя и икону святого
                self.getSaintsByIds(saintsIds: saintsIds)
                
            } else {
                print("Произошла ошибка при получении данных")
            }
            
            // Переход на основной поток для остановки процесса апдейта (иконка лоадера перестанет крутиться)
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }
}

