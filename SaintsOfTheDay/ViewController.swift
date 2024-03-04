//
//  ViewController.swift
//  SaintsOfTheDay
//
//  Created by Максим Бобков on 28.02.2024.
//

import UIKit

class ViewController: UITableViewController {

    private let networkService = NetworkService()
    
    private var saints: [Saint] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        
        title = "Святые сегодняшнего дня"
        
        // Для возможности переиспользовать ячейки
        tableView.register(SaintCell.self, forCellReuseIdentifier: "cell")
        
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
    
    // Получаем данные о святых по собранным id
    func getSaintsByIds(saintsIds: [Int]) {
  
        networkService.getSaintsByIds(saintsIds: saintsIds) { saints in
            if let saints = saints {
                
                print(saints)
                
                self.saints = saints
                
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
}

