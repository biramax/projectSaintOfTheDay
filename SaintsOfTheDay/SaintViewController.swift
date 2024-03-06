//
//  SaintViewController.swift
//  SaintsOfTheDay
//
//  Created by Максим Бобков on 29.02.2024.
//

import UIKit

class SaintViewController: UIViewController {
    
    private let networkService = NetworkService()
    private let coreDataService = CoreDataService()
    private var saintId: Int

    // Икона
    private var saintIcon: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        //view.contentMode = .scaleAspectFill
        //view.clipsToBounds = true // Обрезание по границам
        return view
    }()
    
    // Имя
    private var saintName: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 25)
        return label
    }()
    
    // Описание жизни святого
    private var saintDescription: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    // Добавляем свойства contentSize, scrollView и contentView для обеспечения прокрутки экрана
    
    private var contentSize: CGSize {
        CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = view.bounds
        scrollView.contentSize = contentSize
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.frame.size = contentSize
        return contentView
    }()
    
    
    init(saintId: Int) {
        
        self.saintId = saintId
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        title = "Святые сегодняшнего дня"

        // Если в CoreData имеются данные о святых по состоянию на сегодняшнее число, то берём данные из CoreData
        let currentDate = Date()
        
        if let lastUpdateDate = coreDataService.getSaintsDate() {
            
            // Сравниваем дату последнего обновления с сегодняшней датой
            if Calendar.current.isDate(currentDate, inSameDayAs: lastUpdateDate) {
                
                // Данные для сегодняшней даты уже доступны в CoreData, считываем данные о святом
                if let saint = coreDataService.getSaint(self.saintId) {
                    
                    // Проверяем, что у святого есть икона
                    if let iconUrlString = saint.icons.first?.urlM, let url = URL(string: iconUrlString) {
                        
                        let task = URLSession.shared.dataTask(with: url) { data, response, error in
                            
                            // Если икона не загружена, ничего не размещаем
                            if error != nil {
                                DispatchQueue.main.async {
                                    self.saintIcon.image = nil
                                    self.saintIcon.isHidden = true
                                    self.setupWithoutIconConstraints()
                                }
                                return
                            }
                            
                            // Иначе отображаем икону
                            if let data = data {
                                DispatchQueue.main.async {
                                    let icon = UIImage(data: data)
                                    self.saintIcon.image = icon
                                    self.saintIcon.isHidden = false
                                    
                                    // Передаём ширину и высоту иконы для задания в констрейнтах
                                    self.setupIconConstraints(width: icon?.size.width ?? 0, height: icon?.size.height ?? 0)
                                }
                            } else {
                                self.setupWithoutIconConstraints()
                            }
                        }

                        task.resume()
                    } else {
                        // Если URL изображения недоступен, ничего не размещаем
                        DispatchQueue.main.async {
                            self.saintIcon.image = nil
                            self.saintIcon.isHidden = true
                            self.setupWithoutIconConstraints()
                        }
                    }
                    
                    self.saintName.text = saint.name
                    self.saintDescription.text = saint.description.removeHTMLTags()
                    
                } else {
                    print("Произошла ошибка при получении данных")
                }
                
                StaticVars.dataSource = "CoreData"
                print("Данные из CoreData")
            }
        }
        
        if StaticVars.dataSource == "API" {
            
            print("Данные из API")
            
            networkService.getSaintById(saintId: saintId) { [weak self] saint in
                
                guard let self else { return }
                
                if let saint = saint {
                    
                    print(saint)
                    
                    DispatchQueue.main.async {
                        
                        // Используем highestPriorityIconUrlM для получения URL иконы с наивысшим приоритетом
                        if let highestPriorityIconUrl = saint.highestPriorityIconUrlM(), let url = URL(string: highestPriorityIconUrl) {
                            
                            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                                
                                // Если икона не загружена, ничего не размещаем
                                if error != nil {
                                    DispatchQueue.main.async {
                                        self.saintIcon.image = nil
                                        self.saintIcon.isHidden = true
                                        self.setupWithoutIconConstraints()
                                    }
                                    return
                                }
                                
                                // Иначе отображаем икону
                                if let data = data {
                                    DispatchQueue.main.async {
                                        let icon = UIImage(data: data)
                                        self.saintIcon.image = icon
                                        self.saintIcon.isHidden = false
                                        
                                        // Передаём ширину и высоту иконы для задания в констрейнтах
                                        self.setupIconConstraints(width: icon?.size.width ?? 0, height: icon?.size.height ?? 0)
                                    }
                                } else {
                                    self.setupWithoutIconConstraints()
                                }
                            }
                            
                            task.resume()
                            
                        } else {
                            // Если URL изображения недоступен, ничего не размещаем
                            DispatchQueue.main.async {
                                self.saintIcon.image = nil
                                self.saintIcon.isHidden = true
                                self.setupWithoutIconConstraints()
                            }
                        }
                        
                        self.saintName.text = saint.name
                        self.saintDescription.text = saint.description.removeHTMLTags()
                    }
                    
                } else {
                    print("Произошла ошибка при получении данных")
                }
            }
        }
        
        setupUI()
        addConstraints()
    }
}



private extension SaintViewController {
    
    func setupUI() {
        
        // Для обеспечения прокрутки экрана
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    
        contentView.addSubview(saintIcon)
        contentView.addSubview(saintName)
        contentView.addSubview(saintDescription)
    }
    
    // Выставляем констрейнты, если икона загружена
    func setupIconConstraints(width: CGFloat, height: CGFloat) {
        NSLayoutConstraint.activate([
            saintIcon.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            saintIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saintIcon.widthAnchor.constraint(equalToConstant: width),
            saintIcon.heightAnchor.constraint(equalToConstant: height),
            
            saintName.topAnchor.constraint(equalTo: saintIcon.bottomAnchor, constant: 20),
        ])
    }
    
    // Выставляем констрейнты, если икона не загружена
    func setupWithoutIconConstraints() {
        NSLayoutConstraint.activate([
            saintName.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
        ])
    }
    
    func addConstraints() {
        
        saintIcon.translatesAutoresizingMaskIntoConstraints = false
        saintName.translatesAutoresizingMaskIntoConstraints = false
        saintDescription.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            saintName.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            saintName.heightAnchor.constraint(equalToConstant: 30),
            saintName.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15),
            
            saintDescription.topAnchor.constraint(equalTo: saintName.bottomAnchor, constant: 20),
            saintDescription.leftAnchor.constraint(equalTo: saintName.leftAnchor),
            saintDescription.rightAnchor.constraint(equalTo: saintName.rightAnchor),
            saintDescription.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}
