//
//  SaintViewController.swift
//  SaintsOfTheDay
//
//  Created by Максим Бобков on 29.02.2024.
//

import UIKit

class SaintViewController: UIViewController {
    
    // Создаём объект NetworkService
    private let networkService = NetworkService()
    
    private var saintId: Int

    // Икона
    private var saintIcon: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true // Обрезание по границам
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
        CGSize(width: view.frame.width, height: view.frame.height * 2)
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
        
        networkService.getSaintById(saintId: saintId) { saint in
            
            if let saint = saint {
                
                print(saint)
                
                DispatchQueue.main.async {
                    
                    // Используем highestPriorityIconUrlM для получения URL иконы с наивысшим приоритетом
                    if let highestPriorityIconUrl = saint.highestPriorityIconUrlM(), let url = URL(string: highestPriorityIconUrl) {
                        
                        let task = URLSession.shared.dataTask(with: url) { data, response, error in
                            
                            // Если иконы не загружена, ничего не размещаем
                            if error != nil {
                                DispatchQueue.main.async {
                                    self.saintIcon.image = nil
                                    self.saintIcon.isHidden = true
                                }
                                return
                            }
                            
                            // Иначе отображаем икону
                            if let data = data {
                                DispatchQueue.main.async {
                                    self.saintIcon.image = UIImage(data: data)
                                    self.saintIcon.isHidden = false
                                }
                            }
                        }

                        task.resume()
                        
                    } else {
                        // Если URL изображения недоступен, ничего не размещаем
                        DispatchQueue.main.async {
                            self.saintIcon.image = nil
                            self.saintIcon.isHidden = true
                        }
                    }
                    
                    self.saintName.text = saint.name
                    self.saintDescription.text = saint.description.removeHTMLTags()
                    
                    // Здесь также можете установить изображение для saintIcon
                }
                
            } else {
                print("Произошла ошибка при получении данных")
            }
        }
        
        setupUI()
        addConstraints()
    }  
}



extension SaintViewController {
    
    private func setupUI() {
        
        // Для обеспечения прокрутки экрана
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(saintIcon)
        contentView.addSubview(saintName)
        contentView.addSubview(saintDescription)
    }
    
    private func addConstraints() {
        
        saintIcon.translatesAutoresizingMaskIntoConstraints = false
        saintName.translatesAutoresizingMaskIntoConstraints = false
        saintDescription.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            saintIcon.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            saintIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saintIcon.widthAnchor.constraint(equalToConstant: 200),
            saintIcon.heightAnchor.constraint(equalToConstant: 200),
            
            saintName.topAnchor.constraint(equalTo: saintIcon.bottomAnchor, constant: 20),
            saintName.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saintName.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            saintName.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15),
            
            saintDescription.topAnchor.constraint(equalTo: saintName.bottomAnchor, constant: 20),
            saintDescription.leftAnchor.constraint(equalTo: saintName.leftAnchor),
            saintDescription.rightAnchor.constraint(equalTo: saintName.rightAnchor),
            saintDescription.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}
